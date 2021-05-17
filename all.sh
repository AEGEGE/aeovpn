#!/bin/bash
#all install
sh -x ssh.sh $1
sh -x hosts.sh $1
sh -x system_init.sh $1
sh -x install_docker.sh $1
sh -x users.sh $1
sh -x rke.sh $1
sh -x rancher.sh $1
sh -x mariadb-client.sh $1
