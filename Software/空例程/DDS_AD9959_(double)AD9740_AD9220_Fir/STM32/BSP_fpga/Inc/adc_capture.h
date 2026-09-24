/**
  ******************************************************************************
  * @file    adc_capture.h
  * @brief   AD9220 single-ADC capture control through FPGA FMC registers.
  *
  * FPGA-side pipeline: AD9220 (12b offset binary) -> 2's complement -> FIR II
  * IP (50 MHz / 10 Msps) -> 16-bit signed result stored in 8192x16 dual-port
  * RAM. STM32 reads samples via FMC+MDMA. Sample buffer values are int16
  * signed (approx raw ADC x 8 after FIR truncation).
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

#define ADC_CAPTURE_MAX_POINTS      8192U

/* ADC address offsets (word offset from FPGA_BASE) */
#define ADC_SAMPLE_RAM_ADDR         0x2000U     /* 8192 x 16 FIR-filtered sample RAM */
#define ADC_CMD_ADDR                0x4000U     /* CMD register */
#define ADC_COUNT_ADDR              0x4001U     /* sample count 1..8192 */
#define ADC1_STATUS_ADDR            0x4002U     /* status (read-only) */
#define ADC1_ACTUAL_COUNT_ADDR      0x4003U     /* actual count (read-only) */
#define ADC_ID_ADDR                 0x4004U     /* fixed 0x9220 */

/* ADC_CMD bit definitions */
#define ADC_CMD_START               0x0001U     /* bit0: start sampling */
#define ADC_CMD_STOP                0x0002U     /* bit1: stop sampling */
#define ADC_CMD_CLEAR               0x0004U     /* bit2: clear + reset FSM */

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

/* Sample buffer in AXI SRAM (DMA-accessible). Values are int16 signed. */
extern uint16_t adc_capture_buffer[ADC_CAPTURE_MAX_POINTS];

/* ---- API ---- */
uint16_t          ADC_CaptureReadId(void);
uint16_t          ADC_CaptureReadStatus(void);
uint16_t          ADC_CaptureReadActualCount(void);
HAL_StatusTypeDef ADC_CaptureClear(void);
HAL_StatusTypeDef ADC_CaptureStart(uint16_t sample_count);
HAL_StatusTypeDef ADC_CaptureStop(void);
HAL_StatusTypeDef ADC_CaptureWaitDone(uint32_t timeout_ms);
HAL_StatusTypeDef ADC_CaptureReadMDMA(uint16_t *buffer, uint16_t sample_count, uint32_t timeout_ms);

#ifdef __cplusplus
}
#endif

#endif /* __ADC_CAPTURE_H */
