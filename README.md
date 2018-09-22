## 已经删除ngx_cache_purge模块，使用shell脚本来进行删除缓存，脚本是百度找的。
注：<br>
Openresty使用的是：Libressl<br>
```
使用
groupadd www
useradd -M -s /sbin/nologin -g www www
```
创建www用户和组，不设置缓存目录权限直接挂在会导致nginx无法写入缓存<br>
## 安装Docker之前请用up_kernel.sh把内核升级到4.x版本保证docker的稳定性
## 卸载旧内核命令
```
yum autoremove kernel-3.10.0-* -y #直接卸载3.10.x的旧内核
```

# Docker和docker-compose安装

```
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
wget -c https://github.com/docker/compose/releases/download/1.22.0/docker-compose-Linux-x86_64 -O /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
systemctl enable docker
systemctl start docker
``` 

# Docker启动说明

1、国外主机使用 git clone https://github.com/m1911/mozhe.git 下载 选择需要的WebServer目录到里面去把需要复制的内容复制到指定目录，WebServer目录Dockerfile为创建镜像所使用的文件。

<br>2、国内主机使用 git clone https://gitee.com/m1911/mozhe.git 下载 选择需要的WebServer目录到里面去把需要复制的内容复制到指定目录，WebServer目录Dockerfile为创建镜像所使用的文件。

# 启动命令
使用docker-compose 来启动目录下面的openresty.yml 配置文件
<br>使用docker-compose -f openresty.yml 来指定配置文件进行启动
<br>下面是openresty.yml配置文件内容
```
version: '2'
services:
  nginx:
    image: 'm1911/mozhe'
    container_name: nginx
    restart: always #自动重启
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - /nginx/ngx_conf:/opt/openresty/ngx_conf 
      - /nginx/openstar:/opt/openresty/openstar 
      - /nginx/vhost:/opt/openresty/nginx/conf/vhost 
      - /nginx/ssl:/opt/openresty/nginx/conf/ssl 
      - /nginx/wwwlogs:/data/wwwlogs
```
# WAF鸣谢
[@jx-sec](https://github.com/jx-sec/jxwaf)
