#!/usr/bin/env bash
# USAGE: package.sh <helm-repo-url> <git-repo> <output-dir>
# GITHUB_USER and GITHUB_TOKEN environment variables should contain valid username and token to clone chart repo

set -euo pipefail

HELM_REPO_URL="$1"
GIT_REPO="$2"
GITHUB_TOKEN="$3"
BUILD_DIR="$4"
DEFAULT_GITHUB_USER=koalificationio-bot
TARGET_BRANCH=gh-pages

helm init --client-only

# add helm repos for charts in requirements
helm repo add jetstack https://charts.jetstack.io/

git clone "https://${GITHUB_USER:-$DEFAULT_GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GIT_REPO}" "${BUILD_DIR}"
pushd "${BUILD_DIR}"
git checkout "${TARGET_BRANCH}" || git checkout --orphan "${TARGET_BRANCH}"
popd

for chart in ./stable/*; do
  chart_version=$(grep version "${chart}"/Chart.yaml | awk '{print $2}')
  set +e
    helm inspect "${HELM_REPO_URL}/${chart}" --version "${chart_version}" > /dev/null
    if [[ "$?" -eq "0" ]]; then
      notify "Skipping chart ${chart%/} ${chart_version} as it already exists in ${HELM_REPO_URL}"
    else
      set -e
      echo "--- Packaging ${chart} into ${BUILD_DIR}"
      helm dep update "${chart}" || true
      helm package --destination "${BUILD_DIR}" "${chart}"
    fi
done

ls "${BUILD_DIR}"

pushd "${BUILD_DIR}"
echo "--- Reindexing ${BUILD_DIR}"
if [ -f index.yaml ]; then
  helm repo index --url "${HELM_REPO_URL}" --merge index.yaml .
else
  helm repo index --url "${HELM_REPO_URL}" .
fi
popd
