/*********************************************************
* Module: stm32_fmc_16bit
* Function:
*   STM32H7 FMC asynchronous 16-bit slave interface.
*
*   ========== DAC1 波形 & DDS 控制 (基址 0x0000) ==========
*     0x0000 - 0x03FF   -> DAC1 波形 RAM (1024 x 16-bit)
*     0x0400            -> FTW1 影子寄存器 [15:0]
*     0x0401            -> FTW1 影子寄存器 [31:16]
*     0x0404            -> FTW1 更新触发 (写任意值)
*     0x0408            -> 相位复位脉冲1 (写任意值)
*     0x040C            -> DAC 使能控制位 (bit0=DAC1, bit1=DAC2)
*
*   ========== DAC2 波形 & DDS 控制 (基址 0x0800) ==========
*     0x0800 - 0x0BFF   -> DAC2 波形 RAM (1024 x 16-bit)
*     0x0C00            -> FTW2 影子寄存器 [15:0]
*     0x0C01            -> FTW2 影子寄存器 [31:16]
*     0x0C04            -> FTW2 更新触发 (写任意值)
*     0x0C08            -> 相位复位脉冲2 (写任意值)
*
*   ========== ADC1 采样 (FIR 滤波后) (基址 0x2000) ==========
*     0x2000 - 0x3FFF   -> ADC1 采样 RAM (8192 x 16-bit, 有符号)
*     0x4000            -> ADC_CMD  : bit0=START, bit1=STOP, bit2=CLEAR
*     0x4001            -> ADC_COUNT : 写入采样点数 1..8192 (默认1024)
*     0x4002            -> ADC_STATUS: 读 bit0=busy, bit1=done, bit2=overflow
*     0x4003            -> ADC_ACTUAL_COUNT : 实际采样点数 (只读)
*     0x4004            -> ADC_ID    : 固定 0x9220 (只读)
*
*   说明: 单 ADC (AD9220) 通路。AD9220 偏移二进制 -> 补码 (MSB 取反)
*   -> 符号扩展到 19 位 -> FIR II IP (50MHz 时钟, 10Msps, 12b 输入 / 16b 输出)
*   -> ast_source_valid 有效时写入 8192x16 双时钟双口 RAM (写口 50MHz,
*   读口 125MHz)。
**********************************************************/

module stm32_fmc_16bit (
    input wire          FMC_NE1,
    input wire          FMC_NOE,
    input wire          FMC_NWE,
    input wire [14:0]   FMC_A,
    inout wire [15:0]   FMC_D,

    input wire          clk_125m,
    input wire          adc_clk,        // 10 MHz ADC clock (pll1.c2)
    input wire          clk_fir_50m,    // 50 MHz FIR clock    (pll1.c3)
    input wire          rst_n,
    input wire [11:0]   adc_data,       // AD9220, 12-bit offset binary

    output wire             wf1_wren,
    output wire  [9:0]      wf1_addr,
    output wire  [15:0]     wf1_wrdata,
    input  wire  [15:0]     wf1_rddata,

    output wire             wf2_wren,
    output wire  [9:0]      wf2_addr,
    output wire  [15:0]     wf2_wrdata,
    input  wire  [15:0]     wf2_rddata,

    output wire  [31:0]     ftw1_active,
    output wire             phase_rst1,
    output wire             dac1_enable,

    output wire  [31:0]     ftw2_active,
    output wire             phase_rst2,
    output wire             dac2_enable
);

localparam [15:0] ADC_MAX_POINTS  = 16'd8192;
localparam [14:0] ADC_CMD_ADDR    = 15'h4000;   // unified CMD: START/STOP/CLEAR
localparam [14:0] ADC_COUNT_ADDR  = 15'h4001;
localparam [14:0] ADC1_STAT_ADDR   = 15'h4002;   // status (read-only)
localparam [14:0] ADC1_ACT_ADDR    = 15'h4003;   // actual count (read-only)
localparam [14:0] ADC_ID_ADDR      = 15'h4004;

// ADC_CMD bit definitions
localparam [3:0] CMD_BIT_START = 4'd0;
localparam [3:0] CMD_BIT_STOP  = 4'd1;
localparam [3:0] CMD_BIT_CLEAR = 4'd2;

