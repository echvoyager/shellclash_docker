#!/bin/bash
# 清除安装数据并恢复默认配置，安装失败后也可运行。

# 清除Docker相关配置及数据
docker stop shellclash_docker
docker rm shellclash_docker
docker rmi echvoyager/shellclash_docker
docker network rm macvlan

# 清除网络相关配置
read host_interface < host_interface
ifconfig $host_interface -promisc
ip link delete macvlan_host
rm host_interface