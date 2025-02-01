FROM ubuntu:latest AS builder

RUN apt-get update \
    && apt-get install -y \
    openssl tar git gzip zip unzip curl \
    && apt clean all \
    && rm -rf /var/cache/apt

ARG HELMFILE_VERSION
RUN curl -L -o /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_linux_amd64 -k \
    && chmod +x /usr/local/bin/helmfile

ARG HELM_VERSION
RUN curl -OL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -k \
    && chmod +x helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && tar xpf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && chmod +x linux-amd64/helm \
    && cp -p linux-amd64/helm /usr/local/bin/ \
    && rm -f helm-v${HELM_VERSION}-linux-amd64.tar.gz

ARG SOPS_VERSION
RUN curl -L -o /usr/local/bin/sops https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux -k \
    && chmod +x /usr/local/bin/sops

RUN curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh -k | bash

ARG KUBECTL_VERSION
RUN curl -L -o /usr/local/bin/kubectl https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -k \
    && chmod +x /usr/local/bin/kubectl

ARG TERRAFORM_VERSION
RUN curl -OL https://hashicorp-releases.yandexcloud.net/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && chmod +x terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/terraform \
    && rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

ARG HELMSMAN_APP_VERSION
RUN curl -OL https://github.com/Praqma/helmsman/releases/download/v${HELMSMAN_APP_VERSION}/helmsman_${HELMSMAN_APP_VERSION}_linux_amd64.tar.gz -k \
    && ls -la \
    && tar xpf helmsman_3.17.1_linux_amd64.tar.gz \
    && chmod +x helmsman \
    && cp -p helmsman /usr/local/bin/ \
    && rm -f helmsman_3.17.1_linux_amd64.tar.gz

FROM alpine:3.20.0

RUN apk --no-cache add git openssh-client gettext \
    tar gzip bash curl jq yq

RUN mkdir -p ~/.ssh

COPY --from=builder \
    /usr/local/bin/helmfile \
    /linux-amd64/helm \
    /usr/local/bin/sops \
    /root/yandex-cloud/bin/yc \
    /usr/local/bin/kubectl \
    /usr/local/bin/terraform \
    /usr/local/bin/helmsman \
    /usr/local/bin/

ARG HELM_DIFF \
    HELM_GIT \
    HELM_S3 \
    HELM_SECRETS

RUN /usr/local/bin/helm plugin install https://github.com/databus23/helm-diff --version=${HELM_DIFF} \
    && /usr/local/bin/helm plugin install https://github.com/aslafy-z/helm-git --version=${HELM_GIT} \
    && /usr/local/bin/helm plugin install https://github.com/hypnoglow/helm-s3.git --version=${HELM_S3} \
    && /usr/local/bin/helm plugin install https://github.com/jkroepke/helm-secrets --version v${HELM_SECRETS}

ENV PATH="/usr/local/bin:${PATH}"

CMD ["/bin/bash"]