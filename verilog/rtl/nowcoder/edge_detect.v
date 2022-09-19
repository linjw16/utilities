`timescale 1ns/1ns

module edge_detect(
	input clk,
	input rst_n,
	input data_in,
	output reg data_out
	);
reg data_in_reg = 1'b0, data_in_next;
    reg data_out_next;
    always @(*) begin
        data_in_next = data_in;
        data_out_next = 1'b0;
        if (~data_in_reg & data_in) begin
            data_out_next = 1'b1;
        end
    end
    always @(posedge clk) begin
        if (~rst_n) begin
            data_in_reg <= 1'b0;
            data_out <= 1'b0;
        end else begin
            data_in_reg <= data_in_next;
            data_out <= data_out_next;
        end
    end
endmodule