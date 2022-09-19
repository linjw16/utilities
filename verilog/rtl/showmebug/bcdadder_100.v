/*
 * Created on Thu Sep 08 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 bcdadder_100.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 16:15:24
 */

module bcdadder_100( 
    input [399:0] a, b,
    input cin,
    output cout,
    output [399:0] sum );
    
  // 在这里书写代码
  localparam BCD_WIDTH = 4;
  
  wire [100:0] cin_int;
  
  assign cin_int[0] = cin;
  assign cout = cin_int[100];
  
  generate 
    genvar i;
    for (i=0; i<100; i=i+1) begin: gen_1
      bcd_fadd add_inst (
        .a      (a[i*BCD_WIDTH+:BCD_WIDTH]),
        .b      (b[i*BCD_WIDTH+:BCD_WIDTH]),
        .cin    (cin_int[i]),
        .cout   (cin_int[i+1]),
        .sum    (sum[i*BCD_WIDTH+:BCD_WIDTH])
      )
    end
  endgenerate

endmodule
