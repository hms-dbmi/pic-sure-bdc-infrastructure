#!/usr/bin/env bash
set -euo pipefail

test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mode="${1:-contract}"

case "${mode}" in
  contract | owners) ;;
  *)
    echo "usage: test.sh <contract|owners>" >&2
    exit 2
    ;;
esac

export PYTHONDONTWRITEBYTECODE=1
python3 -m unittest discover -v -s "${test_dir}" -p 'test_*.py'
PYTHONOPTIMIZE=1 python3 -m unittest discover -v -s "${test_dir}" -p 'test_*.py'

if [[ "${mode}" == "owners" ]]; then
  python3 "${test_dir}/run.py" owners
fi
