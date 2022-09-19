/*
 * Created on Mon Jul 25 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:     p4_mux.v
 * @Author:         Jiawei Lin
 * @Last edit:     09:01:49
 */

`timescale 1ns/1ps
`default_nettype none
`resetall

module p4_mux #(
    parameter DATA_WIDTH = 128,
    parameter KEEP_WIDTH = DATA_WIDTH/8,
    parameter S_ID_WIDTH = 8,
    parameter M_ID_WIDTH = S_ID_WIDTH,
    parameter DEST_WIDTH = 4,
    parameter USER_WIDTH = 4,

    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    parameter LAST_ENABLE = 1,
    parameter ID_ENABLE = 0,
    parameter DEST_ENABLE = 0,
    parameter USER_ENABLE = 1,

    parameter S_COUNT = 4,
    parameter UPDATE_TID = 0,
    parameter ARB_TYPE_ROUND_ROBIN = 0,
    parameter ARB_LSB_HIGH_PRIORITY = 1,

    parameter HDR_DATA_WIDTH = DATA_WIDTH,
    parameter HDR_KEEP_WIDTH = HDR_DATA_WIDTH/8,
    parameter HDR_S_ID_WIDTH = S_ID_WIDTH,
    parameter HDR_M_ID_WIDTH = M_ID_WIDTH,
    parameter HDR_DEST_WIDTH = DEST_WIDTH,
    parameter HDR_USER_WIDTH = USER_WIDTH
) (
    input  wire clk,
    input  wire rst,

    input  wire [S_COUNT*DATA_WIDTH-1:0]        s_axis_tdata,
    input  wire [S_COUNT*KEEP_WIDTH-1:0]        s_axis_tkeep,
    input  wire [S_COUNT-1:0]                   s_axis_tvalid,
    output wire [S_COUNT-1:0]                   s_axis_tready,
    input  wire [S_COUNT-1:0]                   s_axis_tlast,
    input  wire [S_COUNT*S_ID_WIDTH-1:0]        s_axis_tid,
    input  wire [S_COUNT*DEST_WIDTH-1:0]        s_axis_tdest,
    input  wire [S_COUNT*USER_WIDTH-1:0]        s_axis_tuser,

    output wire [DATA_WIDTH-1:0]                m_axis_tdata,
    output wire [KEEP_WIDTH-1:0]                m_axis_tkeep,
    output wire                                 m_axis_tvalid,
    input  wire                                 m_axis_tready,
    output wire                                 m_axis_tlast,
    output wire [M_ID_WIDTH-1:0]                m_axis_tid,
    output wire [DEST_WIDTH-1:0]                m_axis_tdest,
    output wire [USER_WIDTH-1:0]                m_axis_tuser,

    input  wire [S_COUNT*HDR_DATA_WIDTH-1:0]    s_axis_hdr_tdata,
    input  wire [S_COUNT*HDR_KEEP_WIDTH-1:0]    s_axis_hdr_tkeep,
    input  wire [S_COUNT-1:0]                   s_axis_hdr_tvalid,
    output wire [S_COUNT-1:0]                   s_axis_hdr_tready,
    input  wire [S_COUNT-1:0]                   s_axis_hdr_tlast,
    input  wire [S_COUNT*HDR_S_ID_WIDTH-1:0]    s_axis_hdr_tid,
    input  wire [S_COUNT*HDR_DEST_WIDTH-1:0]    s_axis_hdr_tdest,
    input  wire [S_COUNT*HDR_USER_WIDTH-1:0]    s_axis_hdr_tuser,

    output wire [HDR_DATA_WIDTH-1:0]            m_axis_hdr_tdata,
    output wire [HDR_KEEP_WIDTH-1:0]            m_axis_hdr_tkeep,
    output wire                                 m_axis_hdr_tvalid,
    input  wire                                 m_axis_hdr_tready,
    output wire                                 m_axis_hdr_tlast,
    output wire [HDR_M_ID_WIDTH-1:0]            m_axis_hdr_tid,
    output wire [HDR_DEST_WIDTH-1:0]            m_axis_hdr_tdest,
    output wire [HDR_USER_WIDTH-1:0]            m_axis_hdr_tuser
);

localparam CL_S_COUNT = $clog2(S_COUNT);

reg  [S_COUNT-1:0] en_hdr_reg = {S_COUNT{1'b1}}, en_hdr_next;
reg  [S_COUNT-1:0] en_pld_reg = {S_COUNT{1'b1}}, en_pld_next;

wire [S_COUNT-1:0] acknowledge;
wire [S_COUNT-1:0] grant;
wire [CL_S_COUNT-1:0] grant_encoded;
wire grant_valid;
wire [S_COUNT-1:0] s_axis_tvalid_int, s_axis_hdr_tvalid_int;
wire [S_COUNT-1:0] s_axis_tready_int, s_axis_hdr_tready_int;

assign s_axis_tvalid_int = s_axis_tvalid & en_pld_reg;
assign s_axis_tready = s_axis_tready_int & en_pld_reg;
assign s_axis_hdr_tvalid_int = s_axis_hdr_tvalid & en_hdr_reg;
assign s_axis_hdr_tready = s_axis_hdr_tready_int & en_hdr_reg;

integer i;
always @(*) begin
    en_hdr_next = en_hdr_reg;
    en_pld_next = en_pld_reg;
    for (i=0; i<S_COUNT; i=i+1) begin
        if (s_axis_tvalid[i] & s_axis_tready[i] & s_axis_tlast[i]) begin
            if (s_axis_hdr_tvalid[i] & s_axis_hdr_tready[i] & s_axis_hdr_tlast[i]) begin
                en_hdr_next[i] = 1'b1;
                en_pld_next[i] = 1'b1;
            end else if (en_hdr_reg[i]) begin
                en_pld_next[i] = 1'b0;
            end else begin
                en_hdr_next[i] = 1'b1;
                en_pld_next[i] = 1'b1;
            end
        end else if (s_axis_hdr_tvalid[i] & s_axis_hdr_tready[i] & s_axis_hdr_tlast[i]) begin
            if (en_pld_reg[i]) begin
                en_hdr_next[i] = 1'b0;
            end else begin
                en_pld_next[i] = 1'b1;
                en_hdr_next[i] = 1'b1;
            end
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        en_hdr_reg <= {S_COUNT{1'b1}};
        en_pld_reg <= {S_COUNT{1'b1}};
    end else begin
        en_hdr_reg <= en_hdr_next;
        en_pld_reg <= en_pld_next;
    end
end

axis_arb_mux #(
    .S_COUNT                (S_COUNT),
    .DATA_WIDTH             (DATA_WIDTH),
    .KEEP_ENABLE            (KEEP_ENABLE),
    .KEEP_WIDTH             (KEEP_WIDTH),
    .ID_ENABLE              (ID_ENABLE),
    .S_ID_WIDTH             (S_ID_WIDTH),
    .M_ID_WIDTH             (M_ID_WIDTH),
    .DEST_ENABLE            (DEST_ENABLE),
    .DEST_WIDTH             (DEST_WIDTH),
    .USER_ENABLE            (USER_ENABLE),
    .USER_WIDTH             (USER_WIDTH),
    .LAST_ENABLE            (LAST_ENABLE),
    .UPDATE_TID             (UPDATE_TID),
    .ARB_TYPE_ROUND_ROBIN   (ARB_TYPE_ROUND_ROBIN),
    .ARB_LSB_HIGH_PRIORITY  (ARB_LSB_HIGH_PRIORITY)
) pkt_mux_1 (
    .clk                    (clk),
    .rst                    (rst),

    .s_axis_tdata           (s_axis_tdata),
    .s_axis_tkeep           (s_axis_tkeep),
    .s_axis_tvalid          (s_axis_tvalid_int),
    .s_axis_tready          (s_axis_tready_int),
    .s_axis_tlast           (s_axis_tlast),
    .s_axis_tid             (s_axis_tid),
    .s_axis_tdest           (s_axis_tdest),
    .s_axis_tuser           (s_axis_tuser),
    
    .m_axis_tdata           (m_axis_tdata),
    .m_axis_tkeep           (m_axis_tkeep),
    .m_axis_tvalid          (m_axis_tvalid),
    .m_axis_tready          (m_axis_tready),
    .m_axis_tlast           (m_axis_tlast),
    .m_axis_tid             (m_axis_tid),
    .m_axis_tdest           (m_axis_tdest),
    .m_axis_tuser           (m_axis_tuser),

    .grant                  (grant),
    .grant_valid            (grant_valid),
    .grant_encoded          (grant_encoded),
    .acknowledge            (acknowledge)
);

axis_mux #(
    .S_COUNT                (S_COUNT),
    .DATA_WIDTH             (HDR_DATA_WIDTH),
    .KEEP_ENABLE            (KEEP_ENABLE),
    .KEEP_WIDTH             (HDR_KEEP_WIDTH),
    .ID_ENABLE              (ID_ENABLE),
    .ID_WIDTH               (HDR_S_ID_WIDTH),
    .DEST_ENABLE            (DEST_ENABLE),
    .DEST_WIDTH             (HDR_DEST_WIDTH),
    .USER_ENABLE            (USER_ENABLE),
    .USER_WIDTH             (HDR_USER_WIDTH)
) hdr_mux_1 (
    .clk                    (clk),
    .rst                    (rst),

    .s_axis_tdata           (s_axis_hdr_tdata),
    .s_axis_tkeep           (s_axis_hdr_tkeep),
    .s_axis_tvalid          (s_axis_hdr_tvalid_int),
    .s_axis_tready          (s_axis_hdr_tready_int),
    .s_axis_tlast           (s_axis_hdr_tlast),
    .s_axis_tid             (s_axis_hdr_tid),
    .s_axis_tdest           (s_axis_hdr_tdest),
    .s_axis_tuser           (s_axis_hdr_tuser),

    .m_axis_tdata           (m_axis_hdr_tdata),
    .m_axis_tkeep           (m_axis_hdr_tkeep),
    .m_axis_tvalid          (m_axis_hdr_tvalid),
    .m_axis_tready          (m_axis_hdr_tready),
    .m_axis_tlast           (m_axis_hdr_tlast),
    .m_axis_tid             (m_axis_hdr_tid),
    .m_axis_tdest           (m_axis_hdr_tdest),
    .m_axis_tuser           (m_axis_hdr_tuser),

    .enable                 (grant_valid),
    .select                 (grant_encoded)
);

endmodule


`resetall