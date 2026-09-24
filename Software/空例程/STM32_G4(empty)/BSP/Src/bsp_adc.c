#include "bsp_adc.h"

void myADC_Start_DMA(myADC_HandleTypeDef *myhadc,uint32_t ADC_Data[ADC_DataSize])
{
HAL_ADCEx_Calibration_Start(myhadc->hadc, ADC_SINGLE_ENDED);
HAL_ADC_Start_DMA(myhadc->hadc,ADC_Data, ADC_DataSize);
}

void myADC_Start_DMA_alter(myADC_HandleTypeDef *myhadc,uint32_t adc[10000])
{
HAL_ADCEx_Calibration_Start(myhadc->hadc, ADC_SINGLE_ENDED);
HAL_ADC_Start_DMA(&hadc2,adc,10000);
HAL_TIM_Base_Start_IT(myhadc->htim);
}

void myADC_Stop_DMA(myADC_HandleTypeDef *myhadc)
{
HAL_ADC_Stop_DMA(myhadc->hadc);
HAL_TIM_Base_Stop(myhadc->htim);
}

/*
一些代码模板示例

myADC_HandleTypeDef ADC_1 = { 
	.hadc = &hadc1, 
	.htim = &htim6, 
	.ConvFinish = false 
};


void ADC_Start()//测量电压
{
	myADC_Start_DMA(&ADC_1 ,ADC1_Data);
	HAL_TIM_Base_Start_IT(&htim6);
	Delay(5);//1MHz采样率，2004采样点
	ADC_process(ADC1_Data);
//  Debug();
}

void ADC_Dual_Start()//测量电压
{
	myADC_Start_DMA(&ADC_1 ,ADC1_Data);
	myADC_Start_DMA(&ADC_4 ,ADC4_Data);
	HAL_TIM_Base_Start_IT(&htim6);
	Delay(5);//1MHz采样率，2004采样点
	ADC_Dual_process(ADC1_Data,ADC4_Data);
//	Debug();
}

void ADC_process(uint32_t pData0[])
{
	float sum0 = 0.0f,sum0_sq = 0.0f;
	for(uint16_t idx = 2; idx < ADC_DataSize - 2; ++idx)
	{
		sum0 += pData0[idx];
		sum0_sq += pData0[idx] * pData0[idx];
	}
	Bias_Voltage_0 = sum0 / (ADC_DataSize - 4);
	float adc0_amp = sqrtf(2.0f * (sum0_sq / (ADC_DataSize - 4) - (Bias_Voltage_0) * (Bias_Voltage_0)));
	Vpp_0 = 2.0f * adc0_amp/4095*3;
	Bias_Voltage_0 = Bias_Voltage_0/4095*3;
}

void ADC_Dual_process(uint32_t pData0[],uint32_t pData1[])
{
	float sum0 = 0.0f, sum1 = 0.0f, sum0_sq = 0.0f, sum1_sq = 0.0f, sum_cross = 0.0f, phase_diff_cos = 0.0f;
	for(uint16_t idx = 2; idx < ADC_DataSize - 2; ++idx)
	{
		sum0 += pData0[idx];
		sum1 += pData1[idx];
		sum0_sq += pData0[idx] * pData0[idx];
		sum1_sq += pData1[idx] * pData1[idx];
		sum_cross += pData0[idx] * pData1[idx];
	}
	Bias_Voltage_0 = sum0 / (ADC_DataSize - 4);
	Bias_Voltage_1 = sum1 / (ADC_DataSize - 4);
	float adc0_amp = sqrtf(2.0f * (sum0_sq / (ADC_DataSize - 4) - (Bias_Voltage_0) * (Bias_Voltage_0)));
	float adc1_amp = sqrtf(2.0f * (sum1_sq / (ADC_DataSize - 4) - (Bias_Voltage_1) * (Bias_Voltage_1)));
	Vpp_0 = 2.0f * adc0_amp;
	Vpp_1 = 2.0f * adc1_amp;
	phase_diff_cos = 2 * (sum_cross / (ADC_DataSize - 20) - (Bias_Voltage_0) * (Bias_Voltage_1)) / (adc0_amp * adc1_amp);
	phase_diff_cos = fmaxf(fminf(phase_diff_cos, 1.0f), -1.0f);
	seta = acosf(phase_diff_cos);
//	Vpp_0 = Vpp_0/4095*3;
//	Vpp_1 = Vpp_1/4095*3;
//	Bias_Voltage_0 = Bias_Voltage_0/4095*3;
//	Bias_Voltage_1 = Bias_Voltage_1/4095*3;
}


*/