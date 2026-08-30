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
JENKINS_ROOT = Path(os.environ["JENKINS_ROOT"])
VALIDATOR = JENKINS_ROOT / "jenkins-docker/scripts/validate-banner-rollout.py"
JENKINS_COMMIT = subprocess.run(
    ["git", "rev-parse", "HEAD"],
    cwd=JENKINS_ROOT,
    text=True,
    capture_output=True,
    check=True,
).stdout.strip()


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def expected_tuple(deployment: str) -> str:
    spec = json.loads((TEST_DIR / "aim-ahead-required-release-input.json").read_text(encoding="utf-8"))
    components = spec["banner_rollout"]["components"]
    payload = {"deployment": deployment, "components": components}
    return hashlib.sha256(json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()).hexdigest()


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
                "--jenkins-source-commit",
                JENKINS_COMMIT,
                "--attestation",
                str(TEST_DIR / "aim-ahead-completed-attestation.synthetic.json"),
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
            expected_tuple("AIM-AHEAD"),
            result.stdout.strip(),
        )

    def test_private_and_rollback_templates_fail_until_attested(self):
        for option, name in (
            ("--attestation", "aim-ahead-operator-attestation.json"),
            ("--rollback-attestation", "rollback-operator-attestation.json"),
        ):
            with self.subTest(option=option):
                jenkins_source = []
                if option == "--rollback-attestation":
                    jenkins_source = ["--jenkins-source-commit", JENKINS_COMMIT]
                result = subprocess.run(
                    ["python3", str(VALIDATOR), option, str(TEST_DIR / name), *jenkins_source],
                    text=True,
                    capture_output=True,
                    timeout=10,
                    check=False,
                )
                self.assertEqual(2, result.returncode, result.stdout + result.stderr)
                self.assertIn("attestation is incomplete", result.stderr)

    def test_synthetic_completed_aim_attestation_passes(self):
        result = subprocess.run(
            ["python3", str(VALIDATOR), "--attestation", str(TEST_DIR / "aim-ahead-completed-attestation.synthetic.json")],
            text=True,
            capture_output=True,
            timeout=10,
            check=False,
        )
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)

    def test_bdc_and_aim_rollback_attestations_pass_separately(self):
        template = json.loads((TEST_DIR / "rollback-operator-attestation.json").read_text(encoding="utf-8"))
        tuples = {
            "BDC": expected_tuple("BDC"),
            "AIM-AHEAD": expected_tuple("AIM-AHEAD"),
        }
        for deployment, tuple_sha in tuples.items():
            with self.subTest(deployment=deployment):
                attestation = json.loads(json.dumps(template))
                attestation["deployment"] = deployment
                attestation["tupleSha256"] = tuple_sha
                attestation["stage"] = "COMPLETE"
                for phase in attestation["phases"]:
                    phase["attested"] = True
                attestation["state"] = {
                    "managementWritesFrozen": True,
                    "frontendRolledBack": True,
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
                        [
                            "python3",
                            str(VALIDATOR),
                            "--rollback-attestation",
                            handle.name,
                            "--jenkins-source-commit",
                            JENKINS_COMMIT,
                        ],
                        text=True,
                        capture_output=True,
                        timeout=10,
                        check=False,
                    )
                self.assertEqual(0, result.returncode, result.stdout + result.stderr)

    def test_frontend_and_backend_rollback_gates_pass_separately(self):
        template = json.loads((TEST_DIR / "rollback-operator-attestation.json").read_text(encoding="utf-8"))
        cases = {
            "FRONTEND_ALLOWED": {
                "attested": [True, False, False, False, False, False],
                "state": {
                    "managementWritesFrozen": True,
                    "frontendRolledBack": False,
                    "targetedActiveOrScheduledRemaining": None,
                    "forwardSchemaRetained": True,
                    "downMigrationRun": False,
                    "psamaRecreated": False,
                },
            },
            "BACKEND_ALLOWED": {
                "attested": [True, True, True, False, False, False],
                "state": {
                    "managementWritesFrozen": True,
                    "frontendRolledBack": True,
                    "targetedActiveOrScheduledRemaining": 0,
                    "forwardSchemaRetained": True,
                    "downMigrationRun": False,
                    "psamaRecreated": False,
                },
            },
            "PSAMA_ALLOWED": {
                "attested": [True, True, True, True, True, False],
                "state": {
                    "managementWritesFrozen": True,
                    "frontendRolledBack": True,
                    "targetedActiveOrScheduledRemaining": 0,
                    "forwardSchemaRetained": True,
                    "downMigrationRun": False,
                    "psamaRecreated": False,
                },
            },
        }
        for stage, expected in cases.items():
            with self.subTest(stage=stage):
                attestation = json.loads(json.dumps(template))
                attestation["deployment"] = "BDC"
                attestation["tupleSha256"] = expected_tuple("BDC")
                attestation["stage"] = stage
                for phase, attested in zip(attestation["phases"], expected["attested"]):
                    phase["attested"] = attested
                attestation["state"] = expected["state"]
                attestation["operator"] = "synthetic-operator"
                attestation["attestedAtUtc"] = "2026-08-29T00:00:00Z"
                with tempfile.NamedTemporaryFile("w", suffix=".json") as handle:
                    json.dump(attestation, handle)
                    handle.flush()
                    result = subprocess.run(
                        [
                            "python3",
                            str(VALIDATOR),
                            "--rollback-attestation",
                            handle.name,
                            "--jenkins-source-commit",
                            JENKINS_COMMIT,
                        ],
                        text=True,
                        capture_output=True,
                        timeout=10,
                        check=False,
                    )
                self.assertEqual(0, result.returncode, result.stdout + result.stderr)

    def test_rollback_rejects_cross_tenant_fabricated_and_bad_metadata(self):
        template = json.loads((TEST_DIR / "rollback-operator-attestation.json").read_text(encoding="utf-8"))
        for deployment, tuple_sha, operator, timestamp, phase in (
            ("BDC", expected_tuple("AIM-AHEAD"), "synthetic-operator", "2026-08-29T00:00:00Z", None),
            ("AIM-AHEAD", "0" * 64, "synthetic-operator", "2026-08-29T00:00:00Z", None),
            ("BDC", expected_tuple("BDC"), "x", "not-a-time", None),
            ("BDC", expected_tuple("BDC"), "synthetic-operator", "2026-08-29T00:00:00Z", "not-an-object"),
        ):
            with self.subTest(deployment=deployment, tuple_sha=tuple_sha, timestamp=timestamp, phase=phase):
                attestation = json.loads(json.dumps(template))
                attestation["deployment"] = deployment
                attestation["tupleSha256"] = tuple_sha
                attestation["stage"] = "COMPLETE"
                for entry in attestation["phases"]:
                    entry["attested"] = True
                if phase is not None:
                    attestation["phases"][0] = phase
                attestation["state"] = {
                    "managementWritesFrozen": True,
                    "frontendRolledBack": True,
                    "targetedActiveOrScheduledRemaining": 0,
                    "forwardSchemaRetained": True,
                    "downMigrationRun": False,
                    "psamaRecreated": True,
                }
                attestation["operator"] = operator
                attestation["attestedAtUtc"] = timestamp
                with tempfile.NamedTemporaryFile("w", suffix=".json") as handle:
                    json.dump(attestation, handle)
                    handle.flush()
                    result = subprocess.run(
                        [
                            "python3",
                            str(VALIDATOR),
                            "--rollback-attestation",
                            handle.name,
                            "--jenkins-source-commit",
                            JENKINS_COMMIT,
                        ],
                        text=True,
                        capture_output=True,
                        timeout=10,
                        check=False,
                    )
                self.assertEqual(2, result.returncode, result.stdout + result.stderr)
                self.assertNotIn("Traceback", result.stderr)

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

    def test_authoritative_contract_is_preserved_byte_for_byte(self):
        backend_root = Path(os.environ["BACKEND_ROOT"])
        authoritative = backend_root / ".github/banner-rollout-contract.json"
        bundled = JENKINS_ROOT / "jenkins-docker/scripts/banner-rollout-contract.json"
        self.assertEqual(authoritative.read_bytes(), bundled.read_bytes())
        spec = json.loads((TEST_DIR / "aim-ahead-required-release-input.json").read_text(encoding="utf-8"))
        self.assertEqual(json.loads(authoritative.read_text(encoding="utf-8")), spec["banner_rollout"]["contract"])

    def test_checklist_accepts_required_commit_as_ref_ancestor(self):
        checklist = (TEST_DIR / "README.md").read_text(encoding="utf-8")
        self.assertIn("merge-base --is-ancestor", checklist)
        self.assertNotIn("resolved commit must be `5d2ba9", checklist)


if __name__ == "__main__":
    unittest.main()
