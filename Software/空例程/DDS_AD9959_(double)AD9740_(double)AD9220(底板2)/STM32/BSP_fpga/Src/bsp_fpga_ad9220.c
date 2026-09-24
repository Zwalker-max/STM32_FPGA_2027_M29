/**
  ******************************************************************************
  * @file    bsp_fpga_ad9220.c
  * @brief   AD9220 dual-ADC capture control through FPGA FMC registers.
  *
  * Supports single-ADC (ADC1 or ADC2) and dual simultaneous sampling.
  ******************************************************************************
  */

#include "bsp_fpga_ad9220.h"
#include "mdma.h"
#include <stddef.h>

#define ADC_WORD_ADDR(word_offset)  (FPGA_BASE_ADDR + ((uint32_t)(word_offset) * 2UL))
#define ADC_REG16(word_offset)      (*((volatile uint16_t *)ADC_WORD_ADDR(word_offset)))

/* ---- Buffers in AXI SRAM (DMA-accessible, non-cacheable MPU region) ---- */

__attribute__((section(".axi_sram"), aligned(32)))
uint16_t adc_capture_buffer[ADC_CAPTURE_MAX_POINTS];

__attribute__((section(".axi_sram"), aligned(32)))
uint16_t adc_capture_buffer2[ADC_CAPTURE_MAX_POINTS];

/* ---- Internal helpers ---- */

static void ADC_CaptureInvalidateDCache(const void *addr, uint32_t byte_count)
{
    uintptr_t start = (uintptr_t)addr & ~(uintptr_t)31U;
    uintptr_t end = ((uintptr_t)addr + byte_count + 31U) & ~(uintptr_t)31U;

    if (byte_count > 0U) {
        SCB_InvalidateDCache_by_Addr((uint32_t *)start, (int32_t)(end - start));
    }
}

/* ---- ID read (address is same for both ADCs) ---- */

uint16_t ADC_CaptureReadId(void)
{
    return ADC_REG16(ADC_ID_ADDR);
}

/* ---- Legacy status/count (ADC1) ---- */

uint16_t ADC_CaptureReadStatus(void)
{
    return ADC_REG16(ADC1_STATUS_ADDR);
}

uint16_t ADC_CaptureReadActualCount(void)
{
    return ADC_REG16(ADC1_ACTUAL_COUNT_ADDR);
}

/* ---- Per-ADC status/count ---- */

uint16_t ADC_CaptureReadStatus1(void)
{
    return ADC_REG16(ADC1_STATUS_ADDR);
}

uint16_t ADC_CaptureReadActualCount1(void)
{
    return ADC_REG16(ADC1_ACTUAL_COUNT_ADDR);
}

uint16_t ADC_CaptureReadStatus2(void)
{
    return ADC_REG16(ADC2_STATUS_ADDR);
}

uint16_t ADC_CaptureReadActualCount2(void)
{
    return ADC_REG16(ADC2_ACTUAL_COUNT_ADDR);
}

/* ---- Common commands ---- */

HAL_StatusTypeDef ADC_CaptureClear(void)
{
    ADC_REG16(ADC_CMD_ADDR) = ADC_CMD_CLEAR;
    __DSB();
    return HAL_OK;
}

HAL_StatusTypeDef ADC_CaptureStop(void)
{
    ADC_REG16(ADC_CMD_ADDR) = ADC_CMD_STOP;
    __DSB();
    return HAL_OK;
}

/* ---- Legacy start (ADC1 single, backward-compatible) ---- */

HAL_StatusTypeDef ADC_CaptureStart(uint16_t sample_count)
{
    return ADC_CaptureStartSingle(1U, sample_count);
}

/* ---- Single-ADC start (ch = 1 or 2) ---- */

HAL_StatusTypeDef ADC_CaptureStartSingle(uint8_t adc_ch, uint16_t sample_count)
{
    uint16_t cmd;

    if ((sample_count == 0U) || (sample_count > ADC_CAPTURE_MAX_POINTS)) {
        return HAL_ERROR;
    }
    if ((adc_ch != 1U) && (adc_ch != 2U)) {
        return HAL_ERROR;
    }

    (void)ADC_CaptureClear();
    ADC_REG16(ADC_COUNT_ADDR) = sample_count;
    __DSB();

    cmd = ADC_CMD_START;
    if (adc_ch == 2U) {
        cmd |= ADC_CMD_ADC_SEL;
    }
    /* DUAL_MODE bit left at 0 → single */
    ADC_REG16(ADC_CMD_ADDR) = cmd;
    __DSB();

    return HAL_OK;
}

