`timescale 1ns/1ns
module seq_detect_1(
	input clk,
	input rst_n,
	input data,
	output reg match,
	output reg not_match
	);
    localparam PATTERN = 6'b01_1100;
    reg [5:0] srl_reg = 6'h00, srl_next;
    reg match_next, not_match_next;
    reg [3:0] cnt_reg = 4'h0, cnt_next;
    always @(*) begin
        srl_next = {srl_reg[4:0], data};
        match_next = 1'b0;
        not_match_next = 1'b0;
        if (~(|cnt_reg)) begin
        end
        cnt_next = cnt_reg + 4'h1;
        if (cnt_reg == 4'h5) begin
            cnt_next = 4'h0;
            match_next = srl_next == PATTERN;
            not_match_next = |(srl_next ^ PATTERN);
        end 
    end
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            srl_reg <= 6'h00;
            match <= 1'b0;
            not_match <= 1'b0;
            cnt_reg <= 4'h0;
        end else begin
            srl_reg <= srl_next;
            match <= match_next;
            not_match <= not_match_next;
            cnt_reg <= cnt_next;
        end
    end
endmodule