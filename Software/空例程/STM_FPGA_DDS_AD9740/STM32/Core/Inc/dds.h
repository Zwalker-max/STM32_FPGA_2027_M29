/**
  ******************************************************************************
  * @file    dds.h
  * @brief   DDS driver for AD9740 waveform generator
  *
  * Provides sine LUT generation, FTW computation, waveform RAM write,
  * DAC control, and USART command processing.
  ******************************************************************************
  */

#ifndef __DDS_H
#define __DDS_H

#include "stm32h7xx_hal.h"
#include <stdint.h>

/* FPGA Register Offsets (FMC address, 16-bit word offset from 0x60000000) */
#define FPGA_BASE_ADDR      0x60000000
#define FPGA                ((volatile uint16_t *)FPGA_BASE_ADDR)

#define WAVEFORM_RAM_SIZE   1024
#define WAVEFORM_RAM_BASE   0x0000      /* 0x0000-0x03FF */
#define FTW_ADDR_LO         0x0400      /* FTW[15:0] */
#define FTW_ADDR_HI         0x0401      /* FTW[31:16] */
#define UPDATE_ADDR         0x0404      /* update enable (write 1) */
#define PHASE_RST_ADDR      0x0408      /* phase reset (write 1) */
#define DAC_CTRL_ADDR       0x040C      /* DAC control (bit0=1 normal, 0 mid-scale) */

/* DDS Physical Constants */
#define DAC_SAMPLE_RATE     125000000.0  /* 125 MHz */
#define PHASE_ACC_BITS      32           /* accumulator width */
#define FTW_SCALE           4294967296.0 /* 2^32 */

/* USART handle (for TX output) */
extern UART_HandleTypeDef huart1;

/*===============================================================
 * Waveform Types & Unified Parameters
 *===============================================================*/

/** Available waveform types for the arbitrary waveform generator */
typedef enum {
    WAVE_SINE,              /* 0: sine wave */
    WAVE_TRIANGLE,          /* 1: symmetric triangle */
    WAVE_SQUARE,            /* 2: square (duty-cycle controlled) */
    WAVE_RISING_SAWTOOTH,   /* 3: rising sawtooth (ramp up) */
    WAVE_FALLING_SAWTOOTH,  /* 4: falling sawtooth (ramp down) */
    WAVE_DC,                /* 5: DC constant level */
    WAVE_SINC,              /* 6: sinc(x) = sin(x)/x pulse */
    WAVE_EXP_DECAY,         /* 7: exponential decay pulse */
    WAVE_GAUSSIAN,          /* 8: Gaussian (bell) pulse */
    WAVE_NOISE,             /* 9: pseudo-random noise */
    WAVE_CUSTOM,            /* 10: user-defined waveform from array */
} WaveformType;

/** Unified parameter structure for DDS_SetWaveform() */
typedef struct {
    uint16_t amplitude;           /* peak amplitude (0~511, beyond clips to 1023) */
    uint8_t  duty_cycle;          /* duty cycle 0~100% (WAVE_SQUARE only) */
    float    pulse_param;         /* pulse width parameter (tau/sigma/lobes) */
    const uint16_t *custom_data;  /* pointer to custom LUT (WAVE_CUSTOM only) */
    uint32_t custom_length;       /* length of custom data (clamped to 1024) */
} WaveformParams;

/*===============================================================
 * API Functions
 *===============================================================*/

/* Waveform generation — fill a 1024-point LUT array */
void DDS_GenerateSineLUT(uint16_t *lut, uint16_t amplitude);
void DDS_GenerateTriangleLUT(uint16_t *lut, uint16_t amplitude);
void DDS_GenerateSquareLUT(uint16_t *lut, uint16_t amplitude, uint8_t duty_percent);
void DDS_GenerateRisingSawtoothLUT(uint16_t *lut, uint16_t amplitude);
void DDS_GenerateFallingSawtoothLUT(uint16_t *lut, uint16_t amplitude);
void DDS_GenerateDCLUT(uint16_t *lut, uint16_t level);
void DDS_GenerateSincLUT(uint16_t *lut, uint16_t amplitude, float num_lobes);
void DDS_GenerateExpDecayLUT(uint16_t *lut, uint16_t amplitude, float tau);
void DDS_GenerateGaussianLUT(uint16_t *lut, uint16_t amplitude, float sigma);
void DDS_GenerateNoiseLUT(uint16_t *lut, uint16_t amplitude, uint32_t seed);

/* Unified waveform switch — generate + write FPGA + phase reset */
void DDS_SetWaveform(WaveformType type, const WaveformParams *params);

/* Write + phase reset convenience (LUT already generated) */
void DDS_LoadWaveform(const uint16_t *lut);

/* Waveform RAM upload (existing — re-declared for context) */
void    DDS_WriteWaveformRAM(const uint16_t *data, uint32_t count);

/* Frequency tuning */
uint32_t DDS_CalcFTW(double target_freq);
void     DDS_SetFrequency(double target_freq);
double   DDS_ReadFrequency(void);

/* DAC control */
void     DDS_EnableDAC(void);
void     DDS_DisableDAC(void);
uint8_t  DDS_GetDACState(void);

/* Phase reset */
void     DDS_PhaseReset(void);

/* Verification */
uint32_t DDS_VerifyWaveform(const uint16_t *expected, uint32_t count);
uint16_t DDS_CalcChecksum(uint32_t start, uint32_t count);

/* Initialization */
void     DDS_Init(void);

#endif /* __DDS_H */
