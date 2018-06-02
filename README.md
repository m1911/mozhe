# Docker启动说明

1、下载 git clone https://github.com/m1911/mozhe.git 把 目录里面的 ngx_conf、openstar和ssl 目录复制到需要挂载到docker里面目录下面
<br>2、需要手动创建的目录
<br>vhost：添加和删除域名使用
<br>wwwlogs：域名访问日志（根据个人需要创建和挂载）


# 启动命令
```docker run --name waf -p 80:80 -p 443:443 -v /data/ngx_conf:/opt/openresty/ngx_conf -v /data/openstar:/opt/openresty/openstar -v /data/vhost:/opt/openresty/nginx/conf/vhost -v /data/ssl:/opt/openresty/nginx/conf/ssl -v /data/wwwlogs:/data/wwwlogs -d nginx```

说明：
<br>-v：挂载本地目录到容器里面