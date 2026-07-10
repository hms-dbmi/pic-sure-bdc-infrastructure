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
         quay.io/navidys/prometheus-podman-exporter:v1.17.0 lusotycoon/apache-exporter:v1.0.10 \
         prom/blackbox-exporter:v0.26.0 prom/mysqld-exporter:v0.17.2; do
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
# blackbox-exporter is required by deploy-monitoring.sh (unconditional, same
# as prometheus/grafana) — it backs the synthetic public/staging probes.
aws s3 cp blackbox-exporter.tar.gz s3://$BUCKET/monitoring/containers/
# mysqld-exporter is optional: deploy-monitoring.sh only starts it when
# --mysql_host is non-empty, monitoring/db-exporters.env (below) exists in
# S3, and that file has non-empty MONITORING_MYSQL_USER and
# MYSQLD_EXPORTER_PASSWORD values; any other case logs a WARN and skips it
# (never fails the monitoring deploy).
aws s3 cp mysqld-exporter.tar.gz s3://$BUCKET/monitoring/containers/

# 2. Config bundle: prometheus/ + grafana/ + blackbox/ trees from the
#    pic-sure-all-in-one repo's monitoring/ directory (branch
#    pic_sure_api_monitoring). This is what deploy-monitoring.sh extracts
#    into /usr/local/docker-config/monitoring/ on the monitoring host,
#    including the FISMA-only grafana/provisioning-bdc/ and
#    grafana/dashboards-bdc/ subtrees (merged into provisioning/ and
#    dashboards/ by deploy-monitoring.sh after extraction).
tar -czf config-bundle.tar.gz -C <path-to-pic-sure-all-in-one>/monitoring prometheus grafana blackbox
aws s3 cp config-bundle.tar.gz s3://$BUCKET/monitoring/

# 3. The deploy scripts themselves — pulled by user-data / SSM at run time.
aws s3 cp deploy-monitoring.sh s3://$BUCKET/monitoring/
aws s3 cp deploy-exporters.sh s3://$BUCKET/monitoring/
# (source: app-infrastructure/scripts/deploy/deploy-monitoring.sh,
#  app-infrastructure/scripts/deploy/deploy-exporters.sh)

