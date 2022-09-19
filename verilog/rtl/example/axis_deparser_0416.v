/*
 * Created on Sat Apr 16 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 axis_deparser.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 23:15:05
 */

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * Deparser merge modified header and payload. 
 */
module axis_deparser # (
	parameter S_DATA_WIDTH = 512,
	parameter S_KEEP_WIDTH = S_DATA_WIDTH/8,
	parameter S_ID_WIDTH = 8,
	parameter S_DEST_WIDTH = 4,
	parameter S_USER_WIDTH = 4,
	parameter M_DATA_WIDTH = S_DATA_WIDTH,
	parameter M_KEEP_WIDTH = M_DATA_WIDTH/8,
	parameter M_ID_WIDTH = S_ID_WIDTH,
	parameter M_DEST_WIDTH = S_DEST_WIDTH,
	parameter M_USER_WIDTH = S_USER_WIDTH,

	parameter HDR_DATA_WIDTH = 560,
	parameter HDR_KEEP_WIDTH = HDR_DATA_WIDTH/8,
	parameter HDR_ID_WIDTH = S_ID_WIDTH,
	parameter HDR_DEST_WIDTH = S_DEST_WIDTH,
	parameter HDR_USER_WIDTH = S_USER_WIDTH
) (
	input  wire 						clk,
	input  wire 						rst,

	input  wire [HDR_DATA_WIDTH-1:0] 	s_axis_hdr_tdata,
	input  wire [HDR_KEEP_WIDTH-1:0] 	s_axis_hdr_tkeep,
	input  wire 						s_axis_hdr_tvalid,
	output wire 						s_axis_hdr_tready,
	input  wire 						s_axis_hdr_tlast,
	input  wire [HDR_ID_WIDTH-1:0] 		s_axis_hdr_tid,
	input  wire [HDR_DEST_WIDTH-1:0] 	s_axis_hdr_tdest,
	input  wire [HDR_USER_WIDTH-1:0]	s_axis_hdr_tuser,

	input  wire [S_DATA_WIDTH-1:0] 		s_axis_tdata,
	input  wire [S_KEEP_WIDTH-1:0] 		s_axis_tkeep,
	input  wire 						s_axis_tvalid,
	output wire 						s_axis_tready,
	input  wire 						s_axis_tlast,
	input  wire [S_ID_WIDTH-1:0] 		s_axis_tid,
	input  wire [S_DEST_WIDTH-1:0] 		s_axis_tdest,	
	input  wire [S_USER_WIDTH-1:0]		s_axis_tuser,

	output wire [M_DATA_WIDTH-1:0] 		m_axis_tdata,
	output wire [M_KEEP_WIDTH-1:0] 		m_axis_tkeep,
	output wire 						m_axis_tvalid,
	input  wire 						m_axis_tready,
	output wire 						m_axis_tlast,
	output wire [M_ID_WIDTH-1:0] 		m_axis_tid,
	output wire [M_DEST_WIDTH-1:0] 		m_axis_tdest,
	output wire [M_USER_WIDTH-1:0]		m_axis_tuser
);

initial begin
	if (S_DATA_WIDTH != M_DATA_WIDTH) begin
		$error("S_DATA_WIDTH != M_DATA_WIDTH, Not support yet. (inst %m)");
		$finish;
	end
	if (S_DATA_WIDTH > HDR_DATA_WIDTH) begin
		$error("S_DATA_WIDTH > HDR_DATA_WIDTH, Not support yet. (inst %m)");
		$finish;
	end
end

localparam KEEP_WIDTH = (HDR_KEEP_WIDTH>S_KEEP_WIDTH) ? HDR_KEEP_WIDTH : S_KEEP_WIDTH;
localparam CL_KEEP_WIDTH = $clog2(KEEP_WIDTH+1); 

