# filename: fwd_back.sh
# not useful
mac_0=72:84:14:8d:5e:c3
mac_1=62:bf:ac:07:cb:2e
ip_0=10.50.0.1
ip_1=10.50.1.1
ipf_0=10.60.0.1
ipf_1=10.60.1.1
# MTU
ip link set mtu 1500 dev eth0
ip link set mtu 1500 dev eth1
# 配置IP地址
# iptables -t nat -L
ip address flush dev eth0
ip address flush dev eth1
ip address add $ip_0/24 dev eth0
ip address add $ip_1/24 dev eth1
# 设置防火墙
iptables --flush
iptables -A INPUT -i eth0 -j ACCEPT
iptables -A INPUT -i eth1 -j ACCEPT
# 对于从eth0发往eth1的数据包，改变其源地址
iptables -t nat -A POSTROUTING -s $ip_0 -d $ipf_0 -j SNAT --to-source $ipf_0
iptables -t nat -A POSTROUTING -s $ip_0 -d $ipf_1 -j SNAT --to-source $ipf_0
iptables -t nat -A POSTROUTING -s $ip_1 -d $ipf_0 -j SNAT --to-source $ipf_1
iptables -t nat -A POSTROUTING -s $ip_1 -d $ipf_1 -j SNAT --to-source $ipf_1
iptables -t nat -A PREROUTING -d $ipf_0 -j DNAT --to-destination $ip_0
iptables -t nat -A PREROUTING -d $ipf_1 -j DNAT --to-destination $ip_1
# 添加路由
ip route flush dev eth0
ip route flush dev eth1
ip route add $ipf_1 dev eth0
ip route add $ipf_0 dev eth1
# 地址解析协议：设置网卡接口eth0邻接节点10.60.1.1的MAC为eth1的物理地址。
arp -i eth0 -d $ipf_0
arp -i eth1 -d $ipf_1
arp -i eth0 -s $ipf_0 $mac_0
arp -i eth1 -s $ipf_1 $mac_1
# 使用iperf3测试，终端1侦听
# iperf3 -s -B 10.50.1.1 -p 1616
# 终端2发流
# iperf3 -B 10.50.0.1 -c 10.60.1.1 -t 6 -i 3 -p 1616