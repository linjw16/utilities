# filename: dow_fpga.sh
sudo setpci -s 0000:ae:00.0 COMMAND=0447
sudo setpci -s 0000:ae:00.0 CAP_EXP+8.w=0120
bit=${1}
scp root@192.168.9.15:/home/linjw/prj/.backup/$bit.bit ./$bit.bit
cp $bit.bit fpga.bit
source /home/vitis/Vivado/2020.2/settings64.sh
xsdb
connect
fpga -f ./fpga.bit
exit
