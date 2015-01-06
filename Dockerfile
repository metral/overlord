FROM google/golang:stable

RUN apt-get update -y
RUN apt-get install net-tools -y
RUN go get github.com/tools/godep

WORKDIR /gopath/src/github.com/metral/overlord
ADD . /gopath/src/github.com/metral/overlord/
RUN godep restore
RUN go get ./...

CMD []
ENTRYPOINT ["/gopath/bin/overlord"]
