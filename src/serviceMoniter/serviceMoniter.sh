#!/bin/bash

# use system crontab to run this script

export PATH=$PATH:/home/test/nodejs/4.2.2/bin

NSQ_RUNNING=`ps aux |grep archive0 |grep -vc grep`
if [ "$NSQ_RUNNING" -lt 4 ]
then
  echo "nsq number < 4 : $NSQ_RUNNING"
  cat /path/nohup.out >> /path/nohup.out.1
  echo > /path/nohup.out
  /path/run.sh
fi

# Elastic Search service
ES_RUNNING=`ps aux |grep 'org.elasticsearch.bootstrap.Elasticsearch'|grep -vc grep`
if [[ "$ES_RUNNING" -lt 1 ]]
then
	echo "elasticsearch stopped, restart...."
	su -c "/path/bin/elasticsearch -d" test  # switch to non-root user execute
fi
