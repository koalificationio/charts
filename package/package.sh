#!/usr/bin/env bash
# USAGE: package.sh <helm-repo-url> <git-repo> <output-dir>
# GITHUB_USER and GITHUB_TOKEN environment variables should contain valid username and token to clone chart repo

set -euo pipefail

HELM_REPO_URL="$1"
GIT_REPO="$2"
BUILD_DIR="$3"
DEFAULT_GITHUB_USER=koalificationio-bot
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

git clone "https://${GITHUB_USER:-$DEFAULT_GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GIT_REPO}" out
cd out
git checkout "${TARGET_BRANCH}" || git checkout --orphan "${TARGET_BRANCH}"
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
