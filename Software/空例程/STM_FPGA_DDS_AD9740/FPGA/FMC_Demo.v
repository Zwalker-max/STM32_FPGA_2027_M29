/*********************************************************
* 顶层模块：FMC_Demo
* 功能：STM32H7 + FPGA DDS 任意波形发生器（AD9740 DAC）
* 架构：
*   CLK_50M → pll1 → c0(125MHz/0°) → 内部逻辑时钟
*                    → c1(125MHz/90°) → DAC_CLK 输出
*   STM32 ←→ stm32_fmc_16bit ←→ ram_2port1 ←→ dds_core
*                                      ↓
*                                 dac_control → DAC_D[9:0]
*
* FMC_D 双向总线直接传入 stm32_fmc_16bit 处理（与原始 BDF 一致）
* FPGA：EP4CE10E22C8N
**********************************************************/

module FMC_Demo (
    // 系统时钟
    input wire          CLK_50M,

    // FMC 总线（连 STM32）
    input wire          FMC_NE1,
    input wire          FMC_NOE,
    input wire          FMC_NWE,
    input wire  [14:0]  FMC_A,
    inout wire  [15:0]  FMC_D,

    // DAC 输出（连 AD9740）
    output wire         DAC_CLK,
    output wire  [9:0]  DAC_D
);

//===========================================================
// 上电复位（POR）
// 计数器在 50MHz 时钟域运行（PLL 可能未锁定，125MHz 不可靠）
// 1023 周期 ≈ 20μs，远超 Cyclone IV PLL 锁相时间（~10μs）
//===========================================================
reg  [9:0] por_cnt;
wire       sys_rst_n;

always @(posedge CLK_50M) begin
    if (por_cnt != 10'h3FF)
        por_cnt <= por_cnt + 10'd1;
end
assign sys_rst_n = (por_cnt == 10'h3FF);

//===========================================================
// 内部互联信号
//===========================================================
wire                clk_125m;       // PLL c0: 125MHz / 0° 内部逻辑时钟

// stm32_fmc_16bit ↔ ram_2port1 (Port A)
wire                wf_wren;
wire    [9:0]       wf_addr;
wire    [15:0]      wf_wrdata;
wire    [15:0]      wf_rddata;

// stm32_fmc_16bit → dds_core
wire    [31:0]      ftw_active;
wire                phase_rst;

// stm32_fmc_16bit → dac_control
wire                /* synthesis keep */dac_enable;

// dds_core → ram_2port1 (Port B)
wire    [9:0]       rd_addr;

// ram_2port1 (Port B) → dac_control
wire    [15:0]      ram_q_b;

//===========================================================
// PLL 例化（50MHz → 125MHz, c0=0° / c1=90°）
//===========================================================
pll1 pll1_inst (
    .inclk0 (CLK_50M),
    .c0     (clk_125m),
    .c1     (DAC_CLK)
);

//===========================================================
// FMC 从机接口 + 地址译码 + DDS 寄存器
// FMC_D 直接传入模块内部处理三态（与原始 BDF 一致）
//===========================================================
stm32_fmc_16bit fmc_inst (
    .FMC_NE1    (FMC_NE1),
    .FMC_NOE    (FMC_NOE),
    .FMC_NWE    (FMC_NWE),
    .FMC_A      (FMC_A),
    .FMC_D      (FMC_D),

    .clk_125m   (clk_125m),
    .rst_n      (sys_rst_n),

    .wf_wren    (wf_wren),
    .wf_addr    (wf_addr),
    .wf_wrdata  (wf_wrdata),
    .wf_rddata  (wf_rddata),

    .ftw_active (ftw_active),
    .phase_rst  (phase_rst),
    .dac_enable (dac_enable)
);

//===========================================================
// 双端口波形 RAM（1024 × 16）
// Port A：STM32 写 / 读    Port B：DDS 只读
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
// DDS 核心：32 位相位累加器
//===========================================================
dds_core dds_inst (
    .clk        (clk_125m),
    .rst_n      (sys_rst_n),

    .ftw        (ftw_active),
    .phase_rst  (phase_rst),
    .rd_addr    (rd_addr)
);

//===========================================================
// DAC 输出流水线
//===========================================================
dac_control dac_ctrl_inst (
    .clk        (clk_125m),
    .rst_n      (sys_rst_n),

    .wf_data    (ram_q_b[9:0]),
    .dac_enable (dac_enable),
    .dac_data   (DAC_D)
);

endmodule
