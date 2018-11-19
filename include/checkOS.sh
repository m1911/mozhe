#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -e
#nginx安装检查系统
nginxCHECKos()
{	
	if [ -f /usr/bin/yum ]; then
		system=`rpm -q centos-release|cut -d- -f3`
		if [ ${system} -eq 7 ]; then
				if [ "${country}" = "CN" ]; then
					mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
					curl -o /etc/yum.repos.d/CentOS-Base.repo -L ${downUrl}/show/rpm/CentOS-Base.repo
					yum makecache
					yum -y install epel-release
					sed -e 's!^mirrorlist=!#mirrorlist=!g' \
        				-e 's!^#baseurl=!baseurl=!g' \
    				    -e 's!//download\.fedoraproject\.org/pub!//mirrors.ustc.edu.cn!g' \
    				    -e 's!http://mirrors\.ustc!https://mirrors.ustc!g' \
    				    -i /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo
    				sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config #关闭selinux
					yum -y install wget gcc gcc-c++ make perl unzip bzip2 libuuid-devel zlib-devel 
					rm -rf /etc/localtime
		   			ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    			else
    				yum -y install epel-release
    				sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config #关闭selinux
					yum -y install wget gcc gcc-c++ make perl unzip bzip2 libuuid-devel zlib-devel
					rm -rf /etc/localtime
		   			ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
				fi
		else
			echo "当前脚只支持CentOS7！"
			exit
		fi
	fi
}
#mysql安装检查系统
mysqlCHECKos()
{
	if [ -f /usr/bin/yum ]; then
		system=`rpm -q centos-release|cut -d- -f3`
		if [ ${system} -eq 7 ]; then
				if [ "${country}" = "CN" ]; then
					yum -y install epel-release 
					sed -e 's!^mirrorlist=!#mirrorlist=!g' \
        				-e 's!^#baseurl=!baseurl=!g' \
    				    -e 's!//download\.fedoraproject\.org/pub!//mirrors.ustc.edu.cn!g' \
    				    -e 's!http://mirrors\.ustc!https://mirrors.ustc!g' \
    				    -i /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo
    				yum -y install yum-plugin-priorities expect wget git libev socat
					rm -rf /etc/localtime
		   			ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    			else
    				yum -y install epel-release
    				yum -y install yum-plugin-priorities expect wget git libev socat
					rm -rf /etc/localtime
		   			ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
				fi
		else
			echo "当前脚只支持CentOS7！"
			exit
		fi
	fi
	add_rpm
}
#临时关闭selinux
Check_selinux()
{
	statusSElinux=`getenforce`
	if [ ${statusSElinux} = "Disabled" ]; then
		echo ${statusSElinux}
	else
		setenforce 0
	fi
}

add_rpm()
{
	if [ "${country}" = "CN" ]; then
		wget -cO /etc/yum.repos.d/mariadb.repo ${downUrl}/show/rpm/mariadb10.2-cn.repo
	else
		wget -cO /etc/yum.repos.d/mariadb.repo ${downUrl}/show/rpm/mariadb10.2-us.repo
	fi
}