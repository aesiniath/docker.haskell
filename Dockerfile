FROM localhost/afcowie/debian:stretch
COPY .stamp /

#
# Install wget (and certificates so https works) and the list of dependencies
# specified by the get_stack.sh script.
#

RUN apt-get install \
	wget ca-certificates \
	g++ gcc libc6-dev libffi-dev libgmp-dev make xz-utils zlib1g-dev git gnupg

#
# Download the latest stack binary and put it in /usr/local/bin
#

RUN wget -q -O - https://get.haskellstack.org/stable/linux-x86_64.tar.gz | \
	tar -x -z -C /usr/local/bin --strip-components=1 --wildcards '*stack'

