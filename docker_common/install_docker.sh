#!/bin/sh

cd `dirname $0`
dir=`pwd`

tar -xf docker.tgz -C /usr/bin/

which systemctl >/dev/nul 2>&1
if [ "$?" != "0" ]
then
        dockerd --iptables=false >/dev/nul 2>&1 &
        echo "#!/bin/bash">/etc/init.d/bmsk-docker
        echo "dockerd --iptables=false >/dev/nul 2>&1 &">>/etc/init.d/bmsk-docker
        chmod 755 /etc/init.d/bmsk-docker
        ln -sf ../init.d/bmsk-docker /etc/rc.d/rc3.d/S99bmsk-docker
else
        mkdir -p /etc/docker
        cp daemon.json /etc/docker/
        cp docker.service /etc/systemd/system/docker.service
        systemctl daemon-reload
        systemctl start docker
        systemctl enable docker
fi
