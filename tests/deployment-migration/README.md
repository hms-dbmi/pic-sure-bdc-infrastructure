# BDC and AIM-AHEAD deployment migration proof

`test.sh` runs each tenant's complete authorization and PIC-SURE migration directories against disposable MySQL 8 databases. It follows the deployed Flyway configuration with baseline version 0 and exercises the deployment's Flyway 10.8 generation. The existing focused owner checks still run with Flyway 11.7.2 where applicable.

The proof covers three starting states per tenant:

- `fresh`: empty `auth` and `picsure` schemas
- `supported-upgrade`: BDC's exact release-controlled directories, or AIM-AHEAD's exact tested public migration-history baseline
- `occurrence-only`: the supported state plus the checksum-pinned occurrence migration and synthetic occurrence rows

`matrix.tsv` uses Ticket 15's columns and vocabulary. `PASS` means the full sequence and its history, schema, authorization, data, allocator, and route assertions passed. `MATCH` means the BDC and AIM-AHEAD banner SQL hashes equal the corresponding hashes read from AIO migration commit `05b1a77512dc0921570f0d442853fdcee75b8131`.

The proof reads Ticket 15's normalized schema and feature-checksum manifests from an exact, clean checkout at that commit. It compares each tenant's generated schema directly with the AIO contract. It compares only the nine corresponding banner feature migrations, not unrelated deployment migration history.

The supported-upgrade fixture preserves synthetic rows in `access_rule`, `privilege`, `accessRule_privilege`, and `role_privilege`, which the forward authorization range writes. It also preserves an existing role and PIC-SURE user.

The occurrence-only fixture deliberately places a Saved occurrence at priority 90 and an expired Published occurrence at priority 80 above the live maximum of 40. The expected allocator value is 41. Existing priorities must remain `4,30,40,80,90`; the migration must not compact them. The same fixture checks publication actor/time backfill, system actor and updated-time fallbacks, Saved exclusion, and an exact restore link.

## Pinned inputs

The BDC sizing anchor `c968244d882f4bee9028f179e4fcaef3033c55d5` had moved by kickoff. The kickoff input is release-control branch `george_dev_deployment` at commit `1339c50749fadd1f2e55f8b5a5b68b3ab0422f9a`. Its `infrastructure_git_hash` was `pic_sure_api_rewrite`, resolved at kickoff to `2f384ada6e84fc6c041741b83db940e1253e6bf6`. That source ends at authorization V21 and PIC-SURE V8.

The user confirmed AIM-AHEAD's migration source as `https://github.com/hms-dbmi/pic-sure-bdc-infrastructure.git` at `pic_sure_api_rewrite`. At kickoff that ref resolved to `2f384ada6e84fc6c041741b83db940e1253e6bf6`. Its AIM-AHEAD directories end at authorization V23 and PIC-SURE V8 before the banner feature. The matrix calls this a tested public migration-history baseline. It is not a claim about AIM-AHEAD's deployed state.

AIM-AHEAD release control remains private inside the FISMA boundary. This local proof neither requires nor infers its contents. A deployment operator must update and attest the private release control manually as Ticket 21 defines.

The images are pinned by digest:

- MySQL `mysql:8.0.43@sha256:ccf4fed7ff4b886aeb3573a1f5d5b509525ecff55a2d1e2653c27a5abdded309`
- deployment Flyway `flyway/flyway:10.8@sha256:2f39377b52cdf1c70ffe9c1437aabed4e70fb716bb41323b03ee09ce17aaf292`; the proof reads its runtime version and requires the matrix to record the reported 10.8.1
- focused feature Flyway `flyway/flyway:11.7.2@sha256:8ace7d9825bb3ad1d6e14ee27b3a830b638ac841ba424b99b2d92aa65a99d484`

## Run the proof

Run every cell and both owner checks:

```bash
tests/deployment-migration/test.sh all
```

One cell can be selected with `bdc:fresh`, `bdc:supported-upgrade`, `bdc:occurrence-only`, `aim-ahead:fresh`, `aim-ahead:supported-upgrade`, or `aim-ahead:occurrence-only`.

Ticket 16 depends on Ticket 15. The default path fetches AIO commit `05b1a77512dc0921570f0d442853fdcee75b8131` from `hms-dbmi/PIC-SURE-Migrations` and fails with a publication-order message until that commit is reachable. Before publication, set `AIO_PROOF_SOURCE_ROOT` to a clean local checkout whose `HEAD` is that exact commit.

For repeat runs without fresh clones, set `DEPLOYMENT_PROOF_SOURCE_ROOT` to a directory containing detached, clean checkouts in this layout:

```text
bdc/release-control
bdc/infrastructure
aim-ahead/infrastructure
aio-contract
```

`AIO_PROOF_SOURCE_ROOT` overrides `aio-contract` with a direct Ticket 15 checkout. The script checks every checkout's exact SHA and cleanliness. Cached deployment inputs must also be detached. The proof rejects changed already-applied migrations, checksum drift, and matrix/result drift.

The proof does not run Jenkins, RDS, application binaries, PSAMA cache refresh, or a live deployment. Mixed-binary compatibility remains Ticket 17 work. Rollout ordering and cache refresh remain Ticket 18 work.
