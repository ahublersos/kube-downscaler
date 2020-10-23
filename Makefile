.PHONY: test docker push

IMAGE            ?= 467536752717.dkr.ecr.us-east-1.amazonaws.com/kube-downscaler
VERSION          ?= $(shell git describe --tags --always --dirty)
TAG              ?= $(VERSION)

default: docker

.PHONY: install
install:
	poetry install

.PHONY: lint
lint: install
	poetry run pre-commit run --all-files


test: lint install
	poetry run coverage run --source=kube_downscaler -m py.test -v
	poetry run coverage report

version:
	sed -i.bak "s/version: v.*/version: v$(VERSION)/" deploy/*.yaml && rm deploy/*.bak
	sed -i.bak "s/kube-downscaler:.*/kube-downscaler:$(VERSION)/" deploy/*.yaml && rm deploy/*.bak

docker:
	docker build --build-arg "VERSION=$(VERSION)" -t "$(IMAGE):$(TAG)" .
	@echo 'Docker image $(IMAGE):$(TAG) can now be used.'

#push: docker
#	docker push "$(IMAGE):$(TAG)"
#	docker tag "$(IMAGE):$(TAG)" "$(IMAGE):latest"
#	docker push "$(IMAGE):latest"
