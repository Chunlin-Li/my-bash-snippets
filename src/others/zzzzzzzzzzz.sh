#!/bin/bash

awk_script_path=/home/test/shell/awk/test.awk
log_path=/hdd1/adx_nsq_output/
running=''
pid=''



run () {
	nohup tail -n 1000000 -f $1 |awk -f ${awk_script_path} &
	pid=$!
	echo the awk pid is $pid
	pid=`ps aux --sort start_time |grep -B 10 -P '^\w+\s+'${pid}'\s+' |grep 'tail -n 1000000 -f' |tail -n1|awk '{print $2}'`
	echo the tail pid is $pid
	running=$1
}




while true; do

	latest_file=${log_path}`ls --sort=time /hdd1/adx_nsq_output/ |grep console |head -n1`
	if [[ $running != $latest_file ]];then
		echo ######, $running, $latest_file
		if [[ $pid == "" ]];then
			echo will start...
		else
			echo kill old process $pid
			kill $pid
		fi
		run $latest_file
		echo started! pid is $pid
	fi

	sleep 5

done

# echo $latest_file
