#ifndef __BSP_ADC_H__
#define __BSP_ADC_H__

#include "bsp.h"

#define ADC_DataSize 2004

typedef struct {
	ADC_HandleTypeDef *hadc;
	TIM_HandleTypeDef *htim;
	__IOM bool ConvFinish;
} myADC_HandleTypeDef;

void myADC_Start_DMA(myADC_HandleTypeDef *myhadc , uint32_t ADC_Data[ADC_DataSize]);
void myADC_Start_DMA_alter(myADC_HandleTypeDef *myhadc,uint32_t ADC_Data[10000]);
void myADC_Stop_DMA(myADC_HandleTypeDef *myhadc);

//void ADC_process(uint32_t pData0[]);
//void ADC_Dual_process(uint32_t pData0[],uint32_t pData1[]);
//void ADC_Dual_Start();
//需要用的时候复制粘贴到bsp.c

#endif /* __BSP_ADC_H__ */
