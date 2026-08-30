#!/usr/bin/env python3

import copy
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
TEST_DIR = Path(__file__).resolve().parent


def load_runner():
    spec = importlib.util.spec_from_file_location("ticket22b_banner_local_runner", TEST_DIR / "run.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class BannerLocalIntegrationContractTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.runner = load_runner()
        cls.roots = cls.runner.configured_roots(require_all=True)
        cls.verified_heads = cls.runner.verify_roots(cls.roots)

    def test_operations_renders_the_existing_logging_transport(self):
        template = (
            ROOT
            / "app-infrastructure/template-renderer/templates/operations.env.tftpl"
        ).read_text(encoding="utf-8")
        self.assertIn("LOGGING_SERVICE_URL=http://pic-sure-logging", template)
        self.assertIn("LOGGING_API_KEY=${logging_api_key}", template)

        renderer = (
            ROOT / "app-infrastructure/template-renderer/main.tf"
        ).read_text(encoding="utf-8")
        operations = renderer[renderer.index('resource "aws_s3_object" "operations_env"') :]
        operations = operations[: operations.index('resource "aws_s3_object" "query_env"')]
        self.assertIn("logging_api_key", operations)
        self.assertIn("var.logging_api_key", operations)

    def test_release_inputs_pin_the_executable_commit_that_contains_logging_wiring(self):
        runner = self.runner
        logging_commit = "d10cecdeb89f14f8c672a81347ffa70d9b001ab3"
        roots = self.roots
        inputs = {
            "BDC": json.loads(
                (roots["bdc_release_control"] / "build-spec.json").read_text(encoding="utf-8")
            ),
            "AIM_AHEAD": json.loads(
                (ROOT / "tests/fisma-banner-rollout/aim-ahead-required-release-input.json").read_text(
                    encoding="utf-8"
                )
            ),
        }
        for deployment, spec in inputs.items():
            with self.subTest(deployment=deployment):
                self.assertEqual(logging_commit, spec["infrastructure_git_hash"])
                self.assertEqual(
                    logging_commit,
                    spec["banner_rollout"]["components"]["infrastructure"]["commit"],
                )
        validator = (
            roots["jenkins"] / "jenkins-docker/scripts/validate-banner-rollout.py"
        ).read_text(encoding="utf-8")
        self.assertIn(f'"commit": "{logging_commit}"', validator)

    def test_bdc_and_aim_local_proof_contract_is_checked_in(self):
        required = (
            "README.md",
            "contract.json",
            "contract-source.json",
            "expected-matrix.json",
            "fixtures/aim-ahead.json",
            "fixtures/bdc.json",
            "run.py",
            "test.sh",
        )
        missing = [name for name in required if not (TEST_DIR / name).is_file()]
        self.assertEqual([], missing, f"missing BDC/AIM local proof files: {missing}")

    def test_ticket22a_contract_snapshot_is_exact_and_closed(self):
        runner = self.runner
        contract = runner.verify_contract_snapshot(self.roots["aio"])
        self.assertEqual(
            "28885897e199529ac3c0957d4e87a492328fd5480936a7cd3e740c7cf57d49be",
            runner.sha256_file(TEST_DIR / "contract.json"),
        )
        self.assertFalse(contract["additionalProperties"])
        self.assertEqual(
            {"$ref": "#/$defs/commit"},
            contract["properties"]["sourceCommits"]["additionalProperties"],
        )

    def test_deployment_fixtures_use_distinct_real_tenant_inputs(self):
        runner = self.runner
        with tempfile.TemporaryDirectory() as directory:
            bdc = runner.validate_fixture(
                TEST_DIR / "fixtures/bdc.json",
                Path(directory) / "bdc",
                self.verified_heads,
            )
            aim = runner.validate_fixture(
                TEST_DIR / "fixtures/aim-ahead.json",
                Path(directory) / "aim-ahead",
                self.verified_heads,
            )
        self.assertNotEqual(bdc["migrationRoot"], aim["migrationRoot"])
        self.assertNotEqual(bdc["httpdTemplate"], aim["httpdTemplate"])
        self.assertNotEqual(bdc["renderedHttpdSha256"], aim["renderedHttpdSha256"])
        self.assertEqual(bdc["sharedBackendCommit"], aim["sharedBackendCommit"])
        self.assertEqual(bdc["sharedFrontendCommit"], aim["sharedFrontendCommit"])
        self.assertEqual(self.verified_heads["backend"], bdc["sharedBackendCommit"])
        self.assertEqual(self.verified_heads["frontend"], bdc["sharedFrontendCommit"])

    def test_fixture_filename_binds_the_canonical_tenant_identity_and_paths(self):
        runner = self.runner
        fixture = json.loads((TEST_DIR / "fixtures/bdc.json").read_text(encoding="utf-8"))
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            fixture_path = root / "bdc.json"
            mutations = {
                "identity": ("deployment", "AIM_AHEAD"),
                "migration path": ("migrationRoot", "app-infrastructure/db/aim-ahead"),
                "HTTPD path": (
                    "httpdTemplate",
                    "app-infrastructure/configs/httpd-vhosts-aim-ahead.conf",
                ),
            }
            for label, (field, value) in mutations.items():
                with self.subTest(label=label):
                    changed = copy.deepcopy(fixture)
                    changed[field] = value
                    fixture_path.write_text(json.dumps(changed), encoding="utf-8")
                    with self.assertRaises(runner.ProofError):
                        runner.validate_fixture(
                            fixture_path,
                            root / f"rendered-{field}",
                            self.verified_heads,
                        )

    def test_matrix_is_closed_and_does_not_claim_docker_or_private_aim(self):
        matrix = json.loads((TEST_DIR / "expected-matrix.json").read_text(encoding="utf-8"))
        self.assertEqual(["AIO", "BDC", "AIM_AHEAD"], [row["deployment"] for row in matrix["rows"]])
        for row in matrix["rows"]:
            self.assertEqual("NOT_RUN", row["localIntegration"])
            self.assertEqual("NOT_RUN", row["dockerRuntime"])
        self.assertIn("flyway:11.7.2", matrix["rows"][0]["flywayImage"])
        self.assertIn("flyway:10.8", matrix["rows"][1]["flywayImage"])
        self.assertEqual(matrix["rows"][1]["flywayImage"], matrix["rows"][2]["flywayImage"])
        aim = matrix["rows"][2]
        self.assertEqual("SYNTHETIC_LOCAL_ATTESTATION_ONLY", aim["releaseControlCommit"])
        self.assertEqual("NOT_RUN_MANUAL", aim["liveOperatorAttestation"])
        self.assertTrue(all(value.startswith("NOT_RUN") for value in matrix["limitations"].values()))
        self.assertEqual([16, 17, 18, "22A"], [item["ticket"] for item in matrix["dockerOwnerEntrypoints"]])
        self.assertTrue(
            all(item["status"] == "NOT_RUN_ENOSPC" for item in matrix["dockerOwnerEntrypoints"])
        )
        self.assertEqual(
            "715857456594814957d9abc26ad14efbccb65e11",
            matrix["ownerCommits"]["aioReleaseWorkflow"],
        )

    def test_matrix_provenance_rows_and_owner_commands_are_bound_to_verified_facts(self):
        runner = self.runner
        matrix = json.loads((TEST_DIR / "expected-matrix.json").read_text(encoding="utf-8"))
        mutations = (
            ("shared commit", ("sharedSourceCommits", "backend"), "f" * 40),
            ("owner commit", ("ownerCommits", "jenkins"), "f" * 40),
            ("tuple", ("rolloutTuples", "BDC"), "f" * 64),
            ("AIM checksum", ("aimRequiredInputSha256",), "f" * 64),
            ("fixture row", ("rows", 1, "fixture"), "fixtures/aim-ahead.json"),
            ("Docker owner", ("dockerOwnerEntrypoints", 0, "command"), "true"),
        )
        for label, path, replacement in mutations:
            with self.subTest(label=label):
                changed = copy.deepcopy(matrix)
                target = changed
                for component in path[:-1]:
                    target = target[component]
                target[path[-1]] = replacement
                with self.assertRaises(runner.ProofError):
                    runner.validate_expected_matrix(changed)

    def test_results_validate_without_promoting_runtime_checks(self):
        runner = self.runner
        contract = runner.verify_contract_snapshot(self.roots["aio"])
        validator = runner.load_ticket22a_validator(self.roots["aio"])
        for deployment in ("AIO", "BDC", "AIM_AHEAD"):
            row = runner.result_row(deployment, runner.REQUIRED_BASE, {"synthetic": True}, False)
            validator(contract, row)
            self.assertEqual("NOT_RUN", row["status"])
            self.assertNotIn("PASS", {
                row["checks"]["migrationOwner"],
                row["checks"]["authorizationAndApplicationMigrations"],
                row["checks"]["publishThroughEdge"],
                row["checks"]["auditReceipt"],
                row["checks"]["publishedBrowserRender"],
            })

    def test_result_rows_use_the_deployment_specific_flyway_image(self):
        runner = self.runner
        aio = runner.result_row("AIO", runner.REQUIRED_BASE, {"synthetic": True}, False)
        bdc = runner.result_row("BDC", runner.REQUIRED_BASE, {"synthetic": True}, False)
        aim = runner.result_row("AIM_AHEAD", runner.REQUIRED_BASE, {"synthetic": True}, False)

        self.assertEqual(
            "flyway/flyway:11.7.2@sha256:8ace7d9825bb3ad1d6e14ee27b3a830b638ac841ba424b99b2d92aa65a99d484",
            aio["images"]["flyway"],
        )
        self.assertEqual(
            "flyway/flyway:10.8@sha256:2f39377b52cdf1c70ffe9c1437aabed4e70fb716bb41323b03ee09ce17aaf292",
            bdc["images"]["flyway"],
        )
        self.assertEqual(bdc["images"]["flyway"], aim["images"]["flyway"])

    def test_cleanup_pass_requires_the_temporary_root_to_be_gone(self):
        runner = self.runner
        rows = [runner.result_row("BDC", runner.REQUIRED_BASE, {"synthetic": True}, False)]
        self.assertEqual("NOT_RUN", rows[0]["checks"]["cleanup"])

        with tempfile.TemporaryDirectory() as directory:
            runtime = Path(directory)
            with self.assertRaises(runner.ProofError):
                runner.complete_temporary_cleanup(rows, runtime)
            self.assertEqual("NOT_RUN", rows[0]["checks"]["cleanup"])

        runner.complete_temporary_cleanup(rows, runtime)
        self.assertEqual("PASS", rows[0]["checks"]["cleanup"])

    def test_failure_diagnostics_are_run_scoped_and_allowlisted(self):
        runner = self.runner
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            runtime = root / "runtime"
            diagnostics = root / "diagnostics"
            (runtime / "nested").mkdir(parents=True)
            (runtime / "nested/result.json").write_text("{}\n", encoding="utf-8")
            (runtime / "owner.log").write_text("synthetic failure\n", encoding="utf-8")
            (runtime / "secret.env").write_text("not copied\n", encoding="utf-8")
            copied = runner.preserve_diagnostics(runtime, diagnostics)
            self.assertEqual(["nested/result.json", "owner.log"], copied)
            self.assertFalse((diagnostics / "secret.env").exists())

    def test_failures_at_the_same_commit_use_distinct_diagnostics_directories(self):
        runner = self.runner
        with tempfile.TemporaryDirectory() as directory:
            parent = Path(directory)
            path_for = getattr(
                runner,
                "failure_diagnostics_path",
                lambda root, commit, run_token: root / f"{commit[:12]}-failure",
            )
            first = path_for(parent, runner.REQUIRED_BASE, "run-0001")
            second = path_for(parent, runner.REQUIRED_BASE, "run-0002")
            self.assertNotEqual(first, second)
            self.assertEqual(parent, first.parent)
            self.assertEqual(parent, second.parent)

    def test_owner_composition_is_non_docker_and_fail_closed(self):
        source = (TEST_DIR / "run.py").read_text(encoding="utf-8")
        self.assertNotRegex(source, r"subprocess\.(?:run|Popen)\([^\n]*docker")
        self.assertNotIn("shell=True", source)
        self.assertIn("owner_passed = True", source)
        self.assertLess(source.index("for name, arguments, cwd, env in owner_commands"), source.index("owner_passed = True"))
        for ticket in ("ticket22a-contract", "ticket20-aio-rollout", "ticket19-cache", "ticket21-jenkins"):
            self.assertIn(ticket, source)


if __name__ == "__main__":
    unittest.main()
