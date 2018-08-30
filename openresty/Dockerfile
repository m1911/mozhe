# Dockerfile - Debian 9 Stretch - DEB version
# https://github.com/openresty/docker-openresty

ARG RESTY_IMAGE_BASE="debian"
ARG RESTY_IMAGE_TAG="stretch-slim"
FROM ${RESTY_IMAGE_BASE}:${RESTY_IMAGE_TAG}

MAINTAINER m1911 2018年8月29日

ARG Make_J="2" 
ARG SRC_DIR="/opt/src"
ARG Resty_Version="1.13.6.2"
ARG Ngx_cache_purge="2.5"
ARG Libressl_Version="2.7.4"
ARG Jemalloc_Version="5.1.0"
ARG Pagespeed_Version="1.13.35.2"
ARG Install_DIR="/opt/openresty"

RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y ca-certificates wget make gcc g++ libpcre3 libpcre3-dev git bzip2 uuid-dev zlib1g.dev \
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
    && cd ../ \
    && wget -c https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${Libressl_Version}.tar.gz \
    && tar zxf libressl-${Libressl_Version}.tar.gz \
    && cd ${SRC_DIR} \
    && wget -c https://github.com/apache/incubator-pagespeed-ngx/archive/v${Pagespeed_Version}-stable.tar.gz \
    && tar zxf v${Pagespeed_Version}-stable.tar.gz \ 
    && mv incubator-pagespeed-ngx-${Pagespeed_Version}-stable/ ngx_pagespeed \
    && cd ngx_pagespeed \
    && wget -c https://dl.google.com/dl/page-speed/psol/${Pagespeed_Version}-x64.tar.gz \
    && tar zxf ${Pagespeed_Version}-x64.tar.gz \
    && cd ../ \
    && git clone https://github.com/google/ngx_brotli.git \
    && cd ngx_brotli \
    && git submodule update --init \
    && cd ../ \
    && wget -c https://github.com/nginx-modules/ngx_cache_purge/archive/${Ngx_cache_purge}.tar.gz \
    && tar zxf ${Ngx_cache_purge}.tar.gz \
    && wget -c https://openresty.org/download/openresty-${Resty_Version}.tar.gz \
    && tar zxf openresty-${Resty_Version}.tar.gz \
    && cd openresty-${Resty_Version} \
    && sed -i  '/NGINX_VER/{s/openresty/Mozhe/g}'  ./bundle/nginx-1.13.6/src/core/nginx.h \
    && sed -i "s#Server: openresty#Server: Mozhe#" ./bundle/nginx-1.13.6/src/http/ngx_http_header_filter_module.c \
    && sed -i "s#\"<hr><center>openresty<\/center>\"#\"<hr><center>Mozhe<\/center>\"#" ./bundle/nginx-1.13.6/src/http/ngx_http_special_response.c \
    && ./configure \
	    --user=www \
	    --group=www \
	    --prefix=${Install_DIR} \
	    --with-http_v2_module \
	    --with-http_gunzip_module \
	    --with-http_realip_module \
	    --with-http_stub_status_module \
	    --with-http_gzip_static_module \
	    --with-luajit --with-http_ssl_module \	
	    --with-pcre --with-ld-opt="-ljemalloc" \
	    --add-module=${SRC_DIR}/ngx_brotli \
	    --add-module=${SRC_DIR}/ngx_pagespeed \
	    --with-openssl=${SRC_DIR}/libressl-${Libressl_Version} \
	    --add-module=${SRC_DIR}/ngx_cache_purge-${Ngx_cache_purge} \
    && make \
    && make -j${Make_J} install \
    && chown www:www -R ${Install_DIR} \
    && cd ${Install_DIR} \
    && chown www:www nginx/sbin/nginx \
    && chmod 750 nginx/sbin/nginx \
    && chmod u+s nginx/sbin/nginx \
    && ln -s /opt/openresty/nginx/sbin/* /usr/local/sbin/ \
    && cd ${SRC_DIR} \
    && git clone https://github.com/m1911/mozhe.git \
    && cd mozhe/openresty \
    && mv openstar ${Install_DIR} \
    && mv ngx_conf ${Install_DIR} \
    && rm -rf ${Install_DIR}/nginx/conf/nginx.conf \    
    && mkdir -p ${Install_DIR}/nginx/conf/vhost \
    && mkdir -p ${Install_DIR}/nginx/conf/ssl \
    && ln -sf ${Install_DIR}/ngx_conf/nginx.conf ${Install_DIR}/nginx/conf/nginx.conf \
    && ln -sf ${Install_DIR}/ngx_conf/proxy.conf ${Install_DIR}/nginx/conf/proxy.conf \
    && ln -sf ${Install_DIR}/ngx_conf/vhost.conf ${Install_DIR}/nginx/conf/vhost.conf \
    && ln -sf ${Install_DIR}/ngx_conf/waf.conf ${Install_DIR}/nginx/conf/waf.conf \
    && chown www:www -R ${Install_DIR} \
    && rm -rf /etc/localtime \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get remove --purge --auto-remove -y ca-certificates git g++ \
    && rm -rf /var/lib/apt/lists/*	\
    && rm -rf ${SRC_DIR}


WORKDIR ${Install_DIR}/nginx/

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

