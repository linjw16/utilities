module top_module (
    input clk,
    input shift_ena,
    input count_ena,
    input data,
    output [3:0] q);
    reg [3:0] q_reg = 4'h0, q_next;
    always @(*) begin
        if (shift_ena) begin
            q_next = {q_reg[2:0], data};
        end else if (count_ena) begin
            q_next = q_reg - 4'h1;
        end else begin
            q_next = q_reg;
        end
    end
    always @(posedge clk) begin
        q_reg <= q_next;
    end
	assign q = q_reg;
endmodule
