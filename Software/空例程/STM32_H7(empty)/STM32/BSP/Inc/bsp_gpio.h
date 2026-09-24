#ifndef __BSP_GPIO_H__
#define __BSP_GPIO_H__

#include "bsp.h"

/* Active-low keys, matching the CubeMX labels in Core/Inc/main.h. */
#define KEY_1_Trigger	(HAL_GPIO_ReadPin(KEY_S1_GPIO_Port, KEY_S1_Pin) == GPIO_PIN_RESET)
#define KEY_2_Trigger	(HAL_GPIO_ReadPin(KEY_S2_GPIO_Port, KEY_S2_Pin) == GPIO_PIN_RESET)
#define KEY_3_Trigger	(HAL_GPIO_ReadPin(KEY_S3_GPIO_Port, KEY_S3_Pin) == GPIO_PIN_RESET)
#define KEY_4_Trigger	(HAL_GPIO_ReadPin(KEY_S4_GPIO_Port, KEY_S4_Pin) == GPIO_PIN_RESET)

uint8_t KEY_Read(void);

#endif /* __BSP_GPIO_H__ */
