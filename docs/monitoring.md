# FISMA Monitoring Runbook

Operational runbook for the FISMA/BDC Prometheus + Grafana monitoring stack:
publishing deploy artifacts, apply order, operator access, and verification.

For the full design (topology, per-service instrumentation plan, dashboards,
rollout stages), see the `pic-sure` repo:
`docs/superpowers/specs/2026-07-06-monitoring-stack-design.md` (§6.2 "FISMA"
and §9 "Verification" are the sections most relevant here).

For what the standalone monitoring host Terraform module actually creates
(instance, IAM, security group, apply order, cross-VPC note, SSM access) see
[`monitoring-infrastructure/README.md`](../monitoring-infrastructure/README.md)
in this repo — that module is applied once per environment and is not
re-applied on stack swaps.

## 1. S3 artifact population

Nothing runs until the deploy artifacts exist under
`s3://$BUCKET/monitoring/` in the stack's deployment bucket. Today this is a
manual operator step; it is the intended body of the future Jenkins
**"Monitoring Build and Deploy"** job (in `avillachlab-jenkins`, not yet
created — see Deferred, below).

```bash
# 1. Container images (run wherever docker/podman + internet access exist).
#    Pinned versions per the monitoring spec.
for i in prom/prometheus:v3.4.1 grafana/grafana:11.6.0 prom/node-exporter:v1.9.1 \
         quay.io/navidys/prometheus-podman-exporter:v1.17.0 lusotycoon/apache-exporter:v1.0.10; do
  n=$(basename "${i%%:*}"); docker pull "$i" && docker save "$i" | gzip > "$n.tar.gz"
done

aws s3 cp prometheus.tar.gz      s3://$BUCKET/monitoring/containers/
aws s3 cp grafana.tar.gz         s3://$BUCKET/monitoring/containers/
aws s3 cp node-exporter.tar.gz   s3://$BUCKET/monitoring/containers/
# podman-exporter image is renamed on upload — deploy-exporters.sh expects
# this exact key:
aws s3 cp prometheus-podman-exporter.tar.gz s3://$BUCKET/monitoring/containers/podman-exporter.tar.gz
# apache-exporter is optional: deploy-httpd.sh only starts the exporter if
# this key exists, and silently skips it (does not fail httpd deploys)
# otherwise.
aws s3 cp apache-exporter.tar.gz s3://$BUCKET/monitoring/containers/

# 2. Config bundle: prometheus/ + grafana/ trees from the pic-sure-all-in-one
#    repo's monitoring/ directory (branch pic_sure_api_monitoring). This is
#    what deploy-monitoring.sh extracts into
#    /usr/local/docker-config/monitoring/ on the monitoring host.
tar -czf config-bundle.tar.gz -C <path-to-pic-sure-all-in-one>/monitoring prometheus grafana
aws s3 cp config-bundle.tar.gz s3://$BUCKET/monitoring/

# 3. The deploy scripts themselves — pulled by user-data / SSM at run time.
aws s3 cp deploy-monitoring.sh deploy-exporters.sh s3://$BUCKET/monitoring/
# (source: app-infrastructure/scripts/deploy/deploy-monitoring.sh,
#  app-infrastructure/scripts/deploy/deploy-exporters.sh)

# 4. Secrets (not committed anywhere — hand-authored per environment):
#    monitoring.env    -> GF_SECURITY_ADMIN_PASSWORD=<grafana admin password>
#    app-token         -> raw scrape token, one line, no trailing newline issues
aws s3 cp monitoring.env s3://$BUCKET/monitoring/
aws s3 cp app-token      s3://$BUCKET/monitoring/
```

Notes on where each key lands and is consumed:

