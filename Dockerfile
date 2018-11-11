FROM localhost/afcowie/debian:stretch
COPY .stamp /

RUN apt-get install wget ca-certificates

RUN wget -q -O - https://get.haskellstack.org/ > get-stack.sh

RUN sh get-stack.sh
