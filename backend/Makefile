#!make

-include .env

ifeq ($(strip $(DEPLOY_REMOTE_TAR_PATH)),)
DEPLOY_REMOTE_TAR_PATH := /tmp/pokr-backend.tar
endif

ifeq ($(strip $(DEPLOY_STACK_SERVICE)),)
DEPLOY_STACK_SERVICE := backend
endif

build-tar:
	rm -fv pokr-backend.tar
	docker build -f docker/Dockerfile -t pokr-backend:latest .
	docker save -o pokr-backend.tar pokr-backend:latest

build-tar-remote:
	rm -fv pokr-backend.tar
	docker buildx create --driver docker-container --name amd64builder --use ssh://$(DEPLOY_SSH_USER)@$(DEPLOY_SSH_HOST) || true
	docker buildx build --builder amd64builder --platform linux/amd64 -f docker/Dockerfile -t pokr-backend:latest --load .
	docker save -o pokr-backend.tar pokr-backend:latest

copy-tar:
	scp pokr-backend.tar $(DEPLOY_SSH_USER)@$(DEPLOY_SSH_HOST):$(DEPLOY_TAR_PATH)
	ssh $(DEPLOY_SSH_USER)@$(DEPLOY_SSH_HOST) "docker load -i $(DEPLOY_TAR_PATH)"
