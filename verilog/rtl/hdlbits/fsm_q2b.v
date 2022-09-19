/*
 * Created on Wed Jul 27 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 fsm_q2b.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 21:48:31
 */


/*
 * It is odd, I had written what it demands, but didn't pass OJ. 
 */
module top_module (
    input clk,
    input resetn,    // active-low synchronous reset
    input x,
    input y,
    output f,
    output g
); 
    localparam ST_A = 4'h0,
    			ST_B = 4'h1,
    			ST_C = 4'h2;
    reg [3:0] state_reg = ST_A, state_next;
    reg [3:0] count_reg = 4'h0, count_next;
    reg f_reg = 1'b0, f_next;
    reg g_reg = 1'b0, g_next;
    
    always @(*) begin
        state_next = state_reg;
        f_next = 1'b0;
        g_next = g_reg;
        case (state_reg) 
            ST_A: begin
                f_next = 1'b1;
                state_next = ST_B;
            end
            ST_B: begin
                if (x) begin
                    if (count_reg == 4'h0) begin
                        count_next = count_reg + 4'h1;
                    end else if (count_reg == 4'h2) begin
                        state_next = ST_C;
                        count_next = 4'h0;
                    end else begin
                        count_next = 4'h1;
                    end
                end else begin
                    if (count_reg == 4'h1) begin
                        count_next = count_reg + 4'h1;
                    end else begin
                        count_next = 4'h0;
                    end
                end
            end
            ST_C: begin
                if (count_reg < 4'h2) begin
                    if (y) begin
                        g_next = 1'b1;
                        count_next = 4'hF;
                    end else begin
                        g_next = 1'b0;
                    	count_next = count_reg + 4'h1;
                    end
                end else begin
                    count_next = 4'hF;
                end
            end
        endcase
    end
    
    always @(posedge clk) begin
        if (~resetn) begin 
            state_reg <= ST_A;
            count_reg <= 4'h0;
			f_reg <= 1'b0;
			g_reg <= 1'b0;
        end else begin
            state_reg <= state_next;
            count_reg <= count_next;
            f_reg <= f_next;
			g_reg <= g_next;
        end
    end
	assign f = f_reg;
    assign g = g_reg;
endmodule
