`timescale 1ns/10ps

module odo_div_or
   (
    input    wire  rst ,
    input    wire  clk_in,
    output   wire  clk_out7
    );
    reg [3:0] cnt_p_reg = 4'h0, cnt_p_next;
    reg [3:0] cnt_n_reg = 4'h0, cnt_n_next;
    reg out_reg = 1'b0, out_next;
    reg p_reg = 1'b0, p_next;
    reg n_reg = 1'b0, n_next;
    assign clk_out7 = p_reg ^ n_reg;
    // assign clk_out7 = p_reg&~n_reg | ~p_reg&n_reg;
    always @(*) begin
        cnt_p_next = cnt_p_reg+1;
        cnt_n_next = cnt_n_reg+1;
        p_next = p_reg;
        n_next = n_reg;
        if (cnt_p_reg == 4'h6) begin
            cnt_p_next = 4'h0;
            p_next = ~p_reg;
        end
        if (cnt_n_reg == 4'h6) begin
            cnt_n_next = 4'h0;
            n_next = ~n_reg;
        end
    end
    always @(posedge clk_in) begin
        if (~rst) begin
            cnt_p_reg <= 4'h0;
            p_reg <= 1'b0;
        end else begin
            cnt_p_reg <= cnt_p_next;
            p_reg <= p_next;
        end
    end
    always @(negedge clk_in) begin
        if (~rst) begin
            cnt_n_reg <= 4'h4;
            n_reg <= 1'b0;
        end else begin
            cnt_n_reg <= cnt_n_next;
            n_reg <= n_next;
        end
    end
endmodule