`timescale 1ns/1ps
module testbench();

	reg clk,rst_n;
	reg [1:0]wave_choise;
	wire [4:0]wave;
	
    initial begin
        $dumpfile("out.vcd");
        $dumpvars(0,testbench);
        wave_choise = 2'b00;
        clk = 0;
        rst_n = 0;#10;
        rst_n = 1;#256;
        wave_choise = 2'b01;#400;
        wave_choise = 2'b10;#400;
        wave_choise = 2'b00;#400;
        wave_choise = 2'b10;#400;
        wave_choise = 2'b01;#400;
        wave_choise = 2'b00;#400;
        forever begin
            #100;
            $display("TS: %d", $time);
            if ($time > 1024) begin
                $finish;
            end
        end
    end

    always #2 clk = !clk;

    sig_gen_1 dut(
        .clk(clk),
        .rst_n(rst_n),
        .wave_choise(wave_choise),
        .wave(wave)
    );
endmodule