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
     5d2ba9f59f161ace5e807c82a0580518a9d44d16 FETCH_HEAD
   ```

   Stop if `merge-base` returns nonzero. Pin the exact reviewed commit, not `FETCH_HEAD`, in the private release input.

2. Pin every value from `aim-ahead-required-release-input.json` in the private release control. Keep the private repository URL, ref, and resolved commit inside the boundary.

3. Copy `aim-ahead-operator-attestation.json` to the private release-control root as `banner-rollout-attestation.json`. Fill the private release-control source, operator, timestamp, and five boolean checks. Do not add the completed file or private values to this public repository. The Retrieve Build Spec job archives this exact filename, and the AIM forward validator rejects the build when it is absent or incomplete.

4. Validate the private release input and attestation together with the Jenkins source pinned in `aim-ahead-required-release-input.json`:

   ```bash
   python3 jenkins-docker/scripts/validate-banner-rollout.py \
     --deployment AIM-AHEAD \
     --operation FORWARD \
     --build-spec /operator/path/private-release-control/build-spec.json \
     --attestation /operator/path/private-release-control/banner-rollout-attestation.json \
     --jenkins-source-commit f643a289a5c93acef917cbeb62962d8c857c2217 \
     --run-database-migrations true \
     --include-api true \
     --include-psama true \
     --include-frontend true
   ```

5. Run Check For Updates on the attested private release-control commit. It routes banner metadata to the combined pipeline with migrations, API, PSAMA, and frontend selected. The old build-before-migration path is used only when `banner_rollout` is absent. Do not use standalone Operations, Gateway, PSAMA, or frontend jobs for the forward release.

This local checklist does not inspect the private release control and does not attest a deployed state. The operator owns the completed attestation.

## Rollback

Use a fresh copy of `rollback-operator-attestation.json` for the affected deployment and exact forward tuple. Validate and retain the record inside the deployment boundary before each manual rollback step. The template does not invent a write-freeze endpoint or perform a mutation.

1. Freeze ordinary banner management writes. The freeze must still allow the targeted-disable operation. Set `stage` to `FRONTEND_ALLOWED`, attest only `FREEZE_BANNER_MANAGEMENT_WRITES`, record `managementWritesFrozen: true`, `frontendRolledBack: false`, a null targeted count, retained forward schema, no down-migration, and `psamaRecreated: false`. Validate this state before the standalone frontend rollback.
2. Roll back the frontend. Do not move Operations or Gateway yet.
3. Disable every Active or Scheduled targeted banner. Set `stage` to `BACKEND_ALLOWED`, attest the first three phases, record `frontendRolledBack: true` and a targeted remaining count of zero, and validate before moving Operations or Gateway below the targeting-capable generation.
4. Roll back Operations and Gateway together through the Wildfly Stack Deploy rollback mode. Keep management writes frozen while that backend remains in service.
5. Keep the forward authorization and PIC-SURE schema. Do not run a Flyway down-migration.
6. Before recreating PSAMA, set `stage` to `PSAMA_ALLOWED`, attest the first five phases, keep `psamaRecreated: false`, and validate. Recreate PSAMA through the standalone Auth Micro App Deploy rollback mode. Then set `stage` to `COMPLETE`, attest all six phases, and record `psamaRecreated: true`.
7. Run this validator with the matching `--required-rollback-stage` before the frontend, backend, and PSAMA steps, and with `COMPLETE` once more on the completed record:

   ```bash
   python3 jenkins-docker/scripts/validate-banner-rollout.py \
     --rollback-attestation /operator/path/rollback-operator-attestation.json \
     --jenkins-source-commit f643a289a5c93acef917cbeb62962d8c857c2217 \
     --required-rollback-stage __CURRENT_STAGE__
   ```

The templates fail validation until an operator fills every required field and attests every phase.
