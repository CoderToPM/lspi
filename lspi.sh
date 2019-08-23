#!/bin/bash
#放到/usr/local/bin这个目录里面
:<<!
@author:yongchaohe
@github:https://github.com/CoderToPM/lspi
支持查看服务器进程信息，其中包含java、node、ringojs、nginx等进程信息（可自行添加或删除过滤关键词）
!
USER_HOME=~/
tmp_file_name=.all_java_procs_${TIME_STAMP}
tmp_file=${USER_HOME}${tmp_file_name}
rm -f ${tmp_file}&&touch ${tmp_file}
`sudo ps -o user,pid,time,command -A -w|grep -E "java|node|ringojs|nginx"|grep -v grep|awk '{print $0}' > ${tmp_file}`
echo -e "\E(0lqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk\E(B
\E(0x\E(B                              \033[32m\E(0\`\E(B 当前\033[44;37mjava\033[0m&\033[46;37mnode\033[0m&\033[47;30mnginx\033[0m进程信息 \E(0\`\E(B\033[0m                              \E(0x\E(B"
while read line
do
    user=`echo ${line}|awk '{print $1}'`
    pid=`echo ${line}|awk '{print $2}'`
    cpu_time=`echo ${line}|awk '{print $3}'`
    container=`echo ${line}|awk '{print $4}'|awk '{split($1,array,"/");print array[length(array)]}' `
    container=`echo ${container}|sed 's/://g'`
    start_path=`sudo ls -l /proc/${pid} 2>/dev/null|grep cwd|awk '{print $NF}'`
    pthread_num=`pstree -p ${pid}|wc -l`
    fd_num=`sudo ls -l /proc/${pid}/fd/ 2>/dev/null|wc -l`
    vmsize=`cat /proc/${pid}/status 2>/dev/null|grep VmSize|awk '{print $2}'`
    rsssize=`cat /proc/${pid}/status 2>/dev/null |grep VmRSS|awk '{print $2}'`
    port=`sudo netstat -lpnt|egrep "${pid}\/${container}"|awk '{print $4}'|awk -F ':' '{ if("'${container}'" ==  "node"){print $4} else if("'${container}'" == "java" || "'${container}'" == "nginx") {print  $2} }' `
    port=`echo ${port}|sed 'N;s/\n//g'`
    if [[ -z ${port} ]]
        then
        continue
    fi
    if [ ${container} == "node" ]
        then
        path=`cat /proc/${pid}/cmdline|awk -F "-l" '{print $2}' |sed 's/logs.$//g'`
        echo  -e "\E(0x\E(B \033[46;37m容器:${container} 启动账号:${user} 进程:${pid} cpu时间:${cpu_time} 线程数:${pthread_num} 句柄数:${fd_num} 虚拟内存：`expr ${vmsize} / 1024`M 内存：`expr ${rsssize} / 1024`M \033[0m\n\E(0x\E(B 路径:${path} 端口:${port}\033[0m"
    elif [ ${container} == "java" ]
        then
        path=`cat /proc/${pid}/cmdline|awk -F "-Dcatalina." '{print $2}'`
        echo  -e "\E(0x\E(B \033[44;37m容器:${container} 启动账号:${user} 进程:${pid} cpu时间:${cpu_time} 线程数:${pthread_num} 句柄数:${fd_num} 虚拟内存：`expr ${vmsize} / 1024`M 内存：`expr ${rsssize} / 1024`M \033[0m\n\E(0x\E(B 路径:${path} 端口:${port}\033[0m"
    elif [ ${container} == "nginx" ]
        then
        path=${start_path}
        echo  -e "\E(0x\E(B \033[47;30m容器:${container} 启动账号:${user} 进程:${pid} cpu时间:${cpu_time} 线程数:${pthread_num} 句柄数:${fd_num} 虚拟内存：`expr ${vmsize} / 1024`M 内存：`expr ${rsssize} / 1024`M \033[0m\n\E(0x\E(B 路径:${path} 端口:${port}\033[0m"
    fi
done < ${tmp_file}
echo -e "\E(0mqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj\E(B" < ${tmp_file}
rm -f ${tmp_file}
