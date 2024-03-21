## 什么是aeovpn
基于ansible playbook与docker，docker-compose开发的部署工具，支持系统版本centos 7.x，Kylin Linux Advanced Server V10 (Tercel)，UnionTech OS Server 20，cpu架构amd64和arm64，在不依赖网络，不依赖任何系统组件，默认在最小化系统下，以及无公网等环境的情况下，一键优化生产环境，批量部署服务，一键部署基于openldap+google-otp认证的openvpn，整合了phpldapadmin，openvpn监控，自行修改密码的工具

## 什么是ansible
ansible是一种新流行的自动化运维工具，基于python2-paramiko模块开发，集合了众多运维工具（puppet、cfengine、chef、func、fabric）的优点，实现了批量系统配置、批量程序部署、批量运行命令功能。
ansible是基于模块工作的，本身没有批量部署的能力。真正具有批量部署的是ansible所运行的模块，ansible只提供一种框架。ansible这个框架主要包含以下功能：<br/>
（1）连接插件connection plugins:负责和被监控端事先通信；<br/>
（2）host inventory:操作主机清单；<br/>
（3）核心模块、command模块、自定义模块；<br/>
（4）借助与插件完成记录日志邮件等功能；<br/>
（5）Playbook：剧本执行多个任务时，非必须可以让节点一次性运行多任务。<br/>

## 什么是docker
Docker将应用程序与该程序的依赖，打包在一个文件里面。运行这个文件，就会生成一个虚拟容器。程序在这个虚拟容器里运行，就好像在真实的物理机上运行一样。有了Docker，就不用担心环境问题。
总体来说，Docker的接口相当简单，用户可以方便地创建和使用容器，把自己的应用放入容器。容器还可以进行版本管理、复制、分享、修改，就像管理普通的代码一样。

## 版本及简介
```
更新简介
1、版本升级docker-20.10.23
2、新增密码修改，磁盘初始化
3、新增时间服务器chrony部署
4、适配arm64环境
5、新增registry私仓部署
6、新增containerd,nerdctl安装部署

版本详情
docker 20.10.23
docker-compose 1.29.2
containerd v1.6.21
congcong126/ansible:2.9.18
osixia/phpldapadmin
osixia/openldap:1.3.0
congcong126/openvpn-ldap-otp:v1.5-1
tiredofit/self-service-password
ruimarinho/openvpn-monitor
nginx:apline
```
## 使用方法
### 目录简介
```
app_install  应用playbook目录
docker_common  docker配置文件目录
containerd_common containerd配置文件目录
group_vars  全局变量
system_init  初始化playbook目录
*.example  主配置文件范例
initialize.sh  初始化脚本
pkg  安装包目录
shell 可执行文件模板
```

### 下载pkg包
```
cd pkg/ 
tar -xf base_pkg_x64.tgz
tar -xf aeovpn_pkg_x86.tgz

#查看离线包
[xxxx pkg]# ls
ansible.tar.xz  changepass.tgz  docker-compose.tgz  nginx.tgz     openvpn-monitor.tgz  registry.tgz
bin             containerd.tgz  docker.tgz          openldap.tgz  phpldapadmin.tgz
```

