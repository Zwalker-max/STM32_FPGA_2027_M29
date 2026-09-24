/**
  ******************************************************************************
  * @file    bsp_fpga_ad9740.c
  * @brief   AD9740 dual-DAC waveform generator driver through FPGA FMC registers
  *
  * Supports sine, triangle, square (with duty-cycle and level control),
  * DC, and user-defined custom (1024-point) waveforms.
  *
  * @note  10-bit DAC output voltage mapping:
  *        DAC code 0   → -1.0V  (full negative)
  *        DAC code 512 →  0.0V  (mid-scale / zero)
  *        DAC code 1023→ +1.0V  (full positive)
  *        Vout = (code / 511.5 - 1.0) × 1.0V
  ******************************************************************************
  */

#include "bsp_fpga_ad9740.h"
#include <math.h>
#include <string.h>

/* Sine lookup table (global, generated once at init) */
static uint16_t sine_lut[WAVEFORM_RAM_SIZE];

#ifndef M_PI
#define M_PI 3.14159265358979323846f
#endif

//===============================================================
// Helper: clamp sample to 10-bit DAC range 0~1023
//===============================================================
static inline uint16_t clamp_10bit(int32_t val)
{
    if (val > 1023) return 1023;
    if (val < 0)    return 0;
    return (uint16_t)val;
}

//===============================================================
// Helper: normalize [-1..+1] × amplitude → DAC sample
//          result = round((norm + 1) * amplitude)
//===============================================================
static inline uint16_t norm_to_dac(double norm, uint16_t amplitude)
{
    double scaled = (norm + 1.0) * (double)amplitude;
    return clamp_10bit((int32_t)(scaled + 0.5));
}

//===============================================================
// 1. Sine Wave
//===============================================================
void DDS_GenerateSineLUT(uint16_t *lut, uint16_t amplitude)
{
    for (uint32_t i = 0; i < WAVEFORM_RAM_SIZE; i++)
    {
        double phase = 2.0 * M_PI * (double)i / (double)WAVEFORM_RAM_SIZE;
        double sin_val = sin(phase);
        double scaled  = (sin_val + 1.0) * (double)amplitude;
        lut[i] = clamp_10bit((int32_t)(scaled + 0.5));
    }
}

//===============================================================
// 2. Triangle Wave
//    Phase 0.0   → 0.00
//    Phase 0.25  → 1.00  (peak)
//    Phase 0.50  → 0.00
//    Phase 0.75  → -1.00 (negative peak)
//    Phase 1.00  → 0.00
//===============================================================
void DDS_GenerateTriangleLUT(uint16_t *lut, uint16_t amplitude)
{
    for (uint32_t i = 0; i < WAVEFORM_RAM_SIZE; i++)
    {
        double phase = (double)i / (double)WAVEFORM_RAM_SIZE;   // 0.0 ~ 1.0

        /* map 0→1 to -1→+1 triangle */
        double tri;
        if (phase < 0.25)
            tri =  4.0 * phase;                  /*  0.00 →  1.00 */
        else if (phase < 0.75)
            tri =  2.0 - 4.0 * phase;            /*  1.00 → -1.00 */
        else
            tri = -4.0 + 4.0 * phase;            /* -1.00 →  0.00 */

        lut[i] = norm_to_dac(tri, amplitude);
    }
}

//===============================================================
// 3. Square Wave (duty-cycle + level controlled)
//    hi_level / lo_level: 10-bit DAC codes (0~1023)
//      code 0   → -1V
//      code 512 →  0V
//      code 1023→ +1V
//    duty_percent = 0 ~ 100
//    Output: hi_level for duty_percent% of cycle, lo_level otherwise
//===============================================================
void DDS_GenerateSquareLUT(uint16_t *lut,
                           uint16_t hi_level,
                           uint16_t lo_level,
                           uint8_t  duty_percent)
{
    if (duty_percent > 100) duty_percent = 100;

    uint16_t hi = clamp_10bit((int32_t)hi_level);
    uint16_t lo = clamp_10bit((int32_t)lo_level);
    uint32_t hi_end = (uint32_t)duty_percent * WAVEFORM_RAM_SIZE / 100;

    for (uint32_t i = 0; i < WAVEFORM_RAM_SIZE; i++)
    {
        lut[i] = (i < hi_end) ? hi : lo;
    }
}

