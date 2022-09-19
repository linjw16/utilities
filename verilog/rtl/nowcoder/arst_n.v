/*
 * VL74 异步复位同步释放
 */
`timescale 1ns/1ns

module arst_n(
    input  wire clk,
    input  wire arst_n,
    input  wire d,
    output reg dout
);
reg arst_n_reg;
always @ (posedge clk or negedge arst_n) begin
    if (!arst_n) begin
        arst_n_reg <= 0;    /* Asynchronous reset. */
    end else begin
        arst_n_reg <= 1;
    end
end
always @ (posedge clk or negedge arst_n_reg)begin
    if(!arst_n_reg) begin
        dout <= 1'b0;
    end else begin 
        dout <= d; 
    end
end
endmodule 