/* 
 *  请设计一个可以实现任意小数分频的时钟分频器，比如说8.7分频的时钟信号
 * 注意rst为低电平复位
 * 87×Tin = 10×Tout = 3×T8+7×T9
 */

`timescale 1ns/1ps
`default_nettype none

module div_M_N(
 input  wire clk_in,
 input  wire rst,
 output wire clk_out
);
localparam NUM_TOTAL = 87;
localparam NUM_SHIFT = 24;
localparam CNT_WIDTH = 8;
localparam NUM_DUT9 = 4'h5;
localparam CNT_UB9 = 4'h9;
localparam CNT_UB4 = 4'h4;
reg [CNT_WIDTH-1:0] cnt_reg = {CNT_WIDTH{1'b0}}, cnt_next;
reg clk_div8_reg = 1'b0, clk_div8_next;
// reg clk_div9_reg = 1'b0, clk_div9_next;
reg [3:0] cnt9p_reg = 1'b0, cnt9p_next;
reg [3:0] cnt9n_reg = 1'b0, cnt9n_next;
reg clk_div18p_reg = 1'b0, clk_div18p_next;
reg clk_div18n_reg = 1'b0, clk_div18n_next;

wire clk_div9 = clk_div18p_reg ^ clk_div18n_reg;

assign clk_out = (cnt_reg >= NUM_SHIFT) ? clk_div9 : clk_div8_reg;

always @(*) begin
    cnt_next = cnt_reg+1;
    clk_div8_next = clk_div8_reg;
    cnt9p_next = cnt9p_reg + 1;
    cnt9n_next = cnt9n_reg + 1;
    clk_div18p_next = clk_div18p_reg;
    clk_div18n_next = clk_div18n_reg;
    if (&cnt_reg[1:0]) begin
        clk_div8_next = ~clk_div8_reg;
    end
    if (cnt_reg >= NUM_TOTAL-1) begin
        cnt_next = 0;
        clk_div8_next = 1'b0;
    end
    if (cnt9p_reg == CNT_UB9-1) begin
        cnt9p_next = 4'h0;
        clk_div18p_next = ~clk_div18p_reg;
    end
    if (cnt9n_reg == CNT_UB9-1) begin
        cnt9n_next = 4'h0;
        clk_div18n_next = ~clk_div18n_reg;
    end
    if (cnt_reg == NUM_SHIFT-1) begin
        cnt9p_next = 4'h0;
        cnt9n_next = NUM_DUT9-1;
        clk_div18p_next = 0;
        clk_div18n_next = 0;
    end
end

always @(posedge clk_in) begin
    if (~rst) begin
        cnt_reg <= {CNT_WIDTH{1'b0}};
        clk_div8_reg <= 1'b0;
        cnt9p_reg <= 4'h0;
        clk_div18p_reg <= 1'b0;
    end else begin
        cnt_reg <= cnt_next;
        clk_div8_reg <= clk_div8_next;
        cnt9p_reg <= cnt9p_next;
        clk_div18p_reg <= clk_div18p_next;
    end
end

always @(negedge clk_in) begin
    if (~rst) begin
        cnt9n_reg <= NUM_DUT9;
        clk_div18n_reg <= 1'b0;
    end else begin
        cnt9n_reg <= cnt9n_next;
        clk_div18n_reg <= clk_div18n_next;
    end
end

endmodule