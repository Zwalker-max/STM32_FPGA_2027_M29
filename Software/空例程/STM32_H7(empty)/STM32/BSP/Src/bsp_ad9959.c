#include "bsp_ad9959.h"

#define DDS_SCL_WR(x)	HAL_GPIO_WritePin(AD9959_SCL_GPIO_Port, AD9959_SCL_Pin, x)
#define DDS_SDA_WR(x)	HAL_GPIO_WritePin(AD9959_SDA_GPIO_Port, AD9959_SDA_Pin, x)
#define DDS_RST_WR(x)	HAL_GPIO_WritePin(AD9959_RST_GPIO_Port, AD9959_RST_Pin, x)
#define DDS_UPD_WR(x)	HAL_GPIO_WritePin(AD9959_UPD_GPIO_Port, AD9959_UPD_Pin, x)
#define DDS_CS_WR(x)	HAL_GPIO_WritePin(AD9959_CS_GPIO_Port,  AD9959_CS_Pin,  x)

static void DDS_WR(uint8_t data)
{
	for (uint8_t i = 0; i < 8; ++i)
	{
		DDS_SDA_WR(data & (0x80 >> i));
		DDS_SCL_WR(1);
		DDS_SCL_WR(0);
	}
	
	DDS_UPD_WR(1);
	DDS_UPD_WR(0);
}

void DDS_Init(void)
{
	DDS_RST_WR(1);
	DDS_RST_WR(0);
	HAL_Delay(5);
	
	DDS_CS_WR(0);
	
	DDS_WR(0x01);
	DDS_WR(0xD0);
	DDS_WR(0x00);
	DDS_WR(0x00);
	
	DDS_WR(0x02);
	DDS_WR(0x20);
	DDS_WR(0x00);
	
	DDS_WR(0x06);
	DDS_WR(0x00);
	DDS_WR(0x13);
	DDS_WR(0xFF);
	
	DDS_CS_WR(1);
}

void DDS_Config(DDS_ChannelTypeDef channel, float freq, float phase, uint32_t amp)
{
	uint32_t regf = freq  * (1ULL << 32) / 500e6 + .5f;
	uint32_t regp = phase * (1ULL << 14) / 360   + .5f;
	uint32_t rega = amp   & 0x03FFU | 0x1000U;
	
	DDS_CS_WR(0);
	
	DDS_WR(0x00);
	DDS_WR(channel);
	
	DDS_WR(0x04);
	DDS_WR(regf >> 24);
	DDS_WR(regf >> 16);
	DDS_WR(regf >> 8 );
	DDS_WR(regf >> 0 );
	
	DDS_WR(0x05);
	DDS_WR(regp >> 8 );
	DDS_WR(regp >> 0 );
	
	DDS_WR(0x06);
	DDS_WR(rega >> 16);
	DDS_WR(rega >> 8 );
	DDS_WR(rega >> 0 );
	
	DDS_CS_WR(1);
}