# Custom Docker Images

This repository contains Dockerfiles for building custom Docker images tailored for DevOps tools such as Ansible, Kaniko, Nginx and a deployer image with Terraform and other deployment utilities. These images are crafted to streamline automation and deployment workflows while ensuring consistency and security across various environments.

## Table of Contents
- [Custom Docker Images for Ansible, Kaniko, and Deployer](#custom-docker-images-for-ansible-kaniko-and-deployer)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Building Images with buildx](#building-images-with-buildx)
    - [Building Images Locally with Makefile](#building-images-locally-with-makefile)
  - [License](#license)

## Overview

The Dockerfiles included in this project allow you to build custom images for various DevOps tools:

* ***Ansible Image:*** a containerized environment for running Ansible;
* ***Kaniko Image:*** a container for building Docker images without requiring a Docker daemon;
* ***Deployer Image:*** a deployment-focused image containing Terraform, Helm, SOPS, and Kubernetes CLI tools;
* ***Nginx Image:*** a lightweight and high-performance containerized web server designed for serving static content, reverse proxying, load balancing, and caching.

## Getting started

### Prerequisites

Ensure Docker with buildx support is installed on your system. Follow the [Docker installation guide](https://docs.docker.com/engine/install/) if buildx isn’t enabled by default. Also you can setting up shell completion for Docker CLI via [Docker Completion Guide](https://docs.docker.com/engine/cli/completion/).

### Building Images with buildx

To use `buildx` for building these images, create a builder instance if necessary:
```bash
docker buildx create --use
```
You can now build each image with appropriate build arguments:
```bash
# Build Ansible image
docker buildx build \
  --build-arg ANSIBLE_CORE_VERSION=2.16.4 \
  --build-arg ANSIBLE_VERSION=9.2.0 \
  --build-arg ANSIBLE_LINT=6.22.2 \
  -t ansible:stable \
  -f ansible.Dockerfile \
  --push .

# Build Kaniko image
docker buildx build \
  -t kaniko:stable \
  -f kaniko.Dockerfile \
  --push .

# Build Deployer image
docker buildx build \
  --build-arg HELMFILE_VERSION=0.147.0 \
  --build-arg HELM_VERSION=3.12.0 \
  --build-arg SOPS_VERSION=3.7.3 \
  --build-arg KUBECTL_VERSION=1.26.3 \
  --build-arg TERRAFORM_VERSION=1.5.3 \
  --build-arg HELMSMAN_APP_VERSION=3.17.0 \
  --build-arg HELM_DIFF=3.6.0 \               
  --build-arg HELM_GIT=0.10.0 \               
  --build-arg HELM_S3=0.11.0 \                
  --build-arg HELM_SECRETS=4.0.0 \
  -t deployer:stable \
  -f deployer.Dockerfile \
  --push .
 
# Build Nginx image
docker buildx build \
  --build-arg NGINX_VERSION=1.27.3 \
  --build-arg OPENSSL_VERSION=3.4.0 \
  -t nginx:stable \
  -f nginx.Dockerfile \
  --push .
```

### Building Images Locally with Makefile

A `Makefile` is provided to simplify local builds. It extracts version variables from `.gitlab-ci.yml` and uses them in Docker builds automatically. To build images locally, run:

```bash
make deployer   # Build deployer image
make nginx      # Build Nginx image
make kaniko     # Build Kaniko image
make all        # Build all images
make print-vars # Print all variables
```

To verify extracted variables, use:
```bash
make print-vars
```
This will print the parsed version numbers used in the builds.

## License

This project is licensed under the [MIT License](LICENSE).
