# Identifies the current build.
# These will be embedded in the app and displayed when it starts.
VERSION ?= 0.0.1.Final-SNAPSHOT
COMMIT_HASH ?= $(shell git rev-parse HEAD)

# SETTINGS BUILD
BUILD_NAME = managef_worker

# Identifies the docker image that will be built and deployed.
DOCKER_ACCOUNT ?= aljesusg

DOCKER_NAME ?= ${DOCKER_ACCOUNT}/${BUILD_NAME}
DOCKER_VERSION ?= dev
DOCKER_TAG = ${DOCKER_NAME}:${DOCKER_VERSION}

# The minimum Go version that must be used to build the app.
GO_VERSION_MANAGEF = 1.9.4

NAMESPACE = manage-f
# Environment variables set when running the Go compiler.
GO_BUILD_ENVVARS = \
	GOOS=linux \
	GOARCH=amd64 \
    CGO_ENABLED=0 \

all: build

clean:
	@echo Cleaning...
	@rm -f sws
	@rm -rf ${GOPATH}/bin/${OUTPUT_BIN}
	@rm -rf ${GOPATH}/pkg/*
	@rm -rf _output/*

go-check:
	@hack/check_go_version.sh "${GO_VERSION_MANAGEF}"

build: go-check
	@echo Building...
	${GO_BUILD_ENVVARS} go build \
		-o ${GOPATH}/bin/${BUILD_NAME} -ldflags "-X main.version=${VERSION} -X main.commitHash=${COMMIT_HASH}"

install:
	@echo Installing...
	${GO_BUILD_ENVVARS} go install \
		-ldflags "-X main.version=${VERSION} -X main.commitHash=${COMMIT_HASH}"

test:
	@echo Running tests, excluding third party tests under vendor
	go test $(shell go list ./... | grep -v -e /vendor/)
#
# dep targets - dependency management
#

dep-install:
	@echo Installing Glide itself
	@mkdir -p ${GOPATH}/bin
	# We want to pin on a specific version
	# @curl https://glide.sh/get | sh
	@curl https://glide.sh/get | awk '{gsub("get TAG https://glide.sh/version", "TAG=v0.13.1", $$0); print}' | sh

dep-update:
	@echo Updating dependencies and storing in vendor directory
	@glide update --strip-vendor

.prepare-docker-image-files:
	@echo Preparing docker image files...
	@mkdir -p ${GOPATH}/_output/docker/${BUILD_NAME}
	@cp -r deploy/docker/* ${GOPATH}/_output/docker/${BUILD_NAME}/
	@cp ${GOPATH}/bin/${BUILD_NAME} ${GOPATH}/_output/docker/${BUILD_NAME}/
	@echo ${DOCKER_TAG}

docker: .prepare-docker-image-files
	@echo Building docker image into local docker daemon...
	docker build -t ${DOCKER_TAG} ${GOPATH}/_output/docker/${BUILD_NAME}

docker-push:
	@echo Pushing current docker image to ${DOCKER_TAG}
	docker push ${DOCKER_TAG}

.prepare-minikube:
	@minikube addons list | grep -q "ingress: enabled" ; \
	if [ "$$?" != "0" ]; then \
		echo "Enabling ingress support to minikube" ; \
		minikube addons enable ingress ; \
	fi
	@grep -q sws /etc/hosts ; \
	if [ "$$?" != "0" ]; then \
		echo "/etc/hosts should have SWS so you can access the ingress"; \
	fi

minikube-docker: .prepare-minikube .prepare-docker-image-files
	@echo Building docker image into minikube docker daemon...
	@eval $$(minikube docker-env) ; \
    docker build -t ${DOCKER_TAG} ${GOPATH}/_output/docker/${BUILD_NAME}