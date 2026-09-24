#include "bsp.h"
#include "bsp_gpio.h"
#include "bsp_uart.h"
#include "bsp_lcd.h"
#include "bsp_ad9959.h"

char     guart1_TxMsg[UART_BufSize];
char     guart1_RxMsg[UART_BufSize];
char     guart2_TxMsg[UART_BufSize];
char     guart2_RxMsg[UART_BufSize];
uint16_t glcd_TxBuf[LCD_BUF_SIZE];

BSP_UART_HandleTypeDef buart1 = {
	.huart  = &huart1,
	.RxMsgUsed = true 
};

BSP_UART_HandleTypeDef buart2 = {
	.huart  = &huart2,
	.RxMsgUsed = true 
};

LCD_HandleTypeDef blcd = {
	.Instance = &LCD_1_80_inch,
	.hspi     = &hspi4,
	.dir      = LCD_DIR_RIGHT,
	.TxBuf    = glcd_TxBuf,
	.foreColor= WHITE,
	.backColor= BLACK,
};

/* ADC DMA buffers - MUST be in AXI SRAM (0x24000000), DMA1 cannot access DTCM (0x20000000) */
__attribute__((section(".ARM.__at_0x24000000"), zero_init))
static uint16_t ADC_AXISRAM_Buf[ADC_MasterDataSize + ADC_SlaveDataSize];

myDualADC_HandleTypeDef myDualADC = {
	.hadc_master = &hadc1,
	.hadc_slave = &hadc2,
	.htim = &htim6,
	.ADC_MasterData = ADC_AXISRAM_Buf,
	.ADC_SlaveData = ADC_AXISRAM_Buf + ADC_MasterDataSize,
	.ConvFinish = false
};

static void PeriodicProcess(void);
static void UpdateScreen(void);

uint16_t ADC1_Data[ADC_MasterDataSize];
uint16_t ADC2_Data[ADC_SlaveDataSize];
static volatile uint8_t adc1_done = 0;
static volatile uint8_t adc2_done = 0;

void MainProcess(void)
{
//	BSP_UART_Start_Receive_DMA(&buart1);
	HAL_UART_Transmit(&huart1, (uint8_t*)"Test\n", 5, 100);
	BSP_UART_Transmit_DMA(&buart1,"STM32H723VGT6\n");
	BSP_UART_Transmit_DMA(&buart1,"M22\n");
	
	adc1_done = 0;
	adc2_done = 0;
	myDualADC.ConvFinish = false;
	myADC_DualStart_DMA(&myDualADC);
	while(!myDualADC.ConvFinish)
	{
		if(__HAL_ADC_GET_FLAG(myDualADC.hadc_master, ADC_FLAG_OVR))
		{
			__HAL_ADC_CLEAR_FLAG(myDualADC.hadc_master, ADC_FLAG_OVR);
			Error_Handler();
		}
		if(__HAL_ADC_GET_FLAG(myDualADC.hadc_slave, ADC_FLAG_OVR))
		{
			__HAL_ADC_CLEAR_FLAG(myDualADC.hadc_slave, ADC_FLAG_OVR);
			Error_Handler();
		}
	}
	myADC_DualStop_DMA(&myDualADC);
	
	/* Invalidate D-Cache before CPU reads DMA-written data */
	SCB_InvalidateDCache_by_Addr((uint32_t*)ADC_AXISRAM_Buf, sizeof(ADC_AXISRAM_Buf));

	for(int i = 0; i < ADC_MasterDataSize; i++) {
		BSP_UART_Transmit_DMA(&buart1,"ADC1&ADC2[%d]:%d ,%d \n",i, myDualADC.ADC_MasterData[i],myDualADC.ADC_SlaveData[i]);
	}
//	LCD_Init(&blcd, &LCD_Font_1206, &LCD_Font_1212, WHITE, BLACK);
//	LCD_Print(&blcd,8,10,"STM32H73VGT6 550Mhz");
//	LCD_Print(&blcd,8,30,"M22");
	
//	AD9959_Init();
//	AD9959_Config(AD9959_CHANNEL_0 , 10000 , 0.f, 1023);
//	AD9959_Config(AD9959_CHANNEL_1 , 10000 , 90.f, 800);
//	AD9959_Config(AD9959_CHANNEL_2 , 10000 , 180.f, 500);
//	AD9959_Config(AD9959_CHANNEL_3 , 10000 , 270.f, 250);
	
	while (1)
	{
//		BSP_UART_Transmit_DMA(&buart1,"STM32H723VGT6\n");
//		HAL_Delay(100);
	}
}


void HAL_UARTEx_RxEventCallback(UART_HandleTypeDef *huart, uint16_t Size)
{
	if (huart == buart1.huart)
	{
		BSP_UART_Transmit_DMA(&buart1, "RxMsg: %s", buart1.UART_RxMsg);
	}
}

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
}

void HAL_ADC_ConvCpltCallback(ADC_HandleTypeDef *hadc)
{
	if(hadc == myDualADC.hadc_master)
	{
	  adc1_done = 1;
	}
	if(hadc == myDualADC.hadc_slave)
	{
	  adc2_done = 1;
	}
	if(adc1_done && adc2_done)
	{
	  myDualADC.ConvFinish = true;
	}
}