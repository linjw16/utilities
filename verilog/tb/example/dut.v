/*
 * Created on Tue Jan 18 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 dut.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 10:15:35
 */
// /* verilator lint_off LITENDIAN */

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * FracTCAM with match table and output and gate. 
 */
module dut #(
	parameter DATA_WIDTH = 5,
	parameter DEPTH = 64,
    parameter WIDTH = 16
) (
	input  wire clk,
	input  wire rst,
	input  wire [DATA_WIDTH*DEPTH-1:0] in_1,
	output wire [DEPTH-1:0] out_1
);

localparam KEEP_WIDTH = DATA_WIDTH / 8;
localparam CL_DATA_WIDTH = $clog2(DATA_WIDTH);
localparam CL_KEEP_WIDTH = $clog2(KEEP_WIDTH);

reg  reg_1 = 0;

wire [DATA_WIDTH-1:0] wire_1, wire_2, wire_3;
wire [-1:0] wire_4;

assign wire_1[2 -: 2] = in_1[1:0];
assign wire_2[2 +: 2] = in_1[80:0];
assign wire_4[0] = clk;

wire [DEPTH-1:0] t_out_1;

test #(
	.DATA_WIDTH(1),
	.DEPTH(4),
	.ENABLE(1)
) test_inst (
	.in_1(clk),
	.out_1(t_out_1)
);

always @(clk) begin
	reg_1 <= 1'b1;
	reg_1 <= 1'b0;
end

endmodule

`resetall