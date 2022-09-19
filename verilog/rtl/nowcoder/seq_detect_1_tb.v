`timescale 1ns/1ns
module testbench();

	reg clk,rst_n;
	reg data;
	wire match;
	wire not_match;
	
initial begin
	$dumpfile("out.vcd");
	$dumpvars(0,testbench);
	clk = 0;
    data = 0;#10;
	rst_n = 0;#10;
    rst_n = 1;#10;
    data = 1;#10;
    data = 1;#10;
    data = 1;#10;
    data = 0;#10;
    data = 0;#10;
    
    data = 0;#10;
    data = 1;#10;
    data = 1;#10;
    data = 1;#10;
    data = 0;#10;
    data = 0;#10;
    
    data = 1;#10;
    data = 1;#10;
    data = 1;#10;
    data = 1;#10;
    data = 0;#10;
    data = 0;#10;
    #50;
    forever begin
        #100;
        $display("TS: %d", $time);
        if ($time >= 1000) begin
            $finish ;
        end
    end
end

always #5 clk = !clk;


seq_detect_1 dut(
	.clk(clk),
	.rst_n(rst_n),

	.data(data),
	.not_match(not_match),
	.match(match)
);
endmodule