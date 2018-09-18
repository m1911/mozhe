#!/bin/bash
#升级内核
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh https://mirrors.tuna.tsinghua.edu.cn/elrepo/extras/el7/x86_64/RPMS/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install kernel-lt -y #安装稳定内核
grub2-set-default 0 #设置启动内核
reboot