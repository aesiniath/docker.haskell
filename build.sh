docker run --rm=true localhost/afcowie/debian:stretch cat /.stamp > .base
if [ .base -nt .stamp ] ; then
	date -u +%FT%TZ > .stamp
fi

docker build \
	--tag=localhost/afcowie/haskell:latest \
	--network=proxy \
	.
