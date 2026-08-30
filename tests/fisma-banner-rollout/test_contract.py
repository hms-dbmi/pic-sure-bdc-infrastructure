#!/usr/bin/env python3
import hashlib
import json
import os
import subprocess
import tempfile
import unittest
from contextlib import contextmanager
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TEST_DIR = Path(__file__).resolve().parent
FIXTURE_DIR = TEST_DIR / "fixtures"
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


def fresh_timestamp() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


@contextmanager
def fresh_aim_attestation():
    attestation = json.loads(
        (FIXTURE_DIR / "aim-ahead-completed-attestation.synthetic.json").read_text(encoding="utf-8")
    )
    attestation["attestedAtUtc"] = fresh_timestamp()
    with tempfile.NamedTemporaryFile("w", suffix=".json") as handle:
        json.dump(attestation, handle)
        handle.flush()
        yield Path(handle.name)


def bind_rollback(attestation: dict, deployment: str) -> None:
    attestation["deployment"] = deployment
    attestation["controllerDeployment"] = deployment
    attestation["targetStack"] = "staging"
    attestation["artifactPrefix"] = "staging/banner-rollout/synthetic-old-run/containers"
    attestation["artifacts"] = {"frontendCommit": "1" * 40, "backendCommit": "2" * 40}
    attestation["tupleSha256"] = expected_tuple(deployment)
    attestation["operator"] = "synthetic-operator"
    attestation["attestedAtUtc"] = fresh_timestamp()


