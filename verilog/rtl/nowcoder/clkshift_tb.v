`timescale 1ns/1ps
`default_nettype none

module testbench ();
    reg clk0 = 0;
    reg clk1 = 0;
    reg rst = 0;
    reg sel = 0;

    wire clk_out;

    initial begin
        $dumpfile("out.vcd");
        $dumpvars(0, testbench);
        #8;
        rst = 1; #16;
        sel = 1; #48;
        sel = 0; #48;
        sel = 1; #48;
        $finish;
    end

    always #2 clk1 = ~clk1;
    always #4 clk0 = ~clk0;
    
    clkshift dut(
        .clk0       (clk0),
        .clk1       (clk1),
        .rst        (rst),
        .sel        (sel),
        .clk_out    (clk_out)
    );

endmodule