#!/usr/bin/env bash

if [[ $1 =~ ^/ ]];then
    method=get
    path=$1
    data=$2
    other=$3
else
    method=$1
    path=$2
    data=$3
    other=$4
fi


cmd="curl -X${method^^} 127.0.0.1:9200${path}"

if [[ ${data} ]];then
    cmd+="-d \$'${data}' "
fi

if [[ ${other} ]];then
    cmd+="${other} "
fi

#echo ${cmd}
eval ${cmd}