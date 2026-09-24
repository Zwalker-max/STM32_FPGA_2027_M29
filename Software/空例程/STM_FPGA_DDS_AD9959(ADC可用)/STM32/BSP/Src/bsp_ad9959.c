#include "bsp_ad9959.h"

#define AD9959_SCL_WR(x)	HAL_GPIO_WritePin(AD9959_SCL_GPIO_Port, AD9959_SCL_Pin, x)
#define AD9959_SDA_WR(x)	HAL_GPIO_WritePin(AD9959_SDA_GPIO_Port, AD9959_SDA_Pin, x)
#define AD9959_UPD_WR(x)	HAL_GPIO_WritePin(AD9959_UPD_GPIO_Port, AD9959_UPD_Pin, x)
#define AD9959_RST_WR(x)	HAL_GPIO_WritePin(AD9959_RST_GPIO_Port, AD9959_RST_Pin, x)
#define AD9959_CS_WR(x)		HAL_GPIO_WritePin(AD9959_CS_GPIO_Port,  AD9959_CS_Pin,  x)

static void AD9959_Transmit(uint8_t byteNum, uint32_t data)
{
	for (uint32_t idx = 1UL << (byteNum * 8 - 1); idx; idx >>= 1)
	{
		AD9959_SDA_WR(data & idx ? 1 : 0);
		AD9959_SCL_WR(1);
		AD9959_SCL_WR(0);
	}
}

void AD9959_Init(void)
{
	AD9959_RST_WR(1);
	AD9959_RST_WR(0);
	HAL_Delay(5);
	
	AD9959_CS_WR(0);
	
	AD9959_Transmit(1, 0x01);
	AD9959_Transmit(3, 0xD00000);
	
	AD9959_Transmit(1, 0x02);
	AD9959_Transmit(2, 0x2000);
	
	AD9959_Transmit(1, 0x06);
	AD9959_Transmit(3, 0x0013FF);
	
	AD9959_CS_WR(1);
}

void AD9959_Config(AD9959_ChannelTypeDef channel, float freq, float phase, uint32_t amp)
{
	uint32_t regf = freq  * (1ULL << 32) / AD9959_MCLK + .5f;
	uint32_t regp = phase * (1ULL << 14) / 360         + .5f;
	uint32_t rega = amp   & 0x03FFU | 0x1000U;
	
	AD9959_CS_WR(0);
	
	AD9959_Transmit(1, 0x00);
	AD9959_Transmit(1, channel);
	
	AD9959_Transmit(1, 0x04);
	AD9959_Transmit(4, regf);
	
	AD9959_Transmit(1, 0x05);
	AD9959_Transmit(2, regp);
	
	AD9959_Transmit(1, 0x06);
	AD9959_Transmit(3, rega);
	
	AD9959_UPD_WR(1);
	AD9959_UPD_WR(0);
	
	AD9959_CS_WR(1);
}