//===============================================================
// 4. DC Constant Level
//    level = 0 ~ 1023  (0→-1V, 512→0V, 1023→+1V)
//===============================================================
void DDS_GenerateDCLUT(uint16_t *lut, uint16_t level)
{
    uint16_t val = clamp_10bit((int32_t)level);
    for (uint32_t i = 0; i < WAVEFORM_RAM_SIZE; i++)
    {
        lut[i] = val;
    }
}

//===============================================================
// 5. Custom Waveform — load user-provided 1024-point array
//    1024 elements × 10-bit DAC codes (0~1023)
//    0→-1V, 512→0V, 1023→+1V
//    If data is NULL, pad with 512 (0V mid-scale)
//===============================================================
void DDS_GenerateCustomLUT(uint16_t *lut, const uint16_t *data)
{
    if (data != NULL)
    {
        memcpy(lut, data, WAVEFORM_RAM_SIZE * sizeof(uint16_t));
    }
    else
    {
        for (uint32_t i = 0; i < WAVEFORM_RAM_SIZE; i++)
            lut[i] = 512;  /* 0V mid-scale */
    }
}

//===============================================================
// Waveform RAM Bulk Write (per-channel)
//===============================================================
void DDS_WriteWaveformRAMCh(DACChannel ch, const uint16_t *data, uint32_t count)
{
    DDS_DisableDAC();

    if (count > WAVEFORM_RAM_SIZE) count = WAVEFORM_RAM_SIZE;

    uint32_t base = (ch == DAC_CH2) ? WAVEFORM_RAM2_BASE : WAVEFORM_RAM_BASE;

    for (uint32_t i = 0; i < count; i++)
    {
        FPGA[base + i] = data[i];
    }
}

void DDS_WriteWaveformRAM(const uint16_t *data, uint32_t count)
{
    DDS_WriteWaveformRAMCh(DAC_CH1, data, count);
    DDS_WriteWaveformRAMCh(DAC_CH2, data, count);
}

//===============================================================
// FTW Computation
//===============================================================
uint32_t DDS_CalcFTW(double target_freq)
{
    if (target_freq < 0.0)  target_freq = 0.0;
    if (target_freq > DAC_SAMPLE_RATE / 2.0) target_freq = DAC_SAMPLE_RATE / 2.0;

    double ftw = target_freq * FTW_SCALE / DAC_SAMPLE_RATE;
    return (uint32_t)(ftw + 0.5);
}

//===============================================================
// Atomic FTW Update (per-channel)
//===============================================================
void DDS_SetFrequencyCh(DACChannel ch, double target_freq)
{
    uint32_t ftw = DDS_CalcFTW(target_freq);

    uint32_t ftw_lo_addr = (ch == DAC_CH2) ? FTW2_ADDR_LO : FTW_ADDR_LO;
    uint32_t ftw_hi_addr = (ch == DAC_CH2) ? FTW2_ADDR_HI : FTW_ADDR_HI;
    uint32_t update_addr  = (ch == DAC_CH2) ? UPDATE2_ADDR : UPDATE_ADDR;

    __disable_irq();
    FPGA[ftw_lo_addr] = (uint16_t)(ftw & 0xFFFF);
    FPGA[ftw_hi_addr] = (uint16_t)((ftw >> 16) & 0xFFFF);
    __DMB();
    FPGA[update_addr] = 0x0001;
    __enable_irq();
}

void DDS_SetFrequency(double target_freq)
{
    DDS_SetFrequencyCh(DAC_CH1, target_freq);
    DDS_SetFrequencyCh(DAC_CH2, target_freq);
}

