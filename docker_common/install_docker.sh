#!/bin/sh
export PATH=$PATH:/opt/docker_bin/

cd `dirname $0`
dir=`pwd`
mkdir -pv /opt/docker_bin/run
cp daemon.json /opt/docker_bin/

tar -xf ../pkg/docker.tgz -C /opt/docker_bin
/opt/docker_bin/dockerd --config-file=/opt/docker_bin/daemon.json >/dev/nul 2>&1 &
