/*
You're familiar with flip-flops that are triggered on the positive edge of the clock, or negative edge of the clock. A dual-edge triggered flip-flop is triggered on both edges of the clock. However, FPGAs don't have dual-edge triggered flip-flops, and always @(posedge clk or negedge clk) is not accepted as a legal sensitivity list.

Build a circuit that functionally behaves like a dual-edge triggered flip-flop: 
(Note: It's not necessarily perfectly equivalent: The output of flip-flops have no glitches, but a larger combinational circuit that emulates this behaviour might. But we'll ignore this detail here.)
*/



module dualedge (
    input clk,
    input d,
    output q
);
	reg q_reg = 1'b0, q_n_reg = 1'b0;
    
    always @(posedge clk) begin
        q_reg = d;
    end
    
    always @(negedge clk) begin
        q_n_reg = d;
    end
    
    assign q = clk ? q_reg : q_n_reg;
endmodule

/*
 * module top_module(
 * 	input clk,
 * 	input d,
 * 	output q);
 * 	
 * 	reg p, n;
 * 	
 * 	// A positive-edge triggered flip-flop
 *     always @(posedge clk)
 *         p <= d ^ n;
 *         
 *     // A negative-edge triggered flip-flop
 *     always @(negedge clk)
 *         n <= d ^ p;
 *     
 *     // Why does this work? 
 *     // After posedge clk, p changes to d^n. Thus q = (p^n) = (d^n^n) = d.
 *     // After negedge clk, n changes to d^p. Thus q = (p^n) = (p^d^p) = d.
 *     // At each (positive or negative) clock edge, p and n FFs alternately
 *     // load a value that will cancel out the other and cause the new value of d to remain.
 *     assign q = p ^ n;
 *     
 *     
 * 	// Can't synthesize this.
 * 	/*always @(posedge clk, negedge clk) begin
 * 		q <= d;
 * 	end*/
 *     
 *     
 * endmodule
*/