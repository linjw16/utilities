/*
 * Created on Thu Jul 28 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 gshare.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 21:40:28
 */

/*
 * Branch direction predictor
 * http://www.hdlbits.com/gshare
 * 
 * 1. Does prediction would change the entry in PHT? 
 * 2. Does 
 * two and a half hours... 
 */

module top_module #(
	parameter DUMMY = 0
) (
	input clk,
	input areset,

	input  predict_valid,
	input  [6:0] predict_pc,
	output predict_taken,
	output [6:0] predict_history,

	input train_valid,
	input train_taken,
	input train_mispredicted,
	input [6:0] train_history,
	input [6:0] train_pc
);

	/* 1. Pattern History Table (PHT). depth: 128, width: 2 */
	localparam ADDR_WIDTH = 7;
	reg [2*2**ADDR_WIDTH-1:0] pht_reg = {2**ADDR_WIDTH{2'b01}}, pht_next;
	reg [1:0] pht_predict, pht_train;
	reg predict_reg = 1'b0, predict_next;
	wire [ADDR_WIDTH:0] idx_predict, idx_train;
	assign idx_predict = {1'b0, predict_pc ^ history_reg};	/* Overflow bit */
	assign idx_train = {1'b0, train_pc ^ train_history};
	assign predict_taken = pht_predict[1];
	// assign predict_taken = (idx_train==idx_predict) ? train_taken : pht_predict[1];
	// assign predict_taken = predict_reg;

	always @(*) begin
		pht_next = pht_reg;
		predict_next = predict_reg;
		pht_train = pht_reg[idx_train<<1+:2];
		pht_predict = pht_reg[idx_predict<<1+:2];
		if (train_valid) begin
			if (train_taken) begin
				pht_next[idx_train<<1+:2] = (&pht_train) ? 2'b11 : pht_train+2'b01;
			end else begin
				pht_next[idx_train<<1+:2] = (|pht_train) ? pht_train-2'b01 : 2'b00;
			end
			predict_next = pht_next[(idx_predict<<1)+1]; 	/* Get the immediate value */
		end else if (predict_valid) begin	/* Prediction does not change the PHT. */
			// pht_next[idx_predict<<1+:2] = pht_predict[1] ? 2'b11 : 2'b00;
			predict_next = pht_predict[1]; 
		end 
	end
	always @(posedge clk or posedge areset) begin
		if (areset) begin
			pht_reg <= {2**ADDR_WIDTH{2'b01}};
			predict_reg <= 1'b0;
		end else begin
			pht_reg <= pht_next;
			predict_reg <= predict_next;
		end
	end

	/* 2. Branch history (BH) */
	localparam BH_DEPTH = 7;
	reg [BH_DEPTH-1:0] history_reg = {BH_DEPTH{1'h0}}, history_next;
	always @(*) begin
		history_next = history_reg;
		if (train_valid && train_mispredicted) begin	/* training takes precedence. */
			history_next = {train_history[BH_DEPTH-2:0], train_taken};
		end else if (predict_valid) begin
			history_next = {history_reg[BH_DEPTH-2:0], predict_taken};
		end
	end
	always @(posedge clk or posedge areset) begin
		if (areset) begin
			history_reg <= {BH_DEPTH{1'h0}};
		end else begin
			history_reg <= history_next;
		end
	end
	assign predict_history = history_reg;

endmodule