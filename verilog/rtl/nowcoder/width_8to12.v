`timescale 1ns/1ns

module width_8to12(
    input           clk,
    input           rst_n,
    input           valid_in,
    input  [7:0]    data_in,
 
    output wire          valid_out,
    output wire [11:0]   data_out
);
    localparam  ST_0 = 4'h0,
                ST_4 = 4'h1,
                ST_8 = 4'h2;
    localparam IN_WIDTH = 8;
    localparam OUT_WIDTH = 12;
    localparam ST_WIDTH = 4;
    reg [IN_WIDTH-1:0] data_in_reg = {IN_WIDTH{1'b0}}, data_in_next;
    reg [OUT_WIDTH-1:0] data_out_reg = {OUT_WIDTH{1'b0}}, data_out_next;
    reg [ST_WIDTH-1:0] state_reg = ST_0, state_next;
    reg valid_out_reg = 1'b0, valid_out_next;
    assign valid_out = valid_out_reg;
    assign data_out = data_out_reg;
    always @(*) begin
        valid_out_next = 1'b0;
        data_in_next = data_in_reg;
        data_out_next = data_out_reg;
        state_next = state_reg;
        case (state_reg)
            ST_0: begin
                if (valid_in) begin
                    data_out_next[OUT_WIDTH-1-:8] = data_in;
                    data_in_next = data_in;
                    valid_out_next = 1'b0;
                    state_next = ST_8;
                end
            end
            ST_4: begin
                if (valid_in) begin
                    data_out_next = {data_in_reg[3:0], data_in};
                    data_in_next = data_in;
                    valid_out_next = 1'b1;
                    state_next = ST_0;
                end
            end
            ST_8: begin
                if (valid_in) begin
                    data_out_next = {data_in_reg, data_in[7:4]};
                    data_in_next = data_in;
                    valid_out_next = 1'b1;
                    state_next = ST_4;
                end
            end
            default: begin
                
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            valid_out_reg <= 1'b0;
            data_in_reg <= {IN_WIDTH{1'b0}};
            data_out_reg <= {OUT_WIDTH{1'b0}};
            state_reg <= {ST_WIDTH{1'b0}};
        end else begin
            valid_out_reg <= valid_out_next;
            data_in_reg <= data_in_next;
            data_out_reg <= data_out_next;
            state_reg <= state_next;
        end
    end

endmodule