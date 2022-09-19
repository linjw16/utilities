#
#    ____  ____ 
#   /   /\/   /
#  /___/  \  /    Vendor: Xilinx
#  \   \   \/     Version : .96
#   \   \         Application : Vivado Transceivers script
#   /   /         Filename : gt_Attributes.tcl
#  /___/   /\     
#  \   \  /  \ 
#   \___\/\___\
# 
#  
#  (c) Copyright 2010-2012 Xilinx, Inc. All rights reserved.
#  
#  This file contains confidential and proprietary information
#  of Xilinx, Inc. and is protected under U.S. and
#  international copyright and other intellectual property
#  laws.
#  
#  DISCLAIMER
#  This disclaimer is not a license and does not grant any
#  rights to the materials distributed herewith. Except as
#  otherwise provided in a valid license issued to you by
#  Xilinx, and to the maximum extent permitted by applicable
#  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
#  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
#  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
#  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
#  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
#  (2) Xilinx shall not be liable (whether in contract or tort,
#  including negligence, or under any other theory of
#  liability) for any loss or damage of any kind or nature
#  related to, arising under or in connection with these
#  materials, including for any direct, or any indirect,
#  special, incidental, or consequential loss or damage
#  (including loss of data, profits, goodwill, or any type of
#  loss or damage suffered as a result of any action brought
#  by a third party) even if such damage or loss was
#  reasonably foreseeable or Xilinx had been advised of the
#  possibility of the same.
#  
#  CRITICAL APPLICATIONS
#  Xilinx products are not designed or intended to be fail-
#  safe, or for use in any application requiring fail-safe
#  performance, such as life-support or safety devices or
#  systems, Class III medical devices, nuclear facilities,
#  applications related to the deployment of airbags, or any
#  other applications that could lead to death, personal
#  injury, or severe property or environmental damage
#  (individually and collectively, "Critical
#  Applications"). Customer assumes the sole risk and
#  liability of any use of Xilinx products in Critical
#  Applications, subject only to applicable laws and
#  regulations governing limitations on product liability.
#  
#  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
#  PART OF THIS FILE AT ALL TIMES. 
# 
#  Get GT attributes Rev .9  Sept 18, 2015
#  Rev .96 add gtp common
################################################################################

set filename "gtParams.txt"

proc byp {a b} {
	global outList
	return [string compare $outList($a) $outList($b)]
}
# check mods to gtx channel pins
set needle "/"
set f [open $filename [list WRONLY CREAT APPEND]]
chan truncate $f 0

set gt_list [get_cells -hierarchical -filter {LIB_CELL =~ *GTXE2_CHANNEL*}]
append gt_list " "
append gt_list [get_cells -hierarchical -filter {LIB_CELL =~ *GTHE2_CHANNEL*}]
append gt_list " "
append gt_list [get_cells -hierarchical -filter {LIB_CELL =~ *GTYE3_CHANNEL*}]
append gt_list " "
append gt_list [get_cells -hierarchical -filter {LIB_CELL =~ *GTYE4_CHANNEL*}]
append gt_list " "
append gt_list [get_cells -hierarchical -filter {LIB_CELL =~ *GTHE3_CHANNEL*}]
append gt_list " "
append gt_list [get_cells -hierarchical -filter {LIB_CELL =~ *GTHE4_CHANNEL*}]
append gt_list " "
append gt_list [get_cells -hierarchical -filter {LIB_CELL =~ *GTPE2_CHANNEL*}]

foreach gt_instance $gt_list {
	set gt_site [get_property SITE [get_cells $gt_instance]]
	#
	report_property [get_cells $gt_instance] -append -file $filename

	set netList [get_nets -of_objects [get_pins -filter {DIRECTION =~ in} -of_objects [get_cells $gt_instance]]]

	set a 1

	set f [open $filename [list WRONLY CREAT APPEND]]
	foreach net  $netList {

		set str [get_property PARENT $net]

		if {[string match *const0* $net] || [string match *GND* $net]} {
			set pinList [get_pins -of_objects [get_nets $net]]
			foreach g $pinList {
				set new [string replace $g 0 [string last $needle $g [string length $g]]]
				set outList($a) [format "%-25s 0" $new]
				[incr a] 
			}
		}
		if {[string match *const1* $net] || [string match *VCC* $net]  } {
			set pinList [get_pins -of_objects [get_nets $net]]
			foreach g $pinList {
				set new [string replace $g 0 [string last $needle $g [string length $g]]]
				set outList($a) [format "%-25s 1" $new]
				[incr a]
			}

		}

		if { [string match *const1* $str ]} {
		set new [string replace $net 0 [string last $needle $net [string length $net]]]
		set outList($a) [format "%-25s 1" $new]
		[incr a]
		}
		if { [string match *const0* $str ]} {
		set new [string replace $net 0 [string last $needle $net [string length $net]]]
			set outList($a) [format "%-25s 0" $new]
			[incr a]

		}
	}

	set byplace [lsort -command byp [array names outList]]

	foreach pl $byplace {
		puts $f " $outList($pl)"
	}

	close $f

}


set cm_list [get_cells -hierarchical -filter {LIB_CELL =~ *GTXE2_COMMON*}]
append cm_list " "
set cm_list [get_cells -hierarchical -filter {LIB_CELL =~ *GTPE2_COMMON*}]
append cm_list " "
append cm_list [get_cells -hierarchical -filter {LIB_CELL =~ *GTHE2_COMMON*}]
append cm_list " "
append cm_list [get_cells -hierarchical -filter {LIB_CELL =~ *GTYE3_COMMON*}]
append cm_list " "
append cm_list [get_cells -hierarchical -filter {LIB_CELL =~ *GTHE4_COMMON*}]
append cm_list " "
append cm_list [get_cells -hierarchical -filter {LIB_CELL =~ *GTYE4_COMMON*}]
append cm_list " "
append cm_list [get_cells -hierarchical -filter {LIB_CELL =~ *GTYE3_COMMON*}]
append cm_list " "
append cm_list [get_cells -hierarchical -filter {LIB_CELL =~ *GTHE3_COMMON*}]

foreach cm_instance $cm_list {
	report_property [get_cells $cm_instance] -append -file $filename
}
