# monitoring-infrastructure

Standalone Terraform root module for the PIC-SURE FISMA monitoring host
(Prometheus + Grafana). Unlike `app-infrastructure`, which is instantiated
once per blue/green stack (`target_stack = a|b`) and destroyed/recreated on
every stack swap, this module is applied **once per environment** and
survives stack swaps — it is the durable observability plane that scrapes
metrics from whichever stack (`a` or `b`) is currently live. See the
monitoring spec, §6.2 (network access model) and the FISMA metrics port
table for the full design.

## What this creates

- `aws_instance.monitoring-ec2` — a single EC2 host (default
  `m7a.large`, 100GB encrypted root volume) running Prometheus and Grafana
  under Podman, tagged `Node = "MONITORING"` so it is discoverable but is
  never part of a `target_stack`.
- `aws_security_group.monitoring` — egress-only. There is no ingress rule:
  operator access is SSM-only (Session Manager port-forwarding), per the
  phase-1 "SSM port-forward only" decision. Reverse scraping access (this
  SG as an allowed source on app-infrastructure instances) is granted by
  app-infrastructure via the `monitoring_security_group_id` output/variable
  wired up in a later task.
- `aws_iam_role`/`aws_iam_instance_profile` — SSM Session Manager access,
  CloudWatch agent, `ec2:DescribeInstances` (required for Prometheus
  `ec2_sd_configs` service discovery), and scoped S3 read access to the
  stack deployment bucket (for pulling `deploy-monitoring.sh` and configs).
- User data fetches and runs
  `s3://<stack_s3_bucket>/monitoring/deploy-monitoring.sh` (authored in a
  separate task) to install/configure the actual monitoring stack.

## Apply order

This module must be applied **before** `monitoring_security_group_id` is
set on the corresponding `app-infrastructure` stack(s) — app-infrastructure
uses that output to authorize the monitoring instance's security group as
an inbound source for the FISMA metrics ports (node_exporter 9100,
podman-exporter 9882, apache_exporter 9117). Apply this module first, take
its `monitoring_security_group_id` output, then apply/update
app-infrastructure with that value.

```
cd monitoring-infrastructure
terraform init
terraform plan   # review carefully
terraform apply  # requires explicit approval — see below
```

## Accessing Grafana (SSM port-forward, phase 1)

There is no public or VPC ingress to the monitoring host. Reach Grafana
(port 3000) via an SSM port-forwarding session:

```bash
aws ssm start-session \
  --target <monitoring-instance-id> \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["3000"],"localPortNumber":["3001"]}'
```

Then browse to `http://localhost:3001`.

## No apply without approval

**Never run `terraform apply` (or `terraform destroy`) against this module
without explicit operator approval.** This is a FISMA-boundary root module
applied against real infrastructure — validate/plan only unless you have
been explicitly told to apply.
