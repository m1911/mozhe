# Nginx一键反代缓存脚本，PowerDNS和PowerDNS-Admin安装配置脚本

## 脚本说明：
1、install.sh 为主脚本。 <br>
2、Monitoring.sh 为监控脚本。

## 脚本操作说明：
chmod u+x install.sh 添加执行权限默认只能使用bash install.sh <br>

### 用法1:  
		install.sh nginx #直接安装nginx
### 用法2:
		install.sh rsync {key|install|sync}
		key：创建ssh免登陆key
		install：安装Lsyncd
		sync：添加同步服务器
### 用法3:
		install.sh mysql {install|init|node}
		install：安装mysql
		init：初始化第一节点
		node：配置其他节点
### 用法4:
		install.sh pdns {install|node|admin}
		install：安装pdns
		node：安装从pdns
		admin：安装pdns_admin
### 用法5:
		install.sh vhost {add|ssl|pdns}
		add：添加80端口虚拟机
		ssl：添加ssl虚拟机
		pdns：添加pdns_admin虚拟机
# 目录说明
```
Nginx安装目录：/usr/local/mozhe
Mysql目录：/data/mysql
Mysql配置文件目录：/etc/my.cnf
Pdns配置文件目录：/etc/pdns/
PDNSAdmin安装目录：/home/pdns_admin
```

