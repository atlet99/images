FROM debian:bookworm-20250113 AS builder

ARG NGINX_VERSION
ARG OPENSSL_VERSION

RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    gcc \
    make \
    wget \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && apt clean all

WORKDIR /usr/src

RUN curl -OL https://github.com/nginx/nginx/releases/download/release-${NGINX_VERSION}/nginx-${NGINX_VERSION}.tar.gz -k && \
    curl -OL https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz -k && \
    tar xzf nginx-${NGINX_VERSION}.tar.gz && \
    tar xzf openssl-${OPENSSL_VERSION}.tar.gz

WORKDIR /usr/src/openssl-${OPENSSL_VERSION}

RUN ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl no-shared && \
    make -j$(nproc) && \
    make install_sw

WORKDIR /usr/src/nginx-${NGINX_VERSION}

RUN ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/var/run/nginx.pid \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_gzip_static_module \
    --with-cc-opt="-I/usr/local/ssl/include" \
    --with-ld-opt="-L/usr/local/ssl/lib -Wl,-rpath,/usr/local/ssl/lib" \
    --with-openssl=/usr/src/openssl-${OPENSSL_VERSION} \
    && make -j$(nproc) \
    && make install

FROM debian:bookworm-20250113-slim

RUN apt-get update && apt-get install -y \
    libpcre3 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/ssl /usr/local/ssl
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx

ENV LD_LIBRARY_PATH="/usr/local/ssl/lib"
ENV PATH="/usr/local/ssl/bin:$PATH"

RUN mkdir -p /var/cache/nginx /var/log/nginx /var/run

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]