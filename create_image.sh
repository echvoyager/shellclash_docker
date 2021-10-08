# 这是我用来生成镜像的命令, 不想用Dockerfile因为不方便; 可自行修改创建自己的OpenWrt虚拟机镜像
# 非脚本, 请手动运行

# 卸载并重置环境
./uninstall_shellclash_docker.sh

# 设置变量
host_interface="eth0"
gateway_ip="192.168.31.1"
host_ip="192.168.31.2"
container_ip="192.168.31.3"
relay_ip="192.168.31.4"

# 设置macvlan
ip link set $host_interface promisc on
ip link add macvlan_host link $host_interface type macvlan mode bridge
ip addr add $relay_ip dev macvlan_host
ip link set macvlan_host up
ip route add $container_ip dev macvlan_host

# Docker安装运行
docker network create -d macvlan --subnet=$gateway_ip/24 --gateway=$gateway_ip -o parent=$host_interface macvlan

docker run --restart=always --name=shellclash_docker --network=macvlan --ip=$container_ip --cap-add=NET_ADMIN -d openwrtorg/rootfs:x86-64

docker exec -it shellclash_docker sh -l

# 容器Shell内运行
> /etc/config/network
echo -e "config interface 'loopback'
\toption proto 'static'
\toption ipaddr '127.0.0.1'
\toption netmask '255.0.0.0'
\toption device 'lo'

config interface 'lan'
\toption proto 'static'
\toption device 'eth0'
\toption ipaddr '192.168.31.3'
\toption netmask '255.255.255.0'
\toption gateway '192.168.31.1'
\toption dns '192.168.31.1'" >> /etc/config/network
uci set dhcp.lan.ignore=1
uci set dhcp.lan.dhcpv6=disabled
uci set dhcp.lan.ra=disabled
uci set firewall.@include[0].reload='1'
uci commit
echo "iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE" >> /etc/firewall.user
reboot
# 退出容器

docker exec -it shellclash_docker sh -l

# 容器Shell内运行
export url='https://cdn.jsdelivr.net/gh/juewuy/ShellClash@master' && wget -q --no-check-certificate -O /tmp/install.sh $url/install.sh && echo -ne "1\n2\n1\n1\n" | sh /tmp/install.sh && source /etc/profile &> /dev/null

echo -e "1\n1\n1\n1\n0\n0\n4\n9\n2\n2\n3\n2\n0\n0\n"| clash
echo -e "7\n6\n1\n192.168.31.1, 119.29.29.29, 223.5.5.5\n2\ntls://dns.pub:853, https://doh.pub/dns-query, tls://dns.alidns.com:853, https://dns.alidns.com/dns-query, tls://dns.rubyfish.cn:853, https://dns.rubyfish.cn/dns-query\n0\n0\n0\n"| clash
echo -e "6\n2\nhttp://192.168.31.4/clash/test.yaml\n1\n1\n"| clash
echo -e "1\n"| clash

echo "echo -e \"\e[1;31m \n安装成功! 请继续在容器内导入Clash配置后启动即可; 若想退出shell请Ctrl+D \e[0m\"" >> /etc/profile
echo "echo -e \"\e[1;32m \n登陆容器shell时ShellClash菜单默认自动运行\n \e[0m\"" >> /etc/profile
echo "clash" >> /etc/profile

> /etc/config/network
echo -e "config interface 'loopback'
\toption proto 'static'
\toption ipaddr '127.0.0.1'
\toption netmask '255.0.0.0'
\toption device 'lo'\n" >> /etc/config/network
# 退出容器

docker commit shellclash_docker echvoyager/shellclash_docker
docker push echvoyager/shellclash_docker

# 清除Docker相关配置及数据
docker stop shellclash_docker
docker rm shellclash_docker
docker rmi openwrtorg/rootfs:x86-64
docker rmi echvoyager/shellclash_docker
docker network rm macvlan

# 清除网络相关配置
ip link set $host_interface promisc off
ip link delete macvlan_host