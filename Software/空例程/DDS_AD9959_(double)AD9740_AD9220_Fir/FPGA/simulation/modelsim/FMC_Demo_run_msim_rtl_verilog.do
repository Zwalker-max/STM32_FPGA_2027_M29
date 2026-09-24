transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/File/CubeMX/STM-FPGA/DDS_AD9959_(double)AD9740_AD9220/FPGA {D:/File/CubeMX/STM-FPGA/DDS_AD9959_(double)AD9740_AD9220/FPGA/stm32_fmc_16bit.v}
vlog -vlog01compat -work work +incdir+D:/File/CubeMX/STM-FPGA/DDS_AD9959_(double)AD9740_AD9220/FPGA {D:/File/CubeMX/STM-FPGA/DDS_AD9959_(double)AD9740_AD9220/FPGA/ram_2port1.v}
vlog -vlog01compat -work work +incdir+D:/File/CubeMX/STM-FPGA/DDS_AD9959_(double)AD9740_AD9220/FPGA {D:/File/CubeMX/STM-FPGA/DDS_AD9959_(double)AD9740_AD9220/FPGA/dds_core.v}
vlog -vlog01compat -work work +incdir+D:/File/CubeMX/STM-FPGA/DDS_AD9959_(double)AD9740_AD9220/FPGA {D:/File/CubeMX/STM-FPGA/DDS_AD9959_(double)AD9740_AD9220/FPGA/dac_control.v}
vlog -vlog01compat -work work +incdir+D:/File/CubeMX/STM-FPGA/DDS_AD9959_(double)AD9740_AD9220/FPGA {D:/File/CubeMX/STM-FPGA/DDS_AD9959_(double)AD9740_AD9220/FPGA/FMC_Demo.v}
vlog -vlog01compat -work work +incdir+D:/File/CubeMX/STM-FPGA/DDS_AD9959_(double)AD9740_AD9220/FPGA {D:/File/CubeMX/STM-FPGA/DDS_AD9959_(double)AD9740_AD9220/FPGA/pll1.v}
vlog -vlog01compat -work work +incdir+D:/File/CubeMX/STM-FPGA/DDS_AD9959_(double)AD9740_AD9220/FPGA/db {D:/File/CubeMX/STM-FPGA/DDS_AD9959_(double)AD9740_AD9220/FPGA/db/pll1_altpll1.v}

