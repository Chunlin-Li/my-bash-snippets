#!/usr/bin/env bash

topic=reqInfo
tmpPath=/tempLog

if [[ "$1" =~ (-help|--help|-h|help) ]]; then
    cat `dirname $0`/README
    exit 0
fi

# precess arguments
# ***************************************

argList=("$@")
argNum=$#

cmd=""
for arg in `seq 0 $((argNum - 1))`; do
    curr=${argList[arg]}
    IFS="=" read -a KVpairs <<< "$curr"
    key=${KVpairs[0]}
    value=${KVpairs[1]}

    case ${key} in
        "field" )
            cmd+=" | grep \"\\\"field\\\":\\\"value\\\",\"" ;;
        "-count" )
            flag_count=true ;;
        "-time" )
            if [[ `echo ${value} | grep -P '^\d{4}-\d{2}-\d{2}_\d{2}$' ` ]];then
                value=${value/_/ }
            fi
            if [[ `echo ${value} | grep -P '^\d{4}-\d{2}-\d{2}$' ` ]]; then
                dateStr=`date -d "${value}" +%Y-%m-%d_* 2>/dev/null`
                echo === it need a very long time to filter all logs of one day.===
            else
                dateStr=`date -d "${value}" +%Y-%m-%d_%H 2>/dev/null`
            fi
            if [[ $? > 0 ]]; then
                echo "-time argument invalid!"
                exit 1
            fi ;;
        "-type" )
            # default type should be history-> cat  realtime -> tail -f
            # determine tail cat
            if [[ ${value} == "history" || ${value} == "realtime" ]]; then
                type=${value}
            else
                echo "type not support!"
                exit 1
            fi ;;
        "-env" )
            if [[ ${value} == "test" || ${value} == "production" ]]; then
                env=${value}
            else
                echo "env type not support!"
                exit 1
            fi ;;
    esac

done
# ****************************************

if [[ ${flag_count} ]]; then
    if expr match "${cmd}" .*grep >> /dev/null; then
        cmd+=" -c "
    else
        cmd+=" | wc -l "
    fi
fi
if [[ ! ${type} ]]; then
    if [[ ! ${dateStr} ]]; then
        type="realtime"
        dateStr=`date +%Y-%m-%d_%H`
    else
        type="history"
    fi
else
    if [[ ! ${dateStr} ]]; then
        dateStr=`date +%Y-%m-%d_%H`
    fi
fi

getFileList() {
    fPattern=$1
    fileList=`find /hdd* ! -readable -prune -o -name "*${fPattern}" -print`
    if [[ ! ${fileList} ]]; then
        fileList=`find "${tmpPath}" ! -readable -prune -o -name "*${fPattern}" -print`
        if [[ ! ${fileList} ]]; then
            # decompress
            compFileList=`find /hdd* ! -readable -prune -o -name "*${fPattern}.gz" -print`
            for compF in ${compFileList}; do
                pigz -d -p 8 < ${compF} > ${tmpPath}/${fPattern}
            done
            fileList=`find "${tmpPath}" ! -readable -prune -o -name "*${fPattern}" -print`
        fi
    fi
    eval $2=$fileList
    return 0
}

# echo cat ${path_pre}test-${topic}.${dateStr}.log ${cmd}

if [[ ${type} == "history" ]]; then
    if [[ ${env} == "test" ]]; then
        getFileList test-${topic}.${dateStr}.log f01
        eval cat ${f01} ${cmd}
    elif [[ ${env} == "production" ]]; then
        getFileList production-${topic}.${dateStr}.log f01
        eval cat ${f01} ${cmd}
    else
        getFileList test-${topic}.${dateStr}.log f01
        getFileList production-${topic}.${dateStr}.log f02
        echo cat ${f01} ${f02} ${cmd}
        eval cat ${f01} ${f02} ${cmd}
    fi
else
    if [[ ${env} == "test" ]];then
        getFileList test-${topic}.${dateStr}.log f01
        eval tail -q -f ${f01} ${cmd}
    elif [[ ${env} == "production" ]];then
        getFileList production-${topic}.${dateStr}.log f01
        eval tail -q -f ${f01} ${cmd}
    else
        getFileList test-${topic}.${dateStr}.log f01
        getFileList production-${topic}.${dateStr}.log f02
        eval tail -q -f ${f01} -f ${f02} ${cmd}
    fi
fi
