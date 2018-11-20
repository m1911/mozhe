#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -e

installMYSQLserver(){
	echo -ne "\033[33m请设置管理员密码(直接回车随机生成密码):\033[0m"
	read rootPassword
	#检测是否输入了密码
	if [ -z ${rootPassword} ]; then
		rootPassword=`head -c 100 /dev/urandom | tr -dc [:alnum:] |head -c 16` #随机生成8位字符作为密码
		echo -e "\033[31m已经自动生成随机密码\033[0m"
	fi
	Check_selinux
	mysqlCHECKos

	yum -y install MariaDB-server MariaDB-client
	mv /etc/my.cnf /etc/my.cnf.bak
	wget -cO /etc/my.cnf ${downUrl}/show/Mysql/mariadb_my.cnf
	mkdir -p ${dataDir}
	cp -R /var/lib/mysql/* ${dataDir}
	chown -R mysql.mysql ${dataDir}
	systemctl start mariadb
	#开始配置Mysql_secure_installation
	SECURE_MYSQL=$(expect -c "
	set timeout 3
	spawn /usr/bin/mysql_secure_installation -S /tmp/mysql.sock
	expect \"Enter current password for root (enter for none):\"
	send \"\r\"
	expect \"Set root password?\"
	send \"y\r\"
	expect \"New password:\"
	send \"${rootPassword}\r\"
	expect \"Re-enter new password:\"
	send \"${rootPassword}\r\"
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
	echo ${rootPassword} > /tmp/mysqlPassword.txt
	mysqlCHECKfirewall
}
#初始节点
initialGALERAserver()
{
	read -p "输入集群名称(所有节点名称一致)：" clusterNAME
	if [ -z ${clusterNAME} ]; then
		echo "集群名称不能为空"
		exit
	fi
	read -p "请输入集群IP：" clusterIP
	if [ -z ${clusterIP} ]; then
		echo "集群IP不能为空"
		exit
	fi
	read -p "输入节点名称(名称不能重复)：" nodeNAME
	if [ -z ${nodeNAME} ]; then
		echo "节点名称不能为空"
		exit
	fi
	read -p "输入当前节点IP：" nodeIP
	if [ -z ${nodeIP} ]; then
		echo "节点IP不能为空"
		exit
	fi
	read -p "设置同步账号密码：" sstPassword
	if [ -z ${sstPassword} ]; then
		echo "密码不能为空"
		exit
	fi
	rootPassword=`cat /tmp/mysqlPassword.txt`
	/usr/bin/mysql -u root -p${rootPassword} << EOF
	CREATE USER 'sstuser'@'localhost' IDENTIFIED BY '${sstPassword}';
	GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO 'sstuser'@'localhost';
    FLUSH PRIVILEGES;
EOF
	systemctl stop mariadb
	wget -cO /tmp/galera.cnf ${downUrl}/show/Mysql/mariadb_galera.cnf
	sed -i "s#wsrep_cluster_name=#wsrep_cluster_name=\"${clusterNAME}\"#" /tmp/galera.cnf
	sed -i "s#wsrep_cluster_address=\"gcomm://\"#wsrep_cluster_address=\"gcomm://${clusterIP}\"#" /tmp/galera.cnf
	sed -i "s#wsrep_node_name=#wsrep_node_name=${nodeNAME}#" /tmp/galera.cnf
	sed -i "s#wsrep_node_address=#wsrep_node_address=${nodeIP}#" /tmp/galera.cnf
	sed -i "s#wsrep_sst_auth=#wsrep_sst_auth=\"sstuser:${sstPassword}\"#" /tmp/galera.cnf
	sed -i '/#galera/ r /tmp/galera.cnf' /etc/my.cnf
	galera_new_cluster
}
configNODEserver()
{
	read -p "输入集群名称(所有节点名称一致)：" clusterNAME
	if [ -z ${clusterNAME} ]; then
		echo "集群名称不能为空"
		exit
	fi
	read -p "请输入集群IP：" clusterIP
	if [ -z ${clusterIP} ]; then
		echo "集群IP不能为空"
		exit
	fi
	read -p "输入节点名称(名称不能重复)：" nodeNAME
	if [ -z ${nodeNAME} ]; then
		echo "节点名称不能为空"
		exit
	fi
	read -p "输入当前节点IP：" nodeIP
	if [ -z ${nodeIP} ]; then
		echo "节点IP不能为空"
		exit
	fi
	read -p "设置同步账号密码：" sstPassword
	if [ -z ${sstPassword} ]; then
		echo "密码不能为空"
		exit
	fi
	systemctl stop mariadb
	wget -cO /tmp/galera.cnf ${downUrl}/show/Mysql/mariadb_galera.cnf
	sed -i "s#wsrep_cluster_name=#wsrep_cluster_name=\"${clusterNAME}\"#" /tmp/galera.cnf
	sed -i "s#wsrep_cluster_address=\"gcomm://\"#wsrep_cluster_address=\"gcomm://${clusterIP}\"#" /tmp/galera.cnf
	sed -i "s#wsrep_node_name=#wsrep_node_name=${nodeNAME}#" /tmp/galera.cnf
	sed -i "s#wsrep_node_address=#wsrep_node_address=${nodeIP}#" /tmp/galera.cnf
	sed -i "s#wsrep_sst_auth=#wsrep_sst_auth=\"sstuser:${sstPassword}\"#" /tmp/galera.cnf
	sed -i '/#galera/ r /tmp/galera.cnf' /etc/my.cnf
	tee /etc/systemd/system/mariadb.service.d/timeoutstartsec.conf <<EOF
[Service] 
TimeoutSec=infinity
EOF
	systemctl start mariadb
}