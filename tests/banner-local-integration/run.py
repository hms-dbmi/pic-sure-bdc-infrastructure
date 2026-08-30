#!/usr/bin/env python3

import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import uuid


ROOT = Path(__file__).resolve().parents[2]
TEST_DIR = Path(__file__).resolve().parent
BACKEND_COMMIT = "0178bbd2d1753e07dcead77a6d0e8ca37bf76dd8"
FRONTEND_COMMIT = "7b69aa960ff98f97c1a2d026b7137b0e3dcdf603"
MIGRATIONS_COMMIT = "05b1a77512dc0921570f0d442853fdcee75b8131"
JENKINS_COMMIT = "2d8a5d17bfe5a96664cdad5bc29a028a3ea8528b"
BDC_RELEASE_CONTROL_COMMIT = "e91d914228fd8984b052cd08d615711f7cce4b57"
AIO_COMMIT = "52adb20a8160a2c956b9dd7fc642a30cd1a79ac9"
AIO_RELEASE_WORKFLOW_COMMIT = "715857456594814957d9abc26ad14efbccb65e11"
AIO_RELEASE_CONTROL_COMMIT = "bfb07196be55f7f121dc250f7aa51d826642ff86"
REQUIRED_BASE = "cc1920a76fb6aeb9266fb4cffe98e946c2d983e4"
ROLLOUT_SHA256 = "f8cb265d735b757872391e04fdcd5b999b785eaa427ca13f8f2eefd493715359"
BDC_TUPLE = "6b0295fd358b9002b7028bb30721ec2c57f44bc81db6c531a5f06550398bfdb8"
AIM_TUPLE = "3431521f73a4a286df6ada99794901bb1ff390ebd9963302502b7d3efb16053f"
AIM_INPUT_SHA256 = "50903f05197a640a8849cffe1a138956933107ac02b12c3b95799e68542bc409"
SYNTHETIC_LOGGING_KEY = "t22b-synthetic-shared-logging-key"
SYNTHETIC_PRIVATE_RELEASE_COMMIT = "a" * 40
NOT_RUN_UUID = "00000000-0000-4000-8000-000000000000"
ZERO_SHA256 = "0" * 64
FISMA_IMAGES = {
    "mysql": "mysql:8.0.43@sha256:ccf4fed7ff4b886aeb3573a1f5d5b509525ecff55a2d1e2653c27a5abdded309",
    "flyway": "flyway/flyway:10.8@sha256:2f39377b52cdf1c70ffe9c1437aabed4e70fb716bb41323b03ee09ce17aaf292",
    "javaBuild": "maven:3-amazoncorretto-25@sha256:de7a3e517efac1b933af6ceb375974a061ba71c908ea51a18bd937716a8ade93",
    "javaRuntime": "amazoncorretto:25@sha256:397edfaaa0fdfc95001d4c4a4ab82174073277a5d630fd9375c94dca25b5991d",
    "playwright": "mcr.microsoft.com/playwright:v1.60.0-noble@sha256:9bd26ad900bb5e0f4dee75839e957a89ae89c2b7ab1e76050e559790e946b948",
}
AIO_IMAGES = {
    **FISMA_IMAGES,
    "flyway": "flyway/flyway:11.7.2@sha256:8ace7d9825bb3ad1d6e14ee27b3a830b638ac841ba424b99b2d92aa65a99d484",
}
ROOT_ENVIRONMENTS = {
    "aio": ("BANNER_LOCAL_AIO_ROOT", "AIO proof"),
    "aio_release_control": ("BANNER_LOCAL_AIO_RELEASE_CONTROL_ROOT", "AIO release control"),
    "backend": ("BANNER_LOCAL_BACKEND_ROOT", "shared backend"),
    "frontend": ("BANNER_LOCAL_FRONTEND_ROOT", "shared frontend"),
    "migrations": ("BANNER_LOCAL_MIGRATIONS_ROOT", "AIO migration parity"),
    "jenkins": ("BANNER_LOCAL_JENKINS_ROOT", "Jenkins deployment workflow"),
    "bdc_release_control": (
        "BANNER_LOCAL_BDC_RELEASE_CONTROL_ROOT",
        "BDC release control",
    ),
}
FIXTURE_CONTRACTS = {
    "bdc.json": {
        "deployment": "BDC",
        "migrationRoot": "app-infrastructure/db/bdc",
        "httpdTemplate": "app-infrastructure/configs/httpd-vhosts-bdc.conf",
        "targetStack": "b",
        "privateDnsName": "bdc.synthetic.invalid",
        "publicDnsName": "bdc.synthetic.invalid",
        "publicDnsNameStaging": "bdc-staging.synthetic.invalid",
        "expectedAuthMigrationMaximum": 27,
        "expectedPicsureMigrationMaximum": 11,
    },
    "aim-ahead.json": {
        "deployment": "AIM_AHEAD",
        "migrationRoot": "app-infrastructure/db/aim-ahead",
        "httpdTemplate": "app-infrastructure/configs/httpd-vhosts-aim-ahead.conf",
        "targetStack": "b",
        "privateDnsName": "aim-ahead.synthetic.invalid",
        "publicDnsName": "aim-ahead.synthetic.invalid",
        "publicDnsNameStaging": "aim-ahead-staging.synthetic.invalid",
        "expectedAuthMigrationMaximum": 29,
        "expectedPicsureMigrationMaximum": 11,
    },
}


