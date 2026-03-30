#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 OUTPUT_PATH" >&2
  exit 1
fi

output_path="$1"
script_dir="$(cd "$(dirname "$0")" && pwd)"
template_path="$script_dir/../assets/requirement-analysis-template.md"

if [ -e "$output_path" ]; then
  echo "Refusing to overwrite existing file: $output_path" >&2
  exit 1
fi

mkdir -p "$(dirname "$output_path")"
cp "$template_path" "$output_path"
echo "Created $output_path"
