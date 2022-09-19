/*
 * Created on Wed Jul 27 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 fsm_2bbp.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 22:17:23
 */


/*
 * Branch direction predictors. 
 * R. Nair, "Optimal 2-bit branch predictors", IEEE Trans. Computers, vol. 44 no. 5, May, 1995
 */
module top_module(
    input clk,
    input areset,
    input train_valid,
    input train_taken,
    output [1:0] state
);
    reg [1:0] state_reg = 2'b01, state_next;
    always @(*) begin 
        state_next = state_reg;
        if (train_valid) begin
            if (train_taken) begin
                state_next = (&state_reg) ? 2'b11 : state_reg+2'b01;
            end else begin
                state_next = (|state_reg) ? state_reg-2'b01 : 2'b00;
            end
        end
    end
    always @(posedge clk or posedge areset) begin 
        if (areset) begin
            state_reg <= 2'b01;
        end else begin
            state_reg <= state_next;
        end
    end
	assign state = state_reg;
endmodule
