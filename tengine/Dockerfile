# Dockerfile - Debian 9 Stretch - DEB version

ARG RESTY_IMAGE_BASE="debian"
ARG RESTY_IMAGE_TAG="stretch-slim"
FROM ${RESTY_IMAGE_BASE}:${RESTY_IMAGE_TAG}

MAINTAINER m1911 2018年8月29日

ARG Make_J="2" 
ARG SRC_DIR="/opt/src"
ARG Jemalloc_Version="5.1.0"
ARG Libressl_Version="2.7.4"
ARG Pagespeed_Version="1.13.35.2"
ARG Ngx_cache_purge="2.5"
ARG Lua_cjson="2.1.0.6"
ARG Ngx_devel_kit="0.3.1rc1"
ARG Nginx_lua_module="0.10.13"
ARG Tengine_Version="2.2.2"
ARG Install_DIR="/usr/local/nginx"

RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y ca-certificates wget build-essential unzip libpcre3 libpcre3-dev git bzip2 uuid-dev zlib1g.dev \
    && groupadd www \
    && useradd -s /sbin/nologin -g www www \
    && mkdir -p ${SRC_DIR} \
    && mkdir -p /data/cache \
    && mkdir -p /data/wwwlogs \
    && mkdir -p /data/ngx_pagespeed \
    && chown www.www -R  /data/ngx_pagespeed /data/wwwlogs /data/cache \
    && chmod -R 777  /data/ngx_pagespeed /data/wwwlogs /data/cache \
    && cd ${SRC_DIR} \
    && wget -c https://github.com/jemalloc/jemalloc/releases/download/${Jemalloc_Version}/jemalloc-${Jemalloc_Version}.tar.bz2 \
    && tar xjf jemalloc-${Jemalloc_Version}.tar.bz2 \
    && cd jemalloc-${Jemalloc_Version} \
    && ./configure \
    && make && make install \
    && echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf \
    && ldconfig \
<<<<<<< HEAD
    && cd .. \
	&& wget -c https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${Libressl_Version}.tar.gz \
    && tar zxf libressl-${Libressl_Version}.tar.gz \
=======
    && cd ../ \
    && wget -c https://www.openssl.org/source/openssl-${Openssl_Version}.tar.gz \
    && tar zxf openssl-${Openssl_Version}.tar.gz \
>>>>>>> 888e3e2790642b71c52dbfdba5869d2d57248ee9
    && cd ${SRC_DIR} \
    && wget -c https://github.com/apache/incubator-pagespeed-ngx/archive/v${Pagespeed_Version}-stable.tar.gz \
    && tar zxf v${Pagespeed_Version}-stable.tar.gz \ 
    && mv incubator-pagespeed-ngx-${Pagespeed_Version}-stable/ ngx_pagespeed \
<<<<<<< HEAD
<<<<<<< HEAD
	&& cd ngx_pagespeed \
	&& wget -c https://dl.google.com/dl/page-speed/psol/${Pagespeed_Version}-x64.tar.gz \
	&& tar zxf ${Pagespeed_Version}-x64.tar.gz \
	&& cd .. \
    && wget -c https://github.com/nginx-modules/ngx_cache_purge/archive/${Ngx_cache_purge}.tar.gz \
    && tar zxf ${Ngx_cache_purge}.tar.gz \
	&& wget -c http://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz \
	&& tar zxf LuaJIT-2.1.0-beta3.tar.gz \
	&& cd LuaJIT-2.1.0-beta3 \
	&& make && make install \
	&& cd .. \
	&& wget -c https://github.com/openresty/lua-cjson/archive/${Lua_cjson}.tar.gz \
	&& tar zxf ${Lua_cjson}.tar.gz \
	&& cd lua-cjson-${Lua_cjson} \
	&& sed -i 's@^LUA_INCLUDE_DIR.*@&/luajit-2.1@' Makefile \
    && make && make install \
	&& cd .. \
	&& wget -c https://github.com/simplresty/ngx_devel_kit/archive/v${Ngx_devel_kit}.tar.gz \
	&& tar zxf v${Ngx_devel_kit}.tar.gz \
	&& wget -c https://github.com/openresty/lua-nginx-module/archive/v${Nginx_lua_module}.tar.gz \
	&& tar zxf v${Nginx_lua_module}.tar.gz \
	&& wget -c https://github.com/alibaba/tengine/archive/tengine-${Tengine_Version}.tar.gz \
=======
    && cd ngx_pagespeed \
    && wget -c https://dl.google.com/dl/page-speed/psol/${Pagespeed_Version}-x64.tar.gz \
    && tar zxf ${Pagespeed_Version}-x64.tar.gz \
    && cd ../ \
    && wget -c https://github.com/nginx-modules/ngx_cache_purge/archive/${Ngx_cache_purge}.tar.gz \
    && tar zxf ${Ngx_cache_purge}.tar.gz \
