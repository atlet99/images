FROM alpine:3.19.1

ARG ANSIBLE_CORE_VERSION=2.16.4
ARG ANSIBLE_VERSION=9.2.0
ARG ANSIBLE_LINT=6.22.2

LABEL maintainer="pachman17@yandex.ru" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="atlet99/ansible" \
    org.label-schema.description="Run Ansible within Docker" \
    org.label-schema.url="https://github.com/atlet99/ansible-inside-docker" \
    org.label-schema.vcs-url="https://github.com/atlet99/ansible-inside-docker" \
    org.label-schema.vendor="Zhakhongir (atlet99) Rakhmankulov"

RUN apk --no-cache add \
        sudo \
        python3 \
        py3-pip \
        openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        rsync \
        git && \
    apk --no-cache add --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        musl-dev \
        gcc \
        cargo \
        build-base && \
    rm -rf /usr/lib/python3.11/EXTERNALLY-MANAGED && \
    pip3 install --upgrade pip wheel && \
    pip3 install --upgrade cryptography cffi && \
    pip3 install ansible-core==${ANSIBLE_CORE_VERSION} && \
    pip3 install ansible==${ANSIBLE_VERSION} && \
    pip3 install --ignore-installed ansible-lint==${ANSIBLE_LINT} && \
    pip3 install mitogen jmespath && \
    pip3 install --upgrade pywinrm && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache/pip && \
    rm -rf /root/.cargo

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--help" ]