module iverilog_dump();
initial begin
	$dumpfile("dut.fst");
	$dumpvars(0, dut);
end
endmodule
