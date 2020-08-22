FROM docker.io/aesiniath/debian:buster

#
# Install wget (and certificates so https works) and the list of dependencies
# specified by the get_stack.sh script. And netbase, because who knew you needed
# to enable networking to get **http-client** to work. Da fu?
#

RUN apt-get update \
 && apt-get install --no-install-recommends --assume-yes \
	wget ca-certificates \
	g++ gcc libc6-dev libffi-dev libgmp-dev make xz-utils zlib1g-dev git gnupg \
	netbase liblzma-dev libssl-dev \
 && apt-get clean

#
# Download the latest stack binary and put it in /usr/local/bin. Originally
# this went through <https://get.haskellstack.org/stable/linux-x86_64.tar.gz>,
# but knowing exactly what binary is being used to bootstrap is not
# the worst thing.
#

RUN wget -q -O - https://github.com/commercialhaskell/stack/releases/download/v2.3.3/stack-2.3.3-linux-x86_64.tar.gz \
	| tar -x -z -C /usr/local/bin --strip-components=1 --wildcards '*stack'

#
# Download latest snapshot and install its compiler. By *not* specifying the
# snapshot the default latest will be plonked in /root/.stack/global-project
# and that will send in a compiler. If later RUN command specifies a snapshot
# that includes a newer compiler, then just nuke the docker image and redo.
# Otherwise you'll be redownloading the compiler every single time you build
# that layer.
#

ADD files/root/. /root
ADD files/usr/local/bin/. /usr/local/bin

RUN wget -q -O - https://github.com/commercialhaskell/stackage-content/raw/master/stack/stack-setup-2.yaml \
	| patch-setup > /root/setup-info.yaml

ARG RESOLVER
RUN stack setup --resolver=$RESOLVER --setup-info-yaml=/root/setup-info.yaml \
 && cleanup

RUN stack update --resolver=$RESOLVER \
 && cleanup

#
# Now customize the snapshot and start downloading packages. The resolver is
# specified here as with the other layers, but the the list of dependencies to
# be built (and thus cached in the Docker image) are in listed in
# files/src/baselines/package.yaml.
#

WORKDIR /src/baseline
ADD files/src/ /src/
RUN stack build --resolver=$RESOLVER \
 && cleanup
