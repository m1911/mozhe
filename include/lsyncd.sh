#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -e
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
		wget -cO /etc/lsyncd.conf ${downUrl}/show/Nginx/conf/lsyncd.conf
		sed -i '10i\\t'"\"${sync_ip}\"" /etc/lsyncd.conf
		sed -i "s#port = 22#port = ${port}#g" /etc/lsyncd.conf
		systemctl enable lsyncd
		systemctl start lsyncd
		systemctl status lsyncd
	else
		yum -y install lsyncd
		mv /etc/lsyncd.conf /etc/lsyncd.conf_bak
		wget -cO /etc/lsyncd.conf ${downUrl}/show/Nginx/conf/lsyncd.conf
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