| S3 key (under `monitoring/`) | Consumed by | Lands at |
|---|---|---|
| `containers/prometheus.tar.gz` | `deploy-monitoring.sh` | `/opt/picsure/prometheus.tar.gz` on monitoring host |
| `containers/grafana.tar.gz` | `deploy-monitoring.sh` | `/opt/picsure/grafana.tar.gz` on monitoring host |
| `config-bundle.tar.gz` | `deploy-monitoring.sh` | extracted to `/usr/local/docker-config/monitoring/{prometheus,grafana}` |
| `monitoring.env` | `deploy-monitoring.sh` | `/opt/picsure/monitoring.env` (Grafana `--env-file`) |
| `app-token` | `deploy-monitoring.sh` | `/usr/local/docker-config/monitoring/secrets/app-token`, `chmod 600` |
| `containers/node-exporter.tar.gz` | `deploy-exporters.sh` | app instances, `/opt/picsure/node-exporter.tar.gz` |
| `containers/podman-exporter.tar.gz` | `deploy-exporters.sh` | app instances, `/opt/picsure/podman-exporter.tar.gz` |
| `containers/apache-exporter.tar.gz` (optional) | `deploy-httpd.sh` | httpd instance, `/opt/picsure/apache-exporter.tar.gz` |
| `deploy-monitoring.sh` | `monitoring-infrastructure/scripts/monitoring-user_data.sh` | `/opt/picsure/deploy-monitoring.sh` on monitoring host |
| `deploy-exporters.sh` | `wildfly-user_data.sh`, `auth_hpds-user_data.sh`, `httpd-user_data.sh`, `open_hpds-user_data.sh`, `deploy-httpd.sh` | `/opt/picsure/deploy-exporters.sh` on each app instance |

The `app-token` value gates the `X-Application-Token` header
(`http_headers.files` in Prometheus, env var `PICSURE_APPLICATION_TOKEN` on
the service side). Today the active FISMA scrape jobs (`node`, `podman`,
`apache`, all in `monitoring/prometheus/prometheus-bdc.yml`) do not require
it — the token file is provisioned now so it is in place for the M4
per-service actuator scrape jobs (dictionary 9401, logging 9402,
visualization 9403, psama 9404, hpds 8080), which are currently commented out
pending the monorepo consolidation's Phase 3.

## 2. Deploy order

1. Populate S3 as above.
2. `terraform apply` in `monitoring-infrastructure/` — **requires explicit
   operator approval**; see that module's README for the full apply-order
   and cross-VPC discussion. Take its `monitoring_instance_private_ip`
   output.
3. Set `monitoring_ingress_cidr` (as a `/32`, e.g. `10.1.2.3/32` — this is a
   CIDR, **not** a security-group id; `monitoring_ingress_cidr` is defined in
   `app-infrastructure/variables.tf` and consumed in
   `app-infrastructure/security-groups.tf`, because stack `a`/`b` are
   separate VPCs and `source_security_group_id` cannot cross a VPC boundary)
   on the app stack(s)' tfvars.
4. `terraform plan` for `app-infrastructure` per stack — **requires explicit
   operator approval** before any apply. This wires up
   `node-exporter-from-monitoring` / `podman-exporter-from-monitoring` (per
   host SG: wildfly, httpd, hpds) and `apache-exporter-from-monitoring`
   (httpd SG only) ingress rules, scoped to `monitoring_ingress_cidr`.
5. Exporters land automatically:
   - On the **next stack rollout** (new instances), via each app instance's
     user-data, which fetches and runs `deploy-exporters.sh` (node_exporter
     9100 + podman-exporter 9882) and, on the httpd instance,
     `deploy-httpd.sh` conditionally starts apache_exporter (9117) if its S3
     artifact exists.
   - On **already-running instances**, via SSM (no redeploy needed):
     ```bash
     aws ssm send-command \
       --instance-ids <instance-id> \
       --document-name "AWS-RunShellScript" \
       --parameters commands='[
         "aws --region us-east-1 s3 cp s3://'"$BUCKET"'/monitoring/deploy-exporters.sh /opt/picsure/deploy-exporters.sh",
         "chmod +x /opt/picsure/deploy-exporters.sh",
         "/opt/picsure/deploy-exporters.sh --stack_s3_bucket '"$BUCKET"'"
       ]'
     ```
     (`deploy-exporters.sh` accepts `--stack_s3_bucket` (required) and
     `--environment_name` (accepted for forward-compatibility via the
     `$ENVIRONMENT_NAME` `/etc/environment` fallback; only
     `auth_hpds-user_data.sh` currently exports `ENVIRONMENT_NAME` to
     `/etc/environment`, and the value isn't otherwise used by this
     script).)

