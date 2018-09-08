echo -e "\n" 
echo -n -e "\e[35;1m请输入Nginx Proxy_cache缓存的具体路径(友情提示:可以使用Tab补全功能哦!)\e[0m\e[34;5m:\e[0m" 
read -e path 
CACHE_DIR=$path 
echo -e "\e[32;1m----------------------------------------------------------------\e[0m" 
echo -e "\e[32;1m----------------------------------------------------------------\e[0m" 
echo -n -e "\e[32;1m请输入你要删除的动作\n1.按文件类型删除\t2.按具体文件名删除\t3.按文件目录删除\n:" 
read action 
     case $action in 
1) 
echo -e "\e[32;1m----------------------------------------------------------------\e[0m" 
echo -e "\e[32;1m----------------------------------------------------------------\e[0m" 
echo -n -e "\e[34;1m 请输入你要删除的缓存文件类型(可以输入多个参数空格隔开)\e[0m\e[34;5m:\e[0m" 
read -a FILE 
for i in `echo ${FILE[*]}|sed 's/ /\n/g'` 
do 
grep -r -a  \.$i ${CACHE_DIR}| awk 'BEGIN {FS=":"} {print $1}'  > /tmp/cache_list.txt 
 for j in `cat /tmp/cache_list.txt` 
do 
   rm  -rf  $j 
   echo "$i  $j 删除成功!" 
 done 
done 
;; 
2) 
echo -e "\e[32;1m----------------------------------------------------------------\e[0m" 
echo -e "\e[32;1m----------------------------------------------------------------\e[0m" 
echo -n -e "\e[33;1m 请输入你要删除的缓存文件具体名称(可以输入多个参数空格隔开)\e[0m\e[34;5m:\e[0m" 
read -a FILE 
for i in `echo ${FILE[*]}|sed 's/ /\n/g'` 
do 
grep -r -a  $i ${CACHE_DIR}| awk 'BEGIN {FS=":"} {print $1}'  > /tmp/cache_list.txt 
 for j in `cat /tmp/cache_list.txt` 
do 
   rm  -rf  $j 
   echo "$i  $j 删除成功!" 
 done 
done 
;; 
3) 
echo -e "\e[32;1m----------------------------------------------------------------\e[0m" 
echo -e "\e[32;1m----------------------------------------------------------------\e[0m" 
echo -n -e "\e[33;1m支持的模式有:\n1.清除网站store目录下的所有缓存:test.dd.com/data/upload/shop/store\n2.清除网站shop下的所有缓存:test.dd.com/data/upload/shop\e[0m\n" 
echo -n -e "\e[34;1m 请输入你要删除的缓存文件具体目录\e[0m\e[34;5m:\e[0m" 
read -a FILE 
for i in `echo ${FILE[*]}|sed 's/ /\n/g'` 
do 
grep -r -a  "$i" ${CACHE_DIR}| awk 'BEGIN {FS=":"} {print $1}'  > /tmp/cache_list.txt 
 for j in `cat /tmp/cache_list.txt` 
do 
   rm  -rf  $j 
   echo "$i  $j 删除成功!" 
 done 
done 
;; 
*) 
echo "输入错误,请重新输入" 
;; 
esac