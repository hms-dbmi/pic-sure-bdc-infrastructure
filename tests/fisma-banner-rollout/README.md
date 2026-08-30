# FISMA banner rollout operator checklist

The Jenkins workflow enforces the forward order for BDC and AIM-AHEAD when a release input contains `banner_rollout`. It validates migrations, PSAMA, Operations, Gateway, and frontend selection before any build or deployment job starts. The backend deployment must finish its health waits before Jenkins publishes the frontend.

## AIM-AHEAD private release control

Do not copy BDC release control into the AIM-AHEAD boundary. Start with `aim-ahead-required-release-input.json` and update the existing private release control manually.

1. Confirm the required reviewed commit is present in the public infrastructure ref history. The branch tip may be a descendant after publication:

   ```bash
   git -C /operator/path/pic-sure-bdc-infrastructure fetch \
     https://github.com/hms-dbmi/pic-sure-bdc-infrastructure.git \
     refs/heads/pic_sure_api_rewrite
   git -C /operator/path/pic-sure-bdc-infrastructure merge-base --is-ancestor \
     c18c56a4aeaf7b75a1f4feb4bc19c5c09a29c7c1 FETCH_HEAD
   ```

   Stop if `merge-base` returns nonzero. Pin the exact reviewed commit, not `FETCH_HEAD`, in the private release input.

   The executable infrastructure dependency is `c18c56a4aeaf7b75a1f4feb4bc19c5c09a29c7c1`, a descendant of the reviewed base and the earlier immutable-artifact commits. It adds the banner bootstrap switch as well as the exact IAM paths and host-side `--artifact_etag` downloads. The following metadata commit pins that executable commit and Jenkins `7bae491da1a8cbab4075c0dc8c189e8c0eccc264`. This dependency order avoids a self-reference.

2. Pin every value from `aim-ahead-required-release-input.json` in the private release control. Keep the private repository URL, ref, and resolved commit inside the boundary.

3. Copy `aim-ahead-operator-attestation.json` to the private release-control root as `banner-rollout-attestation.json`. Fill the private release-control source, operator, timestamp, and five boolean checks. Do not add the completed file or private values to this public repository. The Retrieve Build Spec job archives this exact filename, and the AIM forward validator rejects the build when it is absent or incomplete.

4. Validate the private release input and attestation together with the Jenkins source pinned in `aim-ahead-required-release-input.json`:

   ```bash
   python3 jenkins-docker/scripts/validate-banner-rollout.py \
     --deployment AIM-AHEAD \
     --operation FORWARD \
     --build-spec /operator/path/private-release-control/build-spec.json \
     --attestation /operator/path/private-release-control/banner-rollout-attestation.json \
     --jenkins-source-commit 7bae491da1a8cbab4075c0dc8c189e8c0eccc264 \
     --release-control-commit __ACTUAL_CHECKED_OUT_PRIVATE_RELEASE_CONTROL_COMMIT__ \
     --controller-deployment aim-ahead \
     --run-database-migrations true \
     --include-api true \
     --include-psama true \
     --include-frontend true
   ```

5. Use the supported **Check For Updates → Deployment Pipeline → PIC-SURE Pipeline Build and Deploy** entrypoint on the attested private release-control commit. Check For Updates first builds the HPDS, Logging, Visualization, and Dictionary images used by the rebuilt stack. It withholds Gateway, Operations, Query, PSAMA, and frontend from the mutable bootstrap namespace. Deployment Pipeline also disables standard critical artifacts in the new Wildfly and HTTPD instance user-data, so an intervening standard writer cannot publish them during bootstrap. The immutable combined job publishes those components backend-first after initialization. A manual run may start at Deployment Pipeline only when it supplies the same exact `deployment_git_hash`, three dataset keys, `STACK_S3_BUCKET`, `BANNER_ROLLOUT=true`, and `BANNER_ROLLOUT_OPERATION=FORWARD` inputs produced by Check For Updates. Deployment Pipeline validates before its backup and migration stages, retains the deployment-state lock, token and configuration rendering, stack rebuild, initialization, sensor check, and state write, then invokes the combined job with migrations attested as complete. Direct forward runs of the combined or leaf jobs fail closed.

