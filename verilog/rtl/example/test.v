/*
 * Created on Sat Feb 19 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 test.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 15:35:16
 */


`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * FracTCAM with match table and output and gate. 
 */
module test #(
	parameter DATA_WIDTH = 5,
	parameter DEPTH = 8,
	parameter ENABLE = 1
) (
	input  wire clk,
	input  wire rst,
	input  wire [DATA_WIDTH-1:0] in_1,
	output wire [DEPTH-1:0] out_1
);


assign out_1 = in_1;

endmodule

`resetall