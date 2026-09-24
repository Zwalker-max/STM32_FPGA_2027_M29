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
*   ========== ADC1 采样 (基址 0x1000) ==========
*     0x1000 - 0x1FEF   -> ADC1 采样 RAM (4080 x 16-bit)
*     0x1FF0            -> ADC_CMD  : 统一命令寄存器
*                           bit0=START, bit1=STOP, bit2=CLEAR,
*                           bit3=ADC_SEL (0=ADC1,1=ADC2),
*                           bit4=DUAL_MODE (0=single,1=dual sync)
*     0x1FF1            -> ADC_COUNT : 写入采样点数 1..4080 (默认1024)
*     0x1FF2            -> ADC1_STATUS: 读 bit0=busy, bit1=done, bit2=overflow
*     0x1FF3            -> ADC1_ACTUAL_COUNT : 实际采样点数 (只读)
*     0x1FF4            -> ADC_ID    : 固定 0x9220 (只读)
*
*   ========== ADC2 采样 (基址 0x2000) ==========
*     0x2000 - 0x2FEF   -> ADC2 采样 RAM (4080 x 16-bit)
*     0x2FF2            -> ADC2_STATUS: 读 bit0=busy, bit1=done, bit2=overflow
*     0x2FF3            -> ADC2_ACTUAL_COUNT : 实际采样点数 (只读)
**********************************************************/

module stm32_fmc_16bit (
    input wire          FMC_NE1,
    input wire          FMC_NOE,
    input wire          FMC_NWE,
    input wire [14:0]   FMC_A,
    inout wire [15:0]   FMC_D,

    input wire          clk_125m,
    input wire          adc_clk,
    input wire          rst_n,
    input wire [11:0]   adc_data,
    input wire [11:0]   adc2_data,

    output wire             wf1_wren,
    output wire  [9:0]     wf1_addr,
    output wire  [15:0]    wf1_wrdata,
    input  wire  [15:0]    wf1_rddata,

    output wire             wf2_wren,
    output wire  [9:0]     wf2_addr,
    output wire  [15:0]    wf2_wrdata,
    input  wire  [15:0]    wf2_rddata,

    output wire  [31:0]    ftw1_active,
    output wire             phase_rst1,
    output wire             dac1_enable,

    output wire  [31:0]    ftw2_active,
    output wire             phase_rst2,
    output wire             dac2_enable
);

localparam [15:0] ADC_MAX_POINTS  = 16'd4080;
localparam [14:0] ADC_CMD_ADDR    = 15'h1FF0;   // unified CMD: START/STOP/CLEAR/ADC_SEL/DUAL_MODE
localparam [14:0] ADC_COUNT_ADDR  = 15'h1FF1;
localparam [14:0] ADC1_STAT_ADDR  = 15'h1FF2;   // ADC1 status (read-only)
localparam [14:0] ADC1_ACT_ADDR   = 15'h1FF3;   // ADC1 actual count (read-only)
localparam [14:0] ADC_ID_ADDR     = 15'h1FF4;

// ADC2 address space (0x2000 – 0x2FF3)
localparam [14:0] ADC2_RAM_BASE   = 15'h2000;
localparam [14:0] ADC2_RAM_END    = 15'h2FEF;
localparam [14:0] ADC2_STAT_ADDR  = 15'h2FF2;   // ADC2 status (read-only)
localparam [14:0] ADC2_ACT_ADDR   = 15'h2FF3;   // ADC2 actual count (read-only)

// ADC_CMD bit definitions
localparam [3:0] CMD_BIT_START     = 4'd0;
localparam [3:0] CMD_BIT_STOP      = 4'd1;
localparam [3:0] CMD_BIT_CLEAR     = 4'd2;
localparam [3:0] CMD_BIT_ADC_SEL   = 4'd3;
localparam [3:0] CMD_BIT_DUAL_MODE = 4'd4;

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

wire is_adc1_ram     = (user_addr >= 15'h1000) && (user_addr <= 15'h1FEF);
wire is_adc_cmd      = (user_addr == ADC_CMD_ADDR);
wire is_adc_count    = (user_addr == ADC_COUNT_ADDR);
wire is_adc1_status  = (user_addr == ADC1_STAT_ADDR);
wire is_adc1_actual  = (user_addr == ADC1_ACT_ADDR);
wire is_adc_id       = (user_addr == ADC_ID_ADDR);

