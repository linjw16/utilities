/*
 * Created on Wed Jul 27 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 fsm_hdlc.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 16:21:15
 */

/*
 * High-Level Data Link Control, HDLC. 
 */

module top_module#(
	parameter DUMMY = 0
) (
    input clk,
    input reset,    // Synchronous reset
    input in_1,
    output disc,
    output flag,
    output err);
    assign in = in_1;
    localparam ST_IDLE = 4'h0,
    			ST_BEG = 4'h1,
    			ST_END = 4'h2,
    			ST_ERR = 4'h3;
    localparam CNT_WIDTH = 4;
    reg [3:0] state_reg = ST_IDLE, state_next;
    reg [3:0] count_reg = 4'h0, count_next;
    reg flag_reg = 1'b0, flag_next;
    reg error_reg = 1'b0, error_next;
    reg discd_reg = 1'b0, discd_next;
    always @(*) begin
        state_next = state_reg;
        count_next = count_reg;
        flag_next = 1'b0;
        error_next = 1'b0;
        discd_next = 1'b0;
        case(state_reg)
            ST_IDLE: begin
                if (in) begin	/* Counter-Input: 0-0, 1-1, 2-1, 3-1, 4-1, 5-1, 6-1, 7-0 */
                    if (count_reg == 4'h6) begin
                        error_next = 1'b1;
                    end else begin	/* Input 1 on initial state */
                        count_next = count_reg + 4'h1;
                    end
                end else begin /* Counter begin with 1 */
                    count_next = 4'h0;
                    if (count_reg == 4'h5) begin
                        discd_next = 1'b1;
                    end else if (count_reg == 4'h6) begin
                        if (error_reg) begin
                            error_next = 1'b0;	/* Dummy */
                        end else begin
                            state_next = ST_BEG;
                            flag_next = 1'b1;
                        end
                    end                  
                end
            end
            ST_BEG: begin
                if (in) begin	/* Counter-Input: 0-0, 1-1, 2-1, 3-1, 4-1, 5-1, 6-0/1, 7-X/0 */
                    if (count_reg == 4'h6) begin
                        error_next = 1'b1;
                        // state_next = ST_IDLE;
                    end else begin
                    	count_next = count_reg + 4'h1;
                    end
                end else begin
                    count_next = 4'h0;
                    if (count_reg == 4'h5) begin
                        discd_next = 1'b1;
                    end else if (count_reg == 4'h6) begin
                        if (error_reg) begin
                            error_next = 1'b0;	/* Dummy */
                        end else begin
                            state_next = ST_IDLE;
                            flag_next = 1'b1;
                        end
                    end
                end
            end
        endcase
    end
    
    always @(posedge clk) begin
        if (reset) begin
            state_reg <= ST_IDLE;
            count_reg <= 4'h0;
            error_reg <= 1'b0;
            discd_reg <= 1'b0;
            flag_reg <= 1'b0;
        end else begin
        	state_reg <= state_next;
            count_reg <= count_next;
            error_reg <= error_next;
            discd_reg <= discd_next;
            flag_reg <= flag_next;
        end
    end
	assign disc = discd_reg;
	assign flag = flag_reg;
	assign err = error_reg;
endmodule

