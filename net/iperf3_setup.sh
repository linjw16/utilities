# filename: iperf3_setup.sh
# path: 192.168.9.17/home/linjw/rec_E810/
# MTU
ip link set mtu 4200 dev p4p1
ip link set mtu 4200 dev p4p2

# IP地址
ip address flush dev p4p1
ip address flush dev p4p2
ip address add 10.20.9.24/24 dev p4p1
ip address add 10.20.9.25/24 dev p4p2

# 设置防火墙
iptables --flush
iptables -A INPUT -i p4p1 -j ACCEPT
iptables -A INPUT -i p4p2 -j ACCEPT

# 添加路由
ip route flush dev p4p1
ip route add 10.20.47.16 dev p4p1
ip route add 10.20.47.17 dev p4p1

# 地址解析协议
arp -i p4p1 -s 10.20.47.16 3a:32:19:cb:4c:36
arp -i p4p1 -s 10.20.47.17 3a:32:19:cb:4c:36

# 使用iperf3测试，终端1侦听
# iperf3 -s -B 10.20.9.24 -i 4 -p 1616 -A 16
# 终端2发流
# iperf3 -B 10.20.9.24 -c 10.20.47.16 -P 4 -t 16 -i 4 -p 1616 -A 16,16
# iperf3 -B 10.20.9.24 -c 10.20.47.17 -P 4 -t 16 -i 4 -p 1616 -A 16,16
