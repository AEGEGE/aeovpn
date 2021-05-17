#!/bin/bash
cd `dirname $0`

bash ./initialize_docker.sh

tty >/dev/nul
if [ "$?" == "0" ]
then
tty=t
else
tty=
fi

docker run --network host --name ansible -e ANSIBLE_SSH_CONTROL_PATH=/dev/shm/ssh_ctl_%%h_%%p_%%r --rm -v `pwd`:/bmsk -w /bmsk -i$tty ansible ansible-playbook -f 3 --ssh-common-args="$ANSIBLE_SSH_COMMON_ARGS" -i $1 app_install/ldap.yml
