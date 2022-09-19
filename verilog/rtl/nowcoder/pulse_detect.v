`timescale 1ns/1ns

module pulse_detect(
	input 				clk_fast, 
	input 				clk_slow,   
	input 				rst_n,
	input				data_in,

	output  		 	dataout
);
    reg pulse_f_reg = 1'b0, pulse_f_next;
    reg pulse_s_reg = 1'b0, pulse_s_next;
    assign dataout = pulse_s_reg;
    always @(*) begin
        pulse_f_next = pulse_f_reg;
        pulse_s_next = pulse_s_reg;
        if (data_in) begin
            pulse_f_next = 1'b1;
        end
        if (pulse_f_reg) begin
            pulse_s_next = 1'b1;
        end
        if (pulse_s_reg) begin
            pulse_f_next = 1'b0;
            pulse_s_next = 1'b0;
        end
    end
    always @(posedge clk_fast or negedge rst_n) begin
        if (~rst_n) begin
            pulse_f_reg <= 1'b0;
        end else begin
            pulse_f_reg <= pulse_f_next;
        end
    end
       
    always @(posedge clk_slow or negedge rst_n) begin
        if (~rst_n) begin
            pulse_s_reg <= 1'b0;
        end else begin
            pulse_s_reg <= pulse_s_next;
        end
    end
endmodule