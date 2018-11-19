#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -e
#安装master_pdns
installMASTERpdns()
{
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
	hostnamectl set-hostname ${host_name}
	#安装pdns
	curl -o /etc/yum.repos.d/powerdns-auth-master.repo https://repo.powerdns.com/repo-files/centos-auth-master.repo
	rpm --import https://repo.powerdns.com/CBC8B383-pub.asc
	yum -y install pdns pdns-backend-mysql
		
	#创建数据库已经pdns用户
	username=root
	db_root_password=`cat /tmp/mysqlPassword.txt`
	mysql -u ${username} -p${db_root_password} << EOF
	CREATE DATABASE ${db_name};
	GRANT ALL ON ${db_name}.* TO '${db_user}'@'localhost' IDENTIFIED BY '${db_user_password}';
	FLUSH PRIVILEGES;
EOF
	wget -cO /tmp/pdns.sql ${downUrl}/show/Mysql/pdns.sql
	mysql -u ${username} -p${db_root_password} -D ${db_name} < /tmp/pdns.sql
	#设置pdns配置文件
	mv /etc/pdns/pdns.conf /etc/pdns/pdns.conf_back
	wget -cO /etc/pdns/pdns.conf ${downUrl}/show/PowerDNS/pdns_master.conf
	sed -i "s#gmysql-user=#gmysql-user=${db_user}#" /etc/pdns/pdns.conf
	sed -i "s#gmysql-password=#gmysql-password=${db_user_password}#" /etc/pdns/pdns.conf
	sed -i "s#gmysql-dbname=#gmysql-dbname=${db_name}#" /etc/pdns/pdns.conf
	sed -i "s#api-key=#api-key=${api_key}#" /etc/pdns/pdns.conf
	sed -i "s#default-soa-mail=#default-soa-mail=admin.${host_name}#" /etc/pdns/pdns.conf
	sed -i "s#default-soa-name=#default-soa-name=${host_name}#" /etc/pdns/pdns.conf
	dnsCHECKfirewall	
	systemctl enable pdns
	systemctl start pdns
	systemctl status pdns
}
#安装slave_pdns
installSLAVEpdns()
{
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
	hostnamectl set-hostname ${host_name}
	curl -o /etc/yum.repos.d/powerdns-auth-master.repo https://repo.powerdns.com/repo-files/centos-auth-master.repo
	rpm --import https://repo.powerdns.com/CBC8B383-pub.asc
	yum -y install pdns pdns-backend-mysql
		
	#设置pdns配置文件
	mv /etc/pdns/pdns.conf /etc/pdns/pdns.conf_back
	wget -cO /etc/pdns/pdns.conf ${downUrl}/show/PowerDNS/pdns_slave.conf
	sed -i "s#gmysql-user=#gmysql-user=${db_user}#" /etc/pdns/pdns.conf
	sed -i "s#gmysql-password=#gmysql-password=${db_user_password}#" /etc/pdns/pdns.conf
	sed -i "s#gmysql-dbname=#gmysql-dbname=${db_name}#" /etc/pdns/pdns.conf
	dnsCHECKfirewall
	systemctl enable pdns
	systemctl start pdns
	systemctl status pdns
}
#安装pdns_admin
installPDNSadmin()
{
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

		username=root
		db_root_password=`cat /tmp/mysqlPassword.txt`
		mysql -u ${username} -p${db_root_password} <<EOF
	CREATE DATABASE ${db_name} CHARACTER SET utf8 COLLATE utf8_general_ci;
	GRANT ALL ON ${db_name}.* TO '${db_user}'@'localhost' IDENTIFIED BY '${db_user_password}';
	FLUSH PRIVILEGES;
EOF
		yum -y install https://centos7.iuscommunity.org/ius-release.rpm
		yum -y install python36u python36u-devel python36u-pip
		pip3.6 install -U pip
		pip install -U virtualenv
		rm -f /usr/bin/python3 && ln -s /usr/bin/python3.6 /usr/bin/python3
		yum -y install gcc MariaDB-devel MariaDB-shared openldap-devel xmlsec1-devel xmlsec1-openssl libtool-ltdl-devel
		curl -sL https://dl.yarnpkg.com/rpm/yarn.repo -o /etc/yum.repos.d/yarn.repo
		yum -y install yarn
		
		if [ "${country}" = "CN" ]; then
			git clone https://gitee.com/m1911/PowerDNS-Admin.git ${pdnsadminWEBdir}
		else
			git clone https://github.com/ngoduykhanh/PowerDNS-Admin.git ${pdnsadminWEBdir}
		fi
		
		cd ${pdnsadminWEBdir}
		virtualenv -p python3 flask
		. ./flask/bin/activate
		pip install python-dotenv
		pip install -r requirements.txt
		cp config_template.py config.py

		sed -i "s#SQLA_DB_USER = 'pda'#SQLA_DB_USER = '${db_user}'#" ${pdnsadminWEBdir}/config.py
		sed -i "s#SQLA_DB_PASSWORD = 'changeme'#SQLA_DB_PASSWORD = '${db_user_password}'#" ${pdnsadminWEBdir}/config.py
		sed -i "s#SQLA_DB_NAME = 'pda'#SQLA_DB_NAME = '${db_name}'#" ${pdnsadminWEBdir}/config.py

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
WorkingDirectory=${pdnsadminWEBdir}
ExecStart=${pdnsadminWEBdir}/flask/bin/gunicorn --workers 2 --bind unix:${pdnsadminWEBdir}/powerdns-admin.sock app:app

[Install]
WantedBy=multi-user.target
EOF
		chmod 755 /etc/systemd/system/powerdns-admin.service
		systemctl daemon-reload &&systemctl enable powerdns-admin &&systemctl start powerdns-admin
}