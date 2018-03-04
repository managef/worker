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
GO_VERSION_MANAGEF = 1.8.3

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

install:
	@echo Installing...
	go get -u github.com/golang/protobuf/{proto,protoc-gen-go}
	export PATH=${PATH}:${GOPATH}/bin

build: go-check
	@echo Building...
	@echo Generate Protos...
	protoc -I rpc/ rpc/*.proto --go_out=plugins=grpc:rpc

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