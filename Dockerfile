FROM alpine:3.11 AS builder

RUN echo "===> Installing build dependencies..." \
    && apk add --no-cache bash ca-certificates libstdc++ python3 bsd-compat-headers \
    openssl libpcap zlib flex bison swig \
    make cmake g++ \
    linux-headers python3-dev openssl-dev libpcap-dev zlib-dev flex-dev fts-dev \
    git

ARG ZEEK_VERSION=v3.1.3

RUN echo "===> Cloning zeek..." \
    && git clone --single-branch --branch "$ZEEK_VERSION" --recurse-submodules https://github.com/zeek/zeek.git /tmp/zeek

RUN echo "===> Building & installing zeek..." \
    && cd /tmp/zeek \
    && ./configure --disable-python \
    && make -j2 \
    && make test \
    && make install

FROM alpine:3.11

LABEL Maintainer="{haas,wilkens}@informatik.uni-hamburg.de"

RUN echo "===> Installing runtime dependencies..." \
    && apk add --no-cache bash git ca-certificates python3 py3-pip libstdc++ openssl libpcap zlib

# Copy zeek from builder
COPY --from=builder /usr/local/zeek /usr/local/zeek

# Copy config file for zkg (and force zkg to use it)
COPY zkg.conf /usr/local/zeek/zkg/config
ENV ZKG_CONFIG_FILE /usr/local/zeek/zkg/config

RUN echo "===> Installing zkg..." \
    && pip3 install setuptools wheel zkg

# Volume for logs
VOLUME /usr/local/zeek/logs

WORKDIR /usr/local/zeek
ENTRYPOINT [ "./bin/zeek" ]
