# Nginx一键反代缓存脚本，PowerDNS和PowerDNS-Admin安装配置脚本

## 脚本说明：
1、mozhe.sh 为主脚本。 <br>
2、Monitoring.sh 为监控脚本。

## 脚本操作说明：
chmod u+x mozhe.sh 添加执行权限默认只能使用sh mozhe.sh <br>

### 用法1: mozhe nginx {install|add|ssl|pdns} <br>
		install：安装nginx
		add：添加vhost
		ssl：添加https_vhost
		pdns：添加pdns_admin vhost
### 用法2: mozhe rsync {key|install|sync}
		key：创建ssh免登陆key
		install：安装Lsyncd
		sync：添加同步服务器
### 用法3: mozhe pdns {mysql|install|admin}
		mysql：安装mysql
		install：安装pdns
		admin：安装PowerDNS-Admin

# 目录说明
```
Nginx安装目录：/usr/local/mozhe
Mysql目录：/var/lib/mysql
Mysql配置文件目录：/etc/my.cnf.d/
Pdns配置文件目录：/etc/pdns/
PDNSAdmin安装目录：/home/pdns_admin
```

