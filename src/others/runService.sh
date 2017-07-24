#!/usr/bin/env bash

ProjectName="sundries"  # 项目名称
Port=3030  # 服务监听端口 , 通过设置 NODE_PORT 环境变量实现
CleanNodeModules=true  # 是否每次都清除 node_modules
NodeVersion=8.1.2  # node 版本, 需确保 nvm 有该版本
Restart=true  # 是否每次都重启服务


if [[ -e $1 ]]; then
 echo "usage: ./runDevelopment.sh [git branch name]"
 exit 1;
fi

cd ${ProjectName}  # ./${ProjectName} 目录应该是对应项目的 git 目录

# 清除当前所有的修改
git clean -f -x
if [[ ! ${CleanNodeModules} == true ]]; then
    git clean -d
fi
# 重置到 head
git reset --hard
# 切到 master 分支, 因为考虑到 master 分支一般有保护, 比较稳定
git checkout master
# 确认目标分支是否存在, 如果存在则删除该分支的本地副本
currentBranch=`git branch |grep -cE " $1\$"`
if [[ $1 != "master" && ${currentBranch} > 0 ]]; then
	echo "delete branch" $1
	git branch -D $1
fi
# 拉取远端 repo 信息
git fetch --all -q
# 签出目标分支
git checkout $1
# 更新代码
git pull

# 如无须重启, 则直接退出
if [[ ${Restart} == false ]];then
    exit 0;
fi

# 如果有pid文件, 则杀掉对应正在运行的程序
if [[ -f ../${ProjectName}.pid ]]; then
  kill `cat ../${ProjectName}.pid`
fi

source ~/.nvm/nvm.sh
nvm use ${NodeVersion}
npm install --production

NODE_PORT=${Port} setsid npm run devl 1>>../${ProjectName}.log 2>&1 &
pid=$!
echo 'pid is ' ${pid}
echo ${pid} > ../${ProjectName}.pid

tail -f ../${ProjectName}.log
