#!/usr/bin/env bash
# USAGE: package.sh <helm-repo-url> <output-dir>

set -euo pipefail

HELM_REPO_URL="$1"
BUILD_DIR="$2"
TARGET_BRANCH=gh-pages

helm init --client-only

# add helm repos for charts in requirements
helm repo add jetstack https://charts.jetstack.io/

mkdir -p "${BUILD_DIR}"
for chart in ./stable/*; do
  echo "--- Packaging ${chart} into ${BUILD_DIR}"
  helm dep update "${chart}" || true
  helm package --destination "${BUILD_DIR}" "${chart}"
done
ls "${BUILD_DIR}"

git clone "${REPO_URL}" out
cd out
git checkout "${TARGET_BRANCH}" || git checkout --orphan ${TARGET_BRANCH}
cd ..

cp out/index.yaml "${BUILD_DIR}" || true
pushd "${BUILD_DIR}"
echo "--- Reindexing ${BUILD_DIR}"
if [ -f index.yaml ]; then
  helm repo index --url "${HELM_REPO_URL}" --merge index.yaml .
else
  helm repo index --url "${HELM_REPO_URL}" .
fi
popd

cp "${BUILD_DIR}"/* out/