class ProofError(RuntimeError):
    pass


def require(condition, message):
    if not condition:
        raise ProofError(message)


def sha256_bytes(value):
    return hashlib.sha256(value).hexdigest()


def sha256_file(path):
    return sha256_bytes(Path(path).read_bytes())


def command(arguments, *, cwd, env=None, timeout=1800, log_path=None):
    completed = subprocess.run(
        [str(argument) for argument in arguments],
        cwd=cwd,
        env=env,
        text=True,
        capture_output=True,
        timeout=timeout,
        check=False,
    )
    output = (completed.stdout or "") + (completed.stderr or "")
    if log_path is not None:
        Path(log_path).write_text(output, encoding="utf-8")
    if completed.returncode != 0:
        raise ProofError(
            f"owner command failed with status {completed.returncode}: "
            f"{' '.join(str(argument) for argument in arguments)}\n{output}"
        )
    return completed


def git_output(root, *arguments):
    completed = subprocess.run(
        ["git", "-C", str(root), *arguments],
        text=True,
        capture_output=True,
        timeout=30,
        check=False,
    )
    if completed.returncode != 0:
        raise ProofError(completed.stderr.strip() or f"git failed in {root}")
    return completed.stdout.strip()


def require_repository(root, expected_commit, label, require_clean=True):
    root = Path(root).resolve()
    require(root.is_dir(), f"{label} root is missing: {root}")
    actual = git_output(root, "rev-parse", "HEAD")
    require(actual == expected_commit, f"{label} commit drift: expected {expected_commit}, got {actual}")
    if require_clean:
        status = git_output(root, "status", "--porcelain=v1", "--untracked-files=all")
        require(not status, f"{label} source is dirty:\n{status}")
    return actual


def require_executing_repository(require_clean=True):
    head = git_output(ROOT, "rev-parse", "HEAD")
    ancestry = subprocess.run(
        ["git", "-C", str(ROOT), "merge-base", "--is-ancestor", REQUIRED_BASE, head],
        timeout=30,
        check=False,
    )
    require(ancestry.returncode == 0, f"executing proof is not descended from {REQUIRED_BASE}")
    if require_clean:
        status = git_output(ROOT, "status", "--porcelain=v1", "--untracked-files=all")
        require(not status, f"executing infrastructure source is dirty:\n{status}")
    return head


def local_checkout(source, destination, commit):
    command(
        ["git", "clone", "--quiet", "--local", "--no-hardlinks", "--no-checkout", source, destination],
        cwd=destination.parent,
        timeout=300,
    )
    command(
        ["git", "-C", destination, "-c", "advice.detachedHead=false", "checkout", "--quiet", "--detach", commit],
        cwd=destination.parent,
        timeout=60,
    )
    require_repository(destination, commit, "reviewed AIO release workflow")


def configured_roots(require_all=True):
    roots = {}
    for name, (variable, _label) in ROOT_ENVIRONMENTS.items():
        value = os.environ.get(variable)
        if require_all:
            require(value, f"{variable} must identify the exact clean owner root")
        if value:
            roots[name] = Path(value).resolve()
    return roots


