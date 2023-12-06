APP_NAME := $(shell basename -s .git $(shell git remote get-url origin))
APP_VERSION := $(shell git describe --tags --abbrev=0)
HASH := $(shell git rev-parse --short HEAD)
GCR_REGISTRY_LOCATION := gcr.io
REGISTRY_LOCATION := ghcr.io
GCR_PROJECT_ID := devops-course-prometheus
USER_ID := silhouetteUA
OS := linux
ARCH := amd64
MAKE_REF := linux
TARGET := $(firstword $(MAKECMDGOALS))


ifeq ($(TARGET), linux)
	OS := linux
	ARCH := amd64
	MAKE_REF := linux
else ifeq ($(TARGET), arm)
	OS := linux
	ARCH := arm
	MAKE_REF := arm
else ifeq ($(TARGET), macos)
	OS := darwin
	ARCH := amd64
	MAKE_REF := macos
else ifeq ($(TARGET), windows)
	OS := windows
	ARCH := amd64
	MAKE_REF := windows
else
	OS := linux
	ARCH := amd64
	MAKE_REF := linux
endif

format:
	gofmt -s -w ./

dependencies:
	go get

lint:
	golangci-lint run -v

test:
	go test

linux: build-info build
arm: build-info build
macos: build-info build
windows: build-info build

build: format dependencies
	CGO_ENABLED=0 GOOS=$(OS) GOARCH=$(ARCH) \
	go build -v -o kbot -ldflags "-X="github.com/silhouetteUA/kbot/cmd.appVersion=$(APP_VERSION)

build-info:
	echo "Starting build for $(TARGET) with the following parameters: OS=$(OS) and ARCH=$(ARCH)"

# image: image-build-info
# 	docker build . -t $(GCR_REGISTRY_LOCATION)/$(GCR_PROJECT_ID)/$(APP_NAME):$(APP_VERSION)-$(ARCH) --build-arg OS=$(MAKE_REF)

image: 
	docker build . -t $(REGISTRY_LOCATION)/$(USER_ID)/$(APP_NAME):$(APP_VERSION)-$(HASH)-$(OS)-$(ARCH) --build-arg OS=$(MAKE_REF)

image-build-info:
	echo "Starting image creation: $(GCR_REGISTRY_LOCATION)/$(GCR_PROJECT_ID)/$(APP_NAME):$(APP_VERSION) with ARCH=$(ARCH)"

# push:
# 	docker push $(GCR_REGISTRY_LOCATION)/$(GCR_PROJECT_ID)/$(APP_NAME):$(APP_VERSION)-$(ARCH)

push:
	docker push $(REGISTRY_LOCATION)/$(USER_ID)/$(APP_NAME):$(APP_VERSION)-$(HASH)-$(OS)-$(ARCH)

clean:
	rm -rf $(APP_NAME)
	docker rmi $(GCR_REGISTRY_LOCATION)/$(GCR_PROJECT_ID)/$(APP_NAME):$(APP_VERSION)-$(ARCH)
