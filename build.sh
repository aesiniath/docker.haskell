if [ ! -f .stamp ] ; then
	date -u +%FT%TZ > .stamp
fi

docker build \
	--tag=localhost/afcowie/haskell:latest \
	--network=proxy \
	.
