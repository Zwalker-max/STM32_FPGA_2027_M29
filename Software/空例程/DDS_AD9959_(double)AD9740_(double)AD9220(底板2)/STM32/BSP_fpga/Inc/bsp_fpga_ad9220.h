/**
  ******************************************************************************
  * @file    bsp_fpga_ad9220.h
  * @brief   AD9220 dual-ADC capture driver through FPGA FMC registers.
  ******************************************************************************
  */

#ifndef __BSP_FPGA_AD9220_H
#define __BSP_FPGA_AD9220_H

#include "stm32h7xx_hal.h"
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifndef FPGA_BASE_ADDR
#define FPGA_BASE_ADDR              0x60000000UL
#endif

#define ADC_CAPTURE_MAX_POINTS      4080U

/* ADC1 (legacy) address offsets — word offset from FPGA_BASE */
#define ADC_SAMPLE_RAM_ADDR         0x1000U
#define ADC_CMD_ADDR                0x1FF0U     /* unified CMD register */
#define ADC_COUNT_ADDR              0x1FF1U
#define ADC1_STATUS_ADDR            0x1FF2U     /* ADC1 status (read-only) */
#define ADC1_ACTUAL_COUNT_ADDR      0x1FF3U     /* ADC1 actual count (read-only) */
#define ADC_ID_ADDR                 0x1FF4U

/* ADC2 address offsets */
#define ADC2_SAMPLE_RAM_ADDR        0x2000U
#define ADC2_STATUS_ADDR            0x2FF2U     /* ADC2 status (read-only) */
#define ADC2_ACTUAL_COUNT_ADDR      0x2FF3U     /* ADC2 actual count (read-only) */

/* ADC_CMD bit definitions */
#define ADC_CMD_START               0x0001U     /* bit0: start sampling */
#define ADC_CMD_STOP                0x0002U     /* bit1: stop sampling */
#define ADC_CMD_CLEAR               0x0004U     /* bit2: clear FIFO + reset FSM */
#define ADC_CMD_ADC_SEL             0x0008U     /* bit3: 0=ADC1, 1=ADC2 (single mode) */
#define ADC_CMD_DUAL_MODE           0x0010U     /* bit4: 0=single, 1=dual sync */

/* Legacy compatibility macros */
#define ADC_CTRL_ADDR               ADC_CMD_ADDR
#define ADC_STATUS_ADDR             ADC1_STATUS_ADDR
#define ADC_ACTUAL_COUNT_ADDR       ADC1_ACTUAL_COUNT_ADDR
#define ADC_CTRL_START              ADC_CMD_START
#define ADC_CTRL_STOP               ADC_CMD_STOP
#define ADC_CTRL_CLEAR              ADC_CMD_CLEAR

/* Status bit masks */
#define ADC_STATUS_BUSY             0x0001U
#define ADC_STATUS_DONE             0x0002U
#define ADC_STATUS_OVERFLOW         0x0004U

#define ADC_CAPTURE_ID_VALUE        0x9220U

extern uint16_t adc_capture_buffer[ADC_CAPTURE_MAX_POINTS];
extern uint16_t adc_capture_buffer2[ADC_CAPTURE_MAX_POINTS];

/* ---- Legacy (ADC1 only) API (unchanged) ---- */
uint16_t ADC_CaptureReadId(void);
uint16_t ADC_CaptureReadStatus(void);
uint16_t ADC_CaptureReadActualCount(void);
HAL_StatusTypeDef ADC_CaptureClear(void);
HAL_StatusTypeDef ADC_CaptureStart(uint16_t sample_count);
HAL_StatusTypeDef ADC_CaptureStop(void);
HAL_StatusTypeDef ADC_CaptureWaitDone(uint32_t timeout_ms);
HAL_StatusTypeDef ADC_CaptureReadMDMA(uint16_t *buffer, uint16_t sample_count, uint32_t timeout_ms);

/* ---- New dual-ADC API ---- */
uint16_t ADC_CaptureReadStatus1(void);
uint16_t ADC_CaptureReadActualCount1(void);
uint16_t ADC_CaptureReadStatus2(void);
uint16_t ADC_CaptureReadActualCount2(void);
HAL_StatusTypeDef ADC_CaptureStartSingle(uint8_t adc_ch, uint16_t sample_count);
HAL_StatusTypeDef ADC_CaptureStartDual(uint16_t sample_count);
HAL_StatusTypeDef ADC_CaptureWaitDone1(uint32_t timeout_ms);
HAL_StatusTypeDef ADC_CaptureWaitDone2(uint32_t timeout_ms);
HAL_StatusTypeDef ADC_CaptureReadMDMA1(uint16_t *buffer, uint16_t sample_count, uint32_t timeout_ms);
HAL_StatusTypeDef ADC_CaptureReadMDMA2(uint16_t *buffer, uint16_t sample_count, uint32_t timeout_ms);

#ifdef __cplusplus
}
#endif

#endif /* __BSP_FPGA_AD9220_H */
