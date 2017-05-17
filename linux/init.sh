#!/bin/bash

# 修改系统的文件句柄
 echo "session required pam_limits.so" >> /etc/pam.d/common-session
 echo "* hard nofile 1048576" >> /etc/security/limits.conf
 echo "* soft nofile 1048576" >> /etc/security/limits.conf
 echo "root hard nofile 1048576" >> /etc/security/limits.conf
 echo "root soft nofile 1048576" >> /etc/security/limits.conf
 echo "ulimit -SHn 1048576" >> /etc/profile


#修改DNS
 echo "nameserver 192.168.1.1" >> /etc/resolvconf/resolv.conf.d/base
 echo "nameserver 114.114.114.114" >> /etc/resolvconf/resolv.conf.d/base
 resolvconf -u

#root登录

 #passwd root

# sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
# service ssh restart

ssh-keygen -t rsa


#修改网卡
# sed -i 's/iface eno1 inet dhcp/iface eno1 inet static/g' /etc/network/interfaces
# echo "address 192.168.1.202" >> /etc/network/interfaces
# echo "netmask 255.255.255.0" >> /etc/network/interfaces
# echo "gateway 192.168.1.1" >> /etc/network/interfaces

# 修改source.list 以便于系统更新
 sed -i 's/cn.archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list 

 apt-get update
# 安装必要的软件包
 apt-get install -y gcc curl libpcre3 libpcre3-dev \
 libssl-dev openssl ruby \
 make python libaio1 libaio-dev >>/dev/null

#安装docker

 apt-get -y install \
  apt-transport-https \
  ca-certificates \
  curl

 curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  apt-key add -

 add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"

 apt-get update

 apt-get -y install docker-ce

#修改Host
 echo "192.168.1.209 ng1.ctys.com" >> /etc/hosts
 echo "192.168.1.2010 ng2.ctys.com" >> /etc/hosts
 echo "192.168.1.201 app1.ctys.com" >> /etc/hosts
 echo "192.168.1.202 app2.ctys.com" >> /etc/hosts
 echo "192.168.1.203 app3.ctys.com" >> /etc/hosts
 echo "192.168.1.204 app4.ctys.com" >> /etc/hosts
 echo "192.168.1.205 im1.ctys.com" >> /etc/hosts
 echo "192.168.1.206 im2.ctys.com" >> /etc/hosts
 echo "192.168.1.207 video1.ctys.com" >> /etc/hosts
 echo "192.168.1.208 video2.ctys.com" >> /etc/hosts





