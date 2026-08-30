#!/usr/bin/env python3
import hashlib
import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TEST_DIR = Path(__file__).resolve().parent
JENKINS_ROOT = Path(
    os.environ.get("JENKINS_ROOT", ROOT.parent / "avillachlab-jenkins")
)
VALIDATOR = JENKINS_ROOT / "jenkins-docker/scripts/validate-banner-rollout.py"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


class PublicAimInputTest(unittest.TestCase):
    def test_aim_input_validates_as_its_own_deployment(self):
        result = subprocess.run(
            [
                "python3",
                str(VALIDATOR),
                "--deployment",
                "AIM-AHEAD",
                "--build-spec",
                str(TEST_DIR / "aim-ahead-required-release-input.json"),
                "--run-database-migrations",
                "true",
                "--include-api",
                "true",
                "--include-psama",
                "true",
                "--include-frontend",
                "true",
            ],
            text=True,
            capture_output=True,
            timeout=10,
            check=False,
        )
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)
        self.assertEqual(
            "dcb24e851f1715a16596f2263c13a2b1aa49b98836c9d367e183d81df4842eca",
            result.stdout.strip(),
        )

    def test_private_and_rollback_templates_fail_until_attested(self):
        for option, name in (
            ("--attestation", "aim-ahead-operator-attestation.json"),
            ("--rollback-attestation", "rollback-operator-attestation.json"),
        ):
            with self.subTest(option=option):
                result = subprocess.run(
                    ["python3", str(VALIDATOR), option, str(TEST_DIR / name)],
                    text=True,
                    capture_output=True,
                    timeout=10,
                    check=False,
                )
                self.assertEqual(2, result.returncode, result.stdout + result.stderr)
                self.assertIn("attestation is incomplete", result.stderr)

    def test_synthetic_completed_aim_attestation_passes(self):
        attestation = json.loads((TEST_DIR / "aim-ahead-operator-attestation.json").read_text(encoding="utf-8"))
        attestation["privateReleaseControl"] = {
            "repository": "ssh://private.invalid/operator-supplied.git",
            "ref": "operator-supplied",
            "resolvedCommit": "a" * 40,
        }
        attestation["checks"] = {key: True for key in attestation["checks"]}
        attestation["operator"] = "synthetic-operator"
        attestation["attestedAtUtc"] = "2026-08-29T00:00:00Z"
        with tempfile.NamedTemporaryFile("w", suffix=".json") as handle:
            json.dump(attestation, handle)
            handle.flush()
            result = subprocess.run(
                ["python3", str(VALIDATOR), "--attestation", handle.name],
                text=True,
                capture_output=True,
                timeout=10,
                check=False,
            )
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)

    def test_bdc_and_aim_rollback_attestations_pass_separately(self):
        template = json.loads((TEST_DIR / "rollback-operator-attestation.json").read_text(encoding="utf-8"))
        tuples = {
            "BDC": "e62b9d8a5be23d050939bd744d522b5e20d1ccf6bdb0a9e248a6e121dbff5449",
            "AIM-AHEAD": "dcb24e851f1715a16596f2263c13a2b1aa49b98836c9d367e183d81df4842eca",
        }
        for deployment, tuple_sha in tuples.items():
            with self.subTest(deployment=deployment):
                attestation = json.loads(json.dumps(template))
                attestation["deployment"] = deployment
                attestation["tupleSha256"] = tuple_sha
                for phase in attestation["phases"]:
                    phase["attested"] = True
                attestation["state"] = {
                    "managementWritesFrozen": True,
                    "targetedActiveOrScheduledRemaining": 0,
                    "forwardSchemaRetained": True,
                    "downMigrationRun": False,
                    "psamaRecreated": True,
                }
                attestation["operator"] = "synthetic-operator"
                attestation["attestedAtUtc"] = "2026-08-29T00:00:00Z"
                with tempfile.NamedTemporaryFile("w", suffix=".json") as handle:
                    json.dump(attestation, handle)
                    handle.flush()
                    result = subprocess.run(
                        ["python3", str(VALIDATOR), "--rollback-attestation", handle.name],
                        text=True,
                        capture_output=True,
                        timeout=10,
                        check=False,
                    )
                self.assertEqual(0, result.returncode, result.stdout + result.stderr)

    def test_aim_input_does_not_infer_private_release_control(self):
        spec = json.loads((TEST_DIR / "aim-ahead-required-release-input.json").read_text(encoding="utf-8"))
        source = spec["banner_rollout"]["releaseControl"]
        self.assertEqual(
            {
                "visibility": "PRIVATE_FISMA_BOUNDARY",
                "operatorManaged": True,
                "resolvedCommitSource": "OPERATOR_ATTESTATION",
            },
            source,
        )
        serialized = json.dumps(spec)
        self.assertNotIn("pic-sure-bdc-release-control", serialized)
        self.assertNotIn("gitlab", serialized.lower())


class ExistingDeploymentProofTest(unittest.TestCase):
    def test_ticket_16_contract_files_are_unchanged(self):
        self.assertEqual(
            "f94f3c3dc4f7cc8462f78d07b9a71c8cabf45a6027e3653e522ddc6cacc6802c",
            sha256(ROOT / "tests/deployment-migration/feature-sql.sha256"),
        )
        self.assertEqual(
            "b343dc423a869b418a77b6b5eaef65e244bc6ddcdb2056b987fd2f8eb05e4739",
            sha256(ROOT / "tests/deployment-migration/matrix.tsv"),
        )

    def test_backend_script_recreates_psama_between_operations_and_gateway(self):
        script = (ROOT / "app-infrastructure/scripts/deploy/deploy-wildfly-stack.sh").read_text(encoding="utf-8")
        operations = script.index('if [[ "$deploy_operations" == "true" ]]')
        psama = script.index('if [[ "$deploy_psama" == "true" ]]')
        gateway = script.index('if [[ "$deploy_gateway" == "true" ]]')
        self.assertLess(operations, psama)
        self.assertLess(psama, gateway)

        psama_script = (ROOT / "app-infrastructure/scripts/deploy/deploy-psama.sh").read_text(encoding="utf-8")
        for command in (
            "systemctl stop container-$CONTAINER_NAME.service",
            "podman rm -f $CONTAINER_NAME",
            "podman create",
            "systemctl start --no-block container-$CONTAINER_NAME.service",
        ):
            self.assertIn(command, psama_script)


if __name__ == "__main__":
    unittest.main()
