/*********************************************************
* 模块：dds_core
* 功能：32 位相位累加器，DDS 核心
* 输入：ftw[31:0] — 频率调谐字（来自 stm32_fmc_16bit.ftw_active）
* 输入：phase_rst  — 同步相位复位（清零累加器）
* 输出：rd_addr[9:0] = phase_acc[31:22]（1024 点波形 RAM 地址）
* FPGA：EP4CE10E22C8N
* 时钟：125MHz（pll1.c0）
* 设计：
*   - 频率分辨率 125MHz/2^32 ≈ 0.0291 Hz
*   - 相位累加器自动溢出回绕，无需额外逻辑
*   - rd_addr 为组合逻辑输出，RAM 同步读产生 1 周期延迟
**********************************************************/
module dds_core (
    input wire          clk,
    input wire          rst_n,
    input wire  [31:0]  ftw,
    input wire          phase_rst,
    output wire  [9:0]  rd_addr
);

// 32 位相位累加器
reg [31:0] phase_acc;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        phase_acc <= 32'd0;
    end
    else if (phase_rst) begin
        phase_acc <= 32'd0;
    end
    else begin
        phase_acc <= phase_acc + ftw;
    end
end

// 高 10 位驱动波形 RAM 读地址（1024 点）
assign rd_addr = phase_acc[31:22];

endmodule
