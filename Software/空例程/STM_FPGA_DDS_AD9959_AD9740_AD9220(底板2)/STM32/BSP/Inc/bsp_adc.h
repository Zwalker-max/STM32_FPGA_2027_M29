#ifndef __BSP_ADC_H__
#define __BSP_ADC_H__

#include "bsp.h"

#define ADC_DataSize 1024
#define ADC_MasterDataSize 1024
#define ADC_SlaveDataSize 1024

typedef struct {
    ADC_HandleTypeDef *hadc;
    TIM_HandleTypeDef *htim;
    volatile uint32_t ADC_Data[ADC_DataSize];  
    __IOM bool ConvFinish;
} myADC_HandleTypeDef;

typedef struct {
	ADC_HandleTypeDef *hadc_master;
	ADC_HandleTypeDef *hadc_slave;
	TIM_HandleTypeDef *htim;
	uint16_t *ADC_MasterData;
	uint16_t *ADC_SlaveData;
	__IOM bool ConvFinish;
} myDualADC_HandleTypeDef;

void myADC_Start_DMA(myADC_HandleTypeDef *myhadc);
void myADC_Stop_DMA(myADC_HandleTypeDef *myhadc);
void myADC_DualStart_DMA(myDualADC_HandleTypeDef *myhadc);
void myADC_DualStop_DMA(myDualADC_HandleTypeDef *myhadc);

#endif /* __BSP_ADC_H__ */