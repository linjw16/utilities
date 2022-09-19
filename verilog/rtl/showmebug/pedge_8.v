module pedge_8 (
    input clk,
    input [7:0] in,
    output [7:0] pedge
);
    //在这里写代码
  reg [7:0] in_reg = 8'h00, in_next;
  reg [7:0] pedge_reg = 8'h00, pedge_next;
  assign pedge = pedge_reg;
  
  always @(*) begin
    in_next = in;
    pedge_next = ~in_reg & in;
  end 
  
  always @(posedge clk) begin
    in_reg <= in_next;
    pedge_reg <= pedge_next;
  end
  
endmodule
