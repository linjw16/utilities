module iverilog_dump();
initial begin
	$dumpfile("top_module.fst");
	$dumpvars(0, top_module);
end
endmodule
