
/* 
 * signal_generator
 * VL29 信号发生器 
 * 
 */

`timescale 1ns/1ps
module sig_gen_1(
	input clk,
	input rst_n,
	input [1:0] wave_choise,
	output reg [4:0]wave
	);
    localparam  ST_SQUARE = 4'h0,
                ST_SAWTOOTH = 4'h1,
                ST_TRIANGULAR = 4'h2;
    localparam CNT_WIDTH = 5;
    localparam PERIOD = 2**CNT_WIDTH;
    reg [3:0] state_reg = ST_SQUARE, state_next;
    reg [4:0] wave_next;
    reg [CNT_WIDTH-1:0] cnt_reg = {CNT_WIDTH{1'b0}}, cnt_next;
    reg inc_reg = 1'b1, inc_next;
    always @(*) begin
        state_next = state_reg;
        wave_next = wave;
        cnt_next = cnt_reg+1;
        inc_next = inc_reg;
        case (state_reg)
            ST_SQUARE: begin
                if (cnt_reg[CNT_WIDTH-1]) begin
                    wave_next = 5'h1F;
                end else begin
                    wave_next = 5'h00;
                end
                if (wave_choise == ST_SAWTOOTH) begin
                    state_next = ST_SAWTOOTH;
                    wave_next = 5'h00;
                    cnt_next = {CNT_WIDTH{1'b0}};
                end else if (wave_choise == ST_TRIANGULAR) begin
                    state_next = ST_TRIANGULAR;
                    if (|wave) begin
                        wave_next = wave-1;
                        cnt_next = 2**(CNT_WIDTH-1);
                    end else begin
                        wave_next = wave+1;
                        cnt_next = {CNT_WIDTH{1'b0}};
                    end
                end
            end
            ST_SAWTOOTH: begin
                if (&wave) begin
                    wave_next = 5'h00;
                end else begin
                    wave_next = wave+1;
                end
                if (wave_choise == ST_SQUARE) begin
                    state_next = ST_SQUARE;
                    wave_next = 5'h00;
                    cnt_next = {CNT_WIDTH{1'b0}};
                end else if (wave_choise == ST_TRIANGULAR) begin
                    state_next = ST_TRIANGULAR;
                    if (~|wave) begin
                        wave_next = 5'h01;
                        cnt_next = wave_next;
                        inc_next = 1'b1;
                    end else begin
                        if (wave == 5'h01) begin
                            wave_next = 5'h00;
                            cnt_next = wave_next;
                            inc_next = 1'b1;
                        end else begin
                            wave_next = wave-1;
                            cnt_next = ~wave_next+1;
                            inc_next = 1'b0;
                        end
                    end
                end
            end
            ST_TRIANGULAR: begin
                if (&wave) begin
                    inc_next = ~inc_reg;
                    wave_next = wave-1;
                end else if (~|wave) begin
                    inc_next = ~inc_reg;
                    wave_next = wave+1;
                end else if (inc_reg) begin
                    wave_next = wave+1;
                end else begin
                    wave_next = wave-1;
                end
                if (wave_choise == ST_SQUARE) begin
                    state_next = ST_SQUARE;
                    wave_next = 5'h00;
                    cnt_next = {CNT_WIDTH{1'b0}};
                end else if (wave_choise == ST_SAWTOOTH) begin
                    state_next = ST_SAWTOOTH;
                    wave_next = wave+1;
                    cnt_next[CNT_WIDTH-2:0] = wave+1;
                end
            end
        endcase
    end
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            wave <= 5'h00;
            state_reg <= ST_SQUARE;
            cnt_reg <= {CNT_WIDTH{1'b0}};
            inc_reg <= 1'b1;
        end else begin
            wave <= wave_next;
            state_reg <= state_next;
            cnt_reg <= cnt_next;
            inc_reg <= inc_next;
        end
    end
endmodule