//===============================================================
// Frequency Readback (per-channel)
//===============================================================
double DDS_ReadFrequencyCh(DACChannel ch)
{
    uint32_t ftw_lo_addr = (ch == DAC_CH2) ? FTW2_ADDR_LO : FTW_ADDR_LO;
    uint32_t ftw_hi_addr = (ch == DAC_CH2) ? FTW2_ADDR_HI : FTW_ADDR_HI;

    uint16_t ftw_lo = FPGA[ftw_lo_addr];
    uint16_t ftw_hi = FPGA[ftw_hi_addr];
    uint32_t ftw    = ((uint32_t)ftw_hi << 16) | ftw_lo;

    return (double)ftw * DAC_SAMPLE_RATE / FTW_SCALE;
}

double DDS_ReadFrequency(void)
{
    return DDS_ReadFrequencyCh(DAC_CH1);
}

//===============================================================
// DAC Output Control (global mode register)
//===============================================================
void DDS_SetDACOutputMode(DACOutputMode mode)
{
    uint16_t reg = 0;
    if (mode == DAC_OUTPUT_DAC1 || mode == DAC_OUTPUT_BOTH)
        reg |= DAC_CTRL_DAC1_EN;
    if (mode == DAC_OUTPUT_DAC2 || mode == DAC_OUTPUT_BOTH)
        reg |= DAC_CTRL_DAC2_EN;
    FPGA[DAC_CTRL_ADDR] = reg;
}

DACOutputMode DDS_GetDACOutputMode(void)
{
    uint16_t reg = FPGA[DAC_CTRL_ADDR];
    uint8_t dac1 = (reg & DAC_CTRL_DAC1_EN) ? 1 : 0;
    uint8_t dac2 = (reg & DAC_CTRL_DAC2_EN) ? 1 : 0;
    return (DACOutputMode)((dac2 << 1) | dac1);
}

void DDS_EnableDAC(void)
{
    DDS_SetDACOutputMode(DAC_OUTPUT_BOTH);
}

void DDS_DisableDAC(void)
{
    DDS_SetDACOutputMode(DAC_OUTPUT_NONE);
}

uint8_t DDS_GetDACState(void)
{
    uint16_t reg = FPGA[DAC_CTRL_ADDR];
    return (uint8_t)(reg & DAC_CTRL_DAC1_EN);
}

//===============================================================
// Phase Accumulator Reset (per-channel)
//===============================================================
void DDS_PhaseResetCh(DACChannel ch)
{
    uint32_t addr = (ch == DAC_CH2) ? PHASE_RST2_ADDR : PHASE_RST_ADDR;
    FPGA[addr] = 0x0001;
}

void DDS_PhaseReset(void)
{
    DDS_PhaseResetCh(DAC_CH1);
    DDS_PhaseResetCh(DAC_CH2);
}

//===============================================================
// Waveform RAM Verification
//===============================================================
uint32_t DDS_VerifyWaveform(const uint16_t *expected, uint32_t count)
{
    uint32_t errors = 0;
    if (count > WAVEFORM_RAM_SIZE) count = WAVEFORM_RAM_SIZE;

    if (expected == NULL) expected = sine_lut;

    for (uint32_t i = 0; i < count; i++)
    {
        uint16_t rd = FPGA[WAVEFORM_RAM_BASE + i];
        uint16_t exp = (i < WAVEFORM_RAM_SIZE) ? expected[i] : 0;
        if ((rd & 0x03FF) != (exp & 0x03FF))
        {
            errors++;
        }
    }
    return errors;
}

//===============================================================
// Checksum
//===============================================================
uint16_t DDS_CalcChecksum(uint32_t start, uint32_t count)
{
    uint32_t sum = 0;
    for (uint32_t i = 0; i < count; i++)
    {
        sum += FPGA[WAVEFORM_RAM_BASE + start + i];
    }
    return (uint16_t)(sum & 0xFFFF);
}

