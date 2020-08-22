#! /usr/bin/env sh

RESOLVER="$1"

podman build \
	--build-arg RESOLVER="$RESOLVER" \
	--tag=docker.io/aesiniath/haskell:"$RESOLVER" \
	--force-rm=true \
	.

