#!/usr/bin/env python3
import re
import sys
from pathlib import Path


def fail(message: str) -> None:
    raise SystemExit(message)


if len(sys.argv) != 4:
    fail(f"usage: {sys.argv[0]} <actual-pattern> <routes.tsv> <deployment>")

actual_pattern, fixture_path, deployment = sys.argv[1:]
entries = [
    line.split("\t", 1)
    for line in Path(fixture_path).read_text(encoding="utf-8").splitlines()
]
expected_patterns = [value for kind, value in entries if kind == "pattern"]
if len(expected_patterns) != 1:
    fail(f"{deployment} route fixture must contain exactly one pattern row")
if actual_pattern != expected_patterns[0]:
    fail(
        f"{deployment} route pattern mismatch: expected {expected_patterns[0]!r}, "
        f"got {actual_pattern!r}"
    )

rule = re.compile(actual_pattern)
for kind, route in entries:
    if kind == "pattern":
        continue
    if kind == "allow":
        if not rule.fullmatch(route):
            fail(f"{deployment} expected allowed route: {route}")
    elif kind == "deny":
        if rule.fullmatch(route):
            fail(f"{deployment} expected denied route: {route}")
    else:
        fail(f"{deployment} route fixture has unknown row type {kind!r}")
