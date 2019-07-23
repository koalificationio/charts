#!/usr/bin/env bash
# USAGE: package.sh <helm-repo-url> <output-dir>

set -euo pipefail

HELM_REPO_URL="$1"
OUTPUT_DIR="$2"

for chart in ./stable/*; do
  echo "--- Packaging $chart into $OUTPUT_DIR"
  helm dep update "$chart" || true
  helm package --destination "$OUTPUT_DIR" "$chart"
done

echo "--- Reindexing $OUTPUT_DIR"
if [ -f index.yaml ]; then
  helm repo index --url "$HELM_REPO_URL" --merge index.yaml "$OUTPUT_DIR"
else
  helm repo index --url "$HELM_REPO_URL" "$OUTPUT_DIR"
fi
ls "$OUTPUT_DIR"
