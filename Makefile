NAME := doh
SPACE_NAME := sbriskin
IMAGE_NAME := $(SPACE_NAME)/$(NAME)
TAG := $(shell date +%y).$(shell date +%m)
PORT := 8843

.PHONY: help build push clean run test kill

help:
	@printf "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\ \1\ :\2/' | column -c2 -t -s :)\n"

build: ## Builds docker image latest
	docker build --pull -t $(IMAGE_NAME):$(TAG) .
	docker tag $(IMAGE_NAME):$(TAG) $(IMAGE_NAME):latest

push: ## Pushes the docker image to docker.io
	# Don't --pull here, we don't want any last minute upsteam changes
	docker build -t $(IMAGE_NAME):$(TAG) .
	docker tag $(IMAGE_NAME):$(TAG) $(IMAGE_NAME):latest
	docker push $(IMAGE_NAME):$(TAG)
	docker push $(IMAGE_NAME):latest

clean: ## Remove built images
	docker rmi $(IMAGE_NAME):$(TAG)
	docker rmi $(IMAGE_NAME):latest

run: ## Run container
	docker run --name $(NAME) --restart always -d -p ${PORT}:443 $(IMAGE_NAME):$(TAG)

test: ## Test connection
	curl http://localhost:${PORT}/dns-query?name=docker.com&type=A

kill: ## Stop and remove container
	docker kill $(NAME)
	docker rm $(NAME)