def verify_roots(roots):
    expected = {
        "aio": AIO_COMMIT,
        "aio_release_control": AIO_RELEASE_CONTROL_COMMIT,
        "backend": BACKEND_COMMIT,
        "frontend": FRONTEND_COMMIT,
        "migrations": MIGRATIONS_COMMIT,
        "jenkins": JENKINS_COMMIT,
        "bdc_release_control": BDC_RELEASE_CONTROL_COMMIT,
    }
    verified = {}
    for name, commit in expected.items():
        _variable, label = ROOT_ENVIRONMENTS[name]
        verified[name] = require_repository(roots[name], commit, label)
    return verified


def render_terraform_template(path, values):
    source = Path(path).read_text(encoding="utf-8")
    escaped_dollar = "\0T22B_DOLLAR\0"
    escaped_percent = "\0T22B_PERCENT\0"
    source = source.replace("$${", escaped_dollar).replace("%%", escaped_percent)
    placeholders = set(re.findall(r"\$\{([A-Za-z_][A-Za-z0-9_]*)\}", source))
    missing = placeholders - set(values)
    require(not missing, f"template {path} is missing values for {sorted(missing)}")
    for name in sorted(placeholders):
        source = source.replace("${" + name + "}", str(values[name]))
    require(not re.search(r"\$\{[A-Za-z_]", source), f"template {path} retained a variable")
    return source.replace(escaped_dollar, "${").replace(escaped_percent, "%")


def env_value(rendered, name):
    prefix = name + "="
    values = [line.removeprefix(prefix) for line in rendered.splitlines() if line.startswith(prefix)]
    require(len(values) == 1, f"rendered env requires exactly one {name}, got {len(values)}")
    return values[0]


def migration_maximum(root):
    versions = []
    for path in Path(root).glob("V*.sql"):
        match = re.match(r"V([0-9]+)__", path.name)
        require(match is not None, f"unexpected migration name: {path}")
        versions.append(int(match.group(1)))
    require(versions, f"no migrations found in {root}")
    require(len(versions) == len(set(versions)), f"duplicate migration version in {root}")
    return max(versions)


def validate_fixture(fixture_path, output_root, verified_heads):
    fixture_path = Path(fixture_path)
    fixture = json.loads(fixture_path.read_text(encoding="utf-8"))
    require(fixture_path.name in FIXTURE_CONTRACTS, f"unknown deployment fixture: {fixture_path.name}")
    require(
        fixture == FIXTURE_CONTRACTS[fixture_path.name],
        f"{fixture_path.name} does not match its canonical tenant identity and paths",
    )
    deployment = fixture["deployment"]
    migration_root = ROOT / fixture["migrationRoot"]
    httpd_template = ROOT / fixture["httpdTemplate"]
    require(migration_root.is_dir(), f"{deployment} migration root is missing")
    require(httpd_template.is_file(), f"{deployment} httpd template is missing")
    require(
        migration_maximum(migration_root / "auth") == fixture["expectedAuthMigrationMaximum"],
        f"{deployment} authorization migration maximum drift",
    )
    require(
        migration_maximum(migration_root / "picsure") == fixture["expectedPicsureMigrationMaximum"],
        f"{deployment} PIC-SURE migration maximum drift",
    )

    common = {
        "target_stack": fixture["targetStack"],
        "env_private_dns_name": fixture["privateDnsName"],
        "picsure_token_introspection_token": "t22b-synthetic-introspection",
        "logging_api_key": SYNTHETIC_LOGGING_KEY,
        "include_open_hpds": "false",
        "picsure_application_token": "t22b-synthetic-application-token",
        "query_service_internal_token": "t22b-synthetic-internal-token",
    }
    gateway = render_terraform_template(
        ROOT / "app-infrastructure/template-renderer/templates/gateway.env.tftpl", common
    )
    operations = render_terraform_template(
        ROOT / "app-infrastructure/template-renderer/templates/operations.env.tftpl",
        {
            "picsure_db_host": f"mysql.{fixture['privateDnsName']}",
            "picsure_db_username": "t22b_synthetic_app",
            "picsure_db_password": "t22b-synthetic-password",
            "picsure_application_token": common["picsure_application_token"],
            "query_service_internal_token": common["query_service_internal_token"],
            "logging_api_key": SYNTHETIC_LOGGING_KEY,
        },
    )
    require(
        env_value(gateway, "LOGGING_API_KEY")
        == env_value(operations, "LOGGING_API_KEY")
        == SYNTHETIC_LOGGING_KEY,
        f"{deployment} rendered Gateway and Operations logging keys differ",
    )
    require(
        env_value(operations, "LOGGING_SERVICE_URL") == "http://pic-sure-logging",
        f"{deployment} Operations logging URL drift",
    )

    httpd = render_terraform_template(
        httpd_template,
        {
            "target_stack": fixture["targetStack"],
            "env_private_dns_name": fixture["privateDnsName"],
            "env_public_dns_name": fixture["publicDnsName"],
            "env_public_dns_name_staging": fixture["publicDnsNameStaging"],
        },
    )
    require("RewriteRule ^/picsure/(.*)$" in httpd, f"{deployment} httpd edge route is absent")
    require("localhost:3000" in httpd, f"{deployment} httpd frontend route is absent")
    require(f"wildfly.{fixture['targetStack']}.{fixture['privateDnsName']}:8080" in httpd,
            f"{deployment} httpd Gateway target did not render")

    deployment_root = Path(output_root) / deployment.lower().replace("_", "-")
    deployment_root.mkdir(parents=True)
    (deployment_root / "gateway.env").write_text(gateway, encoding="utf-8")
    (deployment_root / "operations.env").write_text(operations, encoding="utf-8")
    (deployment_root / "httpd-vhosts.conf").write_text(httpd, encoding="utf-8")
    return {
        "deployment": deployment,
        "fixtureSha256": sha256_file(fixture_path),
        "migrationRoot": fixture["migrationRoot"],
        "httpdTemplate": fixture["httpdTemplate"],
        "renderedGatewaySha256": sha256_bytes(gateway.encode()),
        "renderedOperationsSha256": sha256_bytes(operations.encode()),
        "renderedHttpdSha256": sha256_bytes(httpd.encode()),
        "sharedBackendCommit": verified_heads["backend"],
        "sharedFrontendCommit": verified_heads["frontend"],
    }


