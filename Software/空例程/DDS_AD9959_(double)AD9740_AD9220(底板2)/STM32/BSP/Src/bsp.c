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
	 /*
   *STM adc1 adc2 Test
   */
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

	for(int i = 0; i < ADC_MasterDataSize; i=i+10) {
		BSP_UART_Transmit_DMA(&buart1,"ADC1&ADC2[%d]:%d ,%d \n",i, myDualADC.ADC_MasterData[i],myDualADC.ADC_SlaveData[i]);
	}

	
	
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
  DDS_Init();
  HAL_Delay(5);  /* let any IRQ-pending (delayed by __disable_irq) settle */


  /*
   * Configuration dump: display pre-computed FTW values and expected
   * channel configuration.  FMC reads are avoided here because the
   * STM32H7 FMC read timing (ADDSET=4, DATAST=3 @ ~275 MHz AHB) is
   * too tight for the FPGA to drive FMC_D within the non-bufferable
   * window — a stalled FMC read hangs the CPU indefinitely.
   */
  {
    char buf[100];
    uint32_t ftw;

    /* --- DAC1 Configuration (target = 1 kHz) --- */
    HAL_UART_Transmit(&huart1, (uint8_t *)"\r\n--- DAC1 Config (1 kHz target) ---\r\n", 41, 200);

    ftw = DDS_CalcFTW(1000.0);
    sprintf(buf, "FTW1      = 0x%08lX (%lu) [pre-computed]\r\n", ftw, ftw);
    HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);

    sprintf(buf, "FTW1_LO   = 0x%04X (%u)\r\n", (uint16_t)(ftw & 0xFFFF), (uint16_t)(ftw & 0xFFFF));
    HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);

    sprintf(buf, "FTW1_HI   = 0x%04X (%u)\r\n", (uint16_t)((ftw >> 16) & 0xFFFF), (uint16_t)((ftw >> 16) & 0xFFFF));
    HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);

    sprintf(buf, "DAC1 freq = 1000.00 Hz  (target)\r\n");
    HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);

    /* --- DAC2 Configuration (target = 10 kHz) --- */
    HAL_UART_Transmit(&huart1, (uint8_t *)"\r\n--- DAC2 Config (10 kHz target) ---\r\n", 41, 200);

    ftw = DDS_CalcFTW(10000.0);
    sprintf(buf, "FTW2      = 0x%08lX (%lu) [pre-computed]\r\n", ftw, ftw);
    HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);

    sprintf(buf, "FTW2_LO   = 0x%04X (%u)\r\n", (uint16_t)(ftw & 0xFFFF), (uint16_t)(ftw & 0xFFFF));
    HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);

    sprintf(buf, "FTW2_HI   = 0x%04X (%u)\r\n", (uint16_t)((ftw >> 16) & 0xFFFF), (uint16_t)((ftw >> 16) & 0xFFFF));
    HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);

    sprintf(buf, "DAC2 freq = 10000.00 Hz  (target)\r\n");
    HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);

    /* --- Frequency Ratio --- */
    sprintf(buf, "Freq ratio DAC2/DAC1 = 10.000  (expected)\r\n");
    HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);

    /* --- DAC Control (expected state after DDS_Init) --- */
    sprintf(buf, "\r\nDAC_CTRL = 0x0003 (DAC1=ON DAC2=ON -> BOTH) [expected]\r\n");
    HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);

    HAL_UART_Transmit(&huart1, (uint8_t *)"--- End of Configuration Dump ---\r\n\r\n", 35, 200);
  }
	
	
  /*
   * to verify FMC communication and ADC configuration.
   */
  {
    char buf[96];
    uint16_t adc_id;
    uint16_t adc_status;
    uint16_t actual_count;
    uint16_t read_count;
    const uint16_t demo_points = 1024;
    int i;

    HAL_UART_Transmit(&huart1, (uint8_t *)"\r\nInit AD9220 capture...\r\n", 25, 200);

    adc_id = ADC_CaptureReadId();
    sprintf(buf, "ADC_ID    (0x1FF4) = 0x%04X\r\n", adc_id);
    HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);

    if (adc_id != ADC_CAPTURE_ID_VALUE) {
      HAL_UART_Transmit(&huart1,
                        (uint8_t *)"ADC logic not detected; check FPGA bitstream.\r\n",
                        strlen("ADC logic not detected; check FPGA bitstream.\r\n"),
                        200);
    } else if (ADC_CaptureStart(demo_points) != HAL_OK) {
      HAL_UART_Transmit(&huart1,
                        (uint8_t *)"ADC start failed.\r\n",
                        strlen("ADC start failed.\r\n"),
                        200);
    } else if (ADC_CaptureWaitDone(100) != HAL_OK) {
      adc_status = ADC_CaptureReadStatus();
      sprintf(buf, "ADC wait failed, status=0x%04X\r\n", adc_status);
      HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 200);
      (void)ADC_CaptureStop();
    } else {
      actual_count = ADC_CaptureReadActualCount();
      read_count = (actual_count > demo_points) ? demo_points : actual_count;

      sprintf(buf, "ADC actual count = %u\r\n", actual_count);
      HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);

      if (ADC_CaptureReadMDMA(adc_capture_buffer, read_count, 1000) != HAL_OK) {
        HAL_UART_Transmit(&huart1,
                          (uint8_t *)"ADC MDMA read failed.\r\n",
                          strlen("ADC MDMA read failed.\r\n"),
                          200);
      } else {
        HAL_UART_Transmit(&huart1,
                          (uint8_t *)"ADC samples [0..15]:\r\n",
                          strlen("ADC samples [0..15]:\r\n"),
                          200);
        for (i = 0; i < read_count; i = i + 5) {
          sprintf(buf, "  ADC[%04d] : %4u\r\n",
                  i,
                  adc_capture_buffer[i] & 0x0FFFU);
          HAL_UART_Transmit(&huart1, (uint8_t *)buf, strlen(buf), 100);
        }
      }
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