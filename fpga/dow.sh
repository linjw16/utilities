# 1. download bitstream
source /home/linjw/vivado_setup.sh
xsdb
connect
fpga -f /home/linjw/prj_f1000/.backup/l3fwd_0412.bit
exit

# 2. reload driver
rmmod mqnic.ko
sh /home/linjw/rec_f1000/pcie_hot_reset.sh af:00.0
insmod /home/linjw/prj/fpga_25g/modules/mqnic/mqnic.ko
dmesg -T | grep mqnic