def verify_contract_snapshot(aio_root):
    source = json.loads((TEST_DIR / "contract-source.json").read_text(encoding="utf-8"))
    snapshot = TEST_DIR / "contract.json"
    require(sha256_file(snapshot) == source["sha256"], "Ticket 22A result contract snapshot checksum drift")
    contract = json.loads(snapshot.read_text(encoding="utf-8"))
    require(contract.get("$schema") == "https://json-schema.org/draft/2020-12/schema",
            "result contract is not draft 2020-12")
    require(contract.get("additionalProperties") is False, "result contract root is not closed")
    require(contract["properties"]["sourceCommits"]["additionalProperties"] == {"$ref": "#/$defs/commit"},
            "result contract source commit typing drift")
    if aio_root is not None:
        require_repository(aio_root, source["commit"], "Ticket 22A contract source")
        authoritative = aio_root / source["path"]
        require(authoritative.read_bytes() == snapshot.read_bytes(),
                "Ticket 22A result contract snapshot differs from exact source")
        blob = git_output(aio_root, "rev-parse", f"HEAD:{source['path']}")
        require(blob == source["gitBlob"], "Ticket 22A result contract Git blob drift")
    return contract


def verify_rollout_inputs(roots):
    backend_contract = roots["backend"] / ".github/banner-rollout-contract.json"
    require(sha256_file(backend_contract) == ROLLOUT_SHA256, "backend rollout contract checksum drift")
    bundled = roots["jenkins"] / "jenkins-docker/scripts/banner-rollout-contract.json"
    require(bundled.read_bytes() == backend_contract.read_bytes(), "Jenkins rollout contract bytes drift")

    bdc_spec = json.loads((roots["bdc_release_control"] / "build-spec.json").read_text(encoding="utf-8"))
    require(bdc_spec["banner_rollout"]["tupleSha256"] == BDC_TUPLE, "BDC rollout tuple drift")
    aim_path = ROOT / "tests/fisma-banner-rollout/aim-ahead-required-release-input.json"
    require(sha256_file(aim_path) == AIM_INPUT_SHA256, "AIM required input checksum drift")
    aim_spec = json.loads(aim_path.read_text(encoding="utf-8"))
    require(aim_spec["banner_rollout"]["tupleSha256"] == AIM_TUPLE, "AIM rollout tuple drift")
    attestation = json.loads(
        (ROOT / "tests/fisma-banner-rollout/fixtures/aim-ahead-completed-attestation.synthetic.json").read_text(
            encoding="utf-8"
        )
    )
    require(attestation["privateReleaseControl"]["resolvedCommit"] == SYNTHETIC_PRIVATE_RELEASE_COMMIT,
            "synthetic AIM attestation marker drift")
    require(attestation["releaseInput"]["buildSpecSha256"] == AIM_INPUT_SHA256,
            "synthetic AIM attestation does not bind the public required input")
    require(attestation["releaseInput"]["tupleSha256"] == AIM_TUPLE,
            "synthetic AIM attestation does not bind the public tuple")
    require(all(attestation["checks"].values()), "synthetic AIM attestation is incomplete")
    return attestation


