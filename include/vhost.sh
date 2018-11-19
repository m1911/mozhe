#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

set -e
#添加SSL虚拟机
Add_ssl_host()
{
	echo -e "\033[33m注意要先上传SSL证书不然会启动Nginx会报错\033[0m"
	read -p "请输入域名:" domain
	#检测域名是否为空
	if [ "${domain}" = "" ]; then
		echo -e "\033[31m"域名不允许为空,请重新输入域名."\033[0m"
		exit
	elif [ ! -f "${installDir}/nginx/conf/vhost/${domain}.conf" ]; then
		read -p "请输入后端服务器IP:" Backend_ip
		if [ "${Backend_ip}" != "" ]; then
			read -p "输入更多域名:" moredomain
			if [ "${moredomain}" = "" ]; then
			echo -e "\033[33m已输入的域名有:${domain}\033[0m"
			fi
			echo -n "请输入证书路径(支持Tab补全路径):" 
			read -e certificate_dir
			if [ "${certificate_dir}" = "" ]; then
				echo "证书路径不能为空"
				exit
			fi
			echo -n "请输入Key路径(支持Tab补全路径):" 
			read -e key_dir
			if [ "${key_dir}" = "" ]; then
				echo "Key路径不能为空"
				exit
			fi
			u_name=${domain//./_}_web #把域名的.转换成_。
			CACHE=${domain//./_}
			wget -cO ${installDir}/nginx/conf/vhost/${domain}.conf ${downUrl}/show/Nginx/conf/example_ssl.conf
			sed -i "s#mozhe_xx#${CACHE}#g" ${installDir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#domainweb#${u_name}#g" ${installDir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#0.0.0.0#${Backend_ip}#" ${installDir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#server_name example.com#server_name ${domain} ${moredomain}#" ${installDir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#example.com#${domain}#g" ${installDir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#ssl_certificate ;#ssl_certificate ${certificate_dir};#g" ${installDir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#ssl_certificate_key ;#ssl_certificate_key ${key_dir};#g" ${installDir}/nginx/conf/vhost/${domain}.conf
			${installDir}/nginx/sbin/nginx -t
			if [ $? -eq 0 ]; then
				${installDir}/nginx/sbin/nginx -s reload
			fi
		else
			echo "后端服务器IP不能为空，并且必须要输入IP！"
			exit
		fi
	else
		read -p  "输入的域名已经存在，是否删除。(y|n)" action
		if [[ "${action}" = [nN] || "${action}" = "" ]]; then
			echo "域名删除失败请手动删除"
			exit
		else
			cache_dir=${domain//./_}
			rm -rf ${installDir}/nginx/conf/vhost/${domain}.conf
			rm -rf /data/cache/${cache_dir}
			echo -e "\033[32m已删除域名和缓存目录\033[0m"
		fi
	fi
}
#添加虚拟机
Add_host()
{
	read -p "请输入域名:" domain
	#检测域名是否为空
	if [ "${domain}" = "" ]; then
		echo -e "\033[31m域名不允许为空,请重新输入域名。\033[0m"
		exit
	elif [ ! -f "${installDir}/nginx/conf/vhost/${domain}.conf" ]; then
		read -p "请输入后端服务器IP:" Backend_ip
		if [ "${Backend_ip}" != "" ]; then
			read -p "输入更多域名:" moredomain
			if [ "${moredomain}" = "" ]; then
			echo -e "\033[33m已输入的域名有:${domain}\033[0m"
			fi
			u_name=${domain//./_}_web #把域名的.转换成_。
			CACHE=${domain//./_}
			wget -cO ${installDir}/nginx/conf/vhost/${domain}.conf ${downUrl}/show/Nginx/conf/example.conf
			sed -i "s#mozhe_xx#${CACHE}#g" ${installDir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#domainweb#${u_name}#g" ${installDir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#0.0.0.0#${Backend_ip}#" ${installDir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#server_name example.com#server_name ${domain} ${moredomain}#" ${installDir}/nginx/conf/vhost/${domain}.conf
			sed -i "s#example.com#${domain}#g" ${installDir}/nginx/conf/vhost/${domain}.conf
			${installDir}/nginx/sbin/nginx -t
			if [ $? -eq 0 ]; then
				${installDir}/nginx/sbin/nginx -s reload
			fi
		else
			echo "后端服务器IP不能为空，并且必须要输入IP！"
			exit
		fi
	else
		read -p  "输入的域名已经存在，是否删除。(y|n)" action
		if [[ "${action}" = [nN] || "${action}" = "" ]]; then
			echo "域名删除失败请手动删除"
			exit
		else
			cache_dir=${domain//./_}
			rm -rf ${installDir}/nginx/conf/vhost/${domain}.conf
			rm -rf /data/cache/${cache_dir}
			echo -e "\033[32m已删除域名和缓存目录\033[0m"
		fi
	fi
}
#添加pdns_admin虚拟机
Add_pdns_host()
{
	read -p "请输入域名:" domain
	#检测变量输入是否为空
	if [ -z ${domain} ]; then
	        echo -e "\033[31m"域名不允许为空."\033[0m"
	        exit
	elif [ ! -f "${installDir}/nginx/conf/vhost/${domain}.conf" ]; then
		read -p "输入更多域名:" moredomain
		if [ "${moredomain}" = "" ]; then
			echo -e "\033[33m已输入的域名有:${domain}\033[0m"
		fi
		echo -n "请输入证书路径(支持Tab补全路径):" 
		read -e certificate_dir
		if [ "${certificate_dir}" = "" ]; then
			echo "证书路径不能为空"
			exit
		fi
		echo -n "请输入Key路径(支持Tab补全路径):" 
		read -e key_dir
		if [ "${key_dir}" = "" ]; then
			echo "Key路径不能为空"
			exit
		fi
		wget -cO ${installDir}/nginx/conf/vhost/${domain}.conf ${downUrl}/show/Nginx/conf/pdns.conf
		sed -i "s#server_name example.com#server_name ${domain} ${moredomain}#" ${installDir}/nginx/conf/vhost/${domain}.conf
		sed -i "s#example.com#${domain}#g" ${installDir}/nginx/conf/vhost/${domain}.conf
		sed -i "s#/web#/home/${domain}#g" ${installDir}/nginx/conf/vhost/${domain}.conf
		sed -i "s#ssl_certificate ;#ssl_certificate ${certificate_dir};#g" ${installDir}/nginx/conf/vhost/${domain}.conf
		sed -i "s#ssl_certificate_key ;#ssl_certificate_key ${key_dir};#g" ${installDir}/nginx/conf/vhost/${domain}.conf
		ln -s ${pdnsadminWEBdir} /home/${domain}
		${installDir}/nginx/sbin/nginx -s reload
		if [ $? -eq 0 ]; then
			echo -e "\033[32m"虚拟机添加成功"\033[0m"
			exit
		fi
	else
		read -p  "输入的域名已经存在，是否删除.(y|n)" action
		if [[ "${action}" = [nN] && "${action}" = "" ]]; then
			echo "域名删除失败请手动删除"
			exit
		else
			rm -rf ${installDir}/nginx/conf/vhost/${domain}.conf
			cd /home && rm -rf ${domain}
			echo -e "\033[32m"域名已经删除成功"\033[0m"
		fi
	fi
}