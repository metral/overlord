#!/bin/bash

set -e

source /run/discovery_ip_port

if docker ps | grep -q overlord; then
  docker rm -f overlord
fi

function seen_exists() {
  if etcdctl --endpoint="${DISCOVERY_IP_PORT}" ls | grep --quiet /seen; then
    return 0
  else
    return 1
  fi
}

if seen_exists; then
  etcdctl --endpoint="${DISCOVERY_IP_PORT}" rm seen
  etcdctl --endpoint="${DISCOVERY_IP_PORT}" rm --recursive /registry
  sleep 3
  if seen_exists; then
    echo "etcdctl \"seen\" keys still exist"
    exit 1
  fi
fi

fleetctl list-units | awk '{print $1}' | grep -v UNIT | xargs fleetctl destroy
sleep 3

if [ $(fleetctl list-units | wc -l) -gt 1 ]; then
  echo "Some fleet units still exist"
  exit 1
fi

pushd /root/overlord
echo "Building overlord image, this could take a while..."
./build_run.sh >/dev/null
popd

echo "Complete! Monitor overlord status via \"docker logs overlord\" and wait until its complete"