def expected_matrix_contract():
    return {
        "schemaVersion": 1,
        "rolloutContractSha256": ROLLOUT_SHA256,
        "sharedSourceCommits": {
            "backend": BACKEND_COMMIT,
            "frontend": FRONTEND_COMMIT,
            "migrationParity": MIGRATIONS_COMMIT,
        },
        "ownerCommits": {
            "jenkins": JENKINS_COMMIT,
            "bdcReleaseControl": BDC_RELEASE_CONTROL_COMMIT,
            "aioDeployment": AIO_COMMIT,
            "aioReleaseWorkflow": AIO_RELEASE_WORKFLOW_COMMIT,
            "aioReleaseControl": AIO_RELEASE_CONTROL_COMMIT,
        },
        "rolloutTuples": {"BDC": BDC_TUPLE, "AIM_AHEAD": AIM_TUPLE},
        "aimRequiredInputSha256": AIM_INPUT_SHA256,
        "dockerOwnerEntrypoints": [
            {
                "ticket": 16,
                "root": "infrastructure",
                "command": "tests/deployment-migration/test.sh all",
                "status": "NOT_RUN_ENOSPC",
            },
            {
                "ticket": 17,
                "root": "backend",
                "command": "tests/operations-binary-compatibility/test.sh all",
                "status": "NOT_RUN_ENOSPC",
            },
            {
                "ticket": 18,
                "root": "backend",
                "command": "tests/banner-feed-compatibility/test.sh all",
                "status": "NOT_RUN_ENOSPC",
            },
            {
                "ticket": "22A",
                "root": "aioDeployment",
                "command": "tests/banner-local-integration/test.sh all",
                "status": "NOT_RUN_ENOSPC",
            },
        ],
        "rows": [
            {
                "deployment": "AIO",
                "fixture": "Ticket 22A exact local source",
                "flywayImage": AIO_IMAGES["flyway"],
                "releaseControlCommit": AIO_RELEASE_CONTROL_COMMIT,
                "localIntegration": "NOT_RUN",
                "dockerRuntime": "NOT_RUN",
                "liveOperatorAttestation": "NOT_RUN",
            },
            {
                "deployment": "BDC",
                "fixture": "fixtures/bdc.json",
                "flywayImage": FISMA_IMAGES["flyway"],
                "releaseControlCommit": BDC_RELEASE_CONTROL_COMMIT,
                "localIntegration": "NOT_RUN",
                "dockerRuntime": "NOT_RUN",
                "liveOperatorAttestation": "NOT_RUN",
            },
            {
                "deployment": "AIM_AHEAD",
                "fixture": "fixtures/aim-ahead.json",
                "flywayImage": FISMA_IMAGES["flyway"],
                "releaseControlCommit": "SYNTHETIC_LOCAL_ATTESTATION_ONLY",
                "localIntegration": "NOT_RUN",
                "dockerRuntime": "NOT_RUN",
                "liveOperatorAttestation": "NOT_RUN_MANUAL",
            },
        ],
        "limitations": {
            "productionTls": "NOT_RUN",
            "externalRouting": "NOT_RUN",
            "jenkins": "NOT_RUN",
            "aws": "NOT_RUN",
            "ssm": "NOT_RUN",
            "terraformApply": "NOT_RUN",
            "systemd": "NOT_RUN",
            "podman": "NOT_RUN",
            "alb": "NOT_RUN",
            "privateAimReleaseControl": "NOT_RUN_MANUAL",
        },
    }


def validate_expected_matrix(matrix):
    require(matrix == expected_matrix_contract(), "expected matrix does not match verified proof facts")


