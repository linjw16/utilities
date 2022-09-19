`timescale 1ns/1ps
`default_nettype none

module testbench ();
  reg [31:0] a, b;
  reg sub;
  wire [31:0] sum;
  initial begin
    $dumpfile("out.vcd");
    $dumpvars(0, testbench);
    a = 0;
    b = 0;
    sub = 0;
    #10;
    a = 8;
    b = 7;
    sub = 0;
    #10;
    a = 8;
    b = 7;
    sub = 1;
    #10;
    #100;
  end
  addsub addsub_inst(a, b, sub, sum);
  
endmodule