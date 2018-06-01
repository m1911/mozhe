#Docker启动说明

1、下载 git clone https://github.com/m1911/mozhe.git 把 目录里面的 conf和ssl 目录复制到需要挂载到docker里面目录下面
2、创建一个vhost目录用来管理添加删除虚拟机

#启动命令
docker run --name waf -p 80:80 -p 443 -v /data/openstar:/opt/openresty/openstar -v /data/vhost:/opt/openresty/nginx/conf/vhost -v /data/ssl:/opt/openresty/nginx/conf/ssl -d nginx 

说明：
-V：挂载本地目录到容器里面