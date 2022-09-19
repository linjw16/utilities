`timescale 1ns/1ps
`default_nettype none

module testbench ();
    reg [7:0] in;
    wire [2:0] pos;

    initial begin
        $dumpfile("out.vcd");
        $dumpvars(0, testbench);
        in = 0;
        #10;
        in = 8'b1001_0000;
        #10;
        in = 8'b1001_0100;
        #10;
    end

    encoder_8 inst (in, pos);

endmodule