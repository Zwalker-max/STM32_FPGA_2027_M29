#include "bsp.h"
#include "bsp_gpio.h"
#include "bsp_uart.h"
#include "bsp_lcd.h"
#include "bsp_ad9959.h"
#include "bsp_adc.h"
#include "dds.h"
#include "adc_capture.h"

__attribute__((section(".axi_sram"),aligned(32)))
char     guart1_TxMsg[UART_BufSize];
__attribute__((section(".axi_sram"),aligned(32)))
char     guart1_RxMsg[UART_BufSize];
__attribute__((section(".axi_sram"),aligned(32)))
char     guart2_TxMsg[UART_BufSize];
__attribute__((section(".axi_sram"),aligned(32)))
char     guart2_RxMsg[UART_BufSize];
__attribute__((section(".axi_sram"),aligned(32)))
uint16_t glcd_TxBuf[LCD_BUF_SIZE];

__attribute__((section(".axi_sram")))
BSP_UART_HandleTypeDef buart1 = {
	.huart  = &huart1,
	.RxMsgUsed = true 
};

__attribute__((section(".axi_sram")))
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
__attribute__((section(".axi_sram"),aligned(32)))
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


uint16_t ADC1_Data[ADC_MasterDataSize];
uint16_t ADC2_Data[ADC_SlaveDataSize];
static volatile uint8_t adc1_done = 0;
static volatile uint8_t adc2_done = 0;

