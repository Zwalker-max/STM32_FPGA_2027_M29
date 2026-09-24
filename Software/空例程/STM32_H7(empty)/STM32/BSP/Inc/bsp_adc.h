#ifndef __BSP_ADC_H__
#define __BSP_ADC_H__

#include "bsp.h"

#define ADC_DataSize 2004U

typedef struct {
	ADC_HandleTypeDef *hadc;
	TIM_HandleTypeDef *htim;
	__IOM bool ConvFinish;
} myADC_HandleTypeDef;

HAL_StatusTypeDef myADC_Start_DMA(myADC_HandleTypeDef *myhadc,
                                  uint16_t ADC_Data[ADC_DataSize]);
HAL_StatusTypeDef myADC_Stop_DMA(myADC_HandleTypeDef *myhadc);

//void ADC_process(uint32_t pData0[]);
//void ADC_Dual_process(uint32_t pData0[],uint32_t pData1[]);
//void ADC_Dual_Start();
//��Ҫ�õ�ʱ����ճ����bsp.c

#endif /* __BSP_ADC_H__ */
