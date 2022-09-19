`timescale 1ns/1ps
`default_nettype none

module testbench ();
    reg [7:0] in;
    wire [7:0] pedge;
    reg clk = 0;

    initial begin
        $dumpfile("out.vcd");
        $dumpvars(0, testbench);
        in = 0;
        #10;
        in = 8'b1001_0000;
        #10;
        in = 8'b1001_0100;
        #10;
        $finish;
    end

    always #4 clk = ~clk;

    pedge_8 inst (clk, in, pedge);

endmodule