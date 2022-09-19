# filename: replay.sh
echo export IF=enp15s0d1
tcpreplay -i $IF -M '1' -l 100 ./pkt_send_v4.pcap
tcpreplay -i $IF -M '1' -l 100 ./pkt_send_300.pcap
tcpreplay -i $IF -M '1' -l 100 ./pkt_send_301.pcap