// 诊断旁路: 1 = 跳过 FIR，把原始 ADC 有符号 12 位(符号扩展到 16 位)直接写 RAM。
// 用于定位"只有负值和0"是出在 FIR 量化环节还是 ADC/传输环节。定位后改回 0。
localparam BYPASS_FIR = 1'b0;

//---------------------------------------------------
// Synchronize asynchronous FMC control signals
//---------------------------------------------------
reg ne1_sync1, ne1_sync2;
reg noe_sync1, noe_sync2;
reg nwe_sync1, nwe_sync2;
reg [14:0] addr_sync1, addr_sync2;

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        ne1_sync1  <= 1'b1;
        ne1_sync2  <= 1'b1;
        noe_sync1  <= 1'b1;
        noe_sync2  <= 1'b1;
        nwe_sync1  <= 1'b1;
        nwe_sync2  <= 1'b1;
        addr_sync1 <= 15'd0;
        addr_sync2 <= 15'd0;
    end else begin
        ne1_sync1  <= FMC_NE1;
        ne1_sync2  <= ne1_sync1;
        noe_sync1  <= FMC_NOE;
        noe_sync2  <= noe_sync1;
        nwe_sync1  <= FMC_NWE;
        nwe_sync2  <= nwe_sync1;
        addr_sync1 <= FMC_A;
        addr_sync2 <= addr_sync1;
    end
end

wire cs_valid    = ~ne1_sync2;
wire user_wr_en  = cs_valid & ~nwe_sync2;
wire user_rd_en  = cs_valid & ~noe_sync2;
wire [14:0] user_addr = addr_sync2;

reg user_wr_en_d;
reg user_rd_en_d;

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        user_wr_en_d <= 1'b0;
        user_rd_en_d <= 1'b0;
    end else begin
        user_wr_en_d <= user_wr_en;
        user_rd_en_d <= user_rd_en;
    end
end

wire user_wr_stb = user_wr_en & ~user_wr_en_d;
wire user_rd_stb = user_rd_en & ~user_rd_en_d;

//---------------------------------------------------
// Tri-state FMC data bus
//---------------------------------------------------
reg [15:0] user_rdata;
assign FMC_D = user_rd_en ? user_rdata : 16'hzzzz;
wire [15:0] user_wdata = FMC_D;

