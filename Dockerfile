FROM google/golang:1.4

RUN apt-get update -y
RUN apt-get install net-tools -y
RUN go get github.com/tools/godep

WORKDIR /gopath/src/github.com/metral/overlord
ADD . /gopath/src/github.com/metral/overlord/
RUN godep get ./...

CMD []
ENTRYPOINT ["/gopath/bin/overlord"]
