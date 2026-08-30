#!/usr/bin/env python3

import importlib.util
import json
import os
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
        runner = load_runner()
        aio_root = os.environ.get("BANNER_LOCAL_AIO_ROOT")
        contract = runner.verify_contract_snapshot(Path(aio_root) if aio_root else None)
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
        runner = load_runner()
        with tempfile.TemporaryDirectory() as directory:
            bdc = runner.validate_fixture(TEST_DIR / "fixtures/bdc.json", Path(directory) / "bdc")
            aim = runner.validate_fixture(
                TEST_DIR / "fixtures/aim-ahead.json", Path(directory) / "aim-ahead"
            )
        self.assertNotEqual(bdc["migrationRoot"], aim["migrationRoot"])
        self.assertNotEqual(bdc["httpdTemplate"], aim["httpdTemplate"])
        self.assertNotEqual(bdc["renderedHttpdSha256"], aim["renderedHttpdSha256"])
        self.assertEqual(bdc["sharedBackendCommit"], aim["sharedBackendCommit"])
        self.assertEqual(bdc["sharedFrontendCommit"], aim["sharedFrontendCommit"])

    def test_matrix_is_closed_and_does_not_claim_docker_or_private_aim(self):
        matrix = json.loads((TEST_DIR / "expected-matrix.json").read_text(encoding="utf-8"))
        self.assertEqual(["AIO", "BDC", "AIM_AHEAD"], [row["deployment"] for row in matrix["rows"]])
        for row in matrix["rows"]:
            self.assertEqual("NOT_RUN", row["localIntegration"])
            self.assertEqual("NOT_RUN", row["dockerRuntime"])
        aim = matrix["rows"][2]
        self.assertEqual("SYNTHETIC_LOCAL_ATTESTATION_ONLY", aim["releaseControlCommit"])
        self.assertEqual("NOT_RUN_MANUAL", aim["liveOperatorAttestation"])
        self.assertTrue(all(value.startswith("NOT_RUN") for value in matrix["limitations"].values()))
        self.assertEqual([16, 17, 18, "22A"], [item["ticket"] for item in matrix["dockerOwnerEntrypoints"]])
        self.assertTrue(
            all(item["status"] == "NOT_RUN_ENOSPC" for item in matrix["dockerOwnerEntrypoints"])
        )

    def test_results_validate_without_promoting_runtime_checks(self):
        runner = load_runner()
        aio_root = os.environ.get("BANNER_LOCAL_AIO_ROOT")
        if not aio_root:
            self.skipTest("BANNER_LOCAL_AIO_ROOT is required for the authoritative validator")
        contract = runner.verify_contract_snapshot(Path(aio_root))
        validator = runner.load_ticket22a_validator(Path(aio_root))
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

    def test_failure_diagnostics_are_run_scoped_and_allowlisted(self):
        runner = load_runner()
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
