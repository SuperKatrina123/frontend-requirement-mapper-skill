#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 OUTPUT_DIR" >&2
  exit 1
fi

output_dir="$1"
script_dir="$(cd "$(dirname "$0")" && pwd)"
root_dir="$(cd "$script_dir/.." && pwd)"

declare -a files=(
  "glossary.md:$root_dir/assets/business-glossary-template.md"
  "spec.md:$root_dir/assets/spec-template.md"
  "module-anchors.md:$root_dir/assets/module-anchor-template.md"
  "diff-map.md:$root_dir/assets/diff-map-template.md"
  "ui-contract.md:$root_dir/assets/ui-contract-template.md"
  "payload-diff.md:$root_dir/assets/payload-diff-template.md"
  "analysis.md:$root_dir/assets/requirement-analysis-template.md"
  "qa.md:$root_dir/assets/qa-record-template.md"
)

mkdir -p "$output_dir"

for pair in "${files[@]}"; do
  out_name="${pair%%:*}"
  template_path="${pair#*:}"
  out_path="$output_dir/$out_name"

  if [ -e "$out_path" ]; then
    echo "Refusing to overwrite existing file: $out_path" >&2
    exit 1
  fi

  if [ ! -f "$template_path" ]; then
    echo "Missing template: $template_path" >&2
    exit 1
  fi
done

for pair in "${files[@]}"; do
  out_name="${pair%%:*}"
  template_path="${pair#*:}"
  out_path="$output_dir/$out_name"
  cp "$template_path" "$out_path"
  echo "Created $out_path"
done
