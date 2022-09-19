/*
 * VL37 时钟分频（偶数）
 *  请使用D触发器设计一个同时输出2/4/8分频的50%占空比的时钟分频器
 * 注意rst为低电平复位
 */

`timescale 1ns/1ns

module even_div
    (
    input     wire rst ,
    input     wire clk_in,
    output    wire clk_out2,
    output    wire clk_out4,
    output    wire clk_out8
    );
    reg [3:0] cnt_reg = 4'h0, cnt_next;
    wire clk_out1;
    assign {clk_out8, clk_out4, clk_out2} = cnt_reg; 
    always @(*) begin
        cnt_next = cnt_reg - 1;
    end
    always @(posedge clk_in) begin
        if (~rst) begin
            cnt_reg <= 4'h0;
        end else begin
            cnt_reg <= cnt_next;
        end
    end
endmodule