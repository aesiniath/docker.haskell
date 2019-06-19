#! /usr/bin/env sh

RESOLVER="$1"

docker build \
	--build-arg RESOLVER="$RESOLVER" \
	--tag=oprdyn/haskell:"$RESOLVER" \
	--network=proxy \
	--force-rm=true \
	.