# 4. Secrets (not committed anywhere — hand-authored per environment):
#    monitoring.env         -> GF_SECURITY_ADMIN_PASSWORD=<grafana admin password>
#    app-token               -> raw scrape token, one line, no trailing newline issues
#    db-exporters.env        -> MYSQLD_EXPORTER_PASSWORD=<mysqld_exporter DSN password>
#                                MONITORING_MYSQL_USER=<read-only monitoring user>
#                                (optional — absence means mysqld-exporter is skipped;
#                                see the mysql prerequisites below for the user's SQL grant)
aws s3 cp monitoring.env s3://$BUCKET/monitoring/
aws s3 cp app-token      s3://$BUCKET/monitoring/
aws s3 cp db-exporters.env s3://$BUCKET/monitoring/
```

Notes on where each key lands and is consumed:

| S3 key (under `monitoring/`) | Consumed by | Lands at |
|---|---|---|
| `containers/prometheus.tar.gz` | `deploy-monitoring.sh` | `/opt/picsure/prometheus.tar.gz` on monitoring host |
| `containers/grafana.tar.gz` | `deploy-monitoring.sh` | `/opt/picsure/grafana.tar.gz` on monitoring host |
| `config-bundle.tar.gz` | `deploy-monitoring.sh` | extracted to `/usr/local/docker-config/monitoring/{prometheus,grafana,blackbox}` — `grafana/provisioning-bdc/` and `grafana/dashboards-bdc/` are then merged into `grafana/provisioning/` and `grafana/dashboards/` |
| `monitoring.env` | `deploy-monitoring.sh` | `/opt/picsure/monitoring.env` (Grafana `--env-file`) |
| `app-token` | `deploy-monitoring.sh` | `/usr/local/docker-config/monitoring/secrets/app-token`, `chmod 600` |
| `containers/node-exporter.tar.gz` | `deploy-exporters.sh` | app instances, `/opt/picsure/node-exporter.tar.gz` |
| `containers/podman-exporter.tar.gz` | `deploy-exporters.sh` | app instances, `/opt/picsure/podman-exporter.tar.gz` |
| `containers/apache-exporter.tar.gz` (optional) | `deploy-httpd.sh` | httpd instance, `/opt/picsure/apache-exporter.tar.gz` |
| `containers/blackbox-exporter.tar.gz` | `deploy-monitoring.sh` | `/opt/picsure/blackbox-exporter.tar.gz` on monitoring host |
| `containers/mysqld-exporter.tar.gz` (optional) | `deploy-monitoring.sh` | `/opt/picsure/mysqld-exporter.tar.gz` on monitoring host |
| `db-exporters.env` (optional; both keys `MYSQLD_EXPORTER_PASSWORD` and `MONITORING_MYSQL_USER` required non-empty) | `deploy-monitoring.sh` | `/usr/local/docker-config/monitoring/secrets/db-exporters.env`, `chmod 600` |
| `deploy-monitoring.sh` | `monitoring-infrastructure/scripts/monitoring-user_data.sh` | `/opt/picsure/deploy-monitoring.sh` on monitoring host |
| `deploy-exporters.sh` | `wildfly-user_data.sh`, `auth_hpds-user_data.sh`, `httpd-user_data.sh`, `open_hpds-user_data.sh` | `/opt/picsure/deploy-exporters.sh` on each app instance |

The `app-token` value gates the `X-Application-Token` header
(`http_headers.files` in Prometheus, env var `PICSURE_APPLICATION_TOKEN` on
the service side). Today the active FISMA scrape jobs (`node`, `podman`,
`apache`, all in `monitoring/prometheus/prometheus-bdc.yml`) do not require
it — the token file is provisioned now so it is in place for the M4
per-service actuator scrape jobs (dictionary 9401, logging 9402,
visualization 9403, psama 9404, hpds 8080), which are currently commented out
pending the monorepo consolidation's Phase 3.

## 2. Prerequisites: database monitoring users

`mysqld-exporter` needs a dedicated, **read-only** MySQL user on the RDS
instance (`var.picsure_db_host`, same endpoint the app stack connects to).
Create it out-of-band (not via Terraform — this is application data, not
infrastructure) before populating `db-exporters.env`:

```sql
CREATE USER 'monitoring'@'%' IDENTIFIED BY '<strong-password>';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON performance_schema.* TO 'monitoring'@'%';
```

Put the username in `MONITORING_MYSQL_USER` and the password in
`MYSQLD_EXPORTER_PASSWORD` inside `db-exporters.env` (§1 above). There is no
default username — both keys must be present and non-empty in
`db-exporters.env` for `deploy-monitoring.sh` to start the exporter.
`deploy-monitoring.sh` checks, in order: `--mysql_host` is non-empty, the
`db-exporters.env` secret exists in S3, and (once fetched) it actually
contains non-empty values for both `MONITORING_MYSQL_USER` and
`MYSQLD_EXPORTER_PASSWORD`. If any of those three checks fails, the deploy
logs its own `WARN: skipping mysqld-exporter (...)` line naming the specific
reason and continues (never fails the deploy).

**FISMA dictionary-PostgreSQL — documented stub, not implemented here.**
Unlike MySQL, the FISMA dictionary-PostgreSQL endpoint is **not present
anywhere in this repo** — it only exists in the S3-hosted
`configs/picsure-dictionary/picsure-dictionary.env`. Because
`deploy-monitoring.sh` can't discover it, `postgres_exporter` is
intentionally **not** wired up on the FISMA monitoring host in this change;
the aio (non-FISMA) monitoring stack already implements the equivalent
`postgres-exporter` container against the local `dictionary-db` container,
so the deploy assets (container image, compose service pattern) already
exist and this is a pure plumbing gap, not a missing capability. When the
FISMA dictionary-PG endpoint is exposed to this repo (e.g. as a new
`monitoring_pg_host` tfvar sourced from that S3 env file), replicate the
`mysqld-exporter` pattern above verbatim: a `monitoring/db-exporters.env`
key pair (`MONITORING_PG_USER`/`MONITORING_PG_PASSWORD` or similar), an
S3 `containers/postgres-exporter.tar.gz` artifact, and a guarded
podman-create block in `deploy-monitoring.sh` mirroring the mysqld-exporter
one added here.

## 3. Deploy order

1. Populate S3 as above.
2. Set the new `monitoring-infrastructure` tfvars before applying:
   - `env_public_dns_name` (string, required) — the environment's public ALB
     DNS name; rendered into the FISMA `prometheus-bdc.yml` blackbox scrape
     job in place of the `__PUBLIC_DNS__` token. Leaving it unset makes
     `terraform plan` fail (no default); passing an empty string is not the
     same as omitting it and is not recommended (see the WARN below).
   - `env_staging_dns_name` (string, default `""`) — staging-stack DNS name,
     same substitution for `__STAGING_DNS__`. Empty disables the staging
     probe target.
   - `monitoring_mysql_host` (string, default `""`) — the RDS MySQL endpoint,
     the **same value the app stack passes as `picsure_db_host`**
     (`app-infrastructure/variables.tf`). Empty disables the mysqld_exporter
     deploy entirely (skip-with-WARN, never fails the deploy).
   If `--public_dns`/`--staging_dns` end up empty at deploy time,
   `deploy-monitoring.sh` leaves the corresponding `__PUBLIC_DNS__`/
   `__STAGING_DNS__` token unrendered in `prometheus.yml` (an obviously-broken
   target rather than a silently-wrong one) and logs
   `WARN: blackbox public/staging probes unrendered`.
3. `terraform apply` in `monitoring-infrastructure/` — **requires explicit
   operator approval**; see that module's README for the full apply-order
   and cross-VPC discussion. Take its `monitoring_instance_private_ip`
   output.
4. Set `monitoring_ingress_cidr` (as a `/32`, e.g. `10.1.2.3/32` — this is a
   CIDR, **not** a security-group id; `monitoring_ingress_cidr` is defined in
   `app-infrastructure/variables.tf` and consumed in
   `app-infrastructure/security-groups.tf`, because stack `a`/`b` are
   separate VPCs and `source_security_group_id` cannot cross a VPC boundary)
   on the app stack(s)' tfvars.
5. `terraform plan` for `app-infrastructure` per stack — **requires explicit
   operator approval** before any apply. This wires up
   `node-exporter-from-monitoring` / `podman-exporter-from-monitoring` (per
   host SG: wildfly, httpd, hpds), `apache-exporter-from-monitoring`
   (httpd SG only), and `mysql-from-monitoring` (RDS-facing
   `inbound-mysql-from-wildfly` SG, port 3306 — lets the monitoring host's
   mysqld_exporter reach the RDS instance) ingress rules, all scoped to
   `monitoring_ingress_cidr`.
6. Exporters land automatically:
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

     Note: re-running `deploy-monitoring.sh` itself via SSM requires passing
     `--environment_name` explicitly — the monitoring host's `/etc/environment`
     only has `STACK_S3_BUCKET` set, not `ENVIRONMENT_NAME`, so there is no
     fallback to source for that script.

## 4. Access (SSM port-forward)

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

## 5. Verification checklist

Per the monitoring spec §9 ("FISMA (M3/M4)"), over the SSM port-forwards
above:

- [ ] All configured Prometheus targets show `up == 1` (`node`, `podman`,
      `apache` jobs at minimum; `prometheus` self-scrape job always). The
      monitoring host itself now appears as a `node`/`podman` target too
      (self-scrape by design — it runs the same exporters as the app
      instances so its own disk/TSDB health is observable; see the
      self-referencing `9100`/`9882` ingress rule on
      `aws_security_group.monitoring`).
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
- [ ] `probe_success == 1` for each configured `blackbox` target (public DNS
      always; staging DNS if `env_staging_dns_name` was set) — confirms the
      blackbox-exporter container is reachable from prometheus on the podman
      `monitoring` network and the ALB is answering.
- [ ] Certificate expiry is plausible: `probe_ssl_earliest_cert_expiry` minus
      current time is a sane number of days (not negative, not absent) for
      each `https://` blackbox target.