### 主配置文件详解
```
######################主机组#################################
#对应安装主机需要在主机组中添加对应地址
#ssh,sysinit,hostname等系统基础设置会对所有主机组执行
#registry=true会在当前主机安装私仓
[docker]
192.168.2.65 registry=true

[containerd]
#192.168.2.65 registry=true
#192.168.2.66
#192.168.2.67

[openldap]
192.168.2.65

[openvpn]
192.168.2.65
######################主机组#################################
[all:vars]
# ssh 配置 和 实际宿主机部署路径
server_password='123456'
ansible_ssh_port=22
ansible_ssh_user=root
base_dir="{{playbook_dir}}"
ansible_ssh_private_key_file=/root/.ssh/id_rsa
docker_basedir=/ae

name_prefix="ovpn"
install_path="/data/{{name_prefix}}"
push_ssh_key=True
ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
ansible_ssh_pipelining=True

#ntp server
#设置ntpserver配置，false自建chrony服务，ture则使用外部ntp server，需要安装ntpdate
use_ntpdate=true
ntp_server=192.168.2.66
ext_ntp_server=ntp.aliyun.com

# 如手动执行hostname设置会引入下列变量
# hostname, {{region}}-{{organization}}-{{group_names[0]}}-{{ inventory_hostname.split('.') | join('-') }}
region=bj
organization=who

#install_docker
#daemon.json里可自定义的值
#docker的家目录
docker_graph=/data/docker
#docker默认使用的ip池
docker_bip=11.111.0.1/24
#docker使用的镜像仓库地址
registry_mirrors=https://docker.mirrors.ustc.edu.cn
#docker-compose的地址池
default_address_pools=11.111.100.1/20
#默认添加的伪装地址,用于节点间通信
NET_MASQUERADE=11.111.0.0/16

#changepass
#修改多个密码需要修改用户名和密码，多次依次执行
changepass_user="root"
changepass_password="N4YCkje24Sc^"

#users
#安装rke使用的普通用户
customuser=ae
#安装rke使用的普通用户密码
userpassword="youcustom"

#registry带认证简单私仓
#私仓和containerd数据存放
image_registryDomain="baidu.com"
image_registryPort="5000"
image_registryPassword=nfm88yxxxXXX
image_registrycriData=/data/containerd
image_registryData=/data/registry
#安装服务器地址,默认为master第一个节点,既管理与安装节点
delegate_ip="{{groups['docker'][0]}}"

#ldap
#具体可以参考官方文档:https://github.com/osixia/docker-openldap
LDAP_ORGANISATION="who Inc."
LDAP_DOMAIN=who.com
LDAP_ADMIN_PASSWORD=Snc93xxxXXX
LDAP_BACKEND=mdb
LDAP_PHPMYADMIN=19085
phpldapadmin_image="osixia/phpldapadmin"
openldap_image="osixia/openldap:1.3.0"

#openvpn-ldap
#可参考官方文档:https://github.com/wheelybird/openvpn-server-ldap-otp
openvpn_image="congcong126/openvpn-ldap-otp:v1.5-1"
openldap_host={{groups['openldap'][0]}}
OVPN_PORT=62194
OVPN_PROTOCOL=udp
#NAT OR ROUTE
#true is NAT
#false is ROUTE
OVPN_NAT=false
#Set OVPN_SERVER_CN as the access address
#such as domain or ip
OVPN_SERVER_CN="openvpn.{{LDAP_DOMAIN}}"
OVPN_NETWORK="11.10.0.0 255.255.0.0"
OVPN_ROUTES="172.25.68.0 255.255.255.0"
LDAP_URI=ldap://{{ openldap_host }}
LDAP_BASE_DN="ou=users,dc=who,dc=com"
LDAP_BIND_USER_DN="cn=admin,dc=who,dc=com"
LDAP_BIND_USER_PASS={{ LDAP_ADMIN_PASSWORD }}
LDAP_FILTER="(objectClass=inetOrgPerson)"
OVPN_DNS_SERVERS=223.5.5.5
OVPN_ENABLE_COMPRESSION=false
OVPN_REGISTER_DNS=false
ENABLE_OTP=true
OVPN_MANAGEMENT_ENABLE="true"
#OVPN_MANAGEMENT_TYPE="OVPN_MANAGEMENT_NOAUTH|OVPN_MANAGEMENT_PASSWORD"
#if OVPN_MANAGEMENT_TYPE="OVPN_MANAGEMENT_NOAUTH" then set OVPN_MANAGEMENT_TYPE_VALUE="true"
#if OVPN_MANAGEMENT_TYPE="OVPN_MANAGEMENT_PASSWORD" then set OVPN_MANAGEMENT_TYPE_VALUE="passwd"
OVPN_MANAGEMENT_TYPE="OVPN_MANAGEMENT_PASSWORD"
OVPN_MANAGEMENT_TYPE_VALUE="LSHfmsrxxxXXX"

#ovpn_changepass
#可参考官方文档:https://github.com/tiredofit/docker-self-service-password
ovpn_changepass_image="tiredofit/self-service-password"
ovpn_changepasstoldap_port=389
ovpn_changepass_port=19089

#openvpn-monitor
#可参考官方文档:https://github.com/ruimarinho/docker-openvpn-monitor
openvpn_monitor_image="ruimarinho/openvpn-monitor"
nginx_image="nginx:alpine"
OPENVPNMONITOR_DEFAULT_DATETIMEFORMAT="%%d/%%m/%%Y"
OPENVPNMONITOR_DEFAULT_LATITUDE=40
OPENVPNMONITOR_DEFAULT_LONGITUDE=116
OPENVPNMONITOR_DEFAULT_MAPS=true
OPENVPNMONITOR_DEFAULT_SITE=prod
OPENVPNMONITOR_SITES_0_SHOWDISCONNECT=true
OPENVPNMONITOR_SITES_0_ALIAS=TCP
OPENVPNMONITOR_SITES_0_HOST={{groups['openvpn'][0]}}
OPENVPNMONITOR_SITES_0_NAME=openvpn_monitor
OPENVPNMONITOR_SITES_0_PORT=5555
OPENVPNMONITOR_PORT=19080
#default user:admin
OPENVPN_MONITORPASS=TNqfRxxxXXX

#openssl
#openssl_domain The domain name used for self-signature, multiple domain names use methods "a.com", "b.com"
#The self-signed certificate ip will be obtained according to the group list in hosts
openssl_C=CN
openssl_ST=BJ
openssl_L=BJ
openssl_O=k8s
openssl_OU=k8s
openssl_CN="K8S ONLY CA"
openssl_domain="{{image_registryDomain}}","*.{{image_registryDomain}}"
openssl_days=36500
openssl_RSA=2048
openssl_ea="-sha256"
openssl_asym="rsa"
ROOT_CA_PRIVATEKEY=CA_PRIVATEKEY.key
ROOT_CA_CSR=CA_CSR.csr
ROOT_CA_CERT=CA_CERT.crt
SERVER_PRIVATEKEY=k8s_server.key
SERVER_CSR=k8s_server.csr
SERVER_CRT=k8s_server.crt
```

