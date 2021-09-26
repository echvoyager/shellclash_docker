#!/bin/bash
# Docker安装运行ShellClash旁路由容器
# 我自己在群晖DS920+上测试过, 理论上任何Linux系统都可以用, 但是搞出了问题后果自负。脚本格式和功能还有待改进。

echo -e "\e[1;31m \n如果安装过程中需要退出, 请Ctrl+C退出并运行uninstall_shellclash_docker.sh以重置环境\n \e[0m"

# 读取用户输入信息
echo -e "\033[1m请选择宿主机网络接口(请确定IP是宿主机LAN IP)\033[0m"
ip_info=$(ip -o -4 a show scope global | awk '{split($4, a, "/"); printf("%d%s\n", NR, " - " $2 ": " a[1])}')
echo -e "${ip_info}" && read -p $'\e[1;32m输入对应数字: ' interface_num && echo -en "\e[0m"
host_interface=$(echo "${ip_info}" | awk 'NR=='$interface_num'{split($3, a, ":"); printf("%s\n", a[1])}') && echo $host_interface > host_interface
ip_range=$(echo "${ip_info}" | awk 'NR=='$interface_num'{split($4, a, "."); printf("%s\n", a[1] "." a[2] "." a[3] ".")}')
echo -e "\033[1m\n请补全以下信息\033[0m"
echo -en "\033[1m主网关IP\033[0m: \e[1;32m$ip_range" && read && gateway_ip="${ip_range}${REPLY}" && echo -en "\e[0m"
echo -en "\033[1mShellClash旁路网关IP\033[0m (切勿与内网其他设备冲突!): \e[1;32m$ip_range" && read && container_ip="${ip_range}${REPLY}" && echo -en "\e[0m"
echo -en "\033[1m中转IP\033[0m (用作容器向宿主机沟通, 切勿与内网其他设备冲突!): \e[1;32m$ip_range" && read && relay_ip="${ip_range}${REPLY}" && echo -en "\e[0m"

# 设置macvlan, 宿主机重启后需重新设置
ifconfig $host_interface promisc
ip link add macvlan_host link $host_interface type macvlan mode bridge
ip addr add $relay_ip dev macvlan_host
ip link set macvlan_host up
ip route add $container_ip dev macvlan_host

# Docker安装运行
docker network create -d macvlan --subnet=$gateway_ip/24 --gateway=$gateway_ip -o parent=$host_interface macvlan
docker run --restart always --name shellclash_docker -d --network macvlan --ip=$container_ip --privileged echvoyager/shellclash_docker
docker exec -it shellclash_docker sh -c "echo \"config interface 'lan'
        option proto 'static'
        option device 'eth0'
        option ipaddr '$container_ip'
        option netmask '255.255.255.0'
        option gateway '$gateway_ip'
        option dns '$gateway_ip'\" >> /etc/config/network"

docker exec -it shellclash_docker sed -i "s/dns_nameserver=.*/dns_nameserver='192.168.31.1, 119.29.29.29, 223.5.5.5'/g" /etc/clash/mark 
docker exec -it shellclash_docker sed -i "s|dns_fallback=.*|dns_fallback='tls://dns.pub:853, https://doh.pub/dns-query, tls://dns.alidns.com:853, https://dns.alidns.com/dns-query, tls://dns.rubyfish.cn:853, https://dns.rubyfish.cn/dns-query'|g" /etc/clash/mark
docker exec -it shellclash_docker sh -l
docker exec -it shellclash_docker sh -c "sed -i \"\$(( \$(wc -l </etc/profile)-2 ))d\" /etc/profile"

echo -e "\e[1;31m \n如需重新进入容器shell, 在宿主机运行 docker exec -it shellclash_docker sh -l ,或任意设备运行 ssh root@$container_ip\n \e[0m"