/*
 * Created on Mon Jul 25 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 ps_2.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 14:49:53
 */

/*
 * PS/2 mouse protocol. 
 * Three byte message, IN[3] of byte one is always 1b1.
 */

`resetall
`default_nettype none
`timescale 1ns/1ps

module ps_2(
	input clk,
	input [7:0] in,
	input reset,	// Synchronous reset
	output [23:0] out_bytes,
	output done);

	localparam DATA_WIDTH = 24;
	localparam 	ST_IDLE = 4'h0, 
				ST_BYTE1 = 4'h1, 
				ST_BYTE2 = 4'h2, 
				ST_BYTE3 = 4'h4;
	reg [3:0] state_reg = ST_IDLE, state_next;
	reg [DATA_WIDTH-1:0] out_reg = {DATA_WIDTH{1'b0}}, out_next;
	// State transition logic (combinational)
	always @(*) begin 
		state_next = state_reg;
		out_next = out_reg;
		case (state_reg)
			ST_IDLE: begin
				if (in[3]) begin
					state_next = ST_BYTE1;
					out_next[23:16] = in;
				end else begin 
					state_next = ST_IDLE;
				end
			end
			ST_BYTE1: begin
				out_next[15:8] = in;
				state_next = ST_BYTE2;
			end
			ST_BYTE2: begin
				out_next[7:0] = in;
				state_next = ST_BYTE3;
			end
			ST_BYTE3: begin
				if (in[3]) begin
					out_next[23:16] = in;
					state_next = ST_BYTE1;
				end else begin 
					state_next = ST_IDLE;
				end
			end
		endcase
	end
	// State flip-flops (sequential)
	always @(posedge clk) begin
		if (reset) begin
			state_reg <= ST_IDLE;
			out_reg <= {DATA_WIDTH{1'b0}};
		end else begin
			state_reg <= state_next;
			out_reg <= out_next;
		end
	end
	// Output logic
	assign done = state_reg == ST_BYTE3;
	assign out_bytes = out_reg;

endmodule

`resetall