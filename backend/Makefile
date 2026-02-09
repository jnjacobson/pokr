#!make

-include .env

ifeq ($(strip $(DEPLOY_SSH_PORT)),)
DEPLOY_SSH_PORT := 22
endif

production:
	rm -fv pokr-backend.tar
	docker build -f docker/Dockerfile -t pokr-backend:latest .
	docker save -o pokr-backend.tar pokr-backend:latest

production-remote:
	@test -n "$(DEPLOY_SSH_USER)" || (echo "DEPLOY_SSH_USER not set in .env" && exit 1)
	@test -n "$(DEPLOY_SSH_HOST)" || (echo "DEPLOY_SSH_HOST not set in .env" && exit 1)
	docker buildx create --driver docker-container --name amd64builder --use ssh://$(DEPLOY_SSH_USER)@$(DEPLOY_SSH_HOST) || true
	docker buildx inspect --bootstrap
	docker buildx build --builder amd64builder --platform linux/amd64 -f docker/Dockerfile -t pokr-backend:latest --load .
	docker save -o pokr-backend.tar pokr-backend:latest