This local checklist does not inspect the private release control and does not attest a deployed state. The operator owns the completed attestation.

## Rollback

Use a fresh copy of `rollback-operator-attestation.json` for the affected deployment and exact forward tuple. Fill `controllerDeployment`, `targetStack`, a unique `<targetStack>/banner-rollout/rollback/<rollback-run>/containers` artifact prefix, and the exact old frontend and backend commits. Image jobs reject an existing key. Deploy jobs verify the object metadata and ETag, then the host downloads with that ETag as an `If-Match` condition. Refresh `attestedAtUtc` before each stage; evidence older than 24 hours is rejected. Validate and retain the record inside the deployment boundary before each manual rollback step. The template does not invent a write-freeze endpoint or perform a mutation.

1. Freeze ordinary banner management writes. The freeze must still allow the targeted-disable operation. Set `stage` to `FRONTEND_ALLOWED`, attest only `FREEZE_BANNER_MANAGEMENT_WRITES`, record `managementWritesFrozen: true`, `frontendRolledBack: false`, a null targeted count, retained forward schema, no down-migration, and `psamaRecreated: false`. Validate this state before the standalone frontend rollback.
2. Run **PIC-SURE Frontend Build** at `git_hash=artifacts.frontendCommit` with the exact bucket, target stack, `BANNER_ROLLBACK=true`, and the attestation JSON. It validates `FRONTEND_ALLOWED`, verifies the checkout, and writes the old image only to `artifactPrefix`. Run **PIC-SURE Frontend Deploy** with the same bucket, stack, rollback flag, and JSON. It verifies that exact object and tells the host to download from the attested prefix. Do not move Operations or Gateway yet.
3. Disable every Active or Scheduled targeted banner. Set `stage` to `BACKEND_ALLOWED`, attest the first three phases, record `frontendRolledBack: true` and a targeted remaining count of zero, and validate before moving Operations or Gateway below the targeting-capable generation.
4. Run **PIC-SURE Maven Build** at `git_hash=artifacts.backendCommit` for the target stack. Run **PIC-SURE Operations Service Image**, **PIC-SURE Gateway Image**, **PIC-SURE HPDS Query Service Image**, and **PIC-SURE Auth Micro App Image** with the exact bucket, target stack, `BANNER_ROLLBACK=true`, and the `BACKEND_ALLOWED` JSON. Each job verifies the stamped backend commit and writes only to `artifactPrefix`. Then run **PIC-SURE Wildfly Stack Deploy** with Operations, Gateway, and Query selected, PSAMA unselected, and the same rollback evidence. It verifies and consumes only the attested objects. Keep management writes frozen while that backend remains in service.
5. Keep the forward authorization and PIC-SURE schema. Do not run a Flyway down-migration.
6. Before recreating PSAMA, set `stage` to `PSAMA_ALLOWED`, attest the first five phases, keep `psamaRecreated: false`, and validate. Run **PIC-SURE Auth Micro App Deploy** with the exact bucket, target stack, dataset key, `BANNER_ROLLBACK=true`, and the `PSAMA_ALLOWED` JSON; its Wildfly leaf recreates PSAMA from the already verified attested prefix. Then set `stage` to `COMPLETE`, attest all six phases, and record `psamaRecreated: true`.
7. Run this validator with the matching `--required-rollback-stage` before the frontend, backend, and PSAMA steps, and with `COMPLETE` once more on the completed record:

   ```bash
   python3 jenkins-docker/scripts/validate-banner-rollout.py \
     --rollback-attestation /operator/path/rollback-operator-attestation.json \
     --jenkins-source-commit 7bae491da1a8cbab4075c0dc8c189e8c0eccc264 \
     --controller-deployment __bdc_OR_aim-ahead__ \
     --target-stack __TARGET_STACK__ \
     --required-rollback-stage __CURRENT_STAGE__
   ```

The templates fail validation until an operator fills every required field and attests every phase.
