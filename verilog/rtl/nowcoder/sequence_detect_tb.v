`timescale 1ns/1ns
module testbench();

    reg clk, rst_n;
    reg a;
    wire match;
initial begin
    $dumpfile("out.vcd");
    $dumpvars(0,testbench);
    clk = 0;
    a = 0;
    rst_n = 1; #5;
    rst_n = 0; #4;
    rst_n = 1; #4;
    a = 0; #4;
    a = 1; #4;
    a = 1; #4;
    a = 1; #4;
    a = 0; #4;
    a = 0; #4;
    a = 0; #4;
    a = 1; #4;
    a = 0; #4;
    a = 0; #4;
    a = 1; #4;
    forever begin
        #100;
        $display("End: %d", $time);
        if ($time >= 1000) begin
            $finish ;
        end
    end
end
always begin
    clk = ~clk; #2;
end

sequence_detect dut(
    .clk(clk),
    .rst_n(rst_n),

    .a(a),
    .match(match)
);
endmodule