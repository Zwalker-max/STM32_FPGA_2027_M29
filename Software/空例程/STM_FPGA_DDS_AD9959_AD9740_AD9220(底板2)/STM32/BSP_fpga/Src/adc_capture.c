/**
  ******************************************************************************
  * @file    adc_capture.c
  * @brief   AD9220 capture control through FPGA FMC registers.
  ******************************************************************************
  */

#include "adc_capture.h"
#include "mdma.h"
#include <stddef.h>

#define ADC_WORD_ADDR(word_offset)  (FPGA_BASE_ADDR + ((uint32_t)(word_offset) * 2UL))
#define ADC_REG16(word_offset)      (*((volatile uint16_t *)ADC_WORD_ADDR(word_offset)))

__attribute__((section(".axisram"), aligned(32)))
uint16_t adc_capture_buffer[ADC_CAPTURE_MAX_POINTS];

static void ADC_CaptureInvalidateDCache(const void *addr, uint32_t byte_count)
{
    uintptr_t start = (uintptr_t)addr & ~(uintptr_t)31U;
    uintptr_t end = ((uintptr_t)addr + byte_count + 31U) & ~(uintptr_t)31U;

    if (byte_count > 0U) {
        SCB_InvalidateDCache_by_Addr((uint32_t *)start, (int32_t)(end - start));
    }
}

uint16_t ADC_CaptureReadId(void)
{
    return ADC_REG16(ADC_ID_ADDR);
}

uint16_t ADC_CaptureReadStatus(void)
{
    return ADC_REG16(ADC_STATUS_ADDR);
}

uint16_t ADC_CaptureReadActualCount(void)
{
    return ADC_REG16(ADC_ACTUAL_COUNT_ADDR);
}

HAL_StatusTypeDef ADC_CaptureClear(void)
{
    ADC_REG16(ADC_CTRL_ADDR) = ADC_CTRL_CLEAR;
    __DSB();
    return HAL_OK;
}

HAL_StatusTypeDef ADC_CaptureStart(uint16_t sample_count)
{
    if ((sample_count == 0U) || (sample_count > ADC_CAPTURE_MAX_POINTS)) {
        return HAL_ERROR;
    }

    (void)ADC_CaptureClear();
    ADC_REG16(ADC_COUNT_ADDR) = sample_count;
    __DSB();
    ADC_REG16(ADC_CTRL_ADDR) = ADC_CTRL_START;
    __DSB();

    return HAL_OK;
}

HAL_StatusTypeDef ADC_CaptureStop(void)
{
    ADC_REG16(ADC_CTRL_ADDR) = ADC_CTRL_STOP;
    __DSB();
    return HAL_OK;
}

HAL_StatusTypeDef ADC_CaptureWaitDone(uint32_t timeout_ms)
{
    uint32_t tick_start = HAL_GetTick();

    while ((ADC_CaptureReadStatus() & ADC_STATUS_DONE) == 0U) {
        if ((ADC_CaptureReadStatus() & ADC_STATUS_OVERFLOW) != 0U) {
            return HAL_ERROR;
        }

        if ((timeout_ms != HAL_MAX_DELAY) && ((HAL_GetTick() - tick_start) > timeout_ms)) {
            return HAL_TIMEOUT;
        }
    }

    return HAL_OK;
}

HAL_StatusTypeDef ADC_CaptureReadMDMA(uint16_t *buffer, uint16_t sample_count, uint32_t timeout_ms)
{
    HAL_StatusTypeDef status;
    uint32_t byte_count;

    if ((buffer == NULL) || (sample_count == 0U) || (sample_count > ADC_CAPTURE_MAX_POINTS)) {
        return HAL_ERROR;
    }

    byte_count = (uint32_t)sample_count * sizeof(uint16_t);

    status = HAL_MDMA_Start(&hmdma_mdma_channel0_sw_0,
                            ADC_WORD_ADDR(ADC_SAMPLE_RAM_ADDR),
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