//---------------------------------------------------
// Address decode
//---------------------------------------------------
wire is_wf1_ram      = (user_addr[14:10] == 5'd0);
wire is_wf2_ram      = (user_addr[14:10] == 5'b00010);    /* 0x0800-0x0BFF */

wire is_ftw1_lo      = (user_addr == 15'h0400);
wire is_ftw1_hi      = (user_addr == 15'h0401);
wire is_update1      = (user_addr == 15'h0404);
wire is_ph_rst1      = (user_addr == 15'h0408);
wire is_dac_ctrl     = (user_addr == 15'h040C);

wire is_ftw2_lo      = (user_addr == 15'h0C00);
wire is_ftw2_hi      = (user_addr == 15'h0C01);
wire is_update2      = (user_addr == 15'h0C04);
wire is_ph_rst2      = (user_addr == 15'h0C08);

wire is_adc1_ram     = (user_addr[14:13] == 2'b01);   /* 0x2000-0x3FFF */
wire is_adc_cmd      = (user_addr == ADC_CMD_ADDR);
wire is_adc_count    = (user_addr == ADC_COUNT_ADDR);
wire is_adc1_status  = (user_addr == ADC1_STAT_ADDR);
wire is_adc1_actual  = (user_addr == ADC1_ACT_ADDR);
wire is_adc_id       = (user_addr == ADC_ID_ADDR);

//---------------------------------------------------
// Waveform RAM bridge (DAC1 + DAC2)
//---------------------------------------------------
assign wf1_wren   = user_wr_stb & is_wf1_ram;
assign wf1_addr   = user_addr[9:0];
assign wf1_wrdata = user_wdata;

assign wf2_wren   = user_wr_stb & is_wf2_ram;
assign wf2_addr   = user_addr[9:0];
assign wf2_wrdata = user_wdata;

//---------------------------------------------------
// DDS control registers (DAC1 + DAC2)
//---------------------------------------------------
reg [31:0] ftw1_shadow;
reg [31:0] ftw1_active_reg;
reg        phase_rst1_reg;
reg        dac1_enable_reg;

reg [31:0] ftw2_shadow;
reg [31:0] ftw2_active_reg;
reg        phase_rst2_reg;
reg        dac2_enable_reg;

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        ftw1_shadow     <= 32'd0;
        ftw1_active_reg <= 32'd0;
        phase_rst1_reg  <= 1'b0;
        dac1_enable_reg <= 1'b0;

        ftw2_shadow     <= 32'd0;
        ftw2_active_reg <= 32'd0;
        phase_rst2_reg  <= 1'b0;
        dac2_enable_reg <= 1'b0;
    end else begin
        phase_rst1_reg <= 1'b0;
        phase_rst2_reg <= 1'b0;

        if (user_wr_stb) begin
            if (is_ftw1_lo)
                ftw1_shadow[15:0] <= user_wdata;
            else if (is_ftw1_hi)
                ftw1_shadow[31:16] <= user_wdata;
            else if (is_update1)
                ftw1_active_reg <= ftw1_shadow;
            else if (is_ph_rst1)
                phase_rst1_reg <= 1'b1;
            else if (is_dac_ctrl) begin
                dac1_enable_reg <= user_wdata[0];
                dac2_enable_reg <= user_wdata[1];
            end
            else if (is_ftw2_lo)
                ftw2_shadow[15:0] <= user_wdata;
            else if (is_ftw2_hi)
                ftw2_shadow[31:16] <= user_wdata;
            else if (is_update2)
                ftw2_active_reg <= ftw2_shadow;
            else if (is_ph_rst2)
                phase_rst2_reg <= 1'b1;
        end
    end
end

//---------------------------------------------------
// ADC control registers in FMC clock domain
//---------------------------------------------------
reg [15:0] adc_count_reg;
reg        adc_start_toggle;
reg        adc_stop_toggle;
reg        adc_clear_toggle;

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        adc_count_reg    <= 16'd1024;
        adc_start_toggle <= 1'b0;
        adc_stop_toggle  <= 1'b0;
        adc_clear_toggle <= 1'b0;
    end else if (user_wr_stb) begin
        if (is_adc_count) begin
            if (user_wdata == 16'd0)
                adc_count_reg <= 16'd1;
            else if (user_wdata > ADC_MAX_POINTS)
                adc_count_reg <= ADC_MAX_POINTS;
            else
                adc_count_reg <= user_wdata;
        end else if (is_adc_cmd) begin
            if (user_wdata[CMD_BIT_START])
                adc_start_toggle <= ~adc_start_toggle;
            if (user_wdata[CMD_BIT_STOP])
                adc_stop_toggle <= ~adc_stop_toggle;
            if (user_wdata[CMD_BIT_CLEAR])
                adc_clear_toggle <= ~adc_clear_toggle;
        end
    end
end

//===========================================================
//  ADC1 + FIR capture — all in clk_fir_50m domain
//===========================================================

// AD9220 offset binary -> 2's complement (invert MSB)
wire [11:0] adc_signed = {~adc_data[11], adc_data[10:0]};

// FIR II sink (per UG-0107220): ast_sink_data[11:0] = 12-bit sample data,
// ast_sink_data[18:12] = coefficient-bank-select (bank width = ceil(log2(121)) = 7).
// bankCount=121 -> valid banks 0..120 are EMPTY; an out-of-range bank (>=121)
// falls back to the loaded coefficient set. So drive bank = 0x7F (127) for ALL
// samples, putting adc_signed in [11:0]. Do NOT sign-extend into [18:12] --
// that routes +/- halves to different banks and produces a half-wave.
localparam [6:0] FIR_BANK = 7'h48;     // out-of-range -> loaded coefficient set
wire [18:0] fir_sink_data = {FIR_BANK, adc_signed};

// Bring 10 MHz ADC clock into 50 MHz domain and edge-detect for sample tick
reg adc_clk_s1, adc_clk_s2, adc_clk_s3;
always @(posedge clk_fir_50m or negedge rst_n) begin
    if (!rst_n) begin
        adc_clk_s1 <= 1'b0;
        adc_clk_s2 <= 1'b0;
        adc_clk_s3 <= 1'b0;
    end else begin
        adc_clk_s1 <= adc_clk;
        adc_clk_s2 <= adc_clk_s1;
        adc_clk_s3 <= adc_clk_s2;
    end
end
wire sample_tick = adc_clk_s2 & ~adc_clk_s3;   // 1 pulse per 10 MHz period

wire [15:0] fir_out_data;
wire        fir_out_valid;

reg         cap_busy;
reg  [12:0] cap_wr_addr;

//---------------------------------------------------
// FIR II IP instance (single-rate, 12b signed in, 16b signed out)
//---------------------------------------------------
FIR1 u_fir (
    .clk              (clk_fir_50m),
    .reset_n          (rst_n),
    .ast_sink_data    (fir_sink_data),
    .ast_sink_valid   (cap_busy & sample_tick),
    .ast_sink_error   (2'b00),
    .ast_source_data  (fir_out_data),
    .ast_source_valid (fir_out_valid),
    .ast_source_error ()
);

//---------------------------------------------------
// Cross clock domain: FMC (125MHz) -> FIR (50MHz) for count + start/stop/clear
//---------------------------------------------------
reg [15:0] adc_count_sync1, adc_count_sync2;
reg start_sync1, start_sync2, start_seen;
reg stop_sync1, stop_sync2, stop_seen;
reg clear_sync1, clear_sync2, clear_seen;

wire adc_start_pulse = start_sync2 ^ start_seen;
wire adc_stop_pulse  = stop_sync2 ^ stop_seen;
wire adc_clear_pulse = clear_sync2 ^ clear_seen;

always @(posedge clk_fir_50m or negedge rst_n) begin
    if (!rst_n) begin
        adc_count_sync1 <= 16'd1024;
        adc_count_sync2 <= 16'd1024;
        start_sync1 <= 1'b0;
        start_sync2 <= 1'b0;
        start_seen  <= 1'b0;
        stop_sync1  <= 1'b0;
        stop_sync2  <= 1'b0;
        stop_seen   <= 1'b0;
        clear_sync1 <= 1'b0;
        clear_sync2 <= 1'b0;
        clear_seen  <= 1'b0;
    end else begin
        adc_count_sync1 <= adc_count_reg;
        adc_count_sync2 <= adc_count_sync1;

        start_sync1 <= adc_start_toggle;
        start_sync2 <= start_sync1;
        if (adc_start_pulse)
            start_seen <= start_sync2;

        stop_sync1 <= adc_stop_toggle;
        stop_sync2 <= stop_sync1;
        if (adc_stop_pulse)
            stop_seen <= stop_sync2;

        clear_sync1 <= adc_clear_toggle;
        clear_sync2 <= clear_sync1;
        if (adc_clear_pulse)
            clear_seen <= clear_sync2;
    end
end

//---------------------------------------------------
// ADC1 sample RAM: write at 50 MHz (FIR out), read at 125 MHz (FMC)
//---------------------------------------------------
(* ramstyle = "M9K" *) reg [15:0] adc1_ram [0:8191];

reg [15:0] adc1_rddata;

// Write port (50 MHz FIR domain)
// 诊断旁路: BYPASS_FIR=1 时跳过 FIR，直接写原始 ADC 有符号数据
wire adc_wr_strobe      = BYPASS_FIR ? (cap_busy & sample_tick) : (fir_out_valid & cap_busy);
wire [15:0] adc_ram_wrdata = BYPASS_FIR ? {{4{adc_signed[11]}}, adc_signed} : fir_out_data;

always @(posedge clk_fir_50m) begin
    if (adc_wr_strobe)
        adc1_ram[cap_wr_addr] <= adc_ram_wrdata;
end

// Read port (125 MHz FMC domain)
always @(posedge clk_125m) begin
    adc1_rddata <= adc1_ram[user_addr[12:0]];
end

//---------------------------------------------------
// ADC capture state machine (50 MHz FIR domain)
//---------------------------------------------------
reg         cap_done_ad;
reg         cap_overflow_ad;
reg [15:0]  cap_actual_count_ad;
reg [15:0]  cap_target_count_ad;

always @(posedge clk_fir_50m or negedge rst_n) begin
    if (!rst_n) begin
        cap_busy            <= 1'b0;
        cap_done_ad         <= 1'b0;
        cap_overflow_ad     <= 1'b0;
        cap_actual_count_ad <= 16'd0;
        cap_target_count_ad <= 16'd1024;
        cap_wr_addr         <= 13'd0;
    end else begin
        if (adc_clear_pulse) begin
            cap_busy            <= 1'b0;
            cap_done_ad         <= 1'b0;
            cap_overflow_ad     <= 1'b0;
            cap_actual_count_ad <= 16'd0;
            cap_wr_addr         <= 13'd0;
        end

        if (adc_start_pulse) begin
            cap_done_ad         <= 1'b0;
            cap_overflow_ad     <= 1'b0;
            cap_actual_count_ad <= 16'd0;
            cap_wr_addr         <= 13'd0;
            cap_busy            <= 1'b1;

            if (adc_count_sync2 == 16'd0)
                cap_target_count_ad <= 16'd1;
            else if (adc_count_sync2 > ADC_MAX_POINTS)
                cap_target_count_ad <= ADC_MAX_POINTS;
            else
                cap_target_count_ad <= adc_count_sync2;
        end else if (cap_busy) begin
            if (adc_stop_pulse) begin
                cap_busy            <= 1'b0;
                cap_done_ad         <= 1'b1;
                cap_actual_count_ad <= {3'd0, cap_wr_addr};
            end else if (adc_wr_strobe) begin
                if ({3'd0, cap_wr_addr} >= (cap_target_count_ad - 16'd1)) begin
                    cap_busy            <= 1'b0;
                    cap_done_ad         <= 1'b1;
                    cap_actual_count_ad <= cap_target_count_ad;
                end else begin
                    cap_wr_addr <= cap_wr_addr + 13'd1;
                end
            end
        end
    end
end

//---------------------------------------------------
// Cross clock domain: ADC status (50 MHz) -> FMC (125 MHz)
//---------------------------------------------------
reg busy_sync1, busy_sync2;
reg done_sync1, done_sync2;
reg ovf_sync1, ovf_sync2;
reg [15:0] actual_sync1, actual_sync2;

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        busy_sync1   <= 1'b0;
        busy_sync2   <= 1'b0;
        done_sync1   <= 1'b0;
        done_sync2   <= 1'b0;
        ovf_sync1    <= 1'b0;
        ovf_sync2    <= 1'b0;
        actual_sync1 <= 16'd0;
        actual_sync2 <= 16'd0;
    end else begin
        busy_sync1   <= cap_busy;
        busy_sync2   <= busy_sync1;
        done_sync1   <= cap_done_ad;
        done_sync2   <= done_sync1;
        ovf_sync1    <= cap_overflow_ad;
        ovf_sync2    <= ovf_sync1;
        actual_sync1 <= cap_actual_count_ad;
        actual_sync2 <= actual_sync1;
    end
end

//---------------------------------------------------
// Read data MUX
//---------------------------------------------------
always @(*) begin
    if (is_wf1_ram)
        user_rdata = wf1_rddata;
    else if (is_wf2_ram)
        user_rdata = wf2_rddata;
    else if (is_ftw1_lo)
        user_rdata = ftw1_shadow[15:0];
    else if (is_ftw1_hi)
        user_rdata = ftw1_shadow[31:16];
    else if (is_dac_ctrl)
        user_rdata = {14'd0, dac2_enable_reg, dac1_enable_reg};
    else if (is_ftw2_lo)
        user_rdata = ftw2_shadow[15:0];
    else if (is_ftw2_hi)
        user_rdata = ftw2_shadow[31:16];
    else if (is_adc1_ram)
        user_rdata = adc1_rddata;
    else if (is_adc_cmd)
        user_rdata = 16'd0;
    else if (is_adc_count)
        user_rdata = adc_count_reg;
    else if (is_adc1_status)
        user_rdata = {13'd0, ovf_sync2, done_sync2, busy_sync2};
    else if (is_adc1_actual)
        user_rdata = actual_sync2;
    else if (is_adc_id)
        user_rdata = 16'h9220;
    else
        user_rdata = 16'd0;
end

assign ftw1_active = ftw1_active_reg;
assign phase_rst1  = phase_rst1_reg;
assign dac1_enable = dac1_enable_reg;

assign ftw2_active = ftw2_active_reg;
assign phase_rst2  = phase_rst2_reg;
assign dac2_enable = dac2_enable_reg;

endmodule
