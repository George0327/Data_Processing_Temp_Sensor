// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Mon Dec  2 17:28:17 2024
// Host        : Lenovo_G running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {e:/An
//               3/Sem1/SCS/Temp_data/Temp_data.srcs/sources_1/ip/axis_broadcaster_0/axis_broadcaster_0_stub.v}
// Design      : axis_broadcaster_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "top_axis_broadcaster_0,Vivado 2018.3" *)
module axis_broadcaster_0(aclk, aresetn, s_axis_tvalid, s_axis_tready, 
  s_axis_tdata, m_axis_tvalid, m_axis_tready, m_axis_tdata)
/* synthesis syn_black_box black_box_pad_pin="aclk,aresetn,s_axis_tvalid,s_axis_tready,s_axis_tdata[7:0],m_axis_tvalid[1:0],m_axis_tready[1:0],m_axis_tdata[15:0]" */;
  input aclk;
  input aresetn;
  input s_axis_tvalid;
  output s_axis_tready;
  input [7:0]s_axis_tdata;
  output [1:0]m_axis_tvalid;
  input [1:0]m_axis_tready;
  output [15:0]m_axis_tdata;
endmodule
