注：<br>
openresty和tengine 配置文件的路径完全不相同切勿混用！！！<br>
Openresty使用的是：Libressl<br>
Tengine使用的是：Openssl
```
使用
groupadd www
useradd -M -s /sbin/nologin -g www www
```
创建www用户和组，不创建的话映射出来的缓存目录会因为权限问题无法删除缓存

# Docker启动说明

1、国外主机使用 git clone https://github.com/m1911/mozhe.git 下载 选择需要的WebServer目录到里面去把需要复制的内容复制到指定目录，WebServer目录Dockerfile为创建镜像所使用的文件。

<br>2、国内主机使用 git clone https://gitee.com/m1911/mozhe.git 下载 选择需要的WebServer目录到里面去把需要复制的内容复制到指定目录，WebServer目录Dockerfile为创建镜像所使用的文件。

# 启动命令
使用docker-compose 来启动目录下面的openresty.yml 配置文件
<br>使用docker-compose -f nginx.yml 来指定配置文件进行启动
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
