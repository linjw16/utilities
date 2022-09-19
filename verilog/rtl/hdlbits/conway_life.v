module dut #(
	parameter ROW = 16,
	parameter COL = 16
) (
	input clk,
	input rst,
	input load,
	input [255:0] data,
	output [255:0] q
); 
	assign q = q_reg;
	reg [255:0] q_reg = 255'h7, q_next = 255'h7;
	generate
		genvar i,j;
		for (i=0;i<16;i=i+1) begin: gen_row
			for (j=0;j<16;j=j+1) begin: gen_clm
				wire [9:1] t;
				assign t[1] = q_reg[((i+15)%16)*16+((j+15)%16)];
				assign t[2] = q_reg[((i+15)%16)*16+((j+0)%16)];
				assign t[3] = q_reg[((i+15)%16)*16+((j+1)%16)];
				assign t[4] = q_reg[i*16+((j+15)%16)];
				assign t[5] = q_reg[i*16+j];
				assign t[6] = q_reg[i*16+((j+1)%16)];
				assign t[7] = q_reg[((i+1)%16)*16+((j+15)%16)];
				assign t[8] = q_reg[((i+1)%16)*16+((j+0)%16)];
				assign t[9] = q_reg[((i+1)%16)*16+((j+1)%16)];
				wire [3:0] sum = t[1]+t[2]+t[3]+t[4]+t[6]+t[7]+t[8]+t[9];
				always @(*) begin
					case (sum) 
						0: begin
							q_next[i*16+j] = 1'b0;
						end 
						1: begin
							q_next[i*16+j] = 1'b0;
						end 
						2: begin
							q_next[i*16+j] = q_reg[i*16+j];
						end 
						3: begin
							q_next[i*16+j] = 1'b1;
						end
						default:
							q_next[i*16+j] = 1'b0;
					endcase
				end
			end
		end
	endgenerate
	always @(posedge clk) begin
		if (load) begin
			q_reg <= data;
		end else begin
			q_reg <= q_next;
		end
	end
endmodule
