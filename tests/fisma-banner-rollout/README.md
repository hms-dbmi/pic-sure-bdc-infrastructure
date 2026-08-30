# FISMA banner rollout operator checklist

The Jenkins workflow enforces the forward order for BDC and AIM-AHEAD when a release input contains `banner_rollout`. It validates migrations, PSAMA, Operations, Gateway, and frontend selection before any build or deployment job starts. The backend deployment must finish its health waits before Jenkins publishes the frontend.

## AIM-AHEAD private release control

Do not copy BDC release control into the AIM-AHEAD boundary. Start with `aim-ahead-required-release-input.json` and update the existing private release control manually.

1. Confirm the public infrastructure ref resolves to the required reviewed commit:

   ```bash
   git ls-remote https://github.com/hms-dbmi/pic-sure-bdc-infrastructure.git refs/heads/pic_sure_api_rewrite
   ```

   The resolved commit must be `5d2ba9f59f161ace5e807c82a0580518a9d44d16`. Stop if it differs or if that commit has not been published.

2. Pin every value from `aim-ahead-required-release-input.json` in the private release control. Keep the private repository URL, ref, and resolved commit inside the boundary.

3. Copy `aim-ahead-operator-attestation.json` to an operator-controlled location. Fill only the private release-control source, operator, timestamp, and five boolean checks. Do not add private values to this public repository.

4. Validate the filled file with Jenkins source `9af6bc0d46ccaa0c42fb1e1fc83e471343bf2c78`:

   ```bash
   python3 jenkins-docker/scripts/validate-banner-rollout.py \
     --attestation /operator/path/aim-ahead-operator-attestation.json
   ```

5. Run the combined pipeline with database migrations, PIC-SURE API, PSAMA, and frontend selected. Do not use the standalone Operations, Gateway, PSAMA, or frontend jobs for this release.

This local checklist does not inspect the private release control and does not attest a deployed state. The operator owns the completed attestation.

## Rollback

Use a fresh copy of `rollback-operator-attestation.json` for the affected deployment and exact forward tuple.

1. Freeze ordinary banner management writes. The freeze must still allow the targeted-disable operation.
2. Roll back the frontend first.
3. Disable every Active or Scheduled targeted banner. Record a remaining count of zero before moving Operations or Gateway below the targeting-capable generation.
4. Roll back Operations and Gateway. Keep management writes frozen while that backend remains in service.
5. Keep the forward authorization and PIC-SURE schema. Do not run a Flyway down-migration.
6. Recreate PSAMA, then fill the phase and state attestations.
7. Validate the completed record:

   ```bash
   python3 jenkins-docker/scripts/validate-banner-rollout.py \
     --rollback-attestation /operator/path/rollback-operator-attestation.json
   ```

The templates fail validation until an operator fills every required field and attests every phase.
