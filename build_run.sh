#!/bin/bash

docker rm -f overlord
DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

result=`docker build --rm -t overlord $DIR/.`
echo "$result"

echo ""
echo "=========================================================="
echo ""

build_status=`echo $result | grep "Successfully built"`

if [ "$build_status" ] ; then
    docker run --name overlord -d -v /tmp:/units -v $DIR/conf.json:/tmp/conf.json -v $DIR/unit_templates:/templates overlord
fi
