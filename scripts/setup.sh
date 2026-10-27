#!/usr/bin/env bash

set -euo pipefail

script_dir="$(dirname "${BASH_SOURCE[0]}")"

for script in download-dicts.sh; do
    echo "executing ${script}..."
    ${script_dir}/${script}
done

echo setup successful