class PublicAimInputTest(unittest.TestCase):
    def test_aim_input_validates_as_its_own_deployment(self):
        with fresh_aim_attestation() as attestation:
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
                "--release-control-commit",
                "a" * 40,
                "--controller-deployment",
                "aim-ahead",
                "--attestation",
                str(attestation),
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
                    jenkins_source = [
                        "--jenkins-source-commit",
                        JENKINS_COMMIT,
                        "--controller-deployment",
                        "aim-ahead",
                        "--target-stack",
                        "staging",
                    ]
                result = subprocess.run(
                    ["python3", str(VALIDATOR), option, str(TEST_DIR / name), *jenkins_source],
                    text=True,
                    capture_output=True,
                    timeout=10,
                    check=False,
                )
                self.assertEqual(2, result.returncode, result.stdout + result.stderr)
                if option == "--attestation":
                    self.assertIn("requires the exact --build-spec", result.stderr)
                else:
                    self.assertIn("attestation is incomplete", result.stderr)

    def test_synthetic_completed_aim_attestation_passes_with_exact_input(self):
        with fresh_aim_attestation() as attestation:
            result = subprocess.run(
                [
                "python3",
                str(VALIDATOR),
                "--deployment",
                "AIM-AHEAD",
                "--build-spec",
                str(TEST_DIR / "aim-ahead-required-release-input.json"),
                "--attestation",
                str(attestation),
                "--release-control-commit",
                "a" * 40,
                "--controller-deployment",
                "aim-ahead",
                "--jenkins-source-commit",
                JENKINS_COMMIT,
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

    def test_aim_attestation_fixture_binds_the_exact_release_input(self):
        attestation = json.loads(
            (FIXTURE_DIR / "aim-ahead-completed-attestation.synthetic.json").read_text(encoding="utf-8")
        )
        spec = TEST_DIR / "aim-ahead-required-release-input.json"
        self.assertEqual("a" * 40, attestation["privateReleaseControl"]["resolvedCommit"])
        self.assertEqual(sha256(spec), attestation["releaseInput"]["buildSpecSha256"])
        self.assertEqual(expected_tuple("AIM-AHEAD"), attestation["releaseInput"]["tupleSha256"])
        self.assertEqual(JENKINS_COMMIT, attestation["releaseInput"]["jenkinsSourceCommit"])
        self.assertEqual("__TEST_SUPPLIES_FRESH_TIMESTAMP__", attestation["attestedAtUtc"])
        self.assertFalse((TEST_DIR / "aim-ahead-completed-attestation.synthetic.json").exists())

    def test_bdc_and_aim_rollback_attestations_pass_separately(self):
        template = json.loads((TEST_DIR / "rollback-operator-attestation.json").read_text(encoding="utf-8"))
        tuples = {
            "BDC": expected_tuple("BDC"),
            "AIM-AHEAD": expected_tuple("AIM-AHEAD"),
        }
        for deployment, tuple_sha in tuples.items():
            with self.subTest(deployment=deployment):
                attestation = json.loads(json.dumps(template))
                bind_rollback(attestation, deployment)
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
                            "--controller-deployment",
                            deployment.lower(),
                            "--target-stack",
                            "staging",
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
                bind_rollback(attestation, "BDC")
                attestation["stage"] = stage
                for phase, attested in zip(attestation["phases"], expected["attested"]):
                    phase["attested"] = attested
                attestation["state"] = expected["state"]
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
                            "--controller-deployment",
                            "bdc",
                            "--target-stack",
                            "staging",
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
                bind_rollback(attestation, deployment)
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
                            "--controller-deployment",
                            deployment.lower(),
                            "--target-stack",
                            "staging",
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

    def test_checklist_documents_supported_forward_and_executable_rollback_jobs(self):
        checklist = (TEST_DIR / "README.md").read_text(encoding="utf-8")
        self.assertIn("Check For Updates → Deployment Pipeline", checklist)
        for job in (
            "PIC-SURE Frontend Build",
            "PIC-SURE Frontend Deploy",
            "PIC-SURE Maven Build",
            "PIC-SURE Operations Service Image",
            "PIC-SURE Gateway Image",
            "PIC-SURE HPDS Query Service Image",
            "PIC-SURE Auth Micro App Image",
            "PIC-SURE Wildfly Stack Deploy",
            "PIC-SURE Auth Micro App Deploy",
        ):
            with self.subTest(job=job):
                self.assertIn(job, checklist)
        self.assertIn("--controller-deployment", checklist)
        self.assertIn("--target-stack", checklist)

    def test_banner_host_scripts_download_from_the_attested_artifact_prefix(self):
        scripts = ROOT / "app-infrastructure/scripts/deploy"
        for name in (
            "deploy-operations.sh",
            "deploy-query.sh",
            "deploy-psama.sh",
            "deploy-gateway.sh",
            "deploy-httpd.sh",
        ):
            with self.subTest(script=name):
                text = (scripts / name).read_text(encoding="utf-8")
                self.assertIn("--artifact_prefix", text)
                self.assertIn("artifact_prefix", text)
        orchestrator = (scripts / "deploy-wildfly-stack.sh").read_text(encoding="utf-8")
        self.assertGreaterEqual(orchestrator.count('--artifact_prefix "$artifact_prefix"'), 4)

    def test_pinned_infrastructure_commit_contains_artifact_prefix_support(self):
        spec = json.loads((TEST_DIR / "aim-ahead-required-release-input.json").read_text(encoding="utf-8"))
        pinned = spec["banner_rollout"]["components"]["infrastructure"]["commit"]
        self.assertEqual(pinned, spec["infrastructure_git_hash"])
        for name in (
            "deploy-wildfly-stack.sh",
            "deploy-operations.sh",
            "deploy-query.sh",
            "deploy-psama.sh",
            "deploy-gateway.sh",
            "deploy-httpd.sh",
        ):
            with self.subTest(script=name):
                result = subprocess.run(
                    ["git", "show", f"{pinned}:app-infrastructure/scripts/deploy/{name}"],
                    cwd=ROOT,
                    text=True,
                    capture_output=True,
                    check=False,
                )
                self.assertEqual(0, result.returncode, result.stderr)
                self.assertIn("--artifact_prefix", result.stdout)

    def test_rollback_template_binds_controller_stack_and_artifacts(self):
        template = json.loads((TEST_DIR / "rollback-operator-attestation.json").read_text(encoding="utf-8"))
        self.assertIn("controllerDeployment", template)
        self.assertIn("targetStack", template)
        self.assertIn("artifactPrefix", template)
        self.assertEqual(
            {"frontendCommit", "backendCommit"},
            set(template["artifacts"]),
        )


if __name__ == "__main__":
    unittest.main()
