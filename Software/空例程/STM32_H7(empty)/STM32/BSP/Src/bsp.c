#include "bsp.h"
#include "bsp_uart.h"
#include "bsp_gpio.h"
#include "bsp_adc.h"
#include "bsp_lcd.h"
#include "bsp_ad9959.h"

//��������
BSP_DMA_BUFFER char guart1_TxMsg[UART_BUF_SIZE];
BSP_DMA_BUFFER char guart1_RxMsg[UART_BUF_SIZE];
uint16_t glcd_TxBuf[LCD_BUF_SIZE];
BSP_DMA_BUFFER uint16_t ADC1_Data[ADC_DataSize];
BSP_DMA_BUFFER uint16_t ADC2_Data[ADC_DataSize];
float Bias_Voltage_0,Bias_Voltage_1,Vpp_0,Vpp_1,pha;

//�ṹ������
BSP_UART_HandleTypeDef UART_Debug = {
	.huart  = &huart1,
	.pTxMsg = guart1_TxMsg,
	.pRxMsg = guart1_RxMsg,
};

LCD_HandleTypeDef blcd = {
	.Instance = &LCD_1_80_inch,
	.hspi     = &hspi4,
	.dir      = LCD_DIR_RIGHT,
	.TxBuf    = glcd_TxBuf,
};

myADC_HandleTypeDef ADC_1 = { 
	.hadc = &hadc1, 
	.htim = &htim6, 
	.ConvFinish = false 
};

myADC_HandleTypeDef ADC_2 = { 
	.hadc = &hadc2, 
	.htim = &htim6, 
	.ConvFinish = false 
};

//��������
static void PeriodicProcess(void);
void Debug(void);
void Delay(uint32_t t);
void Delay_short(uint32_t t);
void ADC_Dual_Start(void);
void ADC_Dual_process(const uint16_t pData0[], const uint16_t pData1[]);
uint16_t ADC_GetSingleValue(ADC_HandleTypeDef *hadc);

//��������amplitude
void MainProcess(void)
{
	LCD_Init(&blcd, &LCD_Font_1608, &LCD_Font_1616, WHITE, BLACK);
	BSP_UART_ReceiveToIdle_DMA(&UART_Debug);
	HAL_TIM_Base_Start_IT(&htim17);
	BSP_UART_Transmit_DMA(&UART_Debug, "STM32H723ZG UART1 connected.\r\n");
	DDS_Init();
	while (1)
	{

	}
}

uint16_t ADC_GetSingleValue(ADC_HandleTypeDef *hadc)
{
	uint16_t val = 0;
	HAL_ADC_Start(hadc);
	if(HAL_ADC_PollForConversion(hadc, 10) == HAL_OK)
	{
		val = HAL_ADC_GetValue(hadc);
	}
	HAL_ADC_Stop(hadc);
	return val;
}

void Key_Process(uint8_t keyNum)
{
	switch (keyNum)
	{
		case 0x01:
			BSP_UART_Transmit_DMA(&UART_Debug, "KEY1 PRESSED.\n");
		  break;
		case 0x02:
			BSP_UART_Transmit_DMA(&UART_Debug, "KEY2 PRESSED.\n");
			break;
		default:
			break;
	}
}

void Debug()
{

}

void Delay(uint32_t t)//550MHz主频下延时1ms
{
	for(uint32_t i=0;i<10000*t;i++ )
	{
		__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();//10* __NOP()
		__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();
		__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();
		__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();
		__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();
		__NOP();__NOP();__NOP();__NOP();__NOP();
	}
}

void Delay_short(uint32_t t)//550MHz主频下延时1us
{
	for(uint32_t i=0;i<10*t;i++ )
	{
		__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();//10* __NOP()
		__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();
		__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();
		__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();
		__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();
		__NOP();__NOP();__NOP();__NOP();__NOP();
	}
}

static void PeriodicProcess(void)
{
	uint8_t keyStatus = KEY_Read();
	Key_Process(keyStatus);
}

void HAL_UARTEx_RxEventCallback(UART_HandleTypeDef *huart, uint16_t Size)
{
	if (huart == UART_Debug.huart)
	{
		BSP_UART_Transmit_DMA(&UART_Debug, "RxMsg: %u \n",UART_Debug.pRxMsg[0]);
		BSP_UART_ReceiveToIdle_DMA(&UART_Debug);
	}
}

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
	if (htim == &htim17)
	{
		PeriodicProcess();
	}
}

void HAL_ADC_ConvCpltCallback(ADC_HandleTypeDef *hadc)
{
	if (hadc == &hadc1)
	{
		ADC_1.ConvFinish = true;
	}
	if (hadc == &hadc2)
	{
		ADC_2.ConvFinish = true;
	}
}

void ADC_Dual_Start()
{
	uint32_t cnttime=0;
	ADC_1.ConvFinish=false;ADC_2.ConvFinish=false;
	myADC_Start_DMA(&ADC_1 ,ADC1_Data);
	myADC_Start_DMA(&ADC_2 ,ADC2_Data);
	HAL_TIM_Base_Start_IT(&htim6);
	while(!ADC_1.ConvFinish||!ADC_2.ConvFinish)
	{
		cnttime++;
		Delay_short(10);
		if(cnttime>=1000) break;
	}
	HAL_TIM_Base_Stop(&htim6);
  HAL_ADC_Stop_DMA(&hadc1);
  HAL_ADC_Stop_DMA(&hadc2);
	if(!ADC_1.ConvFinish || !ADC_2.ConvFinish)
	{
    Vpp_0 = 0.0f;
    Vpp_1 = 0.0f;
    return;
	}
	ADC_Dual_process(ADC1_Data,ADC2_Data);
//	Debug();
}

void ADC_Dual_process(const uint16_t pData0[], const uint16_t pData1[])
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
	pha = acosf(phase_diff_cos);
//	Vpp_0 = Vpp_0/4095*3;
//	Vpp_1 = Vpp_1/4095*3;
//	Bias_Voltage_0 = Bias_Voltage_0/4095*3;
//	Bias_Voltage_1 = Bias_Voltage_1/4095*3;
}
