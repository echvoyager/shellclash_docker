#!/bin/bash
# 清除安装数据并恢复默认配置，安装失败后也可运行。
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/shellclash_docker.config

# 清除Docker相关配置及数据
docker stop shellclash_docker
docker rm shellclash_docker
docker rmi echvoyager/shellclash_docker
docker network rm macvlan

# 清除网络相关配置
ip link set $host_interface promisc off
ip link delete macvlan_host
rm $SCRIPT_DIR/shellclash_docker.config