#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -e

#检测是否是root用户
if [ $(id -u) != "0" ]; then
	echo "错误：必须使用Root用户才能执行此脚本."
	exit 1
fi

#包含文件
. mozhe.conf
. include/checkOS.sh
. include/firewall.sh
. include/lsyncd.sh
. include/nginx.sh
. include/pdns.sh
#. include/percona.sh
. include/mariadb.sh
. include/vhost.sh


#nginx配置
Function_vhost()
{
	case "$1" in
        [aA][dD][dD])
			Add_host
            ;;
        [sS][sS][lL])
			Add_ssl_host
            ;;
        [pP][dD][nN][sS])
			Add_pdns_host
            ;;            
        *)
            echo "用法: install.sh vhost {add|ssl|pdns}"
            exit 1
            ;;
    esac
}
#Lsyncd配置
Function_rsync()
{
	case "$1" in
        [kK][eE][yY])
			Create_key 2>&1 /tmp/Create_key.log
            ;;
        [iI][nN][sS][tT][aA][lL][lL])
			Install_Lsyncd 2>&1 /tmp/Install_Lsyncd.log
            ;;
        [cC][oO][pP][yY])
			Sync_servers
            ;;
        *)
            echo "用法: install.sh rsync {key|install|sync}"
            exit 1
            ;;
    esac
}
#mysql配置
Function_mysql()
{
    case "$1" in
        [iI][nN][sS][tT][aA][lL][lL])
            installMYSQLserver 2>&1 /tmp/installMYSQLserver.log
            ;;
        [iI][nN][iI][tT])
            initialGALERAserver 2>&1 /tmp/initialGALERAserver.log
            ;;
        [nN][oO][dD][eE])
            configNODEserver 2>&1 /tmp/configNODEserver.log
            ;;
        *)
            echo "用法: install.sh mysql {install|init|node}"
            exit 1
            ;;
    esac
}
#pdns配置
Function_pdns()
{
	case "$1" in
        [iI][nN][sS][tT][aA][lL][lL])
			installMASTERpdns 2>&1 /tmp/Install_pdns.log
            ;;
        [nN][oO][dD][eE])
            installSLAVEpdns 2>&1 /tmp/initialPXC.log
            ;;
        [aA][dD][mM][Ii][nN])
			installPDNSadmin 2>&1 /tmp/installPDNSadmin.log
            ;;
        *)
            echo "用法: install.sh pdns {install|node|admin}"
            exit 1
            ;;
    esac
}

arg1=$1
arg2=$2

case ${arg1} in
    [nN][gG][iI][nN][xX])
        Install_nginx 2>&1 /tmp/Install_nginx.log
    	;;
    [rR][sS][yY][nN][cC])
		Function_rsync ${arg2}
    	;;
    [mM][yY][sS][qQ][lL])
        Function_mysql ${arg2}
        ;;
    [pP][dD][nN][sS])
		Function_pdns ${arg2}
    	;;
    [vV][hH][oO][sS][tT])
        Function_vhost ${arg2}
        ;;
    *)
		echo "用法: install.sh nginx"
		echo "用法: install.sh rsync {key|install|sync}"
        echo "用法: install.sh mysql {install|init|node}"
		echo "用法: install.sh pdns {install|node|admin}"
        echo "用法: install.sh vhost {add|ssl|pdns}"
		exit 1
		;;
esac