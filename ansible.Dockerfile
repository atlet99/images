# Use the latest stable Alpine image
FROM alpine:3.21.2

# Set the working directory for Ansible
WORKDIR /ansible

# Set default arguments for versions
ARG ANSIBLE_CORE_VERSION=2.16.11
ARG ANSIBLE_VERSION=9.6.1
ARG ANSIBLE_LINT_VERSION=24.12.2

# Disable pip cache
ENV PIP_NO_CACHE_DIR=1

# Disable root user warining for pip
ENV PIP_ROOT_USER_ACTION=ignore

# Global packages for components
ENV BUILD_PACKAGES="cargo build-base libffi-dev openssl-dev python3-dev py3-pip"
ENV RUN_PACKAGES="ca-certificates openssl openssh-client python3 sshpass git rsync"

# Generated requirements file
COPY requirements.txt .

# Set labels for the Docker image
LABEL maintainer="pachman17@yandex.ru" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="atlet99/ansible" \
    org.label-schema.description="Run Ansible within Docker" \
    org.label-schema.url="https://github.com/atlet99/ansible-inside-docker" \
    org.label-schema.vcs-url="https://github.com/atlet99/ansible-inside-docker" \
    org.label-schema.vendor="Zhakhongir (atlet99) Rakhmankulov"

# Update image packages
RUN apk --no-cache update && \
    apk --no-cache upgrade -a

# Install only essential packages
RUN apk --no-cache add --virtual build-dependencies ${BUILD_PACKAGES} && \
    apk --no-cache add ${RUN_PACKAGES} && \
    python3 -m pip install --no-cache-dir --upgrade pip --break-system-packages && \
    pip3 install --no-cache-dir --upgrade wheel --break-system-packages && \
    pip3 install --no-cache-dir --upgrade cryptography cffi certifi --break-system-packages && \
    pip3 install --no-cache-dir ansible==${ANSIBLE_VERSION} --break-system-packages && \
    pip3 install --no-cache-dir ansible-lint==${ANSIBLE_LINT_VERSION} --break-system-packages && \
    pip3 install --no-cache-dir --upgrade pywinrm --break-system-packages && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache/pip && \
    find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
    find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf && \
    rm -rf /root/.cargo

# Prepare default Ansible directory structure
RUN mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

# Default command for the container
CMD [ "ansible-playbook", "--version" ]