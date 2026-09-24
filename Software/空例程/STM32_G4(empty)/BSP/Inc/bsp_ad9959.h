#ifndef __BSP_AD9959_H__
#define __BSP_AD9959_H__

#include "bsp.h"

typedef enum {
	DDS_CHANNEL_0 = 0x10U,
	DDS_CHANNEL_1 = 0x20U,
	DDS_CHANNEL_2 = 0x40U,
	DDS_CHANNEL_3 = 0x80U,
} DDS_ChannelTypeDef;

void DDS_Init(void);
void DDS_Config(DDS_ChannelTypeDef channel, float freq, float phase, uint32_t amp);


#endif /* __BSP_AD9959_H__ */
