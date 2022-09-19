
/*
 * VL36 状态机-重叠序列检测 
 *  设计一个状态机，用来检测序列 1011，要求：
 * 1、进行重叠检测   即10110111 会被检测通过2次
 * 2、寄存器输出，在序列检测完成下一拍输出检测有效
 * 注意rst为低电平复位
 */
 
`timescale 1ns/1ns
module sequence_test2(
	input wire clk  ,
	input wire rst  ,
	input wire data ,
	output wire flag
);
//*************code***********//
    localparam PATTERN = 4'b1011;
    reg [3:0] srl_reg = 4'h0, srl_next;
    reg flag_reg = 1'b0, flag_next;
    assign flag = flag_reg;
    always @(*) begin
        srl_next = {srl_reg[2:0], data};
        flag_next = srl_reg == PATTERN;
    end
    always @(posedge clk) begin
        if (~rst) begin
            srl_reg <= 4'h0;
            flag_reg <= 1'b0;            
        end else begin
            srl_reg <= srl_next;
            flag_reg <= flag_next;
        end
    end
endmodule