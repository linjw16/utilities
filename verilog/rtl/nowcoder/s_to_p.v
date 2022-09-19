`timescale 1ns/1ns

module s_to_p(
	input 				clk 		,   
	input 				rst_n		,
	input				valid_a		,
	input	 			data_a		,
 
 	output	wire 		ready_a		,
 	output	wire			valid_b		,
	output  wire [5:0] 	data_b
);
    localparam WIDTH = 6;
    localparam CNT_WIDTH = 4;
    reg [WIDTH-1:0] srl_reg = {WIDTH{1'b0}}, srl_next;
    reg in_ready_reg = 1'b0, in_ready_next;
    reg out_valid_reg = 1'b0, out_valid_next;
    reg [WIDTH-1:0] out_data_reg = {WIDTH{1'b0}}, out_data_next;
    reg [CNT_WIDTH-1:0] cnt_reg = {CNT_WIDTH{1'b0}}, cnt_next;
    assign ready_a = in_ready_reg;
    assign valid_b = out_valid_reg;
    assign data_b = out_data_reg;
    always @(*) begin
        srl_next = srl_reg;
        cnt_next = cnt_reg;
        out_valid_next = out_valid_reg;
        in_ready_next = 1'b1;
        out_data_next = out_data_reg;
        if (out_valid_reg) begin
            out_valid_next = 1'b0;
        end
        if (valid_a & in_ready_reg) begin
            srl_next = {data_a, srl_reg[WIDTH-2:0]};
            cnt_next = cnt_reg + 1;
            if (cnt_reg == WIDTH-1) begin
                out_data_next = srl_next;
                out_valid_next = 1'b1;
                cnt_next = {CNT_WIDTH{1'b0}};
            end
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            in_ready_reg <= 1'b0;
            out_valid_reg <= 1'b0;
            srl_reg <= {WIDTH{1'b0}};
            cnt_reg <= {CNT_WIDTH{1'b0}};
            out_data_reg <= {WIDTH{1'b0}};
        end else begin
            in_ready_reg <= in_ready_next;
            out_valid_reg <= out_valid_next;
            srl_reg <= srl_next;
            cnt_reg <= cnt_next;
            out_data_reg <= out_data_next;
        end
    end
endmodule