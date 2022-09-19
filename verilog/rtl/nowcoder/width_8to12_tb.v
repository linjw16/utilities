
`timescale 1ns/1ps
module testbench ();
    reg clk;
    reg rst_n;
    reg valid_in;
    reg [7:0] data_in;
    wire valid_out;
    wire [11:0] data_out;
    initial begin
        $dumpfile("out.vcd");
        $dumpvars(0, testbench);
        clk = 0;
        rst_n = 0;
        data_in = 0;
        valid_in = 0;#8;
        rst_n = 1;#9;
        data_in = 8'hA0;
        valid_in = 1'b1;#4;
        data_in = 8'hA1;
        valid_in = 1'b1;#4;
        valid_in = 1'b0;#8;
        data_in = 8'hB0;
        valid_in = 1'b1;#4;
        forever begin
            #16;
            if ($time > 1024) begin
                $finish;
            end
        end
    end
    always #2 clk = ~clk;
    width_8to12 dut(
        .clk        (clk),
        .rst_n      (rst_n),
        .valid_in   (valid_in),
        .data_in    (data_in),
    
        .valid_out  (valid_out),
        .data_out   (data_out)
    );
endmodule