=======
    && cd ngx_pagespeed \
    && wget -c https://dl.google.com/dl/page-speed/psol/${Pagespeed_Version}-x64.tar.gz \
    && tar zxf ${Pagespeed_Version}-x64.tar.gz \
    && cd ../ \
    && wget -c https://github.com/nginx-modules/ngx_cache_purge/archive/${Ngx_cache_purge}.tar.gz \
    && tar zxf ${Ngx_cache_purge}.tar.gz \
>>>>>>> 888e3e2790642b71c52dbfdba5869d2d57248ee9
    && wget -c http://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz \
    && tar zxf LuaJIT-2.1.0-beta3.tar.gz \
    && cd LuaJIT-2.1.0-beta3 \
    && make && make install \
    && cd ../ \
    && wget -c https://github.com/simplresty/ngx_devel_kit/archive/v${Ngx_devel_kit}.tar.gz \
    && tar zxf v${Ngx_devel_kit}.tar.gz \
    && wget -c https://github.com/openresty/lua-nginx-module/archive/v${Nginx_lua_module}.tar.gz \
    && tar zxf v${Nginx_lua_module}.tar.gz \
    && wget -c https://github.com/alibaba/tengine/archive/tengine-${Tengine_Version}.tar.gz \
<<<<<<< HEAD
>>>>>>> 888e3e2790642b71c52dbfdba5869d2d57248ee9
=======
>>>>>>> 888e3e2790642b71c52dbfdba5869d2d57248ee9
    && tar zxf tengine-${Tengine_Version}.tar.gz \
    && cd tengine-tengine-${Tengine_Version} \
    && export LUAJIT_LIB=/usr/local/lib \
    && export LUAJIT_INC=/usr/local/include/luajit-2.1 \
<<<<<<< HEAD
<<<<<<< HEAD
=======
    && sed -i  '/define TENGINE/{s/Tengine/Mozhe/g}'  ./src/core/nginx.h \
>>>>>>> 888e3e2790642b71c52dbfdba5869d2d57248ee9
=======
    && sed -i  '/define TENGINE/{s/Tengine/Mozhe/g}'  ./src/core/nginx.h \
>>>>>>> 888e3e2790642b71c52dbfdba5869d2d57248ee9
    && ./configure \
	    --user=www \
	    --group=www \
		--with-pcre \
		--with-jemalloc \
	    --prefix=${Install_DIR} \
	    --with-http_v2_module \
	    --with-http_gunzip_module \
	    --with-http_realip_module \
		--with-http_concat_module \
	    --with-http_stub_status_module \
	    --with-http_gzip_static_module \
	    --with-http_ssl_module \
        --add-module=${SRC_DIR}/ngx_pagespeed \
		--with-ld-opt="-Wl,-rpath,/usr/local/lib" \
		--with-openssl=${SRC_DIR}/libressl-${Libressl_Version} \
	    --add-module=${SRC_DIR}/ngx_cache_purge-${Ngx_cache_purge} \
		--add-module=${SRC_DIR}/ngx_devel_kit-${Ngx_devel_kit} \
		--add-module=${SRC_DIR}/lua-nginx-module-${Nginx_lua_module} \
<<<<<<< HEAD
    && make && make -j${Make_J} install \
=======
    && make \
    && make -j${Make_J} install \
<<<<<<< HEAD
>>>>>>> 888e3e2790642b71c52dbfdba5869d2d57248ee9
=======
>>>>>>> 888e3e2790642b71c52dbfdba5869d2d57248ee9
    && chown www:www -R ${Install_DIR} \
    && cd ${Install_DIR} \
    && chown www:www sbin/nginx \
    && chmod 750 sbin/nginx \
    && chmod u+s sbin/nginx \
    && ln -s ${Install_DIR}/sbin/* /usr/local/sbin/ \
    && ln -s /usr/local/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2 \
    && cd ${SRC_DIR} \
    && git clone https://github.com/m1911/mozhe.git \
    && cd mozhe/tengine \
    && mv openstar ${Install_DIR} \
    && mv ngx_conf ${Install_DIR} \
    && rm -rf ${Install_DIR}/conf/nginx.conf \    
    && mkdir -p ${Install_DIR}/conf/vhost \
    && mkdir -p ${Install_DIR}/conf/ssl \
    && ln -sf ${Install_DIR}/ngx_conf/nginx.conf ${Install_DIR}/conf/nginx.conf \
    && ln -sf ${Install_DIR}/ngx_conf/proxy.conf ${Install_DIR}/conf/proxy.conf \
    && ln -sf ${Install_DIR}/ngx_conf/vhost.conf ${Install_DIR}/conf/vhost.conf \
    && ln -sf ${Install_DIR}/ngx_conf/waf.conf ${Install_DIR}/conf/waf.conf \
    && chown www:www -R ${Install_DIR} \
    && rm -rf /etc/localtime \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get remove --purge --auto-remove -y ca-certificates git build-essential* \
    && rm -rf /var/lib/apt/lists/*	\
    && rm -rf ${SRC_DIR}

WORKDIR ${Install_DIR}/conf/

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

