// filename:  ./match_pipe/match_pipe.sv
localparam FIFO_DATA_WIDTH = MEMORY_DATA_WIDTH;
localparam FIFO_DEPTH = 1024;
localparam FIFO_KEEP_WIDTH = HDR_LEN_WIDTH;
localparam FIFO_ID_WIDTH = 1;
localparam FIFO_DEST_WIDTH = STATE_WIDTH;
localparam FIFO_USER_WIDTH = TYPE_WIDTH;
localparam FRAME_FIFO = 0;

wire s_axis_fifo_tready;
wire m_axis_fifo_tvalid;

assign read_empty = !m_axis_fifo_tvalid;
assign write_full = !s_axis_fifo_tready;

axis_fifo # (
	.DEPTH					(FIFO_DEPTH),
	.DATA_WIDTH				(FIFO_DATA_WIDTH),
	.KEEP_ENABLE			((FIFO_DATA_WIDTH>8)),
    .KEEP_WIDTH				(FIFO_KEEP_WIDTH),
	.LAST_ENABLE			(0),
	.ID_ENABLE				(0),
	.ID_WIDTH				(FIFO_ID_WIDTH),
	.DEST_ENABLE			(0),
	.DEST_WIDTH				(FIFO_DEST_WIDTH),
	.USER_ENABLE			(0),
	.USER_WIDTH				(FIFO_USER_WIDTH),
	.PIPELINE_OUTPUT		(1),
	.FRAME_FIFO				(FRAME_FIFO),
	.USER_BAD_FRAME_VALUE	(1'b1),
	.USER_BAD_FRAME_MASK	(1'b1),
	.DROP_OVERSIZE_FRAME	(FRAME_FIFO),
	.DROP_BAD_FRAME			(0),
	.DROP_WHEN_FULL			(0)
) axis_fifo_inst (
	.clk				(clk),
	.rst				(reset),

	.s_axis_tdata		(write_data),
	.s_axis_tkeep		(),
	.s_axis_tvalid		(write_enable),
	.s_axis_tready		(s_axis_fifo_tready),
	.s_axis_tlast		(),
	.s_axis_tid			(),
	.s_axis_tdest		(),
	.s_axis_tuser		(),

	.m_axis_tdata		(read_data_fifo),
	.m_axis_tkeep		(),
	.m_axis_tvalid		(m_axis_fifo_tvalid),
	.m_axis_tready		(read_enable),
	.m_axis_tlast		(),
	.m_axis_tid			(),
	.m_axis_tdest		(),
	.m_axis_tuser		(),

	.status_overflow	(),
	.status_bad_frame	(),
	.status_good_frame	()
);