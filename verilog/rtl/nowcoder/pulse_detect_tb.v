`timescale 1ns/1ps
module testbench ();
    reg  clk_fast = 0;
    reg  clk_slow = 0;
    reg  rst_n = 0;
    reg  data_in = 0;
    wire dataout;
    initial begin
        $dumpfile("out.vcd");
        $dumpvars(0, testbench);
        #8;
        rst_n = 1; #8;
        data_in = 1; #4;
        data_in = 0; #96;
        data_in = 1; #4;
        data_in = 0; #128;
        $finish;
    end

    always begin
        #2; clk_fast = ~clk_fast;
    end
    always begin
        #16; clk_slow = ~clk_slow;
    end

    pulse_detect dut (
        .clk_fast   (clk_fast),
        .clk_slow   (clk_slow),
        .rst_n      (rst_n),
        .data_in    (data_in),
        .dataout    (dataout)
    );
endmodule