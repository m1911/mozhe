#!/bin/bash

set -e

vhost_dir=/usr/local/mozhe/nginx/conf/vhost

Date=`date +%H:%M:%S`
MTime_vhost=`stat ${vhost_dir} |sed -n '6p'|awk '{print $3}'`
MTime_vhost_c=${MTime_vhost%.*}

if [ "${Date}" != "${MTime_vhost_c}" ]; then
	/usr/local/mozhe/nginx/sbin/nginx -s reload
else
	exit
fi

	
