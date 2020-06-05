#!/bin/bash

__push__="$1"

# Pull alpine to get newest security updates
docker pull alpine:3.11

# Build tags for version 3.x.y
for TAG in $(cat tags.txt); do
    docker build --build-arg "ZEEK_VERSION=v$TAG" -t "uhhiss/zeek-docker:$TAG" -f Dockerfile .
    if [ "$__push__" == "push" ]; then
        docker push "uhhiss/zeek-docker:$TAG"
    fi
done

# Also tag latest
docker tag "uhhiss/zeek-docker:$TAG" "uhhiss/zeek-docker:latest"
if [ "$__push__" == "push" ]; then
    docker push uhhiss/broker-docker:latest
fi
