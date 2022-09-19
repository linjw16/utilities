module top_module(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging ); 

    localparam 	ST_L = 4'h1, 
    			ST_R = 4'h2, 
    			ST_F = 4'h4, 
    			ST_D = 4'h8, 
    			ST_O = 4'h0;
    reg [3:0] state_reg = ST_L, state_next;
    reg [3:0] last_reg = ST_L, last_next;
    reg [4:0] time_reg = 5'h00, time_next;
    
    assign walk_left = state_reg == ST_L;
    assign walk_right = state_reg == ST_R;
    assign aaah = state_reg == ST_F;
    assign digging = state_reg == ST_D;
    
    always @(*) begin
        state_next = state_reg;
        last_next = last_reg;
        time_next = time_reg;
        case (state_reg) 
            ST_L: begin
                last_next = state_reg;
                if (~ground) begin
                    state_next = ST_F;
                end else if (dig) begin
                    state_next = ST_D;
                end else if (bump_left) begin
                    state_next = ST_R;
                end
            end
			ST_R: begin
                last_next = state_reg;
                if (~ground) begin
                    state_next = ST_F;
                end else if (dig) begin
                    state_next = ST_D;
                end else if (bump_right) begin
                    state_next = ST_L;
                end
            end
			ST_F: begin
                time_next = &time_reg ? time_reg : time_reg+5'h1;
                if (ground) begin
                    if (time_reg > 5'h13) begin
                    	state_next = ST_O;
                    end else begin
                        state_next = last_reg;
                        time_next = 5'h0;
                    end
                end     
            end
			ST_D: begin
                if (~ground) begin
                    state_next = ST_F;
                end
            end
            default: begin
            end
        endcase
    end
    
    always @(posedge clk or posedge areset) begin
        if (areset) begin
            state_reg <= ST_L;
            time_reg <= 5'h00;
        end else begin 
            state_reg <= state_next;
            last_reg <= last_next;
            time_reg <= time_next;
        end
    end
endmodule
