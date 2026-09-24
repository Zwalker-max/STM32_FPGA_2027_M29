/*********************************************************
* Top module: FMC_Demo
* Function:
*   STM32H7 + FPGA DDS waveform generator for AD9740 DAC,
*   plus AD9220 capture control/readback through the same FMC bus.
*
*   CLK_50M -> pll1 c0: 125 MHz logic clock
*                    c1: 125 MHz DAC clock
*                    c2: 10 MHz AD9220 clock
**********************************************************/

module FMC_Demo (
    input wire          CLK_50M,

    input wire          FMC_NE1,
    input wire          FMC_NOE,
    input wire          FMC_NWE,
    input wire  [14:0]  FMC_A,
    inout wire  [15:0]  FMC_D,

    output wire         DAC_CLK,
    output wire  [9:0]  DAC_D,

    input wire   [11:0] ADC_D,
    output wire         ADCCLK
);

//===========================================================
// Power-on reset in the 50 MHz input clock domain.
//===========================================================
reg [9:0] por_cnt;
wire      sys_rst_n;

always @(posedge CLK_50M) begin
    if (por_cnt != 10'h3FF)
        por_cnt <= por_cnt + 10'd1;
end

assign sys_rst_n = (por_cnt == 10'h3FF);

//===========================================================
// Internal interconnect
//===========================================================
wire                clk_125m;
wire                clk_10m;

wire                wf_wren;
wire    [9:0]       wf_addr;
wire    [15:0]      wf_wrdata;
wire    [15:0]      wf_rddata;

wire    [31:0]      ftw_active;
wire                phase_rst;
wire                /* synthesis keep */ dac_enable;

wire    [9:0]       rd_addr;
wire    [15:0]      ram_q_b;

//===========================================================
// PLL: c0=125 MHz logic, c1=125 MHz DAC clock, c2=10 MHz ADC clock.
//===========================================================
pll1 pll1_inst (
    .inclk0 (CLK_50M),
    .c0     (clk_125m),
    .c1     (DAC_CLK),
    .c2     (clk_10m)
);

assign ADCCLK = clk_10m;

//===========================================================
// FMC slave, address decode, DDS registers, ADC capture RAM.
//===========================================================
stm32_fmc_16bit fmc_inst (
    .FMC_NE1    (FMC_NE1),
    .FMC_NOE    (FMC_NOE),
    .FMC_NWE    (FMC_NWE),
    .FMC_A      (FMC_A),
    .FMC_D      (FMC_D),

    .clk_125m   (clk_125m),
    .adc_clk    (clk_10m),
    .rst_n      (sys_rst_n),
    .adc_data   (ADC_D),

    .wf_wren    (wf_wren),
    .wf_addr    (wf_addr),
    .wf_wrdata  (wf_wrdata),
    .wf_rddata  (wf_rddata),

    .ftw_active (ftw_active),
    .phase_rst  (phase_rst),
    .dac_enable (dac_enable)
);

//===========================================================
// 1024 x 16 waveform RAM.
//===========================================================
ram_2port1 ram_inst (
    .clk        (clk_125m),

    .wren_a     (wf_wren),
    .address_a  (wf_addr),
    .data_a     (wf_wrdata),
    .q_a        (wf_rddata),

    .address_b  (rd_addr),
    .q_b        (ram_q_b)
);

//===========================================================
// DDS phase accumulator.
//===========================================================
dds_core dds_inst (
    .clk        (clk_125m),
    .rst_n      (sys_rst_n),

    .ftw        (ftw_active),
    .phase_rst  (phase_rst),
    .rd_addr    (rd_addr)
);

//===========================================================
// AD9740 DAC output pipeline.
//===========================================================
dac_control dac_ctrl_inst (
    .clk        (clk_125m),
    .rst_n      (sys_rst_n),

    .wf_data    (ram_q_b[9:0]),
    .dac_enable (dac_enable),
    .dac_data   (DAC_D)
);

endmodule
