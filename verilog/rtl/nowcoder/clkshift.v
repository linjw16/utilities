`timescale 1ns/1ns

module clkshift(
	input wire clk0  ,
	input wire clk1  ,
	input wire rst  ,
	input wire sel ,
	output wire clk_out
);
    reg clk_out_reg = 1'b0, clk_out_next;
    reg s0_reg = 1'b0, s0_next;
    reg s1_reg = 1'b0, s1_next;
    assign clk_out = s0_reg ? clk1 : s1_reg ? clk1 : clk0;
    always @(*) begin
        s0_next = s0_reg;
        s1_next = s1_reg;
        s0_next = sel;
        s1_next = sel;
    end
    always @(posedge clk0) begin
        if (~rst) begin
            s0_reg <= 0;
        end else begin
            s0_reg <= s0_next;
        end
    end
    always @(posedge clk1) begin
        if (~rst) begin
            s1_reg <= 0;
        end else begin
            s1_reg <= s1_next;
        end
    end
endmodule