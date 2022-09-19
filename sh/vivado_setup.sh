
## filename: 192.168.186.12:/home/linjw/vivado_setup.sh
source /tools/Xilinx/Vivado/2020.2/settings64.sh


## filename: 192.168.47.192:/home/linjw/vivado_setup.sh
cd /home/linjw/prj/
# 1. Vivado enviornment. 
source /home/vitis/Vivado/2020.2/settings64.sh
source /data/petalinux/2020.2/settings.sh
# source /home/vivado/Vivado/2019.1/settings64.sh
# source /home/petalinux/2019.2/settings.sh
# 2. for board F1000
lspci -s af:00.0
sudo setpci -s 0000:ae:00.0 COMMAND=0447
sudo setpci -s 0000:ae:00.0 CAP_EXP+8.w=0120
# 3. Directory
tftpdir=/var/lib/tftpboot/linjw/
prj_plnx=/home/linjw/prj_petalinux/prj_boot/
# 4. VNC server
rm -f /tmp/.X11-unix/X16
vncserver :16


## filename: 192.168.9.202:/home/linjw/vivado_setup.sh
cd /home/linjw/rec/
source /cache_system/ssd/vivado/Vivado/2020.2/settings64.sh
## Disable fatal error report from the slot that plug the F1000 board.                                                                         
setpci -s 0000:5d:00.0 COMMAND=0447
setpci -s 0000:5d:00.0 CAP_EXP+8.w=0120
lspci -s 5e:00.0


## filename: 192.168.9.17:/home/linjw/vivado_setup.sh
cd /home/linjw/prj/
## 1. Vivado tools
source /home/Xilinx/Vivado/2020.2/settings64.sh
source /home/petalinux/2020.2/settings.sh
## 2. VNC desktop
rm -f /tmp/.X11-unix/X16
vncserver :16


## filename: 192.168.9.15:/home/linjw/vivado_setup.sh
## Vivado and Petalinux tools.
source /home/vitis/vitis_2020/Vivado/2020.2/settings64.sh
source /home/petalinux/2020.2/settings.sh
## Virtual Network Console
rm -f /tmp/.X11-unix/X16
vncserver :16
## some directory
echo /home/linjw/prj/smartnic/applications/seasw/rtl/integration
echo /home/linjw/prj/smartnic/corundum/fpga/mqnic/F1000/fpga_100g/


## filename: 192.168.9.7:/home/mount/linjw/vivado_setup.sh
cd /home/mount/linjw/prj/d
## 1. Vivado tools
source /home/mount/Vivado/2020.2/settings64.sh
# source /home/petalinux/2020.2/settings.sh
## 2. VNC desktop
rm -f /tmp/.X11-unix/X16
vncserver :16


## filename: 192.168.101.2:/home/linjw/vivado_setup.sh
source /tools/Xilinx/Vivado/2020.2/settings64.sh
alias mk="clear && make clean && make"
cd /home/linjw/prj/smartnic/