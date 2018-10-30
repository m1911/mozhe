#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -e

Openresty=1.13.6.2 #Openresty版本号
Install_dir=/usr/local/mozhe #Openresty安装目录
D_url=https://dl.ilankui.com #配置文件下载地址
DATA_DIR=/data/mariadb #数据库目录
PDNSAdmin_WEB_DIR=/home/pdns_admin #pdns_admin安装目录
country=`curl -sSk --connect-timeout 30 -m 60 https://ip.vpser.net/country` #判断ip国家

#检测是否是root用户
if [ $(id -u) != "0" ]; then
	echo "错误：必须使用Root用户才能执行此脚本."
	exit 1
fi

#添加vhost选项
Function_nginx()
{
	case "$1" in
		[iI][nN][sS][tT][aA][lL][lL])
			Install_nginx 2>&1 /tmp/Install_nginx.log
            ;;
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
            echo "用法: mozhe nginx {install|add|ssl|pdns}"
            exit 1
            ;;
    esac
}
#安装Lsyncd选项
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
            echo "用法: mozhe rsync {key|install|sync}"
            exit 1
            ;;
    esac
}
#pdns安装选项
Function_pdns()
{
	case "$1" in
        [mM][yY][sS][qQ][lL])
			mariadb 2>&1 /tmp/mariadb.log
            ;;
        [iI][nN][sS][tT][aA][lL][lL])
			Install_pdns 2>&1 /tmp/Install_pdns.log
            ;;
        [aA][dD][mM][Ii][nN])
			Install_pdns_admin 2>&1 /tmp/Install_pdns_admin.log
            ;;
        *)
            echo "用法: mozhe pdns {mysql|install|pdns}"
            exit 1
            ;;
    esac
}
#检查系统
Check_os()
{	
	if [ -f /usr/bin/yum ]; then
		system=`rpm -q centos-release|cut -d- -f3`
		if [ ${system} -eq 7 ]; then
			if [[ ! -d /usr/local/mozhe && ! -d  /data/mariadb ]]; then #判断nginx和mysql目录是否存在进行安装依赖
				if [ "${country}" = "CN" ]; then
					mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
					curl -o /etc/yum.repos.d/CentOS-Base.repo -L ${D_url}/show/rpm/CentOS-Base.repo
					yum makecache
					yum -y install epel-release
					sed -e 's!^mirrorlist=!#mirrorlist=!g' \
        				-e 's!^#baseurl=!baseurl=!g' \
    				    -e 's!//download\.fedoraproject\.org/pub!//mirrors.ustc.edu.cn!g' \
    				    -e 's!http://mirrors\.ustc!https://mirrors.ustc!g' \
    				    -i /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo
    				sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config #关闭selinux
					yum -y install wget socat gcc gcc-c++ perl unzip bzip2 git libuuid-devel zlib-devel yum-utils yum-plugin-priorities expect libev 
					rm -rf /etc/localtime
		   			ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    			else
    				yum -y install epel-release
    				sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config #关闭selinux
					yum -y install wget socat gcc gcc-c++ perl unzip bzip2 git libuuid-devel zlib-devel yum-utils yum-plugin-priorities expect libev 
					rm -rf /etc/localtime
		   			ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
				fi	
	   		fi
		else
			echo "当前脚只支持CentOS7！"
			exit
		fi
	fi
}
#按任意键继续
Get_char()
{
	clear
	echo "+-----------------------------------------------------------------------+"
	echo "|                          欢迎使用安装Nginx脚本                        |"
	echo "+-----------------------------------------------------------------------+"
	echo "|                              Nginx一键脚本                            |"
	echo "+-----------------------------------------------------------------------+"
	echo "|                     更多信息请访问 https://github.com/m1911           |"
	echo "+-----------------------------------------------------------------------+"
	echo ""
	echo "Press any key to start...or Press Ctrl+c to cancel"
	OLDCONFIG=`stty -g`
	stty -icanon -echo min 1 time 0
	dd count=1 2>/dev/null
	stty ${OLDCONFIG}
}
#获取CPU用来编译
Check_cpu()
{
	physical_cpu=`cat /proc/cpuinfo | grep 'physical id' | sort | uniq | wc -l`
	if [ ${physical_cpu} -le 1 ]; then
		cpu=1
	else
		divisor=2
		results=$[physical_cpu/divisor]
		cpu=${results}
	fi
}
#安装扩展
Install_extensions()
{
	mkdir -p /tmp/src
	cd /tmp/src
	 wget -c ${D_url}/show/Nginx/extended/jemalloc-5.1.0.tar.bz2
	tar xjf jemalloc-5.1.0.tar.bz2 &&cd jemalloc-5.1.0
	./configure
    make -j${cpu} &&make -j${cpu} install
    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
    ldconfig &&cd ..
	
	wget -c ${D_url}/show/Nginx/extended/openssl-1.1.0i.tar.gz
	tar zxf openssl-1.1.0i.tar.gz &&cd openssl-1.1.0i
	./config
	make -j${cpu} &&make -j${cpu} install
	cd ..
	
	wget -c ${D_url}/show/Nginx/extended/pcre-8.39.tar.bz2
	tar xjf pcre-8.39.tar.bz2 &&cd pcre-8.39
	./configure
	make -j${cpu} &&make -j${cpu} install
	cd ..
	
	wget -cO v1.13.35.2-stable.tar.gz ${D_url}/show/Nginx/extended/incubator-pagespeed-ngx-1.13.35.2-stable.tar.gz
	tar zxf v1.13.35.2-stable.tar.gz
	mv incubator-pagespeed-ngx-1.13.35.2-stable ngx_pagespeed &&cd ngx_pagespeed
	wget -c ${D_url}/show/Nginx/extended/1.13.35.2-x64.tar.gz
	tar zxf 1.13.35.2-x64.tar.gz &&cd ..
	
	wget -c ${D_url}/show/Nginx/extended/ngx_brotli.tgz
	tar zxf ngx_brotli.tgz
	
	wget -c ${D_url}/show/Nginx/extended/ngx_cache_purge-2.5.tar.gz
	tar zxf ngx_cache_purge-2.5.tar.gz
}
#安装nginx
Install_nginx()
{
	begin_time=$(date +%s)
	Get_char
	Check_os
	Check_cpu
	Install_extensions
	groupadd www &&useradd -M -s /sbin/nologin -g www www
	mkdir -p /data/cache /data/wwwlogs /data/ngx_pagespeed
	chown www.www -R  /data/ngx_pagespeed /data/wwwlogs /data/cache
	chmod -R 777  /data/ngx_pagespeed /data/wwwlogs /data/cache
	cd /tmp/src
	wget -c https://openresty.org/download/openresty-${Openresty}.tar.gz
	tar zxf openresty-${Openresty}.tar.gz &&cd openresty-1.13.6.2
	sed -i  '/NGINX_VER/{s/openresty/Mozhe/g}'  ./bundle/nginx-1.13.6/src/core/nginx.h
    sed -i "s#Server: openresty#Server: Mozhe#" ./bundle/nginx-1.13.6/src/http/ngx_http_header_filter_module.c
    sed -i "s#\"<hr><center>openresty<\/center>\"#\"<hr><center>Mozhe<\/center>\"#" ./bundle/nginx-1.13.6/src/http/ngx_http_special_response.c
	./configure --user=www --group=www --prefix=${Install_dir} --with-luajit --with-http_v2_module --with-http_gunzip_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_ssl_module --with-ld-opt="-ljemalloc" --with-pcre-jit --with-pcre=/tmp/src/pcre-8.39 --with-openssl=/tmp/src/openssl-1.1.0i --add-module=/tmp/src/ngx_brotli --add-module=/tmp/src/ngx_pagespeed --add-module=/tmp/src/ngx_cache_purge-2.5
	make &&make install
	ln -s ${Install_dir}/nginx/sbin/* /usr/local/sbin/
	mv ${Install_dir}/nginx/conf/nginx.conf ${Install_dir}/nginx/conf/nginx.conf_bak
	wget -cO ${Install_dir}/nginx/conf/nginx.conf ${D_url}/show/Nginx/conf/nginx.conf
	mkdir -p ${Install_dir}/nginx/conf/vhost ${Install_dir}/nginx/conf/ssl
	wget -cO /lib/systemd/system/nginx.service ${D_url}/show/Nginx/nginx.service
	${Install_dir}/nginx/sbin/nginx -t
	if [ $? -eq 0 ]; then
		systemctl enable nginx
		systemctl start nginx
		systemctl status nginx
		if [ -f /usr/bin/firewall-cmd ];then
			/usr/bin/firewall-cmd --zone=public --add-port=80/tcp --permanent
			/usr/bin/firewall-cmd --zone=public --add-port=443/tcp --permanent
			/usr/bin/firewall-cmd --reload
		else
			echo "请手动检查防火墙配置！"
		fi
	fi
	end_time=$(date +%s)
	cost_time=$((end_time - begin_time))
	echo "此脚本一共耗时${cost_time}秒"
}
#添加SSL虚拟机
Add_ssl_host()
{
	echo -e "\033[33m注意要先上传SSL证书不然会启动Nginx会报错\033[0m"
	read -p "请输入域名:" domain
	#检测域名是否为空
	if [ "${domain}" = "" ]; then
		echo -e "\033[31m"域名不允许为空,请重新输入域名."\033[0m"
		exit
	elif [ ! -f "${Install_dir}/nginx/conf/vhost/${domain}.conf" ]; then
		read -p "请输入后端服务器IP:" Backend_ip
		if [ "${Backend_ip}" != "" ]; then
			read -p "输入更多域名:" moredomain
			if [ "${moredomain}" = "" ]; then
			echo -e "\033[33m已输入的域名有:${domain}\033[0m"
			fi
			echo -n "请输入证书路径(支持Tab补全路径):" 
			read -e certificate_dir
			if [ "${certificate_dir}" = "" ]; then
				echo "证书路径不能为空"
				exit
			fi
			echo -n "请输入Key路径(支持Tab补全路径):" 
			read -e key_dir
			if [ "${key_dir}" = "" ]; then
				echo "Key路径不能为空"
				exit
			fi
			u_name=${domain//./_}_web #把域名的.转换成_。
			CACHE=${domain//./_}
			wget -cO ${Install_dir}/nginx/conf/vhost/${domain}.conf ${D_url}/show/Nginx/conf/example_ssl.conf
			sed -i "s#mozhe_xx#${CACHE}#g" ${Install_dir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#domainweb#${u_name}#g" ${Install_dir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#0.0.0.0#${Backend_ip}#" ${Install_dir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#server_name example.com#server_name ${domain} ${moredomain}#" ${Install_dir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#example.com#${domain}#g" ${Install_dir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#ssl_certificate ;#ssl_certificate ${certificate_dir};#g" ${Install_dir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#ssl_certificate_key ;#ssl_certificate_key ${key_dir};#g" ${Install_dir}/nginx/conf/vhost/${domain}.conf
			${Install_dir}/nginx/sbin/nginx -t
			if [ $? -eq 0 ]; then
				${Install_dir}/nginx/sbin/nginx -s reload
			fi
		else
			echo "后端服务器IP不能为空，并且必须要输入IP！"
			exit
		fi
	else
		read -p  "输入的域名已经存在，是否删除。(y|n)" action
		if [[ "${action}" = [nN] || "${action}" = "" ]]; then
			echo "域名删除失败请手动删除"
			exit
		else
			cache_dir=${domain//./_}
			rm -rf ${Install_dir}/nginx/conf/vhost/${domain}.conf
			rm -rf /data/cache/${cache_dir}
			echo -e "\033[32m已删除域名和缓存目录\033[0m"
		fi
	fi
}
#添加虚拟机
Add_host()
{
	read -p "请输入域名:" domain
	#检测域名是否为空
	if [ "${domain}" = "" ]; then
		echo -e "\033[31m域名不允许为空,请重新输入域名。\033[0m"
		exit
	elif [ ! -f "${Install_dir}/nginx/conf/vhost/${domain}.conf" ]; then
		read -p "请输入后端服务器IP:" Backend_ip
		if [ "${Backend_ip}" != "" ]; then
			read -p "输入更多域名:" moredomain
			if [ "${moredomain}" = "" ]; then
			echo -e "\033[33m已输入的域名有:${domain}\033[0m"
			fi
			u_name=${domain//./_}_web #把域名的.转换成_。
			CACHE=${domain//./_}
			wget -cO ${Install_dir}/nginx/conf/vhost/${domain}.conf ${D_url}/show/Nginx/conf/example.conf
			sed -i "s#mozhe_xx#${CACHE}#g" ${Install_dir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#domainweb#${u_name}#g" ${Install_dir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#0.0.0.0#${Backend_ip}#" ${Install_dir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#server_name example.com#server_name ${domain} ${moredomain}#" ${Install_dir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#example.com#${domain}#g" ${Install_dir}/nginx/conf/vhost/${domain}.conf
			${Install_dir}/nginx/sbin/nginx -t
			if [ $? -eq 0 ]; then
				${Install_dir}/nginx/sbin/nginx -s reload
			fi
		else
			echo "后端服务器IP不能为空，并且必须要输入IP！"
			exit
		fi
	else
		read -p  "输入的域名已经存在，是否删除。(y|n)" action
		if [[ "${action}" = [nN] || "${action}" = "" ]]; then
			echo "域名删除失败请手动删除"
			exit
		else
			cache_dir=${domain//./_}
			rm -rf ${Install_dir}/nginx/conf/vhost/${domain}.conf
			rm -rf /data/cache/${cache_dir}
			echo -e "\033[32m已删除域名和缓存目录\033[0m"
		fi
	fi
}
#添加pdns_admin虚拟机
Add_pdns_host()
{
	read -p "请输入域名:" domain
	#检测变量输入是否为空
	if [ -z ${domain} ]; then
	        echo -e "\033[31m"域名不允许为空."\033[0m"
	        exit
	elif [ ! -f "${Install_dir}/nginx/conf/vhost/${domain}.conf" ]; then
		read -p "输入更多域名:" moredomain
		read -p "输入网站目录:" web_dir
		if [ "${web_dir}" = "" ]; then
			echo "网站目录不能为空"
			exit
		elif [ "${moredomain}" = "" ]; then
			echo -e "\033[33m已输入的域名有:${domain}\033[0m"
		fi
		echo -n "请输入证书路径(支持Tab补全路径):" 
		read -e certificate_dir
		if [ "${certificate_dir}" = "" ]; then
			echo "证书路径不能为空"
			exit
		fi
		echo -n "请输入Key路径(支持Tab补全路径):" 
		read -e key_dir
		if [ "${key_dir}" = "" ]; then
			echo "Key路径不能为空"
			exit
		fi
		wget -cO ${Install_dir}/nginx/conf/vhost/${domain}.conf ${D_url}/show/Nginx/conf/pdns.conf
		sed -i "s#server_name example.com#server_name ${domain} ${moredomain}#" ${Install_dir}/nginx/conf/vhost/${domain}.conf
		sed -i "s#example.com#${domain}#g" ${Install_dir}/nginx/conf/vhost/${domain}.conf
		sed -i "s#/web#${web_dir}#g" ${Install_dir}/nginx/conf/vhost/${domain}.conf
		sed -i "s#ssl_certificate ;#ssl_certificate ${certificate_dir};#g" ${Install_dir}/nginx/conf/vhost/${domain}.conf
		sed -i "s#ssl_certificate_key ;#ssl_certificate_key ${key_dir};#g" ${Install_dir}/nginx/conf/vhost/${domain}.conf
		ln -sf ${PDNSAdmin_WEB_DIR} ${web_dir}
		${Install_dir}/nginx/sbin/nginx -s reload
		if [ $? -eq 0 ]; then
			echo -e "\033[32m"虚拟机添加成功"\033[0m"
			exit
		fi
	else
		read -p  "输入的域名已经存在，是否删除.(y|n)" action
		if [[ "${action}" = [nN] && "${action}" = "" ]]; then
			echo "域名删除失败请手动删除"
			exit
		else
			rm -rf ${Install_dir}/nginx/conf/vhost/${domain}.conf
			echo -e "\033[32m"域名已经删除成功"\033[0m"
		fi
	fi
}
#创建key并同步到远程服务器
Create_key()
{
	read -p "请输入同步服务器账号:" sync_user
	if [ "${sync_user}" = "" ]; then
		echo "当前选项不能为空。"
		exit
	elif [ "${sync_user}" != "" ]; then
		read -p "请输入同步服务器密码:" sync_password
		if [ "${sync_password}" = "" ]; then
			echo "当前选项不能为空。"
			exit
		elif [ "${sync_password}" != "" ]; then
			read -p "请输入同步服务器IP:" sync_ip
			if [ "${sync_ip}" = "" ]; then
				echo "当前选项不能为空。"
				exit
			elif [ "${sync_ip}" != "" ]; then
				echo -n "请输入同步服务器端口(回车使用默认22端口):"
				read port
				if [ "${port}" = "" ]; then
					port=22
				elif [ ! -e /usr/bin/expect ]; then
					echo "请yum install expect安装此工具"
					exit
				fi
			fi
		fi
	fi
    /usr/bin/ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
	COPY_ID=$(expect -c "
	spawn /usr/bin/ssh-copy-id -p ${port} ${sync_user}@${sync_ip}
	expect \"*sure you want to continue*\"
	send \"yes\r\"
	expect \"*password*\"
   	 send \"${sync_password}\r\"
    expect eof
	")
	echo "${COPY_ID}"
}
#安装Lsyncd
Install_Lsyncd()
{
	echo -e "\033[31m注意同步服务器一定要创建同步文件夹\033[0m"
	read -p "请输入同步服务器IP:" sync_ip
	echo -n "请输入同步服务器端口(回车使用默认22端口):"
	read port
	if [ "${port}" = "" ]; then
		port=22
	elif [ ! -e /usr/bin/rsync ]; then
		yum -y install rsync lsyncd
		mv /etc/lsyncd.conf /etc/lsyncd.conf_bak
		wget -cO /etc/lsyncd.conf ${D_url}/show/Nginx/conf/lsyncd.conf
		sed -i '10i\\t'"\"${sync_ip}\"" /etc/lsyncd.conf
		sed -i "s#port = 22#port = ${port}#g" /etc/lsyncd.conf
		systemctl enable lsyncd
		systemctl start lsyncd
		systemctl status lsyncd
	else
		yum -y install lsyncd
		mv /etc/lsyncd.conf /etc/lsyncd.conf_bak
		wget -cO /etc/lsyncd.conf ${D_url}/show/Nginx/conf/lsyncd.conf
		sed -i '10i\\t'"\"${sync_ip}\"" /etc/lsyncd.conf
		sed -i "s#port = 22#port = ${port}#g" /etc/lsyncd.conf
		systemctl enable lsyncd
		systemctl start lsyncd
		systemctl status lsyncd
	fi
}
#添加同步服务器
Sync_servers()
{
	echo -e "\033[34m每次只能填写一个ip\033[0m"
	read -p "请输入同步服务器账号:" sync_user
	if [ "${sync_user}" = "" ]; then
		echo "当前选项不能为空。"
		exit
	elif [ "${sync_user}" != "" ]; then
		read -p "请输入同步服务器密码:" sync_password
		if [ "${sync_password}" = "" ]; then
			echo "当前选项不能为空。"
			exit
		elif [ "${sync_password}" != "" ]; then
			read -p "请输入同步服务器IP:" sync_ip
			if [ "${sync_ip}" = "" ]; then
				echo "当前选项不能为空。"
				exit
			elif [ "${sync_ip}" != "" ]; then
				echo -n "请输入同步服务器端口(回车使用默认22端口):"
				read port
				if [ "${port}" = "" ]; then
					port=22
				elif [ ! -e /usr/bin/expect ]; then
					echo "请yum install expect安装此工具"
					exit
				fi
			fi
		fi
	fi
	COPY_ID=$(expect -c "
	spawn /usr/bin/ssh-copy-id -p ${port} ${sync_user}@${sync_ip}
	expect \"*password*\"
   	send \"${sync_password}\r\"
    expect eof
	")
	sed -i '10i\\t'"\"${sync_ip}\"" /etc/lsyncd.conf
	systemctl restart lsyncd
	echo "${COPY_ID}"

	
}
#Yum安装mariadb
add_rpm()
{
	if [ "${country}" = "CN" ]; then
		wget -cO /etc/yum.repos.d/mariadb.repo ${D_url}/show/rpm/mariadb-cn.repo
		rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
	else
		wget -cO /etc/yum.repos.d/mariadb.repo ${D_url}/show/rpm/mariadb-us.repo
		rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
	fi
}
mariadb()
{
	echo "1:安装MariaDB"
	echo "2:配置MariaDB_Galera_Cluster"
	echo -e "\033[33m直接回车或者输入其他将直接退出\033[0m"
	read -p "输入选项进行安装:" action
	
	if [[ ${action:-0} -eq 1 ]]; then #变量为空赋值为0
	echo -ne "\033[34m请输入数据库管理员密码(直接回车随机生成密码):\033[0m"
	read db_root_password
	#检测是否输入了密码
	if [ -z ${db_root_password} ]; then
		db_root_password=`head -c 100 /dev/urandom | tr -dc [:alnum:] |head -c 8` #随机生成8位字符作为密码
		echo -e "\033[31m未输入密码，将使用默认密码\033[0m"
	fi
	Check_os
	add_rpm
	setenforce 0
	
	yum install MariaDB-server MariaDB-client galera -y

	rm -rf /etc/my.cnf.d/*
	wget -cO /etc/my.cnf.d/server.cnf ${D_url}/show/Mysql/my.cnf
	
	systemctl start mariadb
	#开始配置Mysql_secure_installation
	SECURE_MYSQL=$(expect -c "
	set timeout 3
	spawn /usr/bin/mysql_secure_installation
	expect \"Enter current password for root (enter for none):\"
	send \"\r\"
	expect \"Set root password?\"
	send \"y\r\"
	expect \"New password:\"
	send \"${db_root_password}\r\"
	expect \"Re-enter new password:\"
	send \"${db_root_password}\r\"
	expect \"Remove anonymous users?\"
	send \"y\r\"
	expect \"Disallow root login remotely?\"
	send \"y\r\"
	expect \"Remove test database and access to it?\"
	send \"y\r\"
	expect \"Reload privilege tables now?\"
	send \"y\r\"
	expect eof
	")
	echo "${SECURE_MYSQL}"
	echo ${db_root_password} > /tmp/mysql_password.txt
	if [ -f /usr/bin/firewall-cmd ];then
		/usr/bin/firewall-cmd --zone=public --add-port=3306/tcp --permanent
		/usr/bin/firewall-cmd --reload
	else
		echo "请手动检查防火墙配置！"
	fi
	elif [[ ${action} -eq 2 ]]; then
		echo -ne "\033[31m是否创建XtraBackup授权账号\033[0m(只需在DB1上设置一次,y/n):"
		read xtrabackup_name
		if [[ "${xtrabackup_name}" = [yY] ]]; then
			read -p "输入XtraBackup账号密码:" sst_password
			db_root_password=`cat /tmp/mysql_password.txt`
			/usr/bin/mysql -u root -p${db_root_password} << EOF
	grant all on *.* to 'sst'@'localhost' identified by '${sst_password}';
	flush privileges;
EOF
		else
			echo -ne "\033[33m输入XtraBackup授权账号密码:\033[0m"
			read sst_password
		fi
		systemctl stop mysql
		read -p "输入集群名称:" cluster_name
		read -p "输入集群IP:" cluster_ip
		read -p "输入节点名称:" node_name
		read -p "输入节点IP:" node_ip
		
		yum install ${D_url}/show/rpm/percona-xtrabackup-24-2.4.4-1.el7.x86_64.rpm -y
		wget -cO /tmp/galera.conf ${D_url}/show/Mysql/galera.conf
		sed -i "s#wsrep_cluster_name=#wsrep_cluster_name=\"${cluster_name}\"#" /tmp/galera.conf
		sed -i "s#wsrep_cluster_address=#wsrep_cluster_address=\"gcomm://${cluster_ip}\"#" /tmp/galera.conf
		sed -i "s#wsrep_node_name=#wsrep_node_name=${node_name}#" /tmp/galera.conf
		sed -i "s#wsrep_node_address=#wsrep_node_address=${node_ip}#" /tmp/galera.conf
		sed -i "s#wsrep_sst_auth=#wsrep_sst_auth=sst:${sst_password}#" /tmp/galera.conf
		sed -i '/=2/ r /tmp/galera.conf' /etc/my.cnf.d/server.cnf
		sed -i "s#bind-address = 0.0.0.0#bind-address = ${node_ip}#" /etc/my.cnf.d/server.cnf

		if [ $? -eq 0 ]; then
			echo -ne "\033[34m是否启动Galera_Cluster(y/n):\033[0m"
			read action2
			if [[ "${action2}" = [yY] ]]; then
				/usr/bin/galera_new_cluster
			else
				systemctl start mysql
			fi
		fi
		sleep 3
		if [ -f /usr/bin/firewall-cmd ];then
			/usr/bin/firewall-cmd --zone=public --add-port=4567/tcp --permanent
			/usr/bin/firewall-cmd --zone=public --add-port=4568/tcp --permanent
			/usr/bin/firewall-cmd --zone=public --add-port=4444/tcp --permanent
			/usr/bin/firewall-cmd --reload
		else
			echo "请手动检查防火墙配置！"
		fi
	fi
	if [[ ${action} -eq 0 ]]; then
		echo -e "\033[31m请重新运行脚本，输入选项进行安装\033[0m"
		exit
	fi
}
#安装pdns
Install_pdns()
{
	echo "1:安装Master服务器"
	echo "2:安装Slave服务器"
	echo -e "\033[33m直接回车或者输入其他将直接退出\033[0m"

	read -p "请输入选项进行安装:" action

	if [[ ${action:-0} -eq 1 ]]; then
		read -p "输入主机名(完整的FQDN):" host_name
		if [ -z ${host_name} ]; then
			exit
		else
			read -p "输入需要创建的数据库用户名:" db_user
				if [ -z ${db_user} ]; then
					db_user=pdns
				fi
			read -p "输入需要创建的数据库用户密码:" db_user_password
				if [ -z ${db_user_password} ]; then
					db_user_password=`head -c 100 /dev/urandom | tr -dc [:alnum:] |head -c 8` #随机密码
				fi
			read -p "输入需要创建的数据库名:" db_name
				if [ -z ${db_name} ]; then
					db_name=pdns
				fi
			read -p "请输入api_key:" api_key
				if [ -z ${api_key} ]; then
					api_key=`head -c 100 /dev/urandom | tr -dc [:alnum:] |head -c 8` #随机密码
				fi
		fi

		#设置主机名
		/usr/bin/hostnamectl set-hostname ${host_name}
		#安装pdns
		wget -cO /etc/yum.repos.d/powerdns-auth-master.repo ${D_url}/show/rpm/centos-auth-master.repo
		rpm --import https://repo.powerdns.com/CBC8B383-pub.asc
		yum install pdns pdns-backend-mysql -y
		
		#创建数据库已经pdns用户
		username=root
		db_root_password=`cat /tmp/mysql_password.txt`
		mysql -u ${username} -p${db_root_password} << EOF
		CREATE DATABASE ${db_name};
		GRANT ALL ON ${db_name}.* TO '${db_user}'@'localhost' IDENTIFIED BY '${db_user_password}';
		FLUSH PRIVILEGES;
EOF
		wget -cO /tmp/pdns.sql ${D_url}/show/Mysql/pdns.sql
		mysql -u ${username} -p${db_root_password} -D ${db_name} < /tmp/pdns.sql
	#设置pdns配置文件
		mv /etc/pdns/pdns.conf /etc/pdns/pdns.conf_back
		wget -cO /etc/pdns/pdns.conf ${D_url}/show/PowerDNS/pdns_master.conf
		sed -i "s#gmysql-user=#gmysql-user=${db_user}#" /etc/pdns/pdns.conf
		sed -i "s#gmysql-password=#gmysql-password=${db_user_password}#" /etc/pdns/pdns.conf
		sed -i "s#gmysql-dbname=#gmysql-dbname=${db_name}#" /etc/pdns/pdns.conf
		sed -i "s#api-key=#api-key=${api_key}#" /etc/pdns/pdns.conf
		sed -i "s#default-soa-mail=#default-soa-mail=admin.${host_name}#" /etc/pdns/pdns.conf
		sed -i "s#default-soa-name=#default-soa-name=${host_name}#" /etc/pdns/pdns.conf

		if [ -f /usr/bin/firewall-cmd ];then
			/usr/bin/firewall-cmd --zone=public --add-port=53/udp --permanent
			/usr/bin/firewall-cmd --reload
		else
			echo "请手动检查防火墙配置！"
		fi
			
		systemctl enable pdns
		systemctl start pdns
		systemctl status pdns
	elif [[ ${action} -eq 2 ]]; then
		read -p "输入主机名(完整的FQDN):" host_name
		if [ -z ${host_name} ]; then
			exit
		else
			echo -e  "\033[33m以下信息全部使用Master服务器信息(此脚本使用Mariadb集群同步数据)\033[0m"
			read -p "输入数据库用户名(Master服务器数据库用户名):" db_user
				if [ -z ${db_user} ]; then
					db_user=pdns
				fi
			read -p "输入数据库用户密码(Master服务器数据库密):" db_user_password
				if [ -z ${db_user_password} ]; then
					echo -e "\033[31m重新Master服务器数据库密码即可\033[0m"
					exit
				fi
			read -p "输入数据库名(Master服务器数据库名):" db_name
				if [ -z ${db_name} ]; then
					db_name=pdns
				fi
		fi
	
		#设置主机名
		/usr/bin/hostnamectl set-hostname ${host_name}
		wget -cO /etc/yum.repos.d/powerdns-auth-master.repo ${D_url}/show/rpm/centos-auth-master.repo
		rpm --import https://repo.powerdns.com/CBC8B383-pub.asc
		yum install pdns pdns-backend-mysql -y
		
		#设置pdns配置文件
		mv /etc/pdns/pdns.conf /etc/pdns/pdns.conf_back
		wget -cO /etc/pdns/pdns.conf ${D_url}/show/PowerDNS/pdns_slave.conf
		sed -i "s#gmysql-user=#gmysql-user=${db_user}#" /etc/pdns/pdns.conf
		sed -i "s#gmysql-password=#gmysql-password=${db_user_password}#" /etc/pdns/pdns.conf
		sed -i "s#gmysql-dbname=#gmysql-dbname=${db_name}#" /etc/pdns/pdns.conf

		if [ -f /usr/bin/firewall-cmd ];then
			/usr/bin/firewall-cmd --zone=public --add-port=53/udp --permanent
			/usr/bin/firewall-cmd --reload
		else
			echo "请手动检查防火墙配置！"
		fi
		
		systemctl enable pdns
		systemctl start pdns
		systemctl status pdns
	fi
}
#安装pdns_admin
Install_pdns_admin()
{

	echo -n "是否开始安装PowerDNS-Admin(y|n):"
	read action

	if [[ "${action}" = [yY] ]]; then
		read -p "输入需要创建的数据库用户:" db_user
		if [ -z ${db_user} ]; then
			db_user=pdnsadmin
		fi
		read -p "输入需要创建的数据库用户密码:" db_user_password
		if [ -z ${db_user_password} ]; then
			db_user_password=`head -c 100 /dev/urandom | tr -dc [:alnum:] |head -c 8` #随机密码
		fi
		read -p "输入需要创建的数据库名:" db_name
		if [ -z ${db_name} ]; then
			db_name=pdnsadmin
		
		elif [[ "${country}" = "CN" && ! -d "/root/.pip" ]]; then
			mkdir ~/.pip
			cat > ~/.pip/pip.conf <<EOF
[global]
index-url = https://pypi.doubanio.com/simple/

[install]
trusted-host=pypi.doubanio.com
EOF
		fi

		yum install python34 python34-devel python-pip gcc mariadb-devel openldap-devel xmlsec1-devel xmlsec1-openssl libtool-ltdl-devel -y

		pip install -U pip
		pip install -U virtualenv
		pip install python-dotenv
		
		curl -sL https://dl.yarnpkg.com/rpm/yarn.repo -o /etc/yum.repos.d/yarn.repo
		rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg
		yum install yarn -y
		
		if [ "${country}" = "CN" ]; then
			git clone https://gitee.com/m1911/PowerDNS-Admin.git ${PDNSAdmin_WEB_DIR}
		else
			git clone https://github.com/ngoduykhanh/PowerDNS-Admin.git ${PDNSAdmin_WEB_DIR}
		fi
		
		cd ${PDNSAdmin_WEB_DIR}
		virtualenv -p python3 flask
		source ./flask/bin/activate
		pip install -r requirements.txt
		cp config_template.py config.py

		username=root
		db_root_password=`cat /tmp/mysql_password.txt`
		mysql -u ${username} -p${db_root_password} <<EOF
	CREATE DATABASE ${db_name};
	GRANT ALL ON ${db_name}.* TO '${db_user}'@'localhost' IDENTIFIED BY '${db_user_password}';
	FLUSH PRIVILEGES;
EOF
		sed -i "s#BIND_ADDRESS = '127.0.0.1'#BIND_ADDRESS = '0.0.0.0'#" ${PDNSAdmin_WEB_DIR}/config.py
		sed -i "s#SQLA_DB_HOST = '127.0.0.1'#SQLA_DB_HOST = 'localhost'#" ${PDNSAdmin_WEB_DIR}/config.py
		sed -i "s#SQLA_DB_USER = 'pda'#SQLA_DB_USER = '${db_user}'#" ${PDNSAdmin_WEB_DIR}/config.py
		sed -i "s#SQLA_DB_PASSWORD = 'changeme'#SQLA_DB_PASSWORD = '${db_user_password}'#" ${PDNSAdmin_WEB_DIR}/config.py
		sed -i "s#SQLA_DB_NAME = 'pda'#SQLA_DB_NAME = '${db_name}'#" ${PDNSAdmin_WEB_DIR}/config.py

		export FLASK_APP=app/__init__.py
		flask db upgrade
		yarn install --pure-lockfile
		flask assets build

	#Configuring Systemd and Gunicorn
		cat >"/etc/systemd/system/powerdns-admin.service"<<EOF
[Unit]
Description=PowerDNS-Admin
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=${PDNSAdmin_WEB_DIR}
ExecStart=${PDNSAdmin_WEB_DIR}/flask/bin/gunicorn --workers 2 --bind unix:${PDNSAdmin_WEB_DIR}/powerdns-admin.sock app:app

[Install]
WantedBy=multi-user.target
EOF
		chmod 755 /etc/systemd/system/powerdns-admin.service
		systemctl daemon-reload &&systemctl enable powerdns-admin &&systemctl start powerdns-admin
	fi

	if [[ ${action} = [nN] ]]; then
		echo -e "\033[31m请重新输入选项进行安装\033[0m"
		exit
	fi
}
arg1=$1
arg2=$2

case ${arg1} in
    [nN][gG][iI][nN][xX])
        Function_nginx ${arg2}
    	;;
    [rR][sS][yY][nN][cC])
		Function_rsync ${arg2}
    	;;
    [pP][dD][nN][sS])
		Function_pdns ${arg2}
    	;;
    *)
		echo "用法: mozhe nginx {install|add|ssl|pdns}"
		echo "用法: mozhe rsync {key|install|sync}"
		echo "用法: mozhe pdns {mysql|install|pdns}"
		exit 1
		;;
esac
