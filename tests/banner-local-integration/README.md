# BDC and AIM-AHEAD banner local integration proof

This proof composes the exact Ticket 22A result contract with the BDC and AIM-AHEAD production-shaped configuration already owned by this repository. It renders the real tenant Gateway, Operations, HTTPD, and migration inputs with synthetic values. It does not start containers or contact a deployment.

The contract snapshot is byte-for-byte identical to `pic-sure-all-in-one` commit `715857456594814957d9abc26ad14efbccb65e11`. `contract-source.json` records its Git blob and SHA-256 checksum. The runner compares the checked-in snapshot directly with that exact clean source root before accepting a result.

## Run

Set these variables to exact clean checkouts at the commits recorded in `expected-matrix.json`:

- `BANNER_LOCAL_AIO_ROOT`
- `BANNER_LOCAL_AIO_RELEASE_CONTROL_ROOT`
- `BANNER_LOCAL_BACKEND_ROOT`
- `BANNER_LOCAL_FRONTEND_ROOT`
- `BANNER_LOCAL_MIGRATIONS_ROOT`
- `BANNER_LOCAL_JENKINS_ROOT`
- `BANNER_LOCAL_BDC_RELEASE_CONTROL_ROOT`

Then run:

```bash
tests/banner-local-integration/test.sh contract
python3 tests/banner-local-integration/run.py contract
tests/banner-local-integration/test.sh owners
```

`contract` runs the focused suite in normal and optimized Python modes. The runner requires this repository to be a clean descendant of `cc1920a76fb6aeb9266fb4cffe98e946c2d983e4`. `owners` also executes the exact Ticket 19, 20, 21, and 22A non-Docker owner suites before it can record those owner checks as `PASS`.

## Result boundary

Every deployment row remains `NOT_RUN` because Docker failed earlier with `ENOSPC` and this ticket does not retry it. Runtime migrations, empty and published feeds, browser rendering, management calls, audit receipt, and deployed cleanup are not claimed. Production TLS, external routing, Jenkins execution, AWS, SSM, Terraform apply, systemd, podman, and ALB behavior are also `NOT_RUN`.

The AIM-AHEAD row binds the public required release input and the repository's synthetic completed attestation. It does not infer a private release-control commit or claim the manual operator attestation; both remain explicitly manual or not run.

Failed runs preserve only run-scoped `.json` and `.log` diagnostics under `BANNER_LOCAL_DIAGNOSTICS_ROOT` (default `/tmp/banner-local-integration-diagnostics`). The temporary rendered fixtures and other transient files are removed by bounded temporary-directory cleanup.
