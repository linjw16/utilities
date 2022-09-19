# filename: dump.sh
tcpdump -c 1000 -i p4p1 -w p4p1.pcap &
tcpdump -c 1000 -i enp175s0d1 -w p4p2.pcap &