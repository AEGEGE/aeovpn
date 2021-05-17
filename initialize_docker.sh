#!/bin/bash
#disable selinux
grep "SELINUX=enforcing" /etc/selinux/config
if [ "$?" == "0" ]
then
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
/usr/sbin/setenforce 0
fi

cd `dirname $0`

docker_bip=`grep docker_bip hosts |awk -F'=' '{print $2}'`
docker_graph=`grep docker_graph hosts |awk -F'=' '{print $2}'`
registry_mirrors=`grep registry_mirrors hosts |awk -F'=' '{print $2}'`
default_address_pools=`grep default_address_pools hosts |awk -F'=' '{print $2}'`
NET_MASQUERADE=`grep NET_MASQUERADE hosts |awk -F'=' '{print $2}'`
harbor_hostname=`grep harbor_hostname hosts |awk -F'=' '{print $2}'`
harbor_port=`grep harbor_port hosts |awk -F'=' '{print $2}'`

cat > docker_common/daemon.json << EOF
{
  "bip": "${docker_bip}",
  "default-address-pools":
  [
    {"base":"${default_address_pools}","size":24}
  ],
  "bridge": "",
  "debug": false,
  "default-runtime": "runc",
  "iptables": false,
  "ip-forward": true,
  "ip-masq": false,
  "iptables": false,
  "ipv6": false,
  "labels": [],
  "live-restore": true,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "tag": "{{.ImageName}}|{{.Name}}",
    "max-file": "10",
    "max-size": "200m"
  },
  "registry-mirrors": [
    "${registry_mirrors}"
  ],
  "insecure-registries": [
    "${harbor_hostname}:${harbor_port}"
  ],
  "runtimes": {},
  "selinux-enabled": false,
  "graph": "${docker_graph}",
  "exec-opts": [
    "native.cgroupdriver=systemd"
  ],
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

cat > docker_common/docker.service << EOF
[Unit]
Description=Docker Application Container Engine
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
OOMScoreAdjust=-1000
mountflags=shared
Type=notify
ExecStartPost=/sbin/iptables -t nat -A POSTROUTING -s ${NET_MASQUERADE} -j MASQUERADE
ExecStart=/usr/bin/dockerd --config-file=/etc/docker/daemon.json
ExecReload=/bin/kill -s HUP $MAINPID
ExecStartPre=/bin/rm -f /var/run/docker.pid
ExecStartPost=/sbin/iptables -I FORWARD -s 0.0.0.0/0 -j ACCEPT
ExecStopPost=/sbin/iptables -t nat -D POSTROUTING -s ${NET_MASQUERADE} -j MASQUERADE
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity
#TasksMax=infinity
TimeoutStartSec=0
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely

Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
EOF

which docker >/dev/nul 2>&1
if [ "$?" != "0" ]
then
echo "install docker binaries"
bash docker_common/install_docker.sh
sleep 1
fi

docker info >/dev/nul 2>&1
if [ "$?" != "0" ]
then
echo start dockerd
dockerd --iptables=false >/dev/nul 2>&1 &
sleep 1
fi

docker inspect a83d0740a9a8 >/dev/nul 2>&1
if [ "$?" != "0" ]
then
echo load ansible docker
docker load -i docker_common/ansible.tar.xz
fi