def owner_commands(roots, aio_release_workflow_root):
    python = sys.executable
    java_home = os.environ.get(
        "BANNER_LOCAL_JAVA_HOME",
        os.environ.get("JAVA_HOME_25_X64", "/opt/homebrew/opt/openjdk@25/libexec/openjdk.jdk/Contents/Home"),
    )
    groovy = os.environ.get(
        "JENKINS_GROOVY_JAR",
        str(Path.home() / ".m2/repository/org/codehaus/groovy/groovy-all/2.4.16/groovy-all-2.4.16.jar"),
    )
    base = {**os.environ, "PYTHONDONTWRITEBYTECODE": "1"}
    jenkins_env = {
        **base,
        "JENKINS_GROOVY_JAR": groovy,
        "BDC_RELEASE_CONTROL_ROOT": str(roots["bdc_release_control"]),
        "BDC_INFRASTRUCTURE_ROOT": str(ROOT),
        "BACKEND_ROOT": str(roots["backend"]),
    }
    infra_env = {**base, "JENKINS_ROOT": str(roots["jenkins"]), "BACKEND_ROOT": str(roots["backend"])}
    rc_env = {
        **base,
        "JENKINS_ROOT": str(roots["jenkins"]),
        "BDC_INFRASTRUCTURE_ROOT": str(ROOT),
        "BACKEND_ROOT": str(roots["backend"]),
    }
    cache_env = {**base, "JAVA_HOME": java_home, "PATH": f"{java_home}/bin:{base['PATH']}"}
    commands = [
        ("ticket22a-contract", ["bash", "tests/banner-local-integration/test.sh", "contract"], roots["aio"], base),
        ("ticket20-aio-rollout", [python, "tests/banner-rollout/test_contract.py"], roots["aio"], base),
        ("ticket20-aio-rollout-opt", [python, "tests/banner-rollout/test_contract.py"], roots["aio"], {**base, "PYTHONOPTIMIZE": "1"}),
        ("ticket20-release-control", [python, "tests/test_build_spec.py"], roots["aio_release_control"], {**base, "AIO_PIN_VALIDATION_ROOT": str(aio_release_workflow_root)}),
        ("ticket20-release-control-opt", [python, "tests/test_build_spec.py"], roots["aio_release_control"], {**base, "PYTHONOPTIMIZE": "1", "AIO_PIN_VALIDATION_ROOT": str(aio_release_workflow_root)}),
        ("ticket17-binary-contract", [python, "-m", "unittest", "discover", "-v", "-s", "tests/operations-binary-compatibility", "-p", "test_*.py"], roots["backend"], base),
        ("ticket17-binary-contract-opt", [python, "-m", "unittest", "discover", "-v", "-s", "tests/operations-binary-compatibility", "-p", "test_*.py"], roots["backend"], {**base, "PYTHONOPTIMIZE": "1"}),
        ("ticket18-feed-contract", [python, "-m", "unittest", "discover", "-v", "-s", "tests/banner-feed-compatibility", "-p", "test_*.py"], roots["backend"], base),
        ("ticket18-feed-contract-opt", [python, "-m", "unittest", "discover", "-v", "-s", "tests/banner-feed-compatibility", "-p", "test_*.py"], roots["backend"], {**base, "PYTHONOPTIMIZE": "1"}),
        ("ticket19-cache", ["mvn", "-q", "-B", "-Dtest=BannerManagementCacheRefreshIntegrationTest,BannerRolloutContractTest", "-Dsurefire.failIfNoSpecifiedTests=false", "-pl", "services/pic-sure-auth-microapp/pic-sure-auth-services", "-am", "test"], roots["backend"], cache_env),
        ("ticket21-jenkins", [python, "tests/fisma-banner-rollout/test_contract.py"], roots["jenkins"], jenkins_env),
        ("ticket21-jenkins-opt", [python, "tests/fisma-banner-rollout/test_contract.py"], roots["jenkins"], {**jenkins_env, "PYTHONOPTIMIZE": "1"}),
        ("ticket21-release-control", [python, "tests/test_banner_rollout.py"], roots["bdc_release_control"], rc_env),
        ("ticket21-release-control-opt", [python, "tests/test_banner_rollout.py"], roots["bdc_release_control"], {**rc_env, "PYTHONOPTIMIZE": "1"}),
        ("ticket21-infrastructure", [python, "tests/fisma-banner-rollout/test_contract.py"], ROOT, infra_env),
        ("ticket21-infrastructure-opt", [python, "tests/fisma-banner-rollout/test_contract.py"], ROOT, {**infra_env, "PYTHONOPTIMIZE": "1"}),
    ]
    require(Path(groovy).is_file(), f"JENKINS_GROOVY_JAR is missing: {groovy}")
    require(Path(java_home).is_dir(), f"Java 25 is missing: {java_home}")
    return commands


