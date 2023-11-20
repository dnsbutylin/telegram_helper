ROOT_DIR := $(shell dirname $(CURDIR))

PROJECT := $(shell cat $(ROOT_DIR)/pyproject.toml | grep "name" | head -1 | awk -F '"' '{print $$2}')
IMAGE_TAG := $(PROJECT)_ci

REPORTS := $(CURDIR)/.reports

SSH_KEY_PATH := $(HOME)/.ssh/id_rsa

clean:
	rm -rf $(REPORTS)

$(REPORTS):
	mkdir -p $(REPORTS)

build:
	DOCKER_BUILDKIT=1 docker build $(ROOT_DIR) \
		--file Dockerfile \
		--tag $(IMAGE_TAG) \
		--build-arg PROJECT=$(PROJECT) \
		--ssh default=$(SSH_KEY_PATH)

rmi:
	docker rmi $(IMAGE_TAG)

all: build
	docker run --rm --volume $(REPORTS):/home/$(PROJECT)/.reports $(IMAGE_TAG)

.DEFAULT_GOAL := all
