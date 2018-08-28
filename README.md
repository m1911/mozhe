注：<br>
```
使用
groupadd www
useradd -M -s /sbin/nologin -g www www
```
创建www用户和组，不创建的话映射出来的缓存目录会因为权限问题无法删除缓存

# Docker启动说明

1、国外主机使用 git clone https://github.com/m1911/mozhe.git 下载 把目录里面的除了docker以为的目录负载到需要挂载到docker里面目录下面

<br>2、国内主机使用 git clone https://gitee.com/m1911/mozhe.git 下载 把目录里面的除了docker以为的目录负载到需要挂载到docker里面目录下面

# 启动命令
使用docker-compose 来启动目录下面的nginx.yml 配置文件
<br>使用docker-compose -f nginx.yml 来指定配置文件进行启动
<br>下面是配置文件内容
```
version: '2'
services:
  nginx:
    image: 'm1911/mozhe'
    container_name: nginx
    restart: always #自动重启
    ports:
      - '80:9080'
      - '443:9443'
    volumes:
      - /nginx/ngx_conf:/opt/openresty/ngx_conf 
      - /nginx/openstar:/opt/openresty/openstar 
      - /nginx/vhost:/opt/openresty/nginx/conf/vhost 
      - /nginx/ssl:/opt/openresty/nginx/conf/ssl 
      - /nginx/wwwlogs:/data/wwwlogs
```