def result_row(deployment, executing_head, fixture, owner_passed):
    source_commits = {
        "deploymentConfig": AIO_COMMIT if deployment == "AIO" else executing_head,
        "backend": BACKEND_COMMIT,
        "frontend": FRONTEND_COMMIT,
        "migrationSource": MIGRATIONS_COMMIT if deployment == "AIO" else executing_head,
        "releaseControl": {
            "AIO": AIO_RELEASE_CONTROL_COMMIT,
            "BDC": BDC_RELEASE_CONTROL_COMMIT,
            "AIM_AHEAD": SYNTHETIC_PRIVATE_RELEASE_COMMIT,
        }[deployment],
    }
    checks = {
        "releaseTupleAndRolloutContract": "PASS",
        "migrationOwner": "NOT_RUN",
        "binarySchemaOwner": "NOT_RUN",
        "feedRollbackOwner": "NOT_RUN",
        "authorizationCacheOwner": "PASS" if owner_passed else "NOT_RUN",
        "deploymentRolloutOwner": "PASS" if owner_passed else "NOT_RUN",
        "authorizationAndApplicationMigrations": "NOT_RUN",
        "emptyAnonymousV2Feed": "NOT_RUN",
        "emptyBrowserRegion": "NOT_RUN",
        "managementAuthorization": "NOT_RUN",
        "publishThroughEdge": "NOT_RUN",
        "auditReceipt": "NOT_RUN",
        "publishedAnonymousV2Feed": "NOT_RUN",
        "publishedBrowserRender": "NOT_RUN",
        "cleanup": "NOT_RUN",
    }
    extension = {
        "proofMode": "NON_DOCKER_ENOSPC",
        "fixture": fixture,
        "dockerRuntime": "NOT_RUN",
        "runtimeObservationValues": "SCHEMA_REQUIRED_NOT_RUN_SENTINELS",
        "liveTlsExternalRoutingJenkinsAwsSsmTerraformSystemdPodmanAlb": "NOT_RUN",
    }
    if deployment == "AIM_AHEAD":
        extension.update(
            {
                "localReleaseControl": "SYNTHETIC_ATTESTATION_ONLY",
                "privateOperatorAttestation": "NOT_RUN_MANUAL",
                "privateReleaseControlCommitClaimed": False,
            }
        )
    return {
        "schemaVersion": 1,
        "deployment": deployment,
        "status": "NOT_RUN",
        "sourceCommits": source_commits,
        "images": AIO_IMAGES if deployment == "AIO" else FISMA_IMAGES,
        "rolloutContractSha256": ROLLOUT_SHA256,
        "checks": checks,
        "observations": {
            "emptyFeedCount": 0,
            "emptyBannerRegionCount": 0,
            "managementRouteCount": 9,
            "publishedFeedCount": 0,
            "publishedBannerRegionCount": 0,
            "auditAction": "NOT_RUN",
            "runtimeArtifacts": {
                "applicationArtifactDigests": {"notRun": ZERO_SHA256},
                "builtImageIds": {"notRun": "NOT_RUN"},
                "publishedBannerUuid": NOT_RUN_UUID,
            },
        },
        "limitations": {
            "productionTls": "NOT_RUN",
            "externalRouting": "NOT_RUN",
            "deploymentAutomation": "NOT_RUN",
            "embeddedMigrationRuntimeParity": "NOT_RUN",
            "liveAuthorization": "NOT_RUN",
            "peerDeploymentLocalProofs": "NOT_RUN",
        },
        "deploymentExtensions": {deployment: extension},
    }


def load_ticket22a_validator(aio_root):
    path = aio_root / "tests/banner-local-integration/run.py"
    spec = importlib.util.spec_from_file_location("ticket22a_banner_local_runner", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.validate_runtime_result


def preserve_diagnostics(runtime_root, diagnostics_root):
    runtime_root = Path(runtime_root)
    diagnostics_root = Path(diagnostics_root)
    diagnostics_root.mkdir(parents=True, exist_ok=True)
    copied = []
    for source in sorted(runtime_root.rglob("*")):
        if source.is_symlink() or not source.is_file():
            continue
        if source.suffix not in {".json", ".log"}:
            continue
        destination = diagnostics_root / source.relative_to(runtime_root)
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)
        copied.append(str(source.relative_to(runtime_root)))
    return copied


