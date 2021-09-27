#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/shellclash_docker.config

ip link set $host_interface promisc on
ip link add macvlan_host link $host_interface type macvlan mode bridge
ip addr add $relay_ip dev macvlan_host
ip link set macvlan_host up
ip route add $container_ip dev macvlan_host

docker container restart shellclash_docker