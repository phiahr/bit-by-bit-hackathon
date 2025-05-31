set_property -dict { PACKAGE_PIN AD11  IOSTANDARD LVDS     } [get_ports { clk_in1_n }]; #IO_L12N_T1_MRCC_33 Sch=sysclk_n
set_property -dict { PACKAGE_PIN AD12  IOSTANDARD LVDS     } [get_ports { clk_in1_p }]; #IO_L12P_T1_MRCC_33 Sch=sysclk_p


#set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS12 } [get_ports { reset_n }]; #IO_25_17 Sch=btnc
#set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS12 } [get_ports { reset_n_clk }]; #IO_0_15 Sch=btnd
set_property -dict { PACKAGE_PIN T28   IOSTANDARD LVCMOS33 } [get_ports { led0 }]; #IO_L11N_T1_SRCC_14 Sch=led[0]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports { led1 }]; #IO_L19P_T3_A10_D26_14 Sch=led[1]
set_property -dict { PACKAGE_PIN U30   IOSTANDARD LVCMOS33 } [get_ports { led2 }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=led[2]
set_property -dict { PACKAGE_PIN U29   IOSTANDARD LVCMOS33 } [get_ports { led3 }]; #IO_L15P_T2_DQS_RDWR_B_14 Sch=led[3]

set_property -dict { PACKAGE_PIN G19   IOSTANDARD LVCMOS12 } [get_ports { reset_n }]; #IO_0_17 Sch=sw[0]
set_property -dict { PACKAGE_PIN G25   IOSTANDARD LVCMOS12 } [get_ports { reset_clk }]; #IO_25_16 Sch=sw[1]
