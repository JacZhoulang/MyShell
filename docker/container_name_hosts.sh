#!/usr/bin/env bash

###################################
#  在单机部署docker容器的时候，经常会遇到docker容器重启，ip发生变化
#  主机访问容器，如果通过ip访问，经常性需要修改
#  因此，写了个脚本来查询当前所有容器的ip地址，并根据容器名Name来添加到hosts映射
######## Querying           #######
######## 2018-4-16          #######
##
###################################

container_name=''
RESULT=''
HOSTS_FILE="/etc/hosts"
for container_id in `docker ps -q`
do

    container_ip=`docker inspect ${container_id} -f='{{.NetworkSettings.Networks.fireyes_default.IPAddress}}'`

    container_name=`docker inspect ${container_id} -f='{{.Name}}' | sed 's/\///g'`

    ALIAS_RESULT=`cat ${HOSTS_FILE} | grep ${container_name}`

    if [ "${ALIAS_RESULT}" != "" ] ; then
        echo ${container_name}
        sed -i "s/ ${container_name}//g" "${HOSTS_FILE}"
    fi
    
    IP_RESULT=`cat /etc/hosts | grep ${container_ip}`
    IP_RESULT=${IP_RESULT%%\#*}
    
    if [ "${IP_RESULT}" != "" ] ; then
        #已经存在当前ip映射，那么在后面追加别名
        
        #执行覆盖操作
        replace_str="${IP_RESULT} ${container_name}"
        # -i 直接修改并保存
        sed -i "s/${IP_RESULT}/${replace_str}/g" "${HOSTS_FILE}"
    else
       
        echo "${container_ip} ${container_name}" >> "${HOSTS_FILE}"
       
    fi

    
done





