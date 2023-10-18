ghdl -a ../Fuentes/I2C.vhd ../Fuentes/I2C_tb.vhd
ghdl -s ../Fuentes/I2C.vhd ../Fuentes/I2C_tb.vhd
ghdl -e I2C_tb
ghdl -r I2C_tb --vcd=I2C_tb.vcd --stop-time=200ms
gtkwave I2C_tb.vcd 