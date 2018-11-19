#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -e
#nginx防火墙
nginxCHECKfirewall()
{
	if [ -e /etc/sysconfig/firewalld ]; then
		systemctl start firewalld
		firewall-cmd --zone=public --add-port=80/tcp --permanent
		firewall-cmd --zone=public --add-port=443/tcp --permanent
		firewall-cmd --reload
	else
		echo "请自行手动YUM安装防火墙"
		exit
	fi
}
#数据库防火墙
mysqlCHECKfirewall()
{		
	if [ -e /etc/sysconfig/firewalld ]; then
		systemctl start firewalld
		firewall-cmd --zone=public --add-port=3306/tcp --permanent
		firewall-cmd --zone=public --add-port=4444/tcp --permanent
		firewall-cmd --zone=public --add-port=4567/tcp --permanent
		firewall-cmd --zone=public --add-port=4568/tcp --permanent
		firewall-cmd --reload
	else
		echo "请自行手动YUM安装防火墙"
		exit
	fi
}
#dns防火墙
dnsCHECKfirewall()
{
	if [ -e /etc/sysconfig/firewalld ]; then
		systemctl start firewalld
		firewall-cmd --zone=public --add-port=53/tcp --permanent
		firewall-cmd --zone=public --add-port=53/udp --permanent
		firewall-cmd --reload
	else
		echo "请自行手动YUM安装防火墙"
		exit
	fi
}