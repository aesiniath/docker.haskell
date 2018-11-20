docker run --rm=true oprdyn/debian:stretch cat /.stamp > .base
touch -d`cat .base` .base
if [ .base -nt .stamp ] ; then
	date -u +%FT%TZ > .stamp
fi

docker build \
	--tag=oprdyn/haskell:lts-12.18 \
	--network=proxy \
	--force-rm=true \
	.

