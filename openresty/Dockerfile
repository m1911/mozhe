# Dockerfile - Debian 9 Stretch - DEB version
# https://github.com/openresty/openresty

ARG RESTY_IMAGE_BASE="debian"
ARG RESTY_IMAGE_TAG="stretch-slim"
FROM ${RESTY_IMAGE_BASE}:${RESTY_IMAGE_TAG}

MAINTAINER m1911 2018年9月1日

ARG Make_J="2" 
ARG SRC_DIR="/opt/src"
ARG Jemalloc_Version="5.1.0"
ARG Libressl_Version="2.7.4"
ARG Pagespeed_Version="1.13.35.2"
ARG Pcre_Version="8.42"
ARG Resty_Version="1.13.6.2"
ARG Install_DIR="/usr/local/mozhe"

RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y ca-certificates wget build-essential cmake unzip git bzip2 uuid-dev zlib1g.dev python lua5.1-0-dev \
    && groupadd www && useradd -s /sbin/nologin -g www www \    
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
    && ldconfig && cd .. \    
    && wget -c https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${Libressl_Version}.tar.gz \
    && tar zxf libressl-${Libressl_Version}.tar.gz \
    && cd ${SRC_DIR} \
    && wget -c https://github.com/apache/incubator-pagespeed-ngx/archive/v${Pagespeed_Version}-stable.tar.gz \
    && tar zxf v${Pagespeed_Version}-stable.tar.gz \ 
    && mv incubator-pagespeed-ngx-${Pagespeed_Version}-stable/ ngx_pagespeed \
    && cd ngx_pagespeed \
    && wget -c https://dl.google.com/dl/page-speed/psol/${Pagespeed_Version}-x64.tar.gz \
    && tar zxf ${Pagespeed_Version}-x64.tar.gz && cd .. \    
    && git clone https://github.com/google/ngx_brotli.git \
    && cd ngx_brotli \
    && git submodule update --init && cd .. \    
	&& wget -c https://ftp.pcre.org/pub/pcre/pcre-${Pcre_Version}.tar.gz \
	&& tar zxf pcre-${Pcre_Version}.tar.gz \
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
		--with-luajit \
	    --with-http_v2_module \
	    --with-http_gunzip_module \
	    --with-http_realip_module \
	    --with-http_stub_status_module \
	    --with-http_gzip_static_module \
		--with-http_ssl_module \	
	    --with-ld-opt="-ljemalloc" \
		--with-pcre=${SRC_DIR}/pcre-${Pcre_Version} \
		--with-pcre-jit \
	    --add-module=${SRC_DIR}/ngx_brotli \
	    --add-module=${SRC_DIR}/ngx_pagespeed \
	    --with-openssl=${SRC_DIR}/libressl-${Libressl_Version} \
    && make && make -j${Make_J} install \
    && chown www:www -R ${Install_DIR} \
    && cd ${Install_DIR} \
    && chown www:www nginx/sbin/nginx \
    && chmod 750 nginx/sbin/nginx && chmod u+s nginx/sbin/nginx\
    && ln -s ${Install_DIR}/nginx/sbin/* /usr/local/sbin/ \
    && cd ${SRC_DIR} \
	&& git clone https://github.com/m1911/mozhe.git \
	&& cd mozhe/jxwaf/libinjection \
	&& chmod +x src/*.py && make all \
    && cp src/libinjection.so ${Install_DIR}/lualib/ \
	&& cd ../lua-aho-corasick/ && make \
	&& cp libac.so ${Install_DIR}/lualib/ \
	&& mkdir -p ${Install_DIR}/nginx/conf/jxwaf \
	&& cp ../conf/jxwaf_config.json ${Install_DIR}/nginx/conf/jxwaf/ \
    && cp -r ../lib/resty/jxwaf  ${Install_DIR}/lualib/resty/ \
    && cd ../ && tar zxvf lua-zlib-1.2.tar.gz \
	&& cd lua-zlib-1.2 && cmake -DLUA_INCLUDE_DIR=${Install_DIR}/luajit/include/luajit-2.1 && make \
	&& cp zlib.so ${Install_DIR}/lualib/ \
    && cd ../../openresty \
    && cp -Rf ngx_conf ${Install_DIR} \
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
    && apt-get remove --purge --auto-remove -y ca-certificates git cmake* build-essential* python* lua5.1-0-dev* \
    && rm -rf /var/lib/apt/lists/*	\
    && rm -rf ${SRC_DIR}


WORKDIR ${Install_DIR}/nginx/

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

