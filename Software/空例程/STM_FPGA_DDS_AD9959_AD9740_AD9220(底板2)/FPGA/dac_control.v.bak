/*********************************************************
* 模块：dac_control
* 功能：AD9740 DAC 输出流水线
* 输入：wf_data[9:0] — 波形 RAM 读出数据
* 输入：dac_enable   — bit0=1 正常输出，bit0=0 强制中间值
* 输出：dac_data[9:0]— 到 DAC_D[9:0] 引脚
* FPGA：EP4CE10E22C8N
* 时钟：125MHz（pll1.c0）
* 设计：
*   - 单级流水线寄存器，对齐 clk_125m 上升沿
*   - 禁用时输出 0x200（512，10 位 DAC 半量程）
*   - 无需 DDR 原语：pll1.c1（90° 相移）提供 DAC_CLK 设置/保持
**********************************************************/
module dac_control (
    input wire          clk,
    input wire          rst_n,
    input wire  [9:0]   wf_data,
    input wire          dac_enable,
    output reg  [9:0]   dac_data
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dac_data <= 10'h200;        // 复位时输出中间值
    end
    else if (dac_enable) begin
        dac_data <= wf_data;         // 正常输出波形数据
    end
    else begin
        dac_data <= 10'h200;         // 禁用时强制中间值
    end
end

endmodule
