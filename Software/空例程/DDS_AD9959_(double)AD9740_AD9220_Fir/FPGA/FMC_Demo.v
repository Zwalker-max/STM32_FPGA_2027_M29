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
    output wire         DAC2_CLK,
    output wire  [9:0]  DAC_D,
    output wire  [9:0]  DAC2_D,

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
wire                clk_fir_50m;    // 50 MHz FIR clock (pll1.c3)
wire                dac_clk_int;       // internal DAC clock net, feeds both DAC_CLK and DAC2_CLK

wire                wf1_wren;
wire    [9:0]       wf1_addr;
wire    [15:0]      wf1_wrdata;
wire    [15:0]      wf1_rddata;

wire                wf2_wren;
wire    [9:0]       wf2_addr;
wire    [15:0]      wf2_wrdata;
wire    [15:0]      wf2_rddata;

wire    [31:0]      ftw1_active;
wire                phase_rst1;
wire                dac1_enable;

wire    [31:0]      ftw2_active;
wire                phase_rst2;
wire                dac2_enable;

wire    [9:0]       rd_addr1;
wire    [15:0]      ram1_q_b;

wire    [9:0]       rd_addr2;
wire    [15:0]      ram2_q_b;

//===========================================================
// PLL: c0=125 MHz logic, c1=125 MHz DAC clock, c2=10 MHz ADC clock,
//      c3=50 MHz FIR clock.
//===========================================================
pll1 pll1_inst (
    .inclk0 (CLK_50M),
    .c0     (clk_125m),
    .c1     (dac_clk_int),
    .c2     (clk_10m),
    .c3     (clk_fir_50m)
);

assign ADCCLK    = clk_10m;
assign DAC_CLK   = dac_clk_int;
assign DAC2_CLK  = dac_clk_int;

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
    .clk_fir_50m(clk_fir_50m),
    .rst_n      (sys_rst_n),
    .adc_data   (ADC_D),

    .wf1_wren   (wf1_wren),
    .wf1_addr   (wf1_addr),
    .wf1_wrdata (wf1_wrdata),
    .wf1_rddata (wf1_rddata),

    .wf2_wren   (wf2_wren),
    .wf2_addr   (wf2_addr),
    .wf2_wrdata (wf2_wrdata),
    .wf2_rddata (wf2_rddata),

    .ftw1_active(ftw1_active),
    .phase_rst1 (phase_rst1),
    .dac1_enable(dac1_enable),

    .ftw2_active(ftw2_active),
    .phase_rst2 (phase_rst2),
    .dac2_enable(dac2_enable)
);

//===========================================================
// 1024 x 16 waveform RAM (DAC1).
//===========================================================
ram_2port1 ram1_inst (
    .clk        (clk_125m),

    .wren_a     (wf1_wren),
    .address_a  (wf1_addr),
    .data_a     (wf1_wrdata),
    .q_a        (wf1_rddata),

    .address_b  (rd_addr1),
    .q_b        (ram1_q_b)
);

//===========================================================
// 1024 x 16 waveform RAM (DAC2).
//===========================================================
ram_2port1 ram2_inst (
    .clk        (clk_125m),

    .wren_a     (wf2_wren),
    .address_a  (wf2_addr),
    .data_a     (wf2_wrdata),
    .q_a        (wf2_rddata),

    .address_b  (rd_addr2),
    .q_b        (ram2_q_b)
);

//===========================================================
// DDS phase accumulator (DAC1).
//===========================================================
dds_core dds1_inst (
    .clk        (clk_125m),
    .rst_n      (sys_rst_n),

    .ftw        (ftw1_active),
    .phase_rst  (phase_rst1),
    .rd_addr    (rd_addr1)
);

//===========================================================
// DDS phase accumulator (DAC2).
//===========================================================
dds_core dds2_inst (
    .clk        (clk_125m),
    .rst_n      (sys_rst_n),

    .ftw        (ftw2_active),
    .phase_rst  (phase_rst2),
    .rd_addr    (rd_addr2)
);

//===========================================================
// AD9740 DAC output pipeline (DAC1).
//===========================================================
dac_control dac_ctrl1_inst (
    .clk        (clk_125m),
    .rst_n      (sys_rst_n),

    .wf_data    (ram1_q_b[9:0]),
    .dac_enable (dac1_enable),
    .dac_data   (DAC_D)
);

//===========================================================
// AD9740 DAC output pipeline (DAC2).
//===========================================================
dac_control dac_ctrl2_inst (
    .clk        (clk_125m),
    .rst_n      (sys_rst_n),

    .wf_data    (ram2_q_b[9:0]),
    .dac_enable (dac2_enable),
    .dac_data   (DAC2_D)
);

endmodule