wire is_adc2_ram     = (user_addr >= ADC2_RAM_BASE) && (user_addr <= ADC2_RAM_END);
wire is_adc2_status  = (user_addr == ADC2_STAT_ADDR);
wire is_adc2_actual  = (user_addr == ADC2_ACT_ADDR);

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
reg        adc_sel_reg;        // 0=ADC1, 1=ADC2 (single mode)
reg        dual_mode_reg;      // 0=single, 1=dual sync

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        adc_count_reg    <= 16'd1024;
        adc_start_toggle <= 1'b0;
        adc_stop_toggle  <= 1'b0;
        adc_clear_toggle <= 1'b0;
        adc_sel_reg      <= 1'b0;
        dual_mode_reg    <= 1'b0;
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
            adc_sel_reg   <= user_wdata[CMD_BIT_ADC_SEL];
            dual_mode_reg <= user_wdata[CMD_BIT_DUAL_MODE];
        end
    end
end

//---------------------------------------------------
// ADC1 sample RAM: write at 10 MHz, read at 125 MHz
//---------------------------------------------------
(* ramstyle = "M9K" *) reg [15:0] adc1_ram [0:4095];

reg [15:0] adc1_rddata;

always @(posedge clk_125m) begin
    adc1_rddata <= adc1_ram[user_addr[11:0]];
end

//---------------------------------------------------
// ADC2 sample RAM: write at 10 MHz, read at 125 MHz
//---------------------------------------------------
(* ramstyle = "M9K" *) reg [15:0] adc2_ram [0:4095];

reg [15:0] adc2_rddata;

always @(posedge clk_125m) begin
    adc2_rddata <= adc2_ram[user_addr[11:0]];
end

//---------------------------------------------------
// Cross clock domain: FMC control to ADC clock
//---------------------------------------------------
reg [15:0] adc_count_sync1, adc_count_sync2;
reg start_sync1, start_sync2, start_seen;
reg stop_sync1, stop_sync2, stop_seen;
reg clear_sync1, clear_sync2, clear_seen;

reg adc_sel_sync1, adc_sel_sync2;
reg dual_mode_sync1, dual_mode_sync2;

wire adc_start_pulse = start_sync2 ^ start_seen;
wire adc_stop_pulse  = stop_sync2 ^ stop_seen;
wire adc_clear_pulse = clear_sync2 ^ clear_seen;

always @(posedge adc_clk or negedge rst_n) begin
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
        adc_sel_sync1   <= 1'b0;
        adc_sel_sync2   <= 1'b0;
        dual_mode_sync1 <= 1'b0;
        dual_mode_sync2 <= 1'b0;
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

        adc_sel_sync1   <= adc_sel_reg;
        adc_sel_sync2   <= adc_sel_sync1;
        dual_mode_sync1 <= dual_mode_reg;
        dual_mode_sync2 <= dual_mode_sync1;
    end
end

//---------------------------------------------------
// ADC sampling state machine (dual-ADC capable)
//---------------------------------------------------
reg        adc1_busy_ad;
reg        adc1_done_ad;
reg        adc1_overflow_ad;
reg [15:0] adc1_actual_count_ad;

reg        adc2_busy_ad;
reg        adc2_done_ad;
reg        adc2_overflow_ad;
reg [15:0] adc2_actual_count_ad;

reg [15:0] adc_target_count_ad;
reg [11:0] adc_wr_addr;          // shared write address for both ADCs

