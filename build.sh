#!/bin/bash

__push__="$1"

# Pull alpine to get newest security updates
docker pull alpine:3.14
docker pull debian:buster-slim

for VERSION in $(cat tags.txt); do
    docker build --build-arg "ZEEK_VERSION=v$VERSION" -t "uhhiss/zeek-docker:$VERSION-alpine" -f Dockerfile.alpine .
    docker build --build-arg "ZEEK_VERSION=v$VERSION" -t "uhhiss/zeek-docker:$VERSION-debian" -f Dockerfile.debian .
    docker tag "uhhiss/zeek-docker:$VERSION-debian" "uhhiss/zeek-docker:$VERSION"
    if [ "$__push__" == "push" ]; then
        docker push "uhhiss/zeek-docker:$VERSION-alpine"
        docker push "uhhiss/zeek-docker:$VERSION-debian"
        docker push "uhhiss/zeek-docker:$VERSION"
    fi
done

# Also tag latest
docker tag "uhhiss/zeek-docker:$VERSION-debian" "uhhiss/zeek-docker:latest"
if [ "$__push__" == "push" ]; then
    docker push uhhiss/zeek-docker:latest
fi
