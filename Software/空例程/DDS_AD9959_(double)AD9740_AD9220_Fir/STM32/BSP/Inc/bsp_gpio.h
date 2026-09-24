#ifndef __BSP_GPIO_H__
#define __BSP_GPIO_H__

#include "bsp.h"

#define KEY_S1_ACTIVE	(HAL_GPIO_ReadPin(KEY_S1_GPIO_Port, KEY_S1_Pin) == 0)
#define KEY_S2_ACTIVE	(HAL_GPIO_ReadPin(KEY_S2_GPIO_Port, KEY_S2_Pin) == 0)
#define KEY_S3_ACTIVE	(HAL_GPIO_ReadPin(KEY_S3_GPIO_Port, KEY_S3_Pin) == 0)
#define KEY_S4_ACTIVE	(HAL_GPIO_ReadPin(KEY_S4_GPIO_Port, KEY_S4_Pin) == 0)

#define KEY_TH_TAP		10U
#define KEY_TH_HOLD		40U
#define KEY_TH_WAIT		10U

#define KEY_FLAG_TAP	0x10U
#define KEY_FLAG_HOLD	0x20U
#define KEY_FLAG_DOUBLE	0x40U

#define KEY_NUM_S1		0x01U
#define KEY_NUM_S2		0x02U
#define KEY_NUM_S3		0x04U
#define KEY_NUM_S4		0x08U

typedef enum {
	KEY_NONE    = 0x00U,
	KEY_S1_TAP  = KEY_FLAG_TAP  | KEY_NUM_S1,
	KEY_S2_TAP  = KEY_FLAG_TAP  | KEY_NUM_S2,
	KEY_S3_TAP  = KEY_FLAG_TAP  | KEY_NUM_S3,
	KEY_S4_TAP  = KEY_FLAG_TAP  | KEY_NUM_S4,
	KEY_S1_HOLD = KEY_FLAG_HOLD | KEY_NUM_S1,
	KEY_S2_HOLD = KEY_FLAG_HOLD | KEY_NUM_S2,
	KEY_S3_HOLD = KEY_FLAG_HOLD | KEY_NUM_S3,
	KEY_S4_HOLD = KEY_FLAG_HOLD | KEY_NUM_S4,
} KEY_LegalStatusTypeDef;

uint8_t KEY_Read(void);
uint8_t KEYEx_Read(void);

#endif /* __BSP_GPIO_H__ */
