FROM openwrtorg/rootfs:x86-64
RUN mkdir -p /var/lock && \
> /etc/config/network && \
echo -e "config interface 'loopback'\n \
    option ifname 'lo'\n \
    option proto 'static'\n \
    option ipaddr '127.0.0.1'\n \
    option netmask '255.0.0.0'\n" >> /etc/config/network && \
uci set dhcp.lan.ignore=1 && \
uci commit dhcp && \
uci set dhcp.lan.dhcpv6=disabled && \
uci set dhcp.lan.ra=disabled && \
uci commit && \
echo "iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE" >> /etc/firewall.user && \
export url='https://cdn.jsdelivr.net/gh/juewuy/ShellClash@master' && wget -q --no-check-certificate -O /tmp/install.sh $url/install.sh  && echo -ne "1\n2\n1\n1\n" | sh /tmp/install.sh && source /etc/profile &> /dev/null && \
echo -e "1\n1\n1\n1\n0\n0\n4\n9\n2\n2\n3\n2\n0\n0\n"| /etc/clash/clash.sh && \
echo "echo -e \"\e[1;31m \n安装成功! 请继续在容器内导入Clash配置后启动即可; 若想退出shell请Ctrl+D \e[0m\"" >> /etc/profile && \
echo "echo -e \"\e[1;32m \n登陆容器shell时ShellClash菜单默认自动运行\n \e[0m\"" >> /etc/profile && \
echo "clash" >> /etc/profile
CMD ["/sbin/init"]