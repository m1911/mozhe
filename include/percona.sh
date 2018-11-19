#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -e

installPXC()
{
	echo -ne "\033[34m请设置管理员密码(直接回车随机生成密码):\033[0m"
	read rootPassword
	#检测是否输入了密码
	if [ -z ${rootPassword} ]; then
		rootPassword=`head -c 100 /dev/urandom | tr -dc [:alnum:] |head -c 16` #随机生成8位字符作为密码
		echo -e "\033[31m已经自动生成随机密码\033[0m"
	fi
	Check_selinux
	mysqlCHECKos

	yum -y install ${downUrl}/show/rpm/percona-release-0.1-6.noarch.rpm
	yum -y install Percona-XtraDB-Cluster-57
	mv /etc/my.cnf /etc/my.cnf.bak
	wget -cO /etc/my.cnf ${downUrl}/show/Mysql/Percona_my.cnf
	mkdir -p ${dataDir}
	chown -R mysql.mysql ${dataDir}
	systemctl start mysql
	tmpPassword=`cat /data/mysql/error.log | grep "A temporary password" | awk -F " " '{print$11}'`
	SECURE_MYSQL=$(expect -c "
		set timeout 3
		spawn /usr/bin/mysql_secure_installation
		expect \"Enter password for user root:\"
		send \"${tmpPassword}\r\"
		expect \"New password:\"
		send \"${rootPassword}\r\"
		expect \"Re-enter new password:\"
		send \"${rootPassword}\r\"
		expect \"Press y|Y for Yes, any other key for No:\"
		send \"n\r\"
		expect \"Change the password for root*\"
		send \"n\r\"
		expect \"Remove anonymous users*\"
		send \"y\r\"
		expect \"Disallow root login remotely*\"
		send \"y\r\"
		expect \"Remove test database and access to it*\"
		send \"y\r\"
		expect \"Reload privilege tables now*\"
		send \"y\r\"
		expect eof
		")
	echo "${SECURE_MYSQL}"
	echo ${rootPassword} > /tmp/mysqlPassword.txt
	mysqlCHECKfirewall
}

initialPXC()
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
	systemctl stop mysql
	wget -cO /tmp/galera.cnf ${downUrl}/show/Mysql/Percona_galera.cnf
	sed -i "s#wsrep_cluster_name=#wsrep_cluster_name=\"${clusterNAME}\"#" /tmp/galera.cnf
	sed -i "s#wsrep_cluster_address=\"gcomm://\"#wsrep_cluster_address=\"gcomm://${clusterIP}\"#" /tmp/galera.cnf
	sed -i "s#wsrep_node_name=#wsrep_node_name=${nodeNAME}#" /tmp/galera.cnf
	sed -i "s#wsrep_node_address=#wsrep_node_address=${nodeIP}#" /tmp/galera.cnf
	sed -i "s#wsrep_sst_auth=#wsrep_sst_auth=\"sstuser:${sstPassword}\"#" /tmp/galera.cnf
	sed -i '/#PXC/ r /tmp/galera.cnf' /etc/my.cnf
	systemctl start mysql@bootstrap.service
}

nodePXC()
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
	Check_selinux
	mysqlCHECKos

	yum -y install ${downUrl}/show/rpm/percona-release-0.1-6.noarch.rpm
	yum -y install Percona-XtraDB-Cluster-57
	mv /etc/my.cnf /etc/my.cnf.bak
	wget -cO /etc/my.cnf ${downUrl}/show/Mysql/Percona_node.cnf
	mkdir -p ${dataDir}
	chown -R mysql.mysql ${dataDir}
	sed -i "s#wsrep_cluster_name=#wsrep_cluster_name=\"${clusterNAME}\"#" /etc/my.cnf
	sed -i "s#wsrep_cluster_address=\"gcomm://\"#wsrep_cluster_address=\"gcomm://${clusterIP}\"#" /etc/my.cnf
	sed -i "s#wsrep_node_name=#wsrep_node_name=${nodeNAME}#" /etc/my.cnf
	sed -i "s#wsrep_node_address=#wsrep_node_address=${nodeIP}#" /etc/my.cnf
	sed -i "s#wsrep_sst_auth=#wsrep_sst_auth=\"sstuser:${sstPassword}\"#" /etc/my.cnf
	mysqlCHECKfirewall
	systemctl start mysql
	#/usr/bin/mysqld_safe --defaults-file=/etc/my.cnf &
}