### 创建主配置文件
```
#需要根据自己的情况修改主配置文件
copy hosts_ovpn.example hosts
```

### 执行批量命令
```
#初始化安装，会/opt/docker_bin安装docker，仅供安装工具使用，生产使用需要执行install_docker.sh安装，并在当前目录生成可执行脚本
sh initialize
#批量配置免密登录
sh ssh.sh hosts
#修改密码
sh changepass.sh hosts
#批量修改主机名(建议修改适合环境hosts)
#修改地区及环境业务名称，主机名例子bj-who-docker-192.168.2.66
sh hosts.sh hosts
#批量初始化服务器
sh system_init.sh hosts
#批量安装docker环境
sh install_docker.sh hosts install
#批量安装containerd环境
sh install_containerd.sh install
#生成自签名证书并同步所有主机
sh sslkey.sh hosts install
#安装openldap及phpldapadmin管理平台
sh openldap.sh hosts install
#安装openvpn-ldap
sh openvpn.sh hosts install
#安装openvpn-monitor监控工具及nginx代理（提供密码安全）
sh openvpn_monitor.sh hosts install
#安装自定义密码修改平台供用户自己修改密码
sh ovpn_changepass.sh hosts install
```

### 镜像改动相关
```
#openvpn-ldap-otp镜像进行了简单修改,新增即使openvpn不是全局代理也可以访问内网其他网段，会根据route段生成iptables伪装，可以生成utf8格式的google验证码，供线下传输
docker exec -it ovpn-openvpn add-otp-user1 xxxx UTF8 > xxxx.txt
#生成客户端配置文件
docker exec -it ovpn-openvpn show-client-config
```
