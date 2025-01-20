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

# Install Python and build dependencies
RUN apk --no-cache add \
        sudo \
        python3 \
        py3-pip \
        python3-dev \
        openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        rsync \
        git && \
    apk --no-cache add --virtual build-dependencies \
        gcc \
        musl-dev \
        libffi-dev \
        python3-dev \
        cargo \
        build-base && \
    rm -rf /usr/lib/python3.11/EXTERNALLY-MANAGED && \

# Create and activate a Python virtual environment
RUN python3 -m venv /venv && \
    . /venv/bin/activate && \
    pip install --upgrade pip wheel && \
    pip install \
        ansible-core==${ANSIBLE_CORE_VERSION} \
        ansible==${ANSIBLE_VERSION} \
        ansible-lint==${ANSIBLE_LINT_VERSION} \
        ansible-compat==24.10.0 \
        attrs==24.2.0 \
        bcrypt==4.2.1 \
        black==24.10.0 \
        bracex==2.5.post1 \
        cryptography==43.0.1 \
        cffi==1.17.1 \
        certifi==2024.8.30 \
        charset-normalizer==3.4.0 \
        click==8.1.8 \
        decorator==5.1.1 \
        dogpile.cache==1.3.3 \
        filelock==3.16.1 \
        idna==3.10 \
        importlib_metadata==8.5.0 \
        iso8601==2.1.0 \
        Jinja2==3.1.4 \
        jmespath==1.0.1 \
        jsonpatch==1.33 \
        jsonpointer==3.0.0 \
        jsonschema==4.22.0 \
        jsonschema-specifications==2023.12.1 \
        keystoneauth1==5.8.0 \
        MarkupSafe==2.1.5 \
        mypy-extensions==1.0.0 \
        netaddr==1.3.0 \
        netifaces==0.11.0 \
        openstacksdk==4.1.0 \
        os-service-types==1.7.0 \
        packaging==24.1 \
        pathspec==0.12.1 \
        pbr==6.1.0 \
        platformdirs==4.3.6 \
        pycparser==2.22 \
        pytz==2024.2 \
        PyYAML==6.0.2 \
        referencing==0.35.1 \
        requests==2.32.3 \
        requestsexceptions==1.4.0 \
        resolvelib==1.0.1 \
        rpds-py==0.20.0 \
        ruamel.yaml==0.18.7 \
        stevedore==5.3.0 \
        subprocess-tee==0.4.2 \
        urllib3==2.2.3 \
        wcmatch==10.0 \
        yamllint==1.35.1 \
        zipp==3.21.0 && \
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