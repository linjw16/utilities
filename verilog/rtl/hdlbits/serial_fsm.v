module top_module #(
	parameter DUMMY = 0
) (
    input clk,
    input in_1,
    input reset,    // Synchronous reset
    output [7:0] out_byte,
    output done
);
	wire in = in_1;
    localparam 	ST_IDLE = 4'h0,
    			ST_BEG = 4'h1,
    			ST_END = 4'h2,
    			ST_PRT = 4'h3,
    			ST_NONE = 4'h4;
    reg [7:0] out_reg = 8'h00, out_next;
    reg done_reg = 1'b0, done_next;
    reg [2:0] count_reg = 3'b000, count_next;    
    reg [3:0] state_reg = ST_IDLE, state_next;
	reg parit_reg = 1'b0, parit_next;
    always @(*) begin
        out_next = out_reg;
        done_next = 1'b0;
        count_next = count_reg;
        state_next = state_reg;
		parit_next = parit_reg;
        case (state_reg)
            ST_IDLE: begin
				parit_next = 1'b0;
                count_next = 3'b000;
                if (in == 1'b0) begin
                    state_next = ST_BEG;
                end else begin
                    state_next = ST_IDLE;
                end
            end
            ST_BEG: begin
				parit_next = parit_reg + in;
                out_next[count_reg] = in;
                if (count_reg == 4'h7) begin
                    state_next = ST_PRT;
                end else begin
                	count_next = count_reg + 4'h1;
                end
            end
			ST_PRT: begin
				if (parit_reg ^ in) begin
				end else begin
					count_next = 4'h0;
				end
				state_next = ST_END;
			end
            ST_END: begin
                count_next = 4'h0;
                if (in) begin
                    if (count_reg == 4'h7) begin
                    	done_next = 1'b1;
	                	state_next = ST_IDLE;
                    end else begin 
    	                done_next = 1'b0;
        	        	state_next = ST_IDLE;
                    end
                end
            end
            // default:
        endcase
    end
    always @(posedge clk) begin
        if (reset) begin
        	out_reg <= 0;
        	done_reg <= 0;
        	count_reg <= 0;
        	state_reg <= 0;
			parit_reg <= 0;
        end else begin
        	out_reg <= out_next;
        	done_reg <= done_next;
        	count_reg <= count_next;
        	state_reg <= state_next;
			parit_reg <= parit_next;
        end
    end
    assign done = done_reg;
	assign out_byte = out_reg;
endmodule
