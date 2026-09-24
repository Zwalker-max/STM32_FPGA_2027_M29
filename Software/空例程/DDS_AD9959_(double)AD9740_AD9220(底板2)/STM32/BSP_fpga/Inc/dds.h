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
#define FTW_ADDR_LO         0x0400      /* FTW1[15:0] */
#define FTW_ADDR_HI         0x0401      /* FTW1[31:16] */
#define UPDATE_ADDR         0x0404      /* update1 (write 1) */
#define PHASE_RST_ADDR      0x0408      /* phase reset1 (write 1) */
#define DAC_CTRL_ADDR       0x040C      /* DAC ctrl: bit0=DAC1_EN, bit1=DAC2_EN */

#define WAVEFORM_RAM2_BASE  0x0800      /* 0x0800-0x0BFF DAC2 LUT */
#define FTW2_ADDR_LO        0x0C00      /* FTW2[15:0] */
#define FTW2_ADDR_HI        0x0C01      /* FTW2[31:16] */
#define UPDATE2_ADDR        0x0C04      /* update2 (write 1) */
#define PHASE_RST2_ADDR     0x0C08      /* phase reset2 (write 1) */

/* DAC_CTRL register bit masks */
#define DAC_CTRL_DAC1_EN    0x0001      /* bit0: DAC1 output enable */
#define DAC_CTRL_DAC2_EN    0x0002      /* bit1: DAC2 output enable */

/* DDS Physical Constants */
#define DAC_SAMPLE_RATE     125000000.0  /* 125 MHz */
#define PHASE_ACC_BITS      32           /* accumulator width */
#define FTW_SCALE           4294967296.0 /* 2^32 */

///* USART handle (for TX output) */
//extern UART_HandleTypeDef huart1;

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

/** DAC output mode — which DAC(s) are actively driven */
typedef enum {
    DAC_OUTPUT_NONE  = 0,         /* both DACs disabled (mid-scale) */
    DAC_OUTPUT_DAC1  = 1,         /* DAC1 only */
    DAC_OUTPUT_DAC2  = 2,         /* DAC2 only */
    DAC_OUTPUT_BOTH  = 3,         /* both DACs active */
} DACOutputMode;

/** DAC channel select for per-channel APIs */
typedef enum {
    DAC_CH1 = 1,                  /* DAC1 (AD9740 #1) */
    DAC_CH2 = 2,                  /* DAC2 (AD9740 #2) */
} DACChannel;

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

/* Per-channel unified waveform switch — generate + write FPGA + phase reset */
void DDS_SetWaveformCh(DACChannel ch, WaveformType type, const WaveformParams *params);

/* Unified waveform switch (both channels) — generate + write FPGA + phase reset */
void DDS_SetWaveform(WaveformType type, const WaveformParams *params);

/* Per-channel waveform load (LUT already generated) */
void DDS_LoadWaveformCh(DACChannel ch, const uint16_t *lut);
void DDS_LoadWaveform(const uint16_t *lut);    /* backward-compat: both channels */

/* Waveform RAM upload */
void    DDS_WriteWaveformRAMCh(DACChannel ch, const uint16_t *data, uint32_t count);
void    DDS_WriteWaveformRAM(const uint16_t *data, uint32_t count);  /* backward-compat */

/* Frequency tuning — per-channel */
uint32_t DDS_CalcFTW(double target_freq);
void     DDS_SetFrequencyCh(DACChannel ch, double target_freq);
void     DDS_SetFrequency(double target_freq);       /* backward-compat: both channels */
double   DDS_ReadFrequencyCh(DACChannel ch);
double   DDS_ReadFrequency(void);                    /* backward-compat: DAC1 */

/* DAC output mode control */
void        DDS_SetDACOutputMode(DACOutputMode mode);
DACOutputMode DDS_GetDACOutputMode(void);
void        DDS_EnableDAC(void);                     /* backward-compat -> DAC_BOTH */
void        DDS_DisableDAC(void);                    /* backward-compat -> DAC_NONE */
uint8_t     DDS_GetDACState(void);                   /* backward-compat: bit0 */

/* Phase reset — per-channel */
void     DDS_PhaseResetCh(DACChannel ch);
void     DDS_PhaseReset(void);                       /* backward-compat: both channels */

/* Verification */
uint32_t DDS_VerifyWaveform(const uint16_t *expected, uint32_t count);
uint16_t DDS_CalcChecksum(uint32_t start, uint32_t count);

/* Initialization */
void     DDS_Init(void);

#endif /* __DDS_H */
