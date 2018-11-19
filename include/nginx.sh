#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -e

#按任意键继续
Get_char()
{
	clear
	echo "+-----------------------------------------------------------------------+"
	echo "|                          欢迎使用安装Nginx脚本                        |"
	echo "+-----------------------------------------------------------------------+"
	echo "|                              Nginx一键脚本                            |"
	echo "+-----------------------------------------------------------------------+"
	echo "|                     更多信息请访问 https://github.com/m1911           |"
	echo "+-----------------------------------------------------------------------+"
	echo ""
	echo "Press any key to start...or Press Ctrl+c to cancel"
	OLDCONFIG=`stty -g`
	stty -icanon -echo min 1 time 0
	dd count=1 2>/dev/null
	stty ${OLDCONFIG}
}
#获取CPU用来编译
Check_cpu()
{
	physical_cpu=`cat /proc/cpuinfo | grep 'physical id' | sort | uniq | wc -l`
	if [ ${physical_cpu} -le 1 ]; then
		cpu=1
	else
		divisor=2
		results=$[physical_cpu/divisor]
		cpu=${results}
	fi
}
#安装扩展
Install_extensions()
{
	mkdir -p /tmp/src
	cd /tmp/src
	 wget -c https://dl.ilankui.com/show/Nginx/extended/jemalloc-5.1.0.tar.bz2
	tar xjf jemalloc-5.1.0.tar.bz2 &&cd jemalloc-5.1.0
	./configure
    make -j${cpu} &&make -j${cpu} install
    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
    ldconfig &&cd ..
	
	wget -c ${downUrl}/show/Nginx/extended/openssl-1.1.0i.tar.gz
	tar zxf openssl-1.1.0i.tar.gz &&cd openssl-1.1.0i
	./config
	make -j${cpu} &&make -j${cpu} install
	cd ..
	
	wget -c ${downUrl}/show/Nginx/extended/pcre-8.39.tar.bz2
	tar xjf pcre-8.39.tar.bz2 &&cd pcre-8.39
	./configure
	make -j${cpu} &&make -j${cpu} install
	cd ..
	
	wget -cO v1.13.35.2-stable.tar.gz ${downUrl}/show/Nginx/extended/incubator-pagespeed-ngx-1.13.35.2-stable.tar.gz
	tar zxf v1.13.35.2-stable.tar.gz
	mv incubator-pagespeed-ngx-1.13.35.2-stable ngx_pagespeed &&cd ngx_pagespeed
	wget -c ${downUrl}/show/Nginx/extended/1.13.35.2-x64.tar.gz
	tar zxf 1.13.35.2-x64.tar.gz &&cd ..
	
	wget -c ${downUrl}/show/Nginx/extended/ngx_brotli.tgz
	tar zxf ngx_brotli.tgz
	
	wget -c ${downUrl}/show/Nginx/extended/ngx_cache_purge-2.5.tar.gz
	tar zxf ngx_cache_purge-2.5.tar.gz
}
#安装nginx
Install_nginx()
{
	begin_time=$(date +%s)
	Get_char
	nginxCHECKos
	Check_cpu
	Install_extensions
	groupadd www &&useradd -M -s /sbin/nologin -g www www
	mkdir -p /data/cache /data/wwwlogs /data/ngx_pagespeed
	chown www.www -R  /data/ngx_pagespeed /data/wwwlogs /data/cache
	chmod -R 777  /data/ngx_pagespeed /data/wwwlogs /data/cache
	cd /tmp/src
	wget -c https://openresty.org/download/openresty-${Openresty}.tar.gz
	tar zxf openresty-${Openresty}.tar.gz &&cd openresty-1.13.6.2
	sed -i  '/NGINX_VER/{s/openresty/Mozhe/g}'  ./bundle/nginx-1.13.6/src/core/nginx.h
    sed -i "s#Server: openresty#Server: Mozhe#" ./bundle/nginx-1.13.6/src/http/ngx_http_header_filter_module.c
    sed -i "s#\"<hr><center>openresty<\/center>\"#\"<hr><center>Mozhe<\/center>\"#" ./bundle/nginx-1.13.6/src/http/ngx_http_special_response.c
	./configure --user=www --group=www --prefix=${installDir} --with-luajit --with-http_v2_module --with-http_gunzip_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_ssl_module --with-ld-opt="-ljemalloc" --with-pcre-jit --with-pcre=/tmp/src/pcre-8.39 --with-openssl=/tmp/src/openssl-1.1.0i --add-module=/tmp/src/ngx_brotli --add-module=/tmp/src/ngx_pagespeed --add-module=/tmp/src/ngx_cache_purge-2.5
	make &&make install
	ln -s ${installDir}/nginx/sbin/* /usr/local/sbin/
	mv ${installDir}/nginx/conf/nginx.conf ${installDir}/nginx/conf/nginx.conf_bak
	wget -cO ${installDir}/nginx/conf/nginx.conf ${downUrl}/show/Nginx/conf/nginx.conf
	mkdir -p ${installDir}/nginx/conf/vhost ${installDir}/nginx/conf/ssl
	wget -cO /lib/systemd/system/nginx.service ${downUrl}/show/Nginx/nginx.service
	${installDir}/nginx/sbin/nginx -t
	if [ $? -eq 0 ]; then
		systemctl enable nginx
		systemctl start nginx
		systemctl status nginx
	fi
	end_time=$(date +%s)
	cost_time=$((end_time - begin_time))
	echo "此脚本一共耗时${cost_time}秒"
	nginxCHECKfirewall
}