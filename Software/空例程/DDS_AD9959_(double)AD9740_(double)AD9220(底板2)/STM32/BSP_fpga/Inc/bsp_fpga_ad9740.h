/**
  ******************************************************************************
  * @file    bsp_fpga_ad9740.h
  * @brief   AD9740 dual-DAC waveform generator driver through FPGA FMC registers
  *
  * Supports sine, triangle, square (with duty-cycle and level control),
  * DC, and user-defined custom (1024-point) waveforms.
  *
  * @note  10-bit DAC output voltage mapping (into 50-ohm load):
  *        DAC code 0   → -1.0V  (full negative)
  *        DAC code 512 →  0.0V  (mid-scale / zero)
  *        DAC code 1023→ +1.0V  (full positive)
  *        Vout = (code / 511.5 - 1.0) × 1.0V
  *
  *        All waveform generators output 10-bit values (0-1023) using
  *        clamp_10bit() to ensure the code stays within range.
  ******************************************************************************
  */

#ifndef __BSP_FPGA_AD9740_H
#define __BSP_FPGA_AD9740_H

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

/*===============================================================
 * Waveform Types & Unified Parameters
 *===============================================================*/

/** Available waveform types for the arbitrary waveform generator */
typedef enum {
    WAVE_SINE,              /* 0: sine wave */
    WAVE_TRIANGLE,          /* 1: symmetric triangle */
    WAVE_SQUARE,            /* 2: square (independent high/low levels, duty cycle) */
    WAVE_DC,                /* 3: DC constant level */
    WAVE_CUSTOM,            /* 4: user-defined 1024-point waveform */
} WaveformType;

/** Unified parameter structure for DDS_SetWaveform() */
typedef struct {
    uint16_t amplitude;           /* peak amplitude for sine/triangle (0~511) */
    uint8_t  duty_cycle;          /* duty cycle 0~100% (WAVE_SQUARE only) */
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

/**
  * @brief  Generate sine wave LUT
  * @param  lut  1024-element output buffer
  * @param  amplitude  peak amplitude (0~511, 511 → full-scale ±1V)
  */
void DDS_GenerateSineLUT(uint16_t *lut, uint16_t amplitude);

/**
  * @brief  Generate symmetric triangle wave LUT
  * @param  lut  1024-element output buffer
  * @param  amplitude  peak amplitude (0~511, 511 → full-scale ±1V)
  */
void DDS_GenerateTriangleLUT(uint16_t *lut, uint16_t amplitude);

/**
  * @brief  Generate square wave LUT with independent high/low 10-bit levels
  * @param  lut      1024-element output buffer
  * @param  hi_level 10-bit high level (0~1023), 0→-1V, 512→0V, 1023→+1V
  * @param  lo_level 10-bit low level (0~1023), same mapping
  * @param  duty_percent  0~100 (percentage of cycle spent at hi_level)
  */
void DDS_GenerateSquareLUT(uint16_t *lut,
                           uint16_t hi_level,
                           uint16_t lo_level,
                           uint8_t  duty_percent);

/**
  * @brief  Generate DC constant level LUT
  * @param  lut   1024-element output buffer
  * @param  level 10-bit level (0~1023), 0→-1V, 512→0V, 1023→+1V
  */
void DDS_GenerateDCLUT(uint16_t *lut, uint16_t level);

/**
  * @brief  Generate custom waveform LUT from user-defined 1024-point array
  * @param  lut  1024-element output buffer
  * @param  data User-provided 1024-element array of 10-bit values (0~1023).
  *              Each value maps linearly: 0→-1V, 512→0V, 1023→+1V.
  *              Pass NULL to fill with mid-scale (512 → 0V).
  * @note   This function only fills the LUT buffer. To output the waveform,
  *         call DDS_LoadWaveformCh() or DDS_WriteWaveformRAMCh() separately.
  */
void DDS_GenerateCustomLUT(uint16_t *lut, const uint16_t *data);

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

#endif /* __BSP_FPGA_AD9740_H */
