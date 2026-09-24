#ifndef __BSP_GPIO_H__
#define __BSP_GPIO_H__

#include "bsp.h"

#define LED_R_On		HAL_GPIO_WritePin(LED_R_GPIO_Port, LED_R_Pin, GPIO_PIN_RESET)
#define LED_G_On		HAL_GPIO_WritePin(LED_G_GPIO_Port, LED_G_Pin, GPIO_PIN_RESET)
#define LED_B_On		HAL_GPIO_WritePin(LED_B_GPIO_Port, LED_B_Pin, GPIO_PIN_RESET)

#define LED_R_Off		HAL_GPIO_WritePin(LED_R_GPIO_Port, LED_R_Pin, GPIO_PIN_SET)
#define LED_G_Off		HAL_GPIO_WritePin(LED_G_GPIO_Port, LED_G_Pin, GPIO_PIN_SET)
#define LED_B_Off		HAL_GPIO_WritePin(LED_B_GPIO_Port, LED_B_Pin, GPIO_PIN_SET)

#define LED_R_Toggle	HAL_GPIO_TogglePin(LED_R_GPIO_Port, LED_R_Pin)
#define LED_G_Toggle	HAL_GPIO_TogglePin(LED_G_GPIO_Port, LED_G_Pin)
#define LED_B_Toggle	HAL_GPIO_TogglePin(LED_B_GPIO_Port, LED_B_Pin)

#define KEY_1_Trigger	(HAL_GPIO_ReadPin(KEY1_GPIO_Port, KEY1_Pin) == 0)
#define KEY_2_Trigger	(HAL_GPIO_ReadPin(KEY2_GPIO_Port, KEY2_Pin) == 0)
#define KEY_3_Trigger	(HAL_GPIO_ReadPin(KEY3_GPIO_Port, KEY3_Pin) == 0)
#define KEY_4_Trigger	(HAL_GPIO_ReadPin(KEY4_GPIO_Port, KEY4_Pin) == 0)

uint8_t KEY_Read(void);

#endif /* __BSP_GPIO_H__ */
