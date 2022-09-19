`timescale 1ns/1ns
module sequence_detect(
	input clk,
	input rst_n,
	input a,
	output reg match
	);

    reg [7:0] pattern = 8'b01110001;
    reg [7:0] srl_reg = 8'h00, srl_next;
    reg match_next = 1'b0;
    
    always @(*) begin
        if (srl_reg ^ pattern) begin
            match_next = 1'b0;
        end else begin
            match_next = 1'b1;
        end
        srl_next = {srl_reg[6:0], a};
		if (match) begin
			srl_next = {6'b00_0000, a};
		end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            srl_reg <= 8'h00;
            match <= 1'b0;
        end else begin
            srl_reg <= srl_next;
            match <= match_next;
        end
    end
endmodule
