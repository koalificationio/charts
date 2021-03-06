#!/usr/bin/env bash
# USAGE: package.sh <helm-repo-url> <git-repo> <output-dir>
# GITHUB_USER and GITHUB_TOKEN environment variables should contain valid username and token to clone chart repo

set -euo pipefail

CHART_REPO_NAME="$1"
CHART_REPO_URL="$2"
GIT_REPO="$3"
GITHUB_TOKEN="$4"
BUILD_DIR="$5"

DEFAULT_GITHUB_USER=koalificationio-bot
TARGET_BRANCH=gh-pages

# add own helm chart repo and repos for charts in requirements
helm repo add "${CHART_REPO_NAME}" "${CHART_REPO_URL}"
helm repo add jetstack https://charts.jetstack.io/

mkdir -p "${BUILD_DIR}"
BUILD_TEMP_DIR=$(mktemp -d)

for chart in ./stable/*; do
  chart_version=$(grep version "${chart}"/Chart.yaml | awk '{print $2}')
  set +e
    chart_basename=$(basename "${chart}")
    helm inspect "${CHART_REPO_NAME}/${chart_basename}" --version "${chart_version}" > /dev/null
    if [[ "$?" -eq "0" ]]; then
      echo "--- Skipping chart ${chart%/} ${chart_version} as it already exists in ${CHART_REPO_URL}"
    else
      set -e
      echo "--- Packaging ${chart} into ${BUILD_TEMP_DIR}"
      helm dep update "${chart}" || true
      helm package "${chart}" --destination "${BUILD_TEMP_DIR}"
    fi
done
ls "${BUILD_TEMP_DIR}"

git clone "https://${GITHUB_USER:-$DEFAULT_GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GIT_REPO}" out
pushd out
git checkout "${TARGET_BRANCH}" || git checkout --orphan "${TARGET_BRANCH}"
cp index.yaml "${BUILD_TEMP_DIR}" || true
popd

pushd "${BUILD_TEMP_DIR}"
echo "--- Reindexing ${BUILD_TEMP_DIR}"
if [ -f index.yaml ]; then
  helm repo index --url "${CHART_REPO_URL}" --merge index.yaml .
else
  helm repo index --url "${CHART_REPO_URL}" .
fi
popd

cp -r "${BUILD_TEMP_DIR}"/* out/
cp -r out/* "${BUILD_DIR}"
