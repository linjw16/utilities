`timescale 1ns/1ps
`default_nettype none

module testbench();
    reg  clk = 0;
    reg  arst_n = 0;
    reg  d = 0;
    wire dout;
    
    initial begin
        $dumpfile("out.vcd");
        $dumpvars(0, testbench);
        #8;
        arst_n = 1; #8;
        d = 1; #15;
        arst_n = 0; #2;
        arst_n = 1; #6;
        d = 1; #48;
        $finish;
    end

    always #2 clk = ~clk;
    arst_n dut (
        .clk    (clk),
        .arst_n (arst_n),
        .d      (d),
        .dout   (dout)
    );
endmodule