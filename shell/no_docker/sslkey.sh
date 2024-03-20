#!/bin/bash
cd `dirname $0`
docker info >/dev/nul 2>&1
if [ "$?" != "0" ]
then
  echo "you must install docker and start it"
  exit 0
else
  if [ `docker version |grep Version |head -1|awk '{print $2}'|sed "s/\.*//g"` -ge 19038 ]
  then
    echo "Environment detection succeeded"
  else
    echo "WARN: Your docker is below 19.03.8. It may cause deployment failure. It is recommended to upgrade to 19.03.8 and later"
  fi
fi

case "$1" in
    -h|--help|?)
    echo "if not docker "
    echo "Usage: 1st arg:config name, for example:hosts"
    echo "Usage: $0 hosts"
    exit 0
;;
esac

if [ ! -n "$1" ]; then
    echo "pls input 1st arg"
    echo "Usage: $0 -h|--help|?"
    exit 0
fi

tty >/dev/nul
if [ "$?" == "0" ]
then
tty=t
else
tty=
fi

docker_basedir=`grep "docker_basedir" $1|awk -F = '{print $2}'`

/opt/docker_bin/docker -H unix:///opt/docker_bin/run/docker.sock run --network host --name ansible_${RANDOM} -e ANSIBLE_SSH_CONTROL_PATH=/dev/shm/ssh_ctl_%%h_%%p_%%r --rm -v `pwd`:$docker_basedir -w $docker_basedir -i$tty congcong126/ansible:2.9.18 ansible-playbook -f 5 --ssh-common-args="$ANSIBLE_SSH_COMMON_ARGS" -i $1 app_install/sslkey.yml --extra-vars "ins=$2"
