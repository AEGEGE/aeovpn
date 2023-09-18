#!/bin/bash
case "$1" in
    -h|--help|?)
    echo "Usage: 1st arg:config name, for example:hosts"
    echo "Usage: $0 hosts"
    exit 0
;;
esac

if [ ! -n "$1" ]; then
    echo "pls input 1st arg"
    echo "Usage: $0 -h|--help|?"
    exit
fi

cd `dirname $0`

bash ./initialize_docker.sh $1

tty >/dev/nul
if [ "$?" == "0" ]
then
tty=t
else
tty=
fi

docker_basedir=`grep "docker_basedir" $1|awk -F = '{print $2}'`

/opt/docker_bin/docker -H unix:///opt/docker_bin/run/docker.sock  run --network host --name ansible_${RANDOM} -e ANSIBLE_SSH_CONTROL_PATH=/dev/shm/ssh_ctl_%%h_%%p_%%r --rm -v `pwd`:$docker_basedir -w $docker_basedir -i$tty congcong126/ansible:2.9.18 ansible-playbook -f 10 --ssh-common-args="$ANSIBLE_SSH_COMMON_ARGS" -i $1 system_init/hosts.yml