always @(posedge adc_clk or negedge rst_n) begin
    if (!rst_n) begin
        adc1_busy_ad         <= 1'b0;
        adc1_done_ad         <= 1'b0;
        adc1_overflow_ad     <= 1'b0;
        adc1_actual_count_ad <= 16'd0;

        adc2_busy_ad         <= 1'b0;
        adc2_done_ad         <= 1'b0;
        adc2_overflow_ad     <= 1'b0;
        adc2_actual_count_ad <= 16'd0;

        adc_target_count_ad  <= 16'd1024;
        adc_wr_addr          <= 12'd0;
    end else begin
        if (adc_clear_pulse) begin
            adc1_busy_ad         <= 1'b0;
            adc1_done_ad         <= 1'b0;
            adc1_overflow_ad     <= 1'b0;
            adc1_actual_count_ad <= 16'd0;

            adc2_busy_ad         <= 1'b0;
            adc2_done_ad         <= 1'b0;
            adc2_overflow_ad     <= 1'b0;
            adc2_actual_count_ad <= 16'd0;

            adc_wr_addr          <= 12'd0;
        end

        if (adc_start_pulse) begin
            adc1_done_ad         <= 1'b0;
            adc1_overflow_ad     <= 1'b0;
            adc1_actual_count_ad <= 16'd0;

            adc2_done_ad         <= 1'b0;
            adc2_overflow_ad     <= 1'b0;
            adc2_actual_count_ad <= 16'd0;

            adc_wr_addr          <= 12'd0;

            if (dual_mode_sync2) begin
                adc1_busy_ad <= 1'b1;
                adc2_busy_ad <= 1'b1;
            end else if (adc_sel_sync2) begin
                adc1_busy_ad <= 1'b0;
                adc2_busy_ad <= 1'b1;
            end else begin
                adc1_busy_ad <= 1'b1;
                adc2_busy_ad <= 1'b0;
            end

            if (adc_count_sync2 == 16'd0)
                adc_target_count_ad <= 16'd1;
            else if (adc_count_sync2 > ADC_MAX_POINTS)
                adc_target_count_ad <= ADC_MAX_POINTS;
            else
                adc_target_count_ad <= adc_count_sync2;

        end else if (adc1_busy_ad || adc2_busy_ad) begin

            // Write current ADC data into respective RAMs
            if (adc1_busy_ad)
                adc1_ram[adc_wr_addr] <= {4'd0, adc_data};
            if (adc2_busy_ad)
                adc2_ram[adc_wr_addr] <= {4'd0, adc2_data};

            if (adc_stop_pulse) begin
                if (adc1_busy_ad) begin
                    adc1_busy_ad         <= 1'b0;
                    adc1_done_ad         <= 1'b1;
                    adc1_actual_count_ad <= {4'd0, adc_wr_addr};
                end
                if (adc2_busy_ad) begin
                    adc2_busy_ad         <= 1'b0;
                    adc2_done_ad         <= 1'b1;
                    adc2_actual_count_ad <= {4'd0, adc_wr_addr};
                end
            end else if ({4'd0, adc_wr_addr} >= (adc_target_count_ad - 16'd1)) begin
                if (adc1_busy_ad) begin
                    adc1_busy_ad         <= 1'b0;
                    adc1_done_ad         <= 1'b1;
                    adc1_actual_count_ad <= adc_target_count_ad;
                end
                if (adc2_busy_ad) begin
                    adc2_busy_ad         <= 1'b0;
                    adc2_done_ad         <= 1'b1;
                    adc2_actual_count_ad <= adc_target_count_ad;
                end
            end else begin
                adc_wr_addr <= adc_wr_addr + 12'd1;
            end
        end
    end
end

//---------------------------------------------------
// Cross clock domain: ADC status to FMC clock
//---------------------------------------------------
reg busy1_sync1, busy1_sync2;
reg done1_sync1, done1_sync2;
reg ovf1_sync1, ovf1_sync2;
reg [15:0] actual1_sync1, actual1_sync2;

reg busy2_sync1, busy2_sync2;
reg done2_sync1, done2_sync2;
reg ovf2_sync1, ovf2_sync2;
reg [15:0] actual2_sync1, actual2_sync2;

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        busy1_sync1   <= 1'b0;
        busy1_sync2   <= 1'b0;
        done1_sync1   <= 1'b0;
        done1_sync2   <= 1'b0;
        ovf1_sync1    <= 1'b0;
        ovf1_sync2    <= 1'b0;
        actual1_sync1 <= 16'd0;
        actual1_sync2 <= 16'd0;

        busy2_sync1   <= 1'b0;
        busy2_sync2   <= 1'b0;
        done2_sync1   <= 1'b0;
        done2_sync2   <= 1'b0;
        ovf2_sync1    <= 1'b0;
        ovf2_sync2    <= 1'b0;
        actual2_sync1 <= 16'd0;
        actual2_sync2 <= 16'd0;
    end else begin
        busy1_sync1   <= adc1_busy_ad;
        busy1_sync2   <= busy1_sync1;
        done1_sync1   <= adc1_done_ad;
        done1_sync2   <= done1_sync1;
        ovf1_sync1    <= adc1_overflow_ad;
        ovf1_sync2    <= ovf1_sync1;
        actual1_sync1 <= adc1_actual_count_ad;
        actual1_sync2 <= actual1_sync1;

        busy2_sync1   <= adc2_busy_ad;
        busy2_sync2   <= busy2_sync1;
        done2_sync1   <= adc2_done_ad;
        done2_sync2   <= done2_sync1;
        ovf2_sync1    <= adc2_overflow_ad;
        ovf2_sync2    <= ovf2_sync1;
        actual2_sync1 <= adc2_actual_count_ad;
        actual2_sync2 <= actual2_sync1;
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
    else if (is_adc2_ram)
        user_rdata = adc2_rddata;
    else if (is_adc_cmd)
        user_rdata = {11'd0, dual_mode_reg, adc_sel_reg, 3'd0};
    else if (is_adc_count)
        user_rdata = adc_count_reg;
    else if (is_adc1_status)
        user_rdata = {13'd0, ovf1_sync2, done1_sync2, busy1_sync2};
    else if (is_adc1_actual)
        user_rdata = actual1_sync2;
    else if (is_adc2_status)
        user_rdata = {13'd0, ovf2_sync2, done2_sync2, busy2_sync2};
    else if (is_adc2_actual)
        user_rdata = actual2_sync2;
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
