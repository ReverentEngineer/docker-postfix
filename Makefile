DOCKER_TAG=reverentengineer/postfix

build:
	docker build -t $(DOCKER_TAG) .

deploy:
	docker push $(DOCKER_TAG)