def failure_diagnostics_path(diagnostics_parent, executing_head, run_token=None):
    token = run_token or uuid.uuid4().hex
    require(re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]{0,63}", token) is not None,
            "diagnostics run token is invalid")
    return Path(diagnostics_parent) / f"{executing_head[:12]}-{token}-failure"


def complete_temporary_cleanup(results, runtime_root):
    require(not Path(runtime_root).exists(), "temporary proof root still exists after cleanup")
    require(
        all(result["checks"]["cleanup"] == "NOT_RUN" for result in results),
        "cleanup state was promoted early",
    )
    for result in results:
        result["checks"]["cleanup"] = "PASS"


def collect_temporary_evidence(runtime, roots, verified_heads, run_owners):
    fixtures = {
        "BDC": validate_fixture(
            TEST_DIR / "fixtures/bdc.json", runtime / "rendered", verified_heads
        ),
        "AIM_AHEAD": validate_fixture(
            TEST_DIR / "fixtures/aim-ahead.json", runtime / "rendered", verified_heads
        ),
    }
    require(
        fixtures["BDC"]["sharedBackendCommit"]
        == fixtures["AIM_AHEAD"]["sharedBackendCommit"],
        "deployment fixtures use different backend trees",
    )
    require(
        fixtures["BDC"]["sharedFrontendCommit"]
        == fixtures["AIM_AHEAD"]["sharedFrontendCommit"],
        "deployment fixtures use different frontend trees",
    )

    owner_passed = False
    if run_owners:
        logs = runtime / "owner-logs"
        logs.mkdir()
        aio_release_workflow_root = runtime / "reviewed-aio-release-workflow"
        local_checkout(
            roots["aio"], aio_release_workflow_root, AIO_RELEASE_WORKFLOW_COMMIT
        )
        for name, arguments, cwd, env in owner_commands(roots, aio_release_workflow_root):
            print(f"Ticket 22B owner: {name}", flush=True)
            command(arguments, cwd=cwd, env=env, timeout=3600, log_path=logs / f"{name}.log")
        require(
            verify_roots(roots) == verified_heads,
            "verified owner roots changed during composition",
        )
        require_executing_repository(require_clean=True)
        owner_passed = True
    return fixtures, owner_passed


def run_proof(run_owners, diagnostics_run_token=None):
    roots = configured_roots(require_all=True)
    verified_heads = verify_roots(roots)
    executing_head = require_executing_repository(require_clean=True)
    contract = verify_contract_snapshot(roots["aio"])
    verify_rollout_inputs(roots)
    expected = json.loads((TEST_DIR / "expected-matrix.json").read_text(encoding="utf-8"))
    validate_expected_matrix(expected)

    diagnostics_parent = Path(
        os.environ.get("BANNER_LOCAL_DIAGNOSTICS_ROOT", "/tmp/banner-local-integration-diagnostics")
    ).resolve()
    temp_parent = Path(os.environ.get("TMPDIR", "/tmp")).resolve()
    with tempfile.TemporaryDirectory(
        prefix="banner-local-nondocker-", dir=temp_parent
    ) as directory:
        runtime = Path(directory)
        try:
            fixtures, owner_passed = collect_temporary_evidence(
                runtime, roots, verified_heads, run_owners
            )
        except Exception:
            preserve_diagnostics(
                runtime,
                failure_diagnostics_path(diagnostics_parent, executing_head, diagnostics_run_token),
            )
            raise

    results = [
        result_row("AIO", executing_head, {"sourceCommit": AIO_COMMIT}, owner_passed),
        result_row("BDC", executing_head, fixtures["BDC"], owner_passed),
        result_row("AIM_AHEAD", executing_head, fixtures["AIM_AHEAD"], owner_passed),
    ]
    complete_temporary_cleanup(results, runtime)
    validator = load_ticket22a_validator(roots["aio"])
    for result in results:
        validator(contract, result)
    observed = {
        "schemaVersion": 1,
        "executingCommit": executing_head,
        "ownerChecks": "PASS" if owner_passed else "NOT_RUN",
        "dockerCapacity": "ENOSPC_CONFIRMED_NOT_RETESTED",
        "results": results,
        "manualLimitations": expected["limitations"],
    }
    print(json.dumps(observed, indent=2, sort_keys=True) + "\n", end="")


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in {"contract", "owners"}:
        raise SystemExit("usage: run.py <contract|owners>")
    run_proof(sys.argv[1] == "owners")


if __name__ == "__main__":
    main()
