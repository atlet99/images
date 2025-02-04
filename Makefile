SHELL := /usr/bin/env bash

ifeq ($(shell echo $$0),zsh)
  SHELL := /bin/zsh
else
  SHELL := /bin/bash
endif

HELMFILE_VERSION := $(shell awk '/HELMFILE_VERSION:/{getline; print $$2}' .gitlab-ci.yml)
HELM_VERSION := $(shell awk '/HELM_VERSION:/{getline; print $$2}' .gitlab-ci.yml)
SOPS_VERSION := $(shell awk '/SOPS_VERSION:/{getline; print $$2}' .gitlab-ci.yml)
KUBECTL_VERSION := $(shell awk '/KUBECTL_VERSION:/{getline; print $$2}' .gitlab-ci.yml)
TERRAFORM_VERSION := $(shell awk '/TERRAFORM_VERSION:/{getline; print $$2}' .gitlab-ci.yml)
HELMSMAN_APP_VERSION := $(shell awk '/HELMSMAN_APP_VERSION:/{getline; print $$2}' .gitlab-ci.yml)
HELM_DIFF := $(shell awk '/HELM_DIFF:/{getline; print $$2}' .gitlab-ci.yml)
HELM_GIT := $(shell awk '/HELM_GIT:/{getline; print $$2}' .gitlab-ci.yml)
HELM_S3 := $(shell awk '/HELM_S3:/{getline; print $$2}' .gitlab-ci.yml)
HELM_SECRETS := $(shell awk '/HELM_SECRETS:/{getline; print $$2}' .gitlab-ci.yml)
NGINX_VERSION := $(shell awk '/NGINX_VERSION:/{getline; print $$2}' .gitlab-ci.yml)
OPENSSL_VERSION := $(shell awk '/OPENSSL_VERSION:/{getline; print $$2}' .gitlab-ci.yml)

.PHONY: all
all: deployer nginx kaniko

.PHONY: deployer
deployer:
	docker build \
	  --build-arg HELMFILE_VERSION=$(HELMFILE_VERSION) \
	  --build-arg HELM_VERSION=$(HELM_VERSION) \
	  --build-arg SOPS_VERSION=$(SOPS_VERSION) \
	  --build-arg KUBECTL_VERSION=$(KUBECTL_VERSION) \
	  --build-arg TERRAFORM_VERSION=$(TERRAFORM_VERSION) \
	  --build-arg HELMSMAN_APP_VERSION=$(HELMSMAN_APP_VERSION) \
	  --build-arg HELM_DIFF=$(HELM_DIFF) \
	  --build-arg HELM_GIT=$(HELM_GIT) \
	  --build-arg HELM_S3=$(HELM_S3) \
	  --build-arg HELM_SECRETS=$(HELM_SECRETS) \
	  -t deployer:custom \
	  -f deployer.Dockerfile .

.PHONY: nginx
nginx:
	docker build \
	  --build-arg NGINX_VERSION=$(NGINX_VERSION) \
	  --build-arg OPENSSL_VERSION=$(OPENSSL_VERSION) \
	  -t nginx:custom \
	  -f nginx.Dockerfile .

.PHONY: kaniko
kaniko:
	docker build \
	  -t kaniko:custom \
	  -f kaniko.Dockerfile .

.PHONY: run-deployer
run-deployer:
	docker run -it --rm deployer:custom bash

.PHONY: run-nginx
run-nginx:
	docker run -it --rm nginx:custom bash

.PHONY: run-kaniko
run-kaniko:
	docker run -it --rm kaniko:custom bash

.PHONY: print-vars
print-vars:
	@echo "HELMFILE_VERSION=$(HELMFILE_VERSION)"
	@echo "HELM_VERSION=$(HELM_VERSION)"
	@echo "SOPS_VERSION=$(SOPS_VERSION)"
	@echo "KUBECTL_VERSION=$(KUBECTL_VERSION)"
	@echo "TERRAFORM_VERSION=$(TERRAFORM_VERSION)"
	@echo "HELMSMAN_APP_VERSION=$(HELMSMAN_APP_VERSION)"
	@echo "HELM_DIFF=$(HELM_DIFF)"
	@echo "HELM_GIT=$(HELM_GIT)"
	@echo "HELM_S3=$(HELM_S3)"
	@echo "HELM_SECRETS=$(HELM_SECRETS)"
	@echo "NGINX_VERSION=$(NGINX_VERSION)"
	@echo "OPENSSL_VERSION=$(OPENSSL_VERSION)"