//===============================================================
// Initialize DDS Subsystem (both channels, independent frequencies)
//===============================================================
void DDS_Init(void)
{
    /* Default waveform: square wave, hi≈+1V (1022), lo=-1V (0), 20% duty */
    DDS_GenerateSquareLUT(sine_lut, 1022, 0, 20);

    /* Write same LUT to both channels' waveform RAMs */
    DDS_WriteWaveformRAMCh(DAC_CH1, sine_lut, WAVEFORM_RAM_SIZE);
    DDS_WriteWaveformRAMCh(DAC_CH2, sine_lut, WAVEFORM_RAM_SIZE);

    /* Set independent frequencies: DAC1 = 1 kHz, DAC2 = 10 kHz */
    DDS_SetFrequencyCh(DAC_CH1, 1000.0);
    DDS_SetFrequencyCh(DAC_CH2, 10000.0);

    DDS_PhaseReset();
    DDS_SetDACOutputMode(DAC_OUTPUT_BOTH);
}

//===============================================================
// Load Waveform — per-channel convenience (write + phase reset)
//===============================================================
void DDS_LoadWaveformCh(DACChannel ch, const uint16_t *lut)
{
    DDS_WriteWaveformRAMCh(ch, lut, WAVEFORM_RAM_SIZE);
    DDS_PhaseResetCh(ch);
}

void DDS_LoadWaveform(const uint16_t *lut)
{
    DDS_LoadWaveformCh(DAC_CH1, lut);
    DDS_LoadWaveformCh(DAC_CH2, lut);
}

//===============================================================
// Per-Channel Unified Waveform Switch
//===============================================================
void DDS_SetWaveformCh(DACChannel ch, WaveformType type, const WaveformParams *params)
{
    uint16_t lut_buffer[WAVEFORM_RAM_SIZE];
    uint32_t write_len = WAVEFORM_RAM_SIZE;

    /* safety: treat NULL params as defaults */
    uint16_t amp = (params != NULL) ? params->amplitude : 511;
    if (amp > 511) amp = 511;

    switch (type)
    {
        case WAVE_SINE:
            DDS_GenerateSineLUT(lut_buffer, amp);
            break;

        case WAVE_TRIANGLE:
            DDS_GenerateTriangleLUT(lut_buffer, amp);
            break;

        case WAVE_SQUARE:
            {
                uint8_t duty = (params != NULL) ? params->duty_cycle : 50;
                if (duty > 100) duty = 100;
                /* Map amplitude*2 → hi_level, 0 → lo_level (backward-compatible) */
                uint16_t hi = clamp_10bit((int32_t)amp * 2);
                uint16_t lo = 0;
                DDS_GenerateSquareLUT(lut_buffer, hi, lo, duty);
            }
            break;

        case WAVE_DC:
            DDS_GenerateDCLUT(lut_buffer, amp);
            break;

        case WAVE_CUSTOM:
            if (params != NULL && params->custom_data != NULL)
            {
                write_len = (params->custom_length > 0
                             && params->custom_length <= WAVEFORM_RAM_SIZE)
                            ? params->custom_length : WAVEFORM_RAM_SIZE;
                memcpy(lut_buffer, params->custom_data, write_len * sizeof(uint16_t));
                if (write_len < WAVEFORM_RAM_SIZE)
                {
                    /* pad remainder with mid-scale (0V) */
                    for (uint32_t i = write_len; i < WAVEFORM_RAM_SIZE; i++)
                        lut_buffer[i] = 512;
                }
            }
            else
            {
                /* fallback: DC mid-scale (0V) */
                DDS_GenerateDCLUT(lut_buffer, 512);
            }
            break;

        default:
            /* unknown type → do nothing */
            return;
    }

    DDS_WriteWaveformRAMCh(ch, lut_buffer, write_len);
    DDS_PhaseResetCh(ch);
}

//===============================================================
// Unified Waveform Switch (both channels)
//===============================================================
void DDS_SetWaveform(WaveformType type, const WaveformParams *params)
{
    DDS_SetWaveformCh(DAC_CH1, type, params);
    DDS_SetWaveformCh(DAC_CH2, type, params);
}
