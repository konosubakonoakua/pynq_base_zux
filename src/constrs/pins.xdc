#### LED
set_property IOSTANDARD LVCMOS18 [get_ports {LED_PL[0]}]
set_property PACKAGE_PIN T11 [get_ports {LED_PL[0]}]

#### USERIO
#####################  #####################
# USERIO4 # USERIO3 #  # USERIO8 # USERIO7 #
#####################  #####################
# USERIO2 # USERIO1 #  # USERIO5 # USERIO6 #
#####################  #####################
set_property PACKAGE_PIN AN13 [get_ports USER_IO_1]
set_property PACKAGE_PIN AM13 [get_ports USER_IO_2]
set_property PACKAGE_PIN AN14 [get_ports USER_IO_3]
set_property PACKAGE_PIN AP14 [get_ports USER_IO_4]
set_property IOSTANDARD LVCMOS18 [get_ports USER_IO_1]
set_property IOSTANDARD LVCMOS18 [get_ports USER_IO_2]
set_property IOSTANDARD LVCMOS18 [get_ports USER_IO_3]
set_property IOSTANDARD LVCMOS18 [get_ports USER_IO_4]
set_property PACKAGE_PIN AM14 [get_ports USER_IO_5]
set_property PACKAGE_PIN AH13 [get_ports USER_IO_6]
set_property PACKAGE_PIN AJ14 [get_ports USER_IO_7]
set_property PACKAGE_PIN AK13 [get_ports USER_IO_8]
set_property IOSTANDARD LVCMOS18 [get_ports USER_IO_5]
set_property IOSTANDARD LVCMOS18 [get_ports USER_IO_6]
set_property IOSTANDARD LVCMOS18 [get_ports USER_IO_7]
set_property IOSTANDARD LVCMOS18 [get_ports USER_IO_8]


#### FIBER
set_property PACKAGE_PIN AL12 [get_ports FIBER_RX_1]
set_property PACKAGE_PIN AL13 [get_ports FIBER_RX_2]
set_property PACKAGE_PIN AN12 [get_ports FIBER_TX_2]
set_property PACKAGE_PIN AP12 [get_ports FIBER_TX_1]
set_property IOSTANDARD LVCMOS18 [get_ports FIBER_TX_1]
set_property IOSTANDARD LVCMOS18 [get_ports FIBER_TX_2]
set_property IOSTANDARD LVCMOS18 [get_ports FIBER_RX_2]
set_property IOSTANDARD LVCMOS18 [get_ports FIBER_RX_1]

#### CLK
set_property PACKAGE_PIN Y8 [get_ports CLK_SYS_125M_clk_p]
set_property IOSTANDARD LVDS [get_ports CLK_SYS_125M_clk_p]
set_property IOSTANDARD LVDS [get_ports CLK_SYS_125M_clk_n]