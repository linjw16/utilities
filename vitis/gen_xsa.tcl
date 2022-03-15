
# 
# Created on Tue Mar 15 2022
# 
# Copyright (c) 2022 IOA UCAS
# 
# @Filename:	 gen_xsa.tcl
# @Author:		 Jiawei Lin
# @Last edit:	 10:27:55
# 
# vivado -mode tcl -source filename.tcl


# Set the name of the project:
set project_name pspl_bd_pj

# Set the project device:
set device xczu19eg-ffvc1760-2-e

# Set the bd name:
set bd_name pspl_bd
set JOBS 4

# Set the path to the directory we want to put the Vivado build in. Convention is <PROJECT NAME>_hw
set proj_dir ../${project_name}

create_project -name ${project_name} -force -dir ${proj_dir} -part ${device}



# Source the BD file, BD naming convention is ${bd_name}.tcl
source ${bd_name}.tcl

make_wrapper -files [get_files ${proj_dir}/${project_name}.srcs/sources_1/bd/${bd_name}/${bd_name}.bd] -inst_template
add_files -fileset sources_1 ${proj_dir}/${project_name}.srcs/sources_1/bd/${bd_name}/hdl/${bd_name}_wrapper.v

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

validate_bd_design
save_bd_design
close_bd_design ${bd_name}

open_bd_design ${proj_dir}/${project_name}.srcs/sources_1/bd/${bd_name}/${bd_name}.bd
set_property synth_checkpoint_mode None [get_files ${proj_dir}/${project_name}.srcs/sources_1/bd/${bd_name}/${bd_name}.bd]

add_files -fileset sources_1 ${proj_dir}/../sources/rtl/${bd_name}_top.v
set_property top ${bd_name}_top [current_fileset]


add_files -fileset constrs_1 ${proj_dir}/../constraints/${bd_name}_top.xdc
add_files -fileset constrs_1 ${proj_dir}/../constraints/${bd_name}.xdc



reset_run synth_1
launch_runs -jobs ${JOBS} synth_1
wait_on_run synth_1

reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs ${JOBS}
wait_on_run impl_1

write_hw_platform -fixed -include_bit -force -file ${proj_dir}/${bd_name}.xsa

quit


