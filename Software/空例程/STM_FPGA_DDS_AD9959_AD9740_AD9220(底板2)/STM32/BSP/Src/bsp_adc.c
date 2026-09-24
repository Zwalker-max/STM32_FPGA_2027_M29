#include "bsp_adc.h"

void myADC_Start_DMA(myADC_HandleTypeDef *myhadc)
{
    HAL_ADCEx_Calibration_Start(myhadc->hadc,ADC_CALIB_OFFSET_LINEARITY,ADC_SINGLE_ENDED);
    HAL_ADC_Start_DMA(myhadc->hadc, (uint32_t*)myhadc->ADC_Data, ADC_DataSize);
    HAL_TIM_Base_Start(myhadc->htim);
}

void myADC_Stop_DMA(myADC_HandleTypeDef *myhadc)
{
    HAL_ADC_Stop_DMA(myhadc->hadc);
    HAL_TIM_Base_Stop(myhadc->htim);
}

void myADC_DualStart_DMA(myDualADC_HandleTypeDef *myhadc)
{
    if(HAL_ADCEx_Calibration_Start(myhadc->hadc_master, ADC_CALIB_OFFSET_LINEARITY, ADC_SINGLE_ENDED) != HAL_OK)
        Error_Handler();
    if(HAL_ADCEx_Calibration_Start(myhadc->hadc_slave, ADC_CALIB_OFFSET_LINEARITY, ADC_SINGLE_ENDED) != HAL_OK)
        Error_Handler();
    /* Clear any residual OVR/EOC flags that calibration may have left */
//    __HAL_ADC_CLEAR_FLAG(myhadc->hadc_master, ADC_FLAG_OVR | ADC_FLAG_EOC);
//    __HAL_ADC_CLEAR_FLAG(myhadc->hadc_slave, ADC_FLAG_OVR | ADC_FLAG_EOC);
//    HAL_ADCEx_MultiModeStart_DMA(myhadc->hadc_master, myhadc->ADC_DualData, ADC_DualDataSize);
		if(HAL_ADC_Start_DMA(myhadc->hadc_master, (uint32_t*)myhadc->ADC_MasterData, ADC_MasterDataSize) != HAL_OK)
		    Error_Handler();
		if(HAL_ADC_Start_DMA(myhadc->hadc_slave, (uint32_t*)myhadc->ADC_SlaveData, ADC_SlaveDataSize) != HAL_OK)
		    Error_Handler();
    HAL_TIM_Base_Start(myhadc->htim);
}
void myADC_DualStop_DMA(myDualADC_HandleTypeDef *myhadc)
{
    HAL_TIM_Base_Stop(myhadc->htim);          /* Stop trigger source first */
    HAL_ADC_Stop_DMA(myhadc->hadc_master);
    HAL_ADC_Stop_DMA(myhadc->hadc_slave);
}