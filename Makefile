CHART_REPO_NAME = koalificationio
CHART_REPO_URL = https://koalificationio.github.io/charts
UPSTREAM_GIT_REPO = "${CHART_REPO_NAME}/charts.git"
CT_IMAGE = quay.io/helmpack/chart-testing:v3.0.0-rc.1
COMMIT = $(shell git rev-parse --short HEAD)

.PHONY: lint shellcheck clean build publish

# Lints the chart changes against origin/master
lint:
	git fetch origin master && \
		docker run \
			--volume "${PWD}:/src" \
			--workdir /src \
			--rm \
			"${CT_IMAGE}" \
			ct lint --config test/ct.yaml

clean:
	rm -rf dist-repo

# Build all Helm packages into dist-repo and regenerate the chart index
build: lint
	cd package && \
		docker-compose build && \
		docker-compose run --rm package ./package/package.sh \
		"${CHART_REPO_NAME}" "${CHART_REPO_URL}" "${UPSTREAM_GIT_REPO}" ${GITHUB_TOKEN} dist-repo
