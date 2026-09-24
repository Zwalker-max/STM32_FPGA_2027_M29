/*********************************************************
* 模块：STM32H7 FMC 异步从机接口
* 功能：32768 × 16bit 寄存器组（32K个16位寄存器）
* FPGA：EP4CE10E22
* FPGA时钟：125MHz
* FMC总线：16bit 数据 / 15bit 地址 / 无NBL / NE1 NOE NWE
**********************************************************/

module stm32_fmc_16bit (
	//FMC 硬件接口
	input wire FMC_NE1,				//片选 低有效
	input wire FMC_NOE,				//读使能 低有效
	input wire FMC_NWE,				//写使能 低有效

	input wire [14:0] FMC_A,		//15bit 地址
	inout wire [15:0] FMC_D,		//16bit 数据

	//FPGA 125MHz 时钟（必须来自PLL，不是外部50M直接输入）
	input wire clk_125m,
	input wire rst_n					//低电平复位
);

//---------------------------------------------------
//异步控制信号 两级同步（防亚稳态）
//---------------------------------------------------
reg ne1_sync1, ne1_sync2;
reg noe_sync1, noe_sync2;
reg nwe_sync1, nwe_sync2;
reg [14:0] addr_sync1, addr_sync2;

always @(posedge clk_125m or negedge rst_n)
begin
	if(!rst_n)
	begin
		ne1_sync1 <= 1'b1;
		ne1_sync2 <= 1'b1;
		noe_sync1 <= 1'b1;
		noe_sync2 <= 1'b1;
		nwe_sync1 <= 1'b1;
		nwe_sync2 <= 1'b1;
		addr_sync1 <= 15'd0;
		addr_sync2 <= 15'd0;
	end
	else
	begin
		ne1_sync1 <= FMC_NE1;
		ne1_sync2 <= ne1_sync1;
		noe_sync1 <= FMC_NOE;
		noe_sync2 <= noe_sync1;
		nwe_sync1 <= FMC_NWE;
		nwe_sync2 <= nwe_sync1;
		addr_sync1 <= FMC_A;
		addr_sync2 <= addr_sync1;
	end
end

//---------------------------------------------------
//读写使能（稳定无毛刺）
//---------------------------------------------------
wire cs_valid = ~ne1_sync2;
wire user_wr_en = cs_valid & ~nwe_sync2;
wire user_rd_en = cs_valid & ~noe_sync2;
wire [14:0] user_addr = addr_sync2;

//---------------------------------------------------
//三态总线控制
//---------------------------------------------------
reg [15:0] user_rdata;
assign FMC_D = user_rd_en ? user_rdata : 16'hzzzz;
wire [15:0] user_wdata = FMC_D;

//---------------------------------------------------
//32768 × 16bit 寄存器组
//---------------------------------------------------
(* ramstyle = "M9K" *) reg [15:0] ram [0:19999];

//写操作
always @(posedge clk_125m or negedge rst_n)
begin
	if(!rst_n)
	begin
		//复位时可不处理
	end
	else if(user_wr_en)
	begin
		ram[user_addr] <= user_wdata;
	end
end

//读操作
always @(*)
begin
	user_rdata = ram[user_addr];
end

endmodule
