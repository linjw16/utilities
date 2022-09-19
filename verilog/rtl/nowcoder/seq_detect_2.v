/*
 * VL28 输入序列不连续的序列检测 
 */
`timescale 1ns/1ns
module sequence_detect(
	input clk,
	input rst_n,
	input data,
	input data_valid,
	output reg match
	);
    localparam PATTERN = 4'b0110;
    localparam SRL_WIDTH = 4;
    reg [SRL_WIDTH-1:0] srl_reg = {SRL_WIDTH{1'b0}}, srl_next;
    reg match_next;
    always @(*) begin
        srl_next = srl_reg;
        match_next = 1'b0;
        if (data_valid) begin
            srl_next = {srl_reg[2:0], data};
            match_next = (srl_next==PATTERN);
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            srl_reg <= {SRL_WIDTH{1'b0}};
            match <= 1'b0;
        end else begin
            srl_reg <= srl_next;
            match <= match_next;
        end
    end
endmodule