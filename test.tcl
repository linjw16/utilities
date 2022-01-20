set base_name {eth_xcvr_gt}

set preset {GTY-10GBASE-R}

set freerun_freq {125}
set line_rate {25.78125}
set refclk_freq {161.1328125}
# set qpll_fracn [expr {int(fmod($line_rate*1000/2 / $refclk_freq, 1)*pow(2, 24))}]
set qpll_fracn [expr {int(1)}]
echo $qpll_fracn
