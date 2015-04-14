#!/bin/bash -e

go get github.com/tools/godep

# Clone "metral/corekube" just to have access to latest corekube-heat.yaml Heat
# template. The tests in "metral/corekube_travis" below use the template to
# deploy a new cluster by overwriting the template's git-command parameter
# to either the PR or commit in the TravisCI environment. The overlord code in
# this build is not used as the code is pulled by corekube itself during
# deployment.
git clone https://github.com/metral/corekube $HOME/corekube
pushd $HOME/corekube
echo "corekube commit: `git rev-parse --short HEAD`"
popd

mkdir -p /tmp/
cp $HOME/gopath/src/github.com/metral/overlord/conf.json /tmp/

# Clone the tests which live in "metral/corekube_travis" and use
# "metral/corekube" Heat template to deploy a cluster, but not before the tests
# overwrite the git-command parameter and tailor it to either the PR or commit
# for overlord to use that in the deployment. The overlord code in 
# this build is not used as the code is pulled by corekube itself during
# deployment.
git clone https://github.com/metral/corekube_travis
pushd corekube_travis/overlord_test
echo "corekube_travis commit: `git rev-parse --short HEAD`"
godep get ./...
popd
