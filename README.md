## ae_install
A deployment tool developed based on ansible playbook, docker, and docker-compose, supports the system version centos 7.x, does not rely on the network, does not rely on any system components, by default in the minimized system, and when there is no public network and other environments, One-click optimization of the production environment, batch deployment and maintenance of server environments within 2000. And on this basis, any automated operation and maintenance program can be customized.

## what's ansible
Ansible is a new and popular automated operation and maintenance tool. It is developed based on the python2-paramiko module and integrates the advantages of many operation and maintenance tools (puppet, cfengine, chef, func, fabric) to realize batch system configuration, batch program deployment, and batch Run command function.
Ansible works based on modules and does not have the ability to deploy in batches. The real batch deployment is the module run by ansible, and ansible only provides a framework. The ansible framework mainly contains the following functions：<br/>
（1）Connection plugins: Responsible for communicating with the monitored terminal in advance；<br/>
（2）host inventory: operating host inventory；<br/>
（3）Core module, command module, custom module；<br/>
（4）With the help of plug-ins to complete functions such as logging emails；<br/>
（5）Playbook：When the script executes multiple tasks, it is not necessary to allow the node to run multiple tasks at once；<br/>

## what's docker
Docker packages the dependencies between the application and the program in a file. Running this file will generate a virtual container. The program runs in this virtual container as if it were running on a real physical machine. With Docker, there is no need to worry about environmental issues.
Generally speaking, the interface of Docker is quite simple, users can easily create and use containers, and put their own applications into the container. Containers can also carry out version management, copying, sharing, and modification, just like managing ordinary code.

## Instructions
### Catalog Introduction
app_install&emsp;&emsp;Application dirs<br/>
docker_common&emsp;&emsp;docker dirs<br/>
group_vars&emsp;&emsp;Global variable<br/>
system_init&emsp;&emsp;Initialize the directory<br/>
*.example&emsp;&emsp;Sample main configuration file<br/>
id_*&emsp;&emsp;Key pair<br/>
*.sh&emsp;&emsp;executable file<br/>
pkg&emsp;&emsp;Directory of all installation packages<br/>

### wget pkg
Download the ovpn_pkg.tgz package from the data center through the network disk, put it in the pkg/ directory of the root path, and execute: mv ovpn_pkg.tgz aeovpn/pkg/ && tar -zxf ovpn_pkg.tgz

### The main configuration file
```
[openldap]
192.168.2.60

[openvpn]
192.168.2.60

#Global Variables
[all:vars]
# ssh configuration
#Server system password
server_password='123456'
#Server System Port
ansible_ssh_port=22
#Server system username
ansible_ssh_user=root
#Root directory
base_dir="{{playbook_dir}}" #root directory
#Secret key location
ansible_ssh_private_key_file=/root/.ssh/id_rsa #Secret key location
docker_basedir="/bmsk" #Mount path
#installation path
install_path="/data"
#pushFree password
push_ssh_key=True
#Login exemption
ansible_ssh_extra_args='-o StrictHostKeyChecking=no' #Login exemption
#Use ssh pipeline
ansible_ssh_pipelining=True
#ntp server
ntp_server=ntp1.aliyun.com

# hostname
#Set hostname area
region=bj
#Set the hostname item
organization=yjtc

#docker
#docker's home directory
docker_graph=/var/lib/docker
#docker ip pool used by default
docker_bip=11.111.0.1/24
#Mirror warehouse address used by docker
registry_mirrors=https://docker.mirrors.ustc.edu.cn
#docker-compose's address pool
default_address_pools=11.111.100.1/20
#The camouflage address added by default, used for communication between nodes
NET_MASQUERADE=11.111.0.0/16

#users
#Create a normal user
customuser=bmsk
#Create normal user password
userpassword="OgnGpjpwScgjeO3J"

#ldap
LDAP_ORGANISATION="Fthl Inc."
LDAP_DOMAIN=fthl.com
LDAP_ADMIN_PASSWORD=123456
LDAP_BACKEND=mdb

#openvpn-ldap
openldap_host={{groups['consul'][0]}}
OVPN_PORT=1194
OVPN_PROTOCOL=tcp
#NAT OR ROUTE
#true is NAT
#false is ROUTE
OVPN_NAT=false
#Set OVPN_SERVER_CN as the access address
#such as domain or ip
OVPN_SERVER_CN=openvpn.fthl.com
OVPN_NETWORK="11.50.0.0 255.255.0.0"
OVPN_ROUTES="192.168.216.0 255.255.255.0"
LDAP_URI=ldap://{{ openldap_host }}
LDAP_BASE_DN="ou=users,dc=fthl,dc=com"
LDAP_BIND_USER_DN="cn=admin,dc=fthl,dc=com"
LDAP_BIND_USER_PASS={{ LDAP_ADMIN_PASSWORD }}
LDAP_FILTER="(objectClass=inetOrgPerson)"
OVPN_MANAGEMENT_ENABLE="true"
#OVPN_MANAGEMENT_TYPE="OVPN_MANAGEMENT_NOAUTH|OVPN_MANAGEMENT_PASSWORD"
#if OVPN_MANAGEMENT_TYPE="OVPN_MANAGEMENT_NOAUTH" then set OVPN_MANAGEMENT_TYPE_VALUE="true"
#if OVPN_MANAGEMENT_TYPE="OVPN_MANAGEMENT_PASSWORD" then set OVPN_MANAGEMENT_TYPE_VALUE="passwd"
OVPN_MANAGEMENT_TYPE="OVPN_MANAGEMENT_NOAUTH"
OVPN_MANAGEMENT_TYPE_VALUE="true"

#openvpn-monitor
OPENVPNMONITOR_DEFAULT_DATETIMEFORMAT="%%d/%%m/%%Y"
OPENVPNMONITOR_DEFAULT_LATITUDE=-37
OPENVPNMONITOR_DEFAULT_LONGITUDE=144
OPENVPNMONITOR_DEFAULT_MAPS=Ture
OPENVPNMONITOR_DEFAULT_SITE=prod
OPENVPNMONITOR_SITES_1_SHOWDISCONNECT=True
OPENVPNMONITOR_SITES_1_ALIAS=TCP
OPENVPNMONITOR_SITES_1_HOST=openvpn-ldap
OPENVPNMONITOR_SITES_1_NAME=openvpn_monitor
OPENVPNMONITOR_SITES_1_PORT=5555
OPENVPNMONITOR_PORT=19080
```

### Create the main configuration file
```
copy ovpn.hosts.example hosts
```

### Execute batch commands
```
#local install docker
sh initialize_docker.sh
#Batch configuration password-free login
sh ssh.sh hosts
#Batch Modify hostnames in bulk
sh hosts.sh hosts
#Batch initialization server
sh system_init.sh hosts
#Batch install docker environment
sh install_docker.sh hosts
```

```
#Install openldap and phpldapadmin
sh -x install_ldap.sh hosts
#Install openvpn
sh -x install_openvpn.sh hosts
#Install openvpn monitor
sh -x install_openvpn_monitor.sh hosts
```