FROM localhost/afcowie/debian:stretch
COPY .stamp /

#
# Install wget (and certificates so https works) and the list of dependencies
# specified by the get_stack.sh script. And netbase, because who knew you needed
# to enable networking to get **http-client** to work. Da fu?
#

RUN apt-get install \
	wget ca-certificates \
	g++ gcc libc6-dev libffi-dev libgmp-dev make xz-utils zlib1g-dev git gnupg \
	netbase

#
# Download the latest stack binary and put it in /usr/local/bin
#

RUN wget -q -O - https://get.haskellstack.org/stable/linux-x86_64.tar.gz | \
	tar -x -z -C /usr/local/bin --strip-components=1 --wildcards '*stack'

#
# Download latest snapshot and install its compiler. By *not* specifying the
# snapshot the default latest will be plonked in /root/.stack/global-project
# and that will send in a compiler. If later RUN command specifies a snapshot
# that includes a newer compiler, then just nuke the .stamp and redo this.
# Otherwise you'll be redownloading the compiler every single time you build
# that layer.
#
# TODO this is *insanely* heavy weight. Current compiler download is 144 MB. We
# need to inject this from a local cache somehow.
# 

ADD files/root/. /root
ADD files/usr/local/bin/cleanup /usr/local/bin

RUN stack setup --resolver=lts-12.18 \
 && cleanup

RUN stack update --resolver=lts-12.18 \
 && cleanup

#
# Now customize the snapshot and start downloading packages. The resolver is
# specified in files/src/stack.yaml, and the list of dependencies to be built
# (and thus cached in the Docker image) are in package.yaml.
#

WORKDIR /src/baseline
ADD files/src/ /src/
RUN stack build --resolver=lts-12.18 \
 && cleanup
