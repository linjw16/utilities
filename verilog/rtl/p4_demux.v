
/*
 * Created on Mon Jul 25 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:     p4_demux.v
 * @Author:            Jiawei Lin
 * @Last edit:     10:45:44
 */

`resetall
`timescale 1ns / 1ps
`default_nettype none

module p4_demux # (
    parameter M_COUNT = 4,
    parameter DATA_WIDTH = 8,
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    parameter KEEP_WIDTH = ((DATA_WIDTH+7)/8),
    parameter ID_ENABLE = 0,
    parameter ID_WIDTH = 8,
    parameter DEST_ENABLE = 0,
    parameter M_DEST_WIDTH = 8,
    parameter S_DEST_WIDTH = M_DEST_WIDTH+$clog2(M_COUNT),
    parameter USER_ENABLE = 1,
    parameter USER_WIDTH = 1,
    parameter TDEST_ROUTE = 0,

    parameter HDR_DATA_WIDTH = DATA_WIDTH,
    parameter HDR_KEEP_ENABLE = (HDR_DATA_WIDTH>8),
    parameter HDR_KEEP_WIDTH = ((HDR_DATA_WIDTH+7)/8),
    parameter HDR_ID_ENABLE = ID_ENABLE,
    parameter HDR_ID_WIDTH = ID_WIDTH,
    parameter HDR_DEST_ENABLE = DEST_ENABLE,
    parameter HDR_M_DEST_WIDTH = M_DEST_WIDTH,
    parameter HDR_S_DEST_WIDTH = HDR_M_DEST_WIDTH+{{cn}},
    parameter HDR_USER_ENABLE = USER_ENABLE,
    parameter HDR_USER_WIDTH = USER_WIDTH,
    parameter HDR_TDEST_ROUTE = TDEST_ROUTE
) (
    input  wire                                    clk,
    input  wire                                    rst,

    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]                    s_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]                    s_axis_tkeep,
    input  wire                                     s_axis_tvalid,
    output wire                                     s_axis_tready,
    input  wire                                     s_axis_tlast,
    input  wire [ID_WIDTH-1:0]                      s_axis_tid,
    input  wire [S_DEST_WIDTH-1:0]                  s_axis_tdest,
    input  wire [USER_WIDTH-1:0]                    s_axis_tuser,

    /*
     * AXI outputs
     */
    output wire [M_COUNT*DATA_WIDTH-1:0]            m_axis_tdata,
    output wire [M_COUNT*KEEP_WIDTH-1:0]            m_axis_tkeep,
    output wire [M_COUNT-1:0]                       m_axis_tvalid,
    input  wire [M_COUNT-1:0]                       m_axis_tready,
    output wire [M_COUNT-1:0]                       m_axis_tlast,
    output wire [M_COUNT*ID_WIDTH-1:0]              m_axis_tid,
    output wire [M_COUNT*M_DEST_WIDTH-1:0]          m_axis_tdest,
    output wire [M_COUNT*USER_WIDTH-1:0]            m_axis_tuser,

    input  wire [HDR_DATA_WIDTH-1:0]                s_axis_hdr_tdata,
    input  wire [HDR_KEEP_WIDTH-1:0]                s_axis_hdr_tkeep,
    input  wire                                     s_axis_hdr_tvalid,
    output wire                                     s_axis_hdr_tready,
    input  wire                                     s_axis_hdr_tlast,
    input  wire [HDR_ID_WIDTH-1:0]                  s_axis_hdr_tid,
    input  wire [HDR_S_DEST_WIDTH-1:0]              s_axis_hdr_tdest,
    input  wire [HDR_USER_WIDTH-1:0]                s_axis_hdr_tuser,

    output wire [M_COUNT*HDR_DATA_WIDTH-1:0]        m_axis_hdr_tdata,
    output wire [M_COUNT*HDR_KEEP_WIDTH-1:0]        m_axis_hdr_tkeep,
    output wire    [M_COUNT-1:0]                    m_axis_hdr_tvalid,
    input  wire    [M_COUNT-1:0]                    m_axis_hdr_tready,
    output wire    [M_COUNT-1:0]                    m_axis_hdr_tlast,
    output wire [M_COUNT*HDR_ID_WIDTH-1:0]          m_axis_hdr_tid,
    output wire [M_COUNT*HDR_M_DEST_WIDTH-1:0]      m_axis_hdr_tdest,
    output wire [M_COUNT*HDR_USER_WIDTH-1:0]        m_axis_hdr_tuser,

    /*
     * Control
     */
    input  wire                                     enable,
    input  wire                                     drop,
    // input  wire                                  select_valid,
    // output wire                                  select_ready,
    input  wire [$clog2(M_COUNT)-1:0]               select
);

/*
wire enable = 1'b1;
wire drop = 1'b0;
wire [CL_M_COUNT-1:0] select;
*/
localparam CL_M_COUNT = $clog2(M_COUNT);

// reg frame_reg = 1'b0, frame_next;
reg en_hdr_reg = 1'b1, en_hdr_next;
reg en_pld_reg = 1'b1, en_pld_next;
// reg [M_COUNT-1:0] frame_reg = {M_COUNT{1'b0}}, frame_next;
// reg [M_COUNT-1:0] en_hdr_reg = {M_COUNT{1'b1}}, en_hdr_next;
// reg [M_COUNT-1:0] en_pld_reg = {M_COUNT{1'b1}}, en_pld_next;

// wire [M_COUNT-1:0] axis_hdr_tready;
wire en_hdr, en_pld;

// assign axis_hdr_tready = m_axis_hdr_tready | frame_reg;
assign en_hdr = en_hdr_reg && enable;
assign en_pld = en_pld_reg && enable;
// assign select_ready = en_hdr_reg & en_pld_reg;

always @(*) begin
    // frame_next = frame_reg;
    en_hdr_next = en_hdr_reg;
    en_pld_next = en_pld_reg;
    // if (select_valid & select_ready) begin
    //     frame_next = 1'b1;
    // end
    if (s_axis_hdr_tlast & s_axis_tlast) begin
        // frame_next = 1'b0;
        en_hdr_next = 1'b1;
        en_pld_next = 1'b1;
    end else if (s_axis_hdr_tlast) begin
        if (en_pld_reg) begin
            en_hdr_next = 1'b0;
        end else begin
            // frame_next = 1'b0;
            en_hdr_next = 1'b1;
            en_pld_next = 1'b1;
        end
    end else if (s_axis_tlast) begin
        if (en_hdr_reg) begin
            en_pld_next = 1'b0;
        end else begin
            // frame_next = 1'b0;
            en_hdr_next = 1'b1;
            en_pld_next = 1'b1;
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        // frame_reg <= 1'b0;
        en_hdr_reg <= 1'b1;
        en_pld_reg <= 1'b1;
    end else begin
        // frame_reg <= frame_next;
        en_hdr_reg <= en_hdr_next;
        en_pld_reg <= en_pld_next;
    end
end

axis_demux #(
    .M_COUNT                (M_COUNT),
    .DATA_WIDTH                (DATA_WIDTH),
    .KEEP_ENABLE            (KEEP_ENABLE),
    .KEEP_WIDTH                (KEEP_WIDTH),
    .ID_ENABLE                (ID_ENABLE),
    .ID_WIDTH                (ID_WIDTH),
    .DEST_ENABLE            (DEST_ENABLE),
    .M_DEST_WIDTH            (M_DEST_WIDTH),
    .S_DEST_WIDTH            (S_DEST_WIDTH),
    .USER_ENABLE            (USER_ENABLE),
    .USER_WIDTH                (USER_WIDTH),
    .TDEST_ROUTE            (TDEST_ROUTE)
) pkt_dmx_1 (
    .clk                    (clk),
    .rst                    (rst),

    .s_axis_tdata            (s_axis_tdata),
    .s_axis_tkeep            (s_axis_tkeep),
    .s_axis_tvalid            (s_axis_tvalid),
    .s_axis_tready            (s_axis_tready),
    .s_axis_tlast            (s_axis_tlast),
    .s_axis_tid                (s_axis_tid),
    .s_axis_tdest            (s_axis_tdest),
    .s_axis_tuser            (s_axis_tuser),

    .m_axis_tdata            (m_axis_tdata),
    .m_axis_tkeep            (m_axis_tkeep),
    .m_axis_tvalid            (m_axis_tvalid),
    .m_axis_tready            (m_axis_tready),
    .m_axis_tlast            (m_axis_tlast),
    .m_axis_tid                (m_axis_tid),
    .m_axis_tdest            (m_axis_tdest),
    .m_axis_tuser            (m_axis_tuser),

    .enable                    (en_pld),
    .drop                    (drop),
    .select                    (select)
);

axis_demux #(
    .M_COUNT                (M_COUNT),
    .DATA_WIDTH                (HDR_DATA_WIDTH),
    .KEEP_ENABLE            (HDR_KEEP_ENABLE),
    .KEEP_WIDTH                (HDR_KEEP_WIDTH),
    .ID_ENABLE                (HDR_ID_ENABLE),
    .ID_WIDTH                (HDR_ID_WIDTH),
    .DEST_ENABLE            (HDR_DEST_ENABLE),
    .M_DEST_WIDTH            (HDR_M_DEST_WIDTH),
    .S_DEST_WIDTH            (HDR_S_DEST_WIDTH),
    .USER_ENABLE            (HDR_USER_ENABLE),
    .USER_WIDTH                (HDR_USER_WIDTH),
    .TDEST_ROUTE            (HDR_TDEST_ROUTE)
) hdr_dmx_1 (
    .clk                    (clk),
    .rst                    (rst),

    .s_axis_tdata            (s_axis_hdr_tdata),
    .s_axis_tkeep            (s_axis_hdr_tkeep),
    .s_axis_tvalid            (s_axis_hdr_tvalid),
    .s_axis_tready            (s_axis_hdr_tready),
    .s_axis_tlast            (s_axis_hdr_tlast),
    .s_axis_tid                (s_axis_hdr_tid),
    .s_axis_tdest            (s_axis_hdr_tdest),
    .s_axis_tuser            (s_axis_hdr_tuser),

    .m_axis_tdata            (m_axis_hdr_tdata),
    .m_axis_tkeep            (m_axis_hdr_tkeep),
    .m_axis_tvalid            (m_axis_hdr_tvalid),
    .m_axis_tready            (m_axis_hdr_tready),
    .m_axis_tlast            (m_axis_hdr_tlast),
    .m_axis_tid                (m_axis_hdr_tid),
    .m_axis_tdest            (m_axis_hdr_tdest),
    .m_axis_tuser            (m_axis_hdr_tuser),

    .enable                    (en_hdr),
    .drop                    (drop),
    .select                    (select)
);

endmodule

`resetall