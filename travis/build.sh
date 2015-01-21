#!/bin/bash -e

go get github.com/tools/godep

git clone https://github.com/metral/corekube $HOME/corekube

git clone https://github.com/metral/corekube_travis
pushd corekube_travis/overlord_test
godep get ./...
popd