function [CL_KEEP_WIDTH-1:0] keep2empty(input [KEEP_WIDTH-1:0] keep);
	/* cal how many 1 in keep */
	integer i;
	begin
		keep2empty = {CL_KEEP_WIDTH{1'b0}};
		for (i = 0; i < KEEP_WIDTH; i = i+1) begin
			keep2empty = keep[i] ? keep2empty : keep2empty + 1;
		end		
	end
endfunction

function [CL_KEEP_WIDTH-1:0] keep2size(input [KEEP_WIDTH-1:0] keep);
	/* cal how many 1 in keep */
	integer i;
	begin
		keep2size = {CL_KEEP_WIDTH{1'b0}};
		for (i = 0; i < KEEP_WIDTH; i = i+1) begin
			keep2size = keep[i] ? keep2size+1 : keep2size;
		end		
	end
endfunction


/*
 * 1. Input ctl and gen
 */
localparam CL_HDR_KEEP_WIDTH = $clog2(HDR_KEEP_WIDTH);
localparam CL_M_KEEP_WIDTH = $clog2(M_KEEP_WIDTH);

wire [CL_DATA_WIDTH-1:0] s_axis_hdr_tsize, s_axis_tsize;
wire [CL_HDR_KEEP_WIDTH-1:0] hdr_tkeep_enc;
wire [CL_M_KEEP_WIDTH-1:0] tkeep_enc;
wire [HDR_DATA_WIDTH-1:0] s_axis_tdata_pad;

assign s_axis_hdr_tsize = {1'b0, hdr_tkeep_enc}+1;
assign s_axis_tsize = {1'b0, tkeep_enc}+1;
assign s_axis_tdata_pad = {
	{HDR_DATA_WIDTH-S_DATA_WIDTH{1'b0}}, 
	s_axis_tdata
};
assign s_axis_tready = (s_axis_hdr_tvalid && s_axis_hdr_tready) || (state_reg == ST_MERGE && m_axis_tready_int_reg);
assign s_axis_hdr_tready = (state_reg == ST_IDLE) && m_axis_tready_int_reg;

priority_encoder # (
	.WIDTH(HDR_KEEP_WIDTH),
	.LSB_HIGH_PRIORITY(0)
) keep2size_1 (
	.input_unencoded	(s_axis_hdr_tkeep),
	.output_valid		(),
	.output_encoded		(hdr_tkeep_enc),
	.output_unencoded	()
);

priority_encoder # (
	.WIDTH(S_KEEP_WIDTH),
	.LSB_HIGH_PRIORITY(0)
) keep2size_2 (
	.input_unencoded	(s_axis_tkeep),
	.output_valid		(),
	.output_encoded		(tkeep_enc),
	.output_unencoded	()
);

/*
 * 2. An FSM for transport
 */
localparam CL_DATA_WIDTH = $clog2(HDR_DATA_WIDTH+1);
localparam ST_WIDTH = 4,
	ST_IDLE		= 0,
	ST_MERGE	= 1,
	ST_LAST		= 2;

reg  [HDR_DATA_WIDTH-1:0]	temp_tdata_reg = {HDR_DATA_WIDTH{1'b0}}, temp_tdata_next;
reg  [M_USER_WIDTH-1:0] 	temp_tuser_reg = {M_USER_WIDTH{1'b0}}, temp_tuser_next;
reg  						temp_tlast_reg = 1'b0, temp_tlast_next;
reg  [M_ID_WIDTH-1:0] 		temp_tid_reg = {M_ID_WIDTH{1'b0}}, temp_tid_next;
reg  [M_DEST_WIDTH-1:0] 	temp_tdest_reg = {M_DEST_WIDTH{1'b0}}, temp_tdest_next;
reg  [CL_DATA_WIDTH-1:0] 	temp_size_reg = {CL_DATA_WIDTH{1'b0}}, 	temp_size_next;

reg  [ST_WIDTH-1:0] state_reg = ST_IDLE, state_next;

always @(*) begin
	state_next = state_reg;

	m_axis_tdata_int	= s_axis_tdata;
	m_axis_tkeep_int	= s_axis_tkeep;
	m_axis_tvalid_int	= 1'b0;
	m_axis_tlast_int	= s_axis_tlast;
	m_axis_tid_int		= s_axis_tid;
	m_axis_tdest_int	= s_axis_tdest;
	m_axis_tuser_int	= s_axis_tuser;

	temp_tdata_next 	= temp_tdata_reg;
	temp_tlast_next 	= temp_tlast_reg;
	temp_tid_next 		= temp_tid_reg;
	temp_tdest_next 	= temp_tdest_reg;
	temp_tuser_next 	= temp_tuser_reg;
	temp_size_next 		= temp_size_reg;

	case (state_reg)
		ST_IDLE: begin
			if (s_axis_hdr_tvalid && s_axis_hdr_tready) begin
				temp_tdata_next = s_axis_hdr_tdata << ((HDR_KEEP_WIDTH-s_axis_hdr_tsize)<<3);
				temp_size_next = (s_axis_hdr_tsize - M_KEEP_WIDTH);
				temp_tid_next = s_axis_hdr_tid;
				temp_tdest_next = s_axis_hdr_tdest;
				temp_tuser_next = s_axis_hdr_tuser;

				m_axis_tdata_int = s_axis_hdr_tdata[M_DATA_WIDTH-1:0];
				m_axis_tkeep_int = s_axis_hdr_tkeep[M_KEEP_WIDTH-1:0];
				m_axis_tvalid_int = 1'b1;
				m_axis_tlast_int = s_axis_tlast;
				m_axis_tid_int = s_axis_hdr_tid;
				m_axis_tdest_int = s_axis_hdr_tdest;
				m_axis_tuser_int = s_axis_hdr_tuser;

				if (s_axis_hdr_tsize > M_KEEP_WIDTH) begin
					state_next = s_axis_tlast ? ST_LAST : ST_MERGE;
					m_axis_tvalid_int = 1'b1;
					m_axis_tlast_int = 1'b0;
				end else if (s_axis_hdr_tsize == M_KEEP_WIDTH) begin
					state_next = s_axis_tlast ? ST_IDLE : ST_MERGE;
				end else begin
					state_next = ST_MERGE;
					temp_tlast_next = s_axis_hdr_tlast;
					temp_size_next = s_axis_hdr_tsize;
				end
			end
		end
		ST_MERGE: begin
			if (s_axis_tvalid && s_axis_tready) begin
				temp_tdata_next = s_axis_tdata_pad << ((HDR_KEEP_WIDTH-s_axis_tsize) << 3);
				temp_size_next = (s_axis_tsize+temp_size_reg-M_KEEP_WIDTH);
				temp_tid_next = s_axis_tid;
				temp_tuser_next = s_axis_tuser;

				m_axis_tdata_int = (temp_tdata_reg >> ((HDR_KEEP_WIDTH-temp_size_reg)<<3)) | (s_axis_tdata_pad << (temp_size_reg<<3));
				m_axis_tkeep_int = {HDR_KEEP_WIDTH+M_KEEP_WIDTH{1'b1}} >> ((HDR_KEEP_WIDTH+M_KEEP_WIDTH-temp_size_reg-s_axis_tsize));
				m_axis_tvalid_int = 1'b1;
				m_axis_tlast_int = 1'b0;
				m_axis_tid_int = s_axis_tid;
				m_axis_tdest_int = temp_tdest_reg;
				m_axis_tuser_int = s_axis_tuser;

				if (s_axis_tlast) begin
					if (M_KEEP_WIDTH > s_axis_tsize+temp_size_reg) begin
						state_next = ST_IDLE;
						m_axis_tlast_int = 1'b1;
					end else begin
						state_next = ST_LAST;
					end
				end
			end
		end
		ST_LAST: begin
			if (m_axis_tready_int_reg) begin
				state_next = ST_IDLE;
				m_axis_tdata_int = temp_tdata_reg >> ((HDR_KEEP_WIDTH-temp_size_reg) << 3);
				m_axis_tkeep_int = {M_KEEP_WIDTH{1'b1}} >> (M_KEEP_WIDTH-temp_size_reg);
				m_axis_tvalid_int = 1'b1;
				m_axis_tlast_int = 1'b1;
				m_axis_tid_int = temp_tid_reg;
				m_axis_tdest_int = temp_tdest_reg;
				m_axis_tuser_int = temp_tuser_reg;
			end
		end
		default: begin
			
		end
	endcase
end

always @(posedge clk) begin
	if (rst) begin
		temp_tdata_reg			<= {HDR_DATA_WIDTH{1'b0}};
		temp_tuser_reg			<= {M_USER_WIDTH{1'b0}};
		temp_tlast_reg			<= 1'b0;
		temp_tdest_reg			<= {M_DEST_WIDTH{1'b0}};
		temp_tid_reg			<= {M_ID_WIDTH{1'b0}};
		temp_size_reg			<= {CL_DATA_WIDTH{1'b0}};
		state_reg				<= ST_IDLE;
	end else begin
		temp_tdata_reg			<= temp_tdata_next;
		temp_tuser_reg			<= temp_tuser_next;
		temp_tlast_reg			<= temp_tlast_next;
		temp_tdest_reg			<= temp_tdest_next;
		temp_tid_reg			<= temp_tid_next;
		temp_size_reg			<= temp_size_next;
		state_reg				<= state_next;
	end
end

/*
 * 5. Output datapath
 */
reg store_avst_int_to_output;
reg store_avst_int_to_temp;
reg store_avst_temp_tto_output;
reg m_axis_tvalid_reg = 1'b0, m_axis_tvalid_next, m_axis_tvalid_int;
reg temp_m_axis_tvalid_reg = 1'b0, temp_m_axis_tvalid_next;
reg m_axis_tready_int_reg = 1'b0;

reg  [M_DATA_WIDTH-1:0] m_axis_tdata_reg = {M_DATA_WIDTH{1'b0}}, 	temp_m_axis_tdata_reg = {M_DATA_WIDTH{1'b0}}, 	m_axis_tdata_int;
reg  [M_KEEP_WIDTH-1:0] m_axis_tkeep_reg = {M_KEEP_WIDTH{1'b0}}, 	temp_m_axis_tkeep_reg = {M_KEEP_WIDTH{1'b0}}, 	m_axis_tkeep_int;
reg  					m_axis_tlast_reg = 1'b0, 					temp_m_axis_tlast_reg = 1'b0, 					m_axis_tlast_int;
reg  [M_ID_WIDTH-1:0] 	m_axis_tid_reg = {M_ID_WIDTH{1'b0}}, 		temp_m_axis_tid_reg = {M_ID_WIDTH{1'b0}}, 		m_axis_tid_int;
reg  [M_DEST_WIDTH-1:0] m_axis_tdest_reg = {M_DEST_WIDTH{1'b0}}, 	temp_m_axis_tdest_reg = {M_DEST_WIDTH{1'b0}}, 	m_axis_tdest_int;
reg  [M_USER_WIDTH-1:0] m_axis_tuser_reg = {M_USER_WIDTH{1'b0}}, 	temp_m_axis_tuser_reg = {M_USER_WIDTH{1'b0}},	m_axis_tuser_int;

assign m_axis_tdata = m_axis_tdata_reg;
assign m_axis_tkeep = m_axis_tkeep_reg;
assign m_axis_tvalid = m_axis_tvalid_reg;
assign m_axis_tlast = m_axis_tlast_reg;
assign m_axis_tid = m_axis_tid_reg;
assign m_axis_tdest = m_axis_tdest_reg;
assign m_axis_tuser = m_axis_tuser_reg;

/* enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input) */
wire m_axis_tready_int_early = m_axis_tready || (!temp_m_axis_tvalid_reg && (!m_axis_tvalid_reg || !m_axis_tvalid_int));

always @* begin
	m_axis_tvalid_next = m_axis_tvalid_reg;
	temp_m_axis_tvalid_next = temp_m_axis_tvalid_reg;

	store_avst_int_to_output = 1'b0;
	store_avst_int_to_temp = 1'b0;
	store_avst_temp_tto_output = 1'b0;

	if (m_axis_tready_int_reg) begin
		if (m_axis_tready || !m_axis_tvalid_reg) begin
			m_axis_tvalid_next = m_axis_tvalid_int;
			store_avst_int_to_output = 1'b1;
		end else begin
			temp_m_axis_tvalid_next = m_axis_tvalid_int;
			store_avst_int_to_temp = 1'b1;
		end
	end else if (m_axis_tready) begin
		m_axis_tvalid_next = temp_m_axis_tvalid_reg;
		temp_m_axis_tvalid_next = 1'b0;
		store_avst_temp_tto_output = 1'b1;
	end
end

always @(posedge clk) begin
	if (rst) begin
		m_axis_tvalid_reg <= 1'b0;
		m_axis_tready_int_reg <= 1'b0;
		temp_m_axis_tvalid_reg <= 1'b0;

		m_axis_tdata_reg <= {M_DATA_WIDTH{1'b0}};
		m_axis_tkeep_reg <= {M_KEEP_WIDTH{1'b0}};
		m_axis_tlast_reg <= 1'b0;
		m_axis_tid_reg <= {M_ID_WIDTH{1'b0}};
		m_axis_tdest_reg <= {M_DEST_WIDTH{1'b0}};
		m_axis_tuser_reg <= {M_USER_WIDTH{1'b0}};
		temp_m_axis_tdata_reg <= {M_DATA_WIDTH{1'b0}};
		temp_m_axis_tkeep_reg <= {M_KEEP_WIDTH{1'b0}};
		temp_m_axis_tlast_reg <= 1'b0;
		temp_m_axis_tid_reg <= {M_ID_WIDTH{1'b0}};
		temp_m_axis_tdest_reg <= {M_DEST_WIDTH{1'b0}};
		temp_m_axis_tuser_reg <= {M_USER_WIDTH{1'b0}};
	end else begin
		m_axis_tvalid_reg <= m_axis_tvalid_next;
		m_axis_tready_int_reg <= m_axis_tready_int_early;
		temp_m_axis_tvalid_reg <= temp_m_axis_tvalid_next;
	end

	if (store_avst_int_to_output) begin
		m_axis_tdata_reg <= m_axis_tdata_int;
		m_axis_tkeep_reg <= m_axis_tkeep_int;
		m_axis_tlast_reg <= m_axis_tlast_int;
		m_axis_tid_reg <= m_axis_tid_int;
		m_axis_tdest_reg <= m_axis_tdest_int;
		m_axis_tuser_reg <= m_axis_tuser_int;
	end else if (store_avst_temp_tto_output) begin
		m_axis_tdata_reg <= temp_m_axis_tdata_reg;
		m_axis_tkeep_reg <= temp_m_axis_tkeep_reg;
		m_axis_tlast_reg <= temp_m_axis_tlast_reg;
		m_axis_tid_reg <= temp_m_axis_tid_reg;
		m_axis_tdest_reg <= temp_m_axis_tdest_reg;
		m_axis_tuser_reg <= temp_m_axis_tuser_reg;
	end

	if (store_avst_int_to_temp) begin
		temp_m_axis_tdata_reg <= m_axis_tdata_int;
		temp_m_axis_tkeep_reg <= m_axis_tkeep_int;
		temp_m_axis_tlast_reg <= m_axis_tlast_int;
		temp_m_axis_tid_reg <= m_axis_tid_int;
		temp_m_axis_tdest_reg <= m_axis_tdest_int;
		temp_m_axis_tuser_reg <= m_axis_tuser_int;
	end
end

endmodule

`resetall