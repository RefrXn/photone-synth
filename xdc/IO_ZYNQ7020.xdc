set_property PACKAGE_PIN T12 [get_ports BCLK]
set_property PACKAGE_PIN R14 [get_ports I2C_SCLK]
set_property PACKAGE_PIN P14 [get_ports I2C_SDAT]
set_property PACKAGE_PIN U12 [get_ports DACDAT]
set_property PACKAGE_PIN T14 [get_ports DACLRC]

set_property IOSTANDARD LVCMOS33 [get_ports BCLK]
set_property IOSTANDARD LVCMOS33 [get_ports DACDAT]
set_property IOSTANDARD LVCMOS33 [get_ports I2C_SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports I2C_SDAT]
set_property IOSTANDARD LVCMOS33 [get_ports DACLRC]

set_property IOSTANDARD LVCMOS33 [get_ports midi_rx]
set_property PACKAGE_PIN M18 [get_ports midi_rx]

# for bd
# set_property PACKAGE_PIN U12 [get_ports DACDAT_0]
# set_property PACKAGE_PIN R14 [get_ports I2C_SCLK_0]
# set_property PACKAGE_PIN P14 [get_ports I2C_SDAT_0]
# set_property IOSTANDARD LVCMOS33 [get_ports DACDAT_0]
# set_property IOSTANDARD LVCMOS33 [get_ports I2C_SCLK_0]
# set_property IOSTANDARD LVCMOS33 [get_ports I2C_SDAT_0]

set_property IOSTANDARD LVCMOS33 [get_ports clk_50m]
set_property PACKAGE_PIN U18 [get_ports clk_50m]
set_property PACKAGE_PIN M15 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
