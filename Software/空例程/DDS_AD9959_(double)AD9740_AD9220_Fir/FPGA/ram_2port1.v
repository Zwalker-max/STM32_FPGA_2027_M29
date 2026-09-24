/*********************************************************
* 模块：ram_2port1
* 功能：1024 × 16bit 双端口波形 RAM（M9K 推断式）
* Port A：STM32 FMC 写 + 读（寄存读，M9K 推断可靠）
* Port B：DDS core 只读（寄存读）
* FPGA：EP4CE10E22C8N
* 时钟：125MHz（pll1.c0）
**********************************************************/
module ram_2port1 (
    input wire          clk,

    // Port A：STM32 FMC 访问（写 + 组合逻辑读）
    input wire          wren_a,
    input wire  [9:0]   address_a,
    input wire  [15:0]  data_a,
    output reg  [15:0]  q_a,            // 寄存读（M9K 推断可靠）

    // Port B：DDS core 只读（寄存读）
    input wire  [9:0]   address_b,
    output reg  [15:0]  q_b
);

// 推断式 M9K 双端口 RAM
// 1024 深度 × 16 位宽，2 个 M9K 块（EP4CE10 共 46 个）
(* ramstyle = "M9K" *) reg [15:0] mem [0:1023];

// Port A：同步写 + 同步寄存读
always @(posedge clk) begin
    if (wren_a)
        mem[address_a] <= data_a;
    q_a <= mem[address_a];
end

// Port B：同步寄存读（DDS core 无需组合读）
always @(posedge clk) begin
    q_b <= mem[address_b];
end

endmodule
