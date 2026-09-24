/**
  ******************************************************************************
  * @file    adc_capture.h
  * @brief   AD9220 capture control through FPGA FMC registers.
  ******************************************************************************
  */

#ifndef __ADC_CAPTURE_H
#define __ADC_CAPTURE_H

#include "stm32h7xx_hal.h"
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifndef FPGA_BASE_ADDR
#define FPGA_BASE_ADDR              0x60000000UL
#endif

#define ADC_CAPTURE_MAX_POINTS      4080U

#define ADC_SAMPLE_RAM_ADDR         0x1000U
#define ADC_CTRL_ADDR               0x1FF0U
#define ADC_COUNT_ADDR              0x1FF1U
#define ADC_STATUS_ADDR             0x1FF2U
#define ADC_ACTUAL_COUNT_ADDR       0x1FF3U
#define ADC_ID_ADDR                 0x1FF4U

#define ADC_CTRL_START              0x0001U
#define ADC_CTRL_STOP               0x0002U
#define ADC_CTRL_CLEAR              0x0004U

#define ADC_STATUS_BUSY             0x0001U
#define ADC_STATUS_DONE             0x0002U
#define ADC_STATUS_OVERFLOW         0x0004U

#define ADC_CAPTURE_ID_VALUE        0x9220U

extern uint16_t adc_capture_buffer[ADC_CAPTURE_MAX_POINTS];

uint16_t ADC_CaptureReadId(void);
uint16_t ADC_CaptureReadStatus(void);
uint16_t ADC_CaptureReadActualCount(void);
HAL_StatusTypeDef ADC_CaptureClear(void);
HAL_StatusTypeDef ADC_CaptureStart(uint16_t sample_count);
HAL_StatusTypeDef ADC_CaptureStop(void);
HAL_StatusTypeDef ADC_CaptureWaitDone(uint32_t timeout_ms);
HAL_StatusTypeDef ADC_CaptureReadMDMA(uint16_t *buffer, uint16_t sample_count, uint32_t timeout_ms);

#ifdef __cplusplus
}
#endif

#endif /* __ADC_CAPTURE_H */