void MainProcess(void)
{
	////START////
	HAL_TIM_Base_Start_IT(&htim17);
	
	
	
	
	  /*
   * USAT1 Test
   */
	BSP_UART_Start_Receive_DMA(&buart1);
	
	  const char *banner =
      "\r\n\r\n"
      "========================================\r\n"
      "  DDS_AD9740  Arbitrary Waveform Gen\r\n"
      "  UART TX: 115200 8N1  (output only)\r\n"
      "========================================\r\n"
			"!!!!!! MPU_InitStruct.SubRegionDisable = 0x00 !!!!!! \r\n";; 
  HAL_UART_Transmit(&huart1, (uint8_t *)banner, strlen(banner), 500);
	
	BSP_UART_Transmit_DMA(&buart1,"STM32H723VGT6\n");
	BSP_UART_Transmit_DMA(&buart1,"M22\n");
	
	
	
	  /*
   *LCD Test
   */
	LCD_Init(&blcd, &LCD_Font_1206, &LCD_Font_1212, WHITE, BLACK);
	LCD_Print(&blcd,8,10,"STM32H73VGT6 550Mhz");
	LCD_Print(&blcd,8,30,"M22");
		
	  /*
   *AD9959 Test
   */
	AD9959_Init();
	AD9959_Config(AD9959_CHANNEL_0 , 100000 , 0.f, 1023);
	AD9959_Config(AD9959_CHANNEL_1 , 2000000 , 90.f, 800);
	AD9959_Config(AD9959_CHANNEL_2 , 30000000 , 180.f, 500);
	AD9959_Config(AD9959_CHANNEL_3 , 100000000 , 270.f, 1023);
//	 /*
//   *STM adc1 adc2 Test
//   */
//	adc1_done = 0;
//	adc2_done = 0;
//	myDualADC.ConvFinish = false;
//	myADC_DualStart_DMA(&myDualADC);
//	while(!myDualADC.ConvFinish)
//	{
//		if(__HAL_ADC_GET_FLAG(myDualADC.hadc_master, ADC_FLAG_OVR))
//		{
//			__HAL_ADC_CLEAR_FLAG(myDualADC.hadc_master, ADC_FLAG_OVR);
//			Error_Handler();
//		}
//		if(__HAL_ADC_GET_FLAG(myDualADC.hadc_slave, ADC_FLAG_OVR))
//		{
//			__HAL_ADC_CLEAR_FLAG(myDualADC.hadc_slave, ADC_FLAG_OVR);
//			Error_Handler();
//		}
//	}
//	myADC_DualStop_DMA(&myDualADC);
//	
//	/* Invalidate D-Cache before CPU reads DMA-written data */
//	SCB_InvalidateDCache_by_Addr((uint32_t*)ADC_AXISRAM_Buf, sizeof(ADC_AXISRAM_Buf));

//	for(int i = 0; i < ADC_MasterDataSize; i=i+10) {
//		BSP_UART_Transmit_DMA(&buart1,"ADC1&ADC2[%d]:%d ,%d \n",i, myDualADC.ADC_MasterData[i],myDualADC.ADC_SlaveData[i]);
//	}

	
	
	  /*
   * DDS initialization: generates 1024-point waveform,
   * writes to FPGA waveform RAM, sets independent frequencies
   * (DAC1=1kHz, DAC2=10kHz), enables both DACs.
   *
   * CRITICAL: flush any pending DMA TX before DDS_Init because
   * DDS_SetFrequencyCh() uses __disable_irq() which can delay
   * DMA completion interrupts, causing HAL state-machine conflict
   * when blocking HAL_UART_Transmit is used afterwards.
   */
  /* Flush: wait until any in-flight DMA TX has fully completed */
  {
    uint32_t t0 = HAL_GetTick();
    while (huart1.gState != HAL_UART_STATE_READY ||
           huart1.hdmatx->State != HAL_DMA_STATE_READY)
    {
      if ((HAL_GetTick() - t0) > 500UL) break;  /* safety timeout */
    }
  }
  BSP_UART_Transmit_DMA(&buart1,"Init DDS (dual-channel, independent freq)...\r\n");
  /* Wait for the above DMA TX to finish before entering DDS_Init */
  {
    uint32_t t0 = HAL_GetTick();
    while (huart1.gState != HAL_UART_STATE_READY ||
           huart1.hdmatx->State != HAL_DMA_STATE_READY)
    {
      if ((HAL_GetTick() - t0) > 500UL) break;
    }
  }
	
	
  /*
   * FPGA AD9220 single-ADC (FIR-filtered) capture verification.
   */
  {
    char       buf[128];
    uint16_t   adc_id;
    uint16_t   status;
    uint16_t   act;
    uint16_t   read_cnt;
    const uint16_t demo_pts = 1024;
    int        i;

    HAL_UART_Transmit(&huart1, (uint8_t *)"\r\n=== FPGA AD9220 ADC Test ===\r\n", 34, 200);

    /* --- ID check --- */
    adc_id = ADC_CaptureReadId();
    sprintf(buf, "ADC_ID (0x4004) = 0x%04X\r\n", adc_id);
    HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);

    if (adc_id != ADC_CAPTURE_ID_VALUE) {
      HAL_UART_Transmit(&huart1,
                        (uint8_t *)"ADC logic not detected; check FPGA bitstream.\r\n",
                        strlen("ADC logic not detected; check FPGA bitstream.\r\n"),
                        200);
    } else {

      /* ============ ADC1 single capture ============ */
      HAL_UART_Transmit(&huart1, (uint8_t *)"\r\n--- ADC Capture ---\r\n", 24, 200);

      if (ADC_CaptureStart(demo_pts) != HAL_OK) {
        HAL_UART_Transmit(&huart1, (uint8_t *)"ADC start failed.\r\n", 20, 200);
      } else if (ADC_CaptureWaitDone(200) != HAL_OK) {
        status = ADC_CaptureReadStatus();
        sprintf(buf, "ADC wait failed, status=0x%04X\r\n", status);
        HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 200);
        (void)ADC_CaptureStop();
      } else {
        act      = ADC_CaptureReadActualCount();
        read_cnt = (act > demo_pts) ? demo_pts : act;

        sprintf(buf, "ADC actual = %u, reading %u samples...\r\n", act, read_cnt);
        HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);

        if (ADC_CaptureReadMDMA(adc_capture_buffer, read_cnt, 1000) != HAL_OK) {
          HAL_UART_Transmit(&huart1, (uint8_t *)"ADC MDMA read failed.\r\n", 24, 200);
        } else {
          HAL_UART_Transmit(&huart1, (uint8_t *)"ADC samples (every 5, int16):\r\n", 32, 200);
          for (i = 0; i < (int)demo_pts; i += 1) {
            sprintf(buf, "  [%04d] : %6d\r\n", i, (int16_t)adc_capture_buffer[i]);
            HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);
          }
        }
      }

      HAL_UART_Transmit(&huart1, (uint8_t *)"\r\n=== ADC Test Complete ===\r\n", 30, 200);
    }
  }
	
	
	
	
	
	while (1)
	{

	}
}



static void PeriodicProcess(void)
{
	uint8_t keyStatus = KEY_Read();
	static int32_t step1 = 100;
	static float step2 = 0.1;
	switch(keyStatus)
	{
		case KEY_S1_TAP:
			break;
		case KEY_S1_HOLD:
			break;
		case KEY_S2_TAP:                                                   
			break;
		case KEY_S2_HOLD:
			break;
		case KEY_S3_TAP:
			break;
		case KEY_S3_HOLD:
			break;
		case KEY_S4_TAP:
			break; 
		case KEY_S4_HOLD:
			break;
		default :
			break;
		
	}
	
	static uint16_t timeCnt = 0;
	if (++timeCnt < 50) return;
	timeCnt = 0;
	
}




void HAL_UARTEx_RxEventCallback(UART_HandleTypeDef *huart, uint16_t Size)
{
	if (huart == buart1.huart)
	{
		/* Only echo if TX is idle — avoids DMA state conflict when
		   this fires during FMC-heavy operations (e.g. DDS_Init).
		   Called from ISR context, so keep it lightweight. */
		if (huart->gState == HAL_UART_STATE_READY)
		{
			BSP_UART_Transmit_DMA(&buart1, "RxMsg: %s\r\n", buart1.UART_RxMsg);
		}
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