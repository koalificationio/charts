UPSTREAM_GIT_REPO = koalificationio/charts.git
CHARTS_URL = https://koalificationio.github.io/charts
CT_IMAGE = gcr.io/kubernetes-charts-ci/test-image:v3.3.2
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
		"${CHARTS_URL}" "${UPSTREAM_GIT_REPO}" ${GITHUB_TOKEN} dist-repo
