
/*
 * Cs450/history shift
 */

module top_module(
    input clk,
    input areset,

    input predict_valid,
    input predict_taken,
    output [31:0] predict_history,

    input train_mispredicted,
    input train_taken,
    input [31:0] train_history
);
    reg [31:0] history_reg = 32'h0, history_next;
    always @(*) begin
        history_next = history_reg;
        if (train_mispredicted) begin
            history_next = {train_history[30:0], train_taken};
        end else if (predict_valid) begin
            history_next = {history_reg[30:0], predict_taken};
        end
    end
    always @(posedge clk or posedge areset) begin
        if (areset) begin
            history_reg <= 32'h0;
        end else begin
            history_reg <= history_next;
        end
    end
    assign predict_history = history_reg;
endmodule
