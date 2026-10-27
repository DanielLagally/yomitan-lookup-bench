#!/usr/bin/env bash
set -euo pipefail

# pinned dictionary versions for consistent results
pixiv_tag="2026-10-27"
jitendex_tag="2026.10.03"

script_dir="$(dirname "${BASH_SOURCE[0]}")"
project_dir="$(dirname "$script_dir")"
dict_dir="${project_dir}/data/dictionaries"

# if it doesn't exist, create dictionary directory
mkdir -p "${dict_dir}"

if [ ! -f "${dict_dir}/jitendex.zip" ]; then
    curl --fail --location --continue-at - --output "${dict_dir}"/jitendex.zip https://github.com/stephenmk/stephenmk.github.io/releases/download/${jitendex_tag}.0/jitendex-yomitan.zip
fi

if [ ! -f "${dict_dir}/pixiv.zip" ]; then
    curl --fail --location --continue-at - --output "${dict_dir}"/pixiv.zip https://github.com/MarvNC/pixiv-yomitan/releases/download/${pixiv_tag}/Pixiv_${pixiv_tag}.zip
fi

echo "sha256sum check:"
cd "$dict_dir"
sha256sum --check "${script_dir}/SHA256SUMS"

echo success
