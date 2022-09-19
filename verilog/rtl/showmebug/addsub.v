
module addsub(
    input [31:0] a,
    input [31:0] b,
    input sub,
    output [31:0] sum
);
    
  // 在这里书写代码
  wire [15:0] sum_low, sum_high;
  wire [31:0] b_int;
  wire cout_1, cout_2;
  
  assign b_int = sub ? ~b : b;
  assign sum = {sum_high, sum_low};
  add16 add16_1 (a[15:0], b_int[15:0], sub, sum_low, cout_1);
  add16 add16_2 (a[31:16], b_int[31:16], cout_1, sum_high, cout_2);
  
endmodule


module add16 (
  input [15:0] a,
  input [15:0] b,
  input cin,
  output [15:0] sum,
  output cout
);
  assign {cout, sum} = {1'b0, a} + {1'b0, b} + {1'b0, cin};
  
endmodule