- [ ] mysql target: either `up == 1` on the `mysql` Prometheus job (when
      `monitoring_mysql_host` was provided, `db-exporters.env` exists in S3,
      and it contains non-empty `MONITORING_MYSQL_USER` and
      `MYSQLD_EXPORTER_PASSWORD` values), or a documented skip — confirm via
      the deploy log's `WARN: skipping mysqld-exporter (...)` line, which
      names which of the three conditions failed (SSM command output /
      `journalctl -u container-mysqld-exporter` if the container should be
      running but isn't).
- [ ] CloudWatch panels render in the `aws-edge` Grafana dashboard (ALB
      request count/5xx/latency/healthy-hosts, RDS CPU/connections/storage,
      EBS burst balance) — confirms the `picsure-cloudwatch` datasource and
      the monitoring role's CloudWatch read policy (below) both work.
- [ ] Static checks before any of the above: `bash -n` on the modified deploy
      scripts, `terraform validate` + `terraform plan` reviewed by an
      operator (no `terraform apply` without explicit approval).

**Security review note:** this change adds `cloudwatch:GetMetricData`,
`cloudwatch:ListMetrics`, `cloudwatch:GetMetricStatistics`,
`ec2:DescribeRegions`, and `tag:GetResources` (all on `Resource: "*"`, as
required by the Grafana CloudWatch datasource — none of these actions
support resource-level scoping) to the `monitoring-ec2-role`'s inline
policy (`monitoring-infrastructure/monitoring-iam.tf`). All four are
read-only; none grant write/delete/modify permissions. Flag this addition
explicitly in any FISMA security control review of the monitoring host's
IAM role.

## 6. Deferred / follow-on work

Not in scope for this runbook or the current rollout stage (M3):

1. ~~**Jenkins job creation** in `avillachlab-jenkins` for the "Monitoring
   Build and Deploy" job described in §1 above~~ — done. Two jobs now exist
   on the `avillachlab-jenkins` repo's `pic_sure_api_monitoring` branch,
   under `jenkins-docker/jobs/`:
   - **"Monitoring Build and Deploy"** — full artifacts (all 7 pinned
     container images, config-bundle.tar.gz, deploy-monitoring.sh,
     deploy-exporters.sh) plus the SSM deploy invocation; this is the
     automated equivalent of §1's manual artifact-population commands.
   - **"Deploy Monitoring Config"** — bundle-only (config-bundle.tar.gz
     from `prometheus/`, `grafana/`, `blackbox/`) plus the same SSM
     deploy invocation, for dashboard/scrape-config-only changes that
     don't need new container images.

   Both jobs are S3/SSM-driven exactly as described in §1 and §3 above and,
   per that contract, **never create or overwrite the operator-managed
   secrets** (`monitoring.env`, `app-token`, `db-exporters.env`) — those
   still must be hand-authored in S3 before the first deploy. The manual
   §1–2 commands remain valid as the break-glass path if the Jenkins jobs
   are unavailable or a one-off artifact needs publishing outside the
   normal job run.
2. **M4 activation**: enabling the per-service actuator scrape jobs
   (dictionary 9401, logging 9402, visualization 9403, psama 9404, hpds
   8080) in `prometheus-bdc.yml`, and the corresponding
   `inbound-metrics-from-monitoring`-style SG rules for those ports — gated
   on the monorepo consolidation's Phase 3 (FISMA builds from the
   monorepo). The M4 hpds tag filter (`tag:Node values [HPDS, OPEN_HPDS]`)
   additionally requires first **adding `Node` tags** to the
   wildfly/auth-hpds/open-hpds instances in `app-infrastructure` — today only
   the httpd and monitoring instances carry a `Node` tag. The
   `prometheus-bdc.yml` M4 comment block itself lives in the
   `pic-sure-all-in-one` repo, not this one.
3. **AIM-AHEAD monitoring parity** — the M3/M4 patterns here apply, but
   rollout to AIM-AHEAD is scheduled with the consolidation's dual-environment
   Phase 3 work, not part of this track.
