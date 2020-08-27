DOCKER_IMAGE_NAME=apply-ops-dashboard

.PHONY: help
help: ## Shows the help menu
	@grep -E '^[a-zA-Z\.\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## builds the docker image
	docker build -t $(DOCKER_IMAGE_NAME) .

.PHONY: start
start: ## starts the container
	docker image inspect $(DOCKER_IMAGE_NAME) 1> /dev/null || make build
	docker run -it -p 5000:5000 --env-file ./.env --rm $(DOCKER_IMAGE_NAME)

.PHONY: start-docker-dev
start-docker-dev: ## starts the dev container
	docker run -it -p 5000:5000 \
	 -v $(CURDIR):/app \
	 -v /app/vendor \
	 --rm $(DOCKER_IMAGE_NAME)

.PHONY: start-dev
start-dev: ##	starts the dev server
	bundle exec rackup --host 0.0.0.0 -p 5000
