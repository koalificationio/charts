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

dist-repo:
	git clone --quiet --single-branch -b gh-pages "https://github.com/${UPSTREAM_GIT_REPO}" dist-repo

# Build all Helm packages into dist-repo and regenerate the chart index
build: dist-repo
	cd package && \
		docker-compose build && \
		docker-compose run --rm package ./package/package.sh "${CHARTS_URL}" dist-repo && \
		cd ../dist-repo && \
		echo "--- Diff" && \
		git diff --stat

# Commit and push the chart index
release: build
	cd dist-repo && \
		git add *.tgz index.yaml && \
		git commit --message "Update to koalificationio/charts@${COMMIT}" && \
		git remote add origin-pages "https://${GITHUB_TOKEN}@github.com/${UPSTREAM_GIT_REPO}" > /dev/null 2>&1
		git push origin-pages gh-pages
