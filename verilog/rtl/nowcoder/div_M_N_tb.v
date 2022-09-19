

`timescale 1ns/1ps
`default_nettype none

module testbench();
	reg clk = 0;
    reg rst = 0;
    wire out;
    initial begin
        $dumpfile("out.vcd");
        $dumpvars(0, testbench);
        rst = 0; #9;
        rst = 1; #512;
        $finish;
    end  
    
    always #2 clk = ~clk;  // Create clock with period=10

    div_M_N dut (
        .rst        (rst),
        .clk_in     (clk),
        .clk_out    (out)
    );
endmodule