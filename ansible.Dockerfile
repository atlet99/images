# Use the latest stable Alpine image
FROM alpine:3.21.2

# Set default arguments for versions
ARG ANSIBLE_CORE_VERSION=2.16.11
ARG ANSIBLE_VERSION=9.6.1
ARG ANSIBLE_LINT_VERSION=24.12.2

# Set labels for the Docker image
LABEL maintainer="pachman17@yandex.ru" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="atlet99/ansible" \
    org.label-schema.description="Run Ansible within Docker" \
    org.label-schema.url="https://github.com/atlet99/ansible-inside-docker" \
    org.label-schema.vcs-url="https://github.com/atlet99/ansible-inside-docker" \
    org.label-schema.vendor="Zhakhongir (atlet99) Rakhmankulov"

# Install system dependencies and Python build tools
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
    rm -rf /usr/lib/python3.11/EXTERNALLY-MANAGED

# Upgrade pip and install Python dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --upgrade pip wheel && \
    pip3 install --upgrade cryptography cffi && \
    pip3 install -r /tmp/requirements.txt && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* /root/.cache/pip /root/.cargo

# Prepare default Ansible directory structure
RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

# Set the working directory for Ansible
WORKDIR /ansible

# Default command for the container
CMD [ "ansible-playbook", "--help" ]