## 3. Access (SSM port-forward)

There is no ingress to the monitoring host other than the metrics-scrape
rules described above — operator access is SSM-only. Prometheus binds
`127.0.0.1:9090` and Grafana `127.0.0.1:3000` on the monitoring host (see the
`-p 127.0.0.1:9090:9090` / `-p 127.0.0.1:3000:3000` port publishes in
`app-infrastructure/scripts/deploy/deploy-monitoring.sh`), so both need a
port-forward, not a direct connection.

```bash
# Grafana
aws ssm start-session \
  --target <monitoring-instance-id> \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["3000"],"localPortNumber":["3001"]}'
# then browse http://localhost:3001

# Prometheus
aws ssm start-session \
  --target <monitoring-instance-id> \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["9090"],"localPortNumber":["9091"]}'
# then browse http://localhost:9091
```

`<monitoring-instance-id>` is the `monitoring_instance_id` Terraform output
from `monitoring-infrastructure`.

## 4. Verification checklist

Per the monitoring spec §9 ("FISMA (M3/M4)"), over the SSM port-forwards
above:

- [ ] All configured Prometheus targets show `up == 1` (`node`, `podman`,
      `apache` jobs at minimum; `prometheus` self-scrape job always).
- [ ] Grafana dashboards render with data (Platform overview, Infrastructure
      at minimum for M3).
- [ ] Prometheus and Grafana are unreachable from the ALB and from any
      non-monitoring security group — there is no ingress rule on
      `aws_security_group.monitoring` other than the default egress-only
      posture; confirm no stray ingress rule has been added.
- [ ] The FISMA metrics ports (9100, 9882, 9117) are reachable **only** from
      `monitoring_ingress_cidr` (the monitoring instance's private IP) —
      confirm via `aws ec2 describe-security-groups` on the wildfly/httpd/hpds
      SGs that the `cidr_blocks` on those rules match the monitoring
      instance's current private IP, not `0.0.0.0/0` or a stale IP from a
      prior instance replacement.
- [ ] Stack-swap discovery: after a `Swap Stacks` operation, the newly-live
      stack's targets appear in Prometheus via the `ec2_sd_configs` tag
      filters (`tag:Environment`, `instance-state-name=running`) in
      `monitoring/prometheus/prometheus-bdc.yml` — no Prometheus config edit
      or restart should be required.
- [ ] If scraping stack-`b` hosts: confirm VPC routing/peering exists between
      the `a` VPC (monitoring instance) and `b` VPC first — see the
      cross-VPC note in `monitoring-infrastructure/README.md`.
- [ ] Static checks before any of the above: `bash -n` on the modified deploy
      scripts, `terraform validate` + `terraform plan` reviewed by an
      operator (no `terraform apply` without explicit approval).

## 5. Deferred / follow-on work

Not in scope for this runbook or the current rollout stage (M3):

1. **Jenkins job creation** in `avillachlab-jenkins` for the "Monitoring
   Build and Deploy" job described in §1 above — today the S3 artifact
   population is a manual operator procedure.
2. **M4 activation**: enabling the per-service actuator scrape jobs
   (dictionary 9401, logging 9402, visualization 9403, psama 9404, hpds
   8080) in `prometheus-bdc.yml`, and the corresponding
   `inbound-metrics-from-monitoring`-style SG rules for those ports — gated
   on the monorepo consolidation's Phase 3 (FISMA builds from the
   monorepo).
3. **AIM-AHEAD monitoring parity** — the M3/M4 patterns here apply, but
   rollout to AIM-AHEAD is scheduled with the consolidation's dual-environment
   Phase 3 work, not part of this track.
