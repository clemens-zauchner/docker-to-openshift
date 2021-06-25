# docker-to-openshift

This repository provides a utility wrapper script for the [kompose]([https://kompose.io/)
tool and examples of Docker Compose YAML files and the corresponding OpenShift files. 
The aim is to make the transition from Docker to OpenShift easier. 

## convert.sh

The basic usege would be:

Usage: convert.sh [OPTIONS]

Options:
	-c	Path to look for Docker Compose / Swarm YAML files
	-o	Path to save OpenShift YAML files to. Default is ./openshift
	-h	Show usage

## flask example

The example in `flask` comes from [awesome-compose](https://github.com/docker/awesome-compose/). 
The Dockerfile is modified slightly to ensure it can be build by [Buildah](https://github.com/containers/buildah)
(the build tool of podman and OpenShift).

The `yaml` files in `openshift` have been generated using the `convert.sh` script:

```bash
cd flask
../convert.sh -f . 
```

The docker compose version can be used with the command

```bash
docker-compose -f flask/docker-compose.yaml up -d
```

This will trigger the image build and start the flask container that returns `Hello World!` on port `5000`.

In OpenShift, the application can be deployed using `oc apply` using the files from this repo:

```bash
oc apply -f https://raw.githubusercontent.com/clemens-zauchner/docker-to-openshift/main/openshift/web-buildconfig.yaml \
	-f https://raw.githubusercontent.com/clemens-zauchner/docker-to-openshift/main/openshift/web-deploymentconfig.yaml \
	-f https://raw.githubusercontent.com/clemens-zauchner/docker-to-openshift/main/openshift/web-imagestream.yaml \
	-f https://raw.githubusercontent.com/clemens-zauchner/docker-to-openshift/main/openshift/web-service.yaml
```



