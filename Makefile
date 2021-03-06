DOCKER_HUB_REPO := zshusers/zsh-$${VERSION\#zsh-}
DOCKER_HUB_TAG ?= latest

require-%:
	@: $(if $(${*}),,$(error $* variable must be set))

build: require-DOCKER_HUB_REPO require-DOCKER_HUB_TAG require-VERSION
	docker build --tag $(DOCKER_HUB_REPO):$(DOCKER_HUB_TAG) \
	             --squash \
	             --build-arg url=https://api.github.com/repos/zsh-users/zsh/tarball/$(VERSION) \
	             .

deploy: require-DOCKER_HUB_REPO require-DOCKER_HUB_TAG require-DOCKER_HUB_USER require-DOCKER_HUB_PASS
	docker login -u $(DOCKER_HUB_USER) -p $(DOCKER_HUB_PASS)
	docker push $(DOCKER_HUB_REPO):$(DOCKER_HUB_TAG)
