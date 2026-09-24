#ifndef __BSP_AD9959_H__
#define __BSP_AD9959_H__

#include "bsp.h"

#define AD9959_MCLK		500000000U

typedef enum {
	AD9959_CHANNEL_0 = 0x10U,
	AD9959_CHANNEL_1 = 0x20U,
	AD9959_CHANNEL_2 = 0x40U,
	AD9959_CHANNEL_3 = 0x80U,
} AD9959_ChannelTypeDef;

void AD9959_Init(void);
void AD9959_Config(AD9959_ChannelTypeDef channel, float freq, float phase, uint32_t amp);

#endif /* __BSP_AD9959_H__ */