/* ---- Dual-ADC synchronous start ---- */

HAL_StatusTypeDef ADC_CaptureStartDual(uint16_t sample_count)
{
    if ((sample_count == 0U) || (sample_count > ADC_CAPTURE_MAX_POINTS)) {
        return HAL_ERROR;
    }

    (void)ADC_CaptureClear();
    ADC_REG16(ADC_COUNT_ADDR) = sample_count;
    __DSB();

    ADC_REG16(ADC_CMD_ADDR) = (ADC_CMD_START | ADC_CMD_DUAL_MODE);
    __DSB();

    return HAL_OK;
}

/* ---- Wait-done helpers ---- */

static HAL_StatusTypeDef ADC_CaptureWaitDoneCh(uint16_t status_addr, uint32_t timeout_ms)
{
    uint32_t tick_start = HAL_GetTick();

    while ((ADC_REG16(status_addr) & ADC_STATUS_DONE) == 0U) {
        if ((ADC_REG16(status_addr) & ADC_STATUS_OVERFLOW) != 0U) {
            return HAL_ERROR;
        }

        if ((timeout_ms != HAL_MAX_DELAY) && ((HAL_GetTick() - tick_start) > timeout_ms)) {
            return HAL_TIMEOUT;
        }
    }

    return HAL_OK;
}

HAL_StatusTypeDef ADC_CaptureWaitDone(uint32_t timeout_ms)
{
    return ADC_CaptureWaitDoneCh(ADC1_STATUS_ADDR, timeout_ms);
}

HAL_StatusTypeDef ADC_CaptureWaitDone1(uint32_t timeout_ms)
{
    return ADC_CaptureWaitDoneCh(ADC1_STATUS_ADDR, timeout_ms);
}

HAL_StatusTypeDef ADC_CaptureWaitDone2(uint32_t timeout_ms)
{
    return ADC_CaptureWaitDoneCh(ADC2_STATUS_ADDR, timeout_ms);
}

/* ---- MDMA read helpers ---- */

static HAL_StatusTypeDef ADC_CaptureReadMDMACh(uint16_t ram_offset, uint16_t *buffer,
                                               uint16_t sample_count, uint32_t timeout_ms)
{
    HAL_StatusTypeDef status;
    uint32_t byte_count;

    if ((buffer == NULL) || (sample_count == 0U) || (sample_count > ADC_CAPTURE_MAX_POINTS)) {
        return HAL_ERROR;
    }

    byte_count = (uint32_t)sample_count * sizeof(uint16_t);

    status = HAL_MDMA_Start(&hmdma_mdma_channel0_sw_0,
                            ADC_WORD_ADDR(ram_offset),
                            (uint32_t)buffer,
                            byte_count,
                            1U);
    if (status != HAL_OK) {
        return status;
    }

    status = HAL_MDMA_PollForTransfer(&hmdma_mdma_channel0_sw_0,
                                      HAL_MDMA_FULL_TRANSFER,
                                      timeout_ms);
    if (status != HAL_OK) {
        return status;
    }

    ADC_CaptureInvalidateDCache(buffer, byte_count);
    return HAL_OK;
}

HAL_StatusTypeDef ADC_CaptureReadMDMA(uint16_t *buffer, uint16_t sample_count, uint32_t timeout_ms)
{
    return ADC_CaptureReadMDMACh(ADC_SAMPLE_RAM_ADDR, buffer, sample_count, timeout_ms);
}

HAL_StatusTypeDef ADC_CaptureReadMDMA1(uint16_t *buffer, uint16_t sample_count, uint32_t timeout_ms)
{
    return ADC_CaptureReadMDMACh(ADC_SAMPLE_RAM_ADDR, buffer, sample_count, timeout_ms);
}

HAL_StatusTypeDef ADC_CaptureReadMDMA2(uint16_t *buffer, uint16_t sample_count, uint32_t timeout_ms)
{
    return ADC_CaptureReadMDMACh(ADC2_SAMPLE_RAM_ADDR, buffer, sample_count, timeout_ms);
}
