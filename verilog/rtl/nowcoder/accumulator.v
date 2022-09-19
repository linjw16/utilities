
/*
 * VL31 数据累加输出 
 *  实现串行输入数据累加输出，输入端输入8bit数据，每当模块接收到4个输入数据后，输出端输出4个接收到数据的累加结果。输入端和输出端与上下游的交互采用valid-ready双向握手机制。要求上下游均能满速传输时，数据传输无气泡，不能由于本模块的设计原因产生额外的性能损失。
 * 电路的接口如下图所示。valid_a用来指示数据输入data_in的有效性，valid_b用来指示数据输出data_out的有效性；ready_a用来指示本模块是否准备好接收上游数据，ready_b表示下游是否准备好接收本模块的输出数据；clk是时钟信号；rst_n是异步复位信号。 
 */
`timescale 1ns/1ns

module valid_ready(
    input  wire clk,
    input  wire rst_n,

    input  wire [7:0] data_in,
    input  wire valid_a,
    output wire ready_a,

    output wire [9:0] data_out,
    output wire valid_b,
    input  wire ready_b  
);
    localparam OUT_WIDTH = 10;
    localparam IN_WIDTH = 8;
    localparam CNT_WIDTH = 4;
    reg [OUT_WIDTH-1:0] data_out_reg = {OUT_WIDTH{1'b0}}, data_out_next;
    reg [IN_WIDTH-1:0] data_in_reg = {IN_WIDTH{1'b0}}, data_in_next;
    reg [CNT_WIDTH-1:0] cnt_reg = {CNT_WIDTH{1'b0}}, cnt_next;
    reg valid_b_reg = 1'b0, valid_b_next;
    assign ready_a = valid_b_reg ? ready_b : 1'b1;
    assign valid_b = valid_b_reg;
    assign data_out = data_out_reg;
    always @(*) begin
        data_out_next = data_out_reg;
        valid_b_next = valid_b_reg;
        cnt_next = cnt_reg;
        if (valid_b & ready_b) begin
            valid_b_next = 1'b0;
        end
        if (valid_a & ready_a) begin
            data_out_next = data_out_reg+{2'b00, data_in};
            cnt_next = cnt_reg + 1;
            if (cnt_reg == 4'h3) begin
                cnt_next = {CNT_WIDTH{1'b0}};
                valid_b_next = 1'b1;
            end else if (~|cnt_reg) begin
                data_out_next = {2'b00, data_in};
            end
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            data_out_reg <= {OUT_WIDTH{1'b0}};
            data_in_reg <= {IN_WIDTH{1'b0}};
            cnt_reg <= {CNT_WIDTH{1'b0}};
            valid_b_reg <= valid_b_next;
        end else begin
            data_out_reg <= data_out_next;
            data_in_reg <= data_in_next;
            cnt_reg <= cnt_next;
            valid_b_reg <= valid_b_next;
        end
    end
endmodule