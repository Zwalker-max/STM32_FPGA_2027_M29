/**
  ******************************************************************************
  * @file    dds.c
  * @brief   DDS driver implementation for AD9740 waveform generator
  *          Supports: Sine, Triangle, Square, Sawtooth, DC, Sinc,
  *                    Exponential Decay, Gaussian, Pseudo-random Noise,
  *                    and Custom waveforms.
  ******************************************************************************
  */

#include "dds.h"
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
// 1. Sine Wave (existing)
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
// 3. Square Wave (duty-cycle controlled)
//    duty_percent = 0 ~ 100
//    output: high (2*ampl) for duty_percent% of cycle, low (0) otherwise
//===============================================================
void DDS_GenerateSquareLUT(uint16_t *lut, uint16_t amplitude, uint8_t duty_percent)
{
    if (duty_percent > 100) duty_percent = 100;

    uint32_t hi_end = (uint32_t)duty_percent * WAVEFORM_RAM_SIZE / 100;
    uint16_t hi_val = clamp_10bit((int32_t)amplitude * 2);
    uint16_t lo_val = 0;

    for (uint32_t i = 0; i < WAVEFORM_RAM_SIZE; i++)
    {
        lut[i] = (i < hi_end) ? hi_val : lo_val;
    }
}

//===============================================================
// 4. Rising Sawtooth (0→2*ampl over full cycle)
//===============================================================
void DDS_GenerateRisingSawtoothLUT(uint16_t *lut, uint16_t amplitude)
{
    for (uint32_t i = 0; i < WAVEFORM_RAM_SIZE; i++)
    {
        double phase = (double)i / (double)WAVEFORM_RAM_SIZE;   // 0.0 ~ 1.0
        double norm = 2.0 * phase - 1.0;                         // -1.0 ~ +1.0
        lut[i] = norm_to_dac(norm, amplitude);
    }
}

//===============================================================
// 5. Falling Sawtooth (2*ampl→0 over full cycle)
//===============================================================
void DDS_GenerateFallingSawtoothLUT(uint16_t *lut, uint16_t amplitude)
{
    for (uint32_t i = 0; i < WAVEFORM_RAM_SIZE; i++)
    {
        double phase = (double)i / (double)WAVEFORM_RAM_SIZE;
        double norm = 1.0 - 2.0 * phase;                         // +1.0 ~ -1.0
        lut[i] = norm_to_dac(norm, amplitude);
    }
}

//===============================================================
// 6. DC Constant Level
//    level = 0 ~ 1023
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
// 7. Sinc Pulse  sin(x)/x
//    主瓣在 LUT 中心，两侧旁瓣逐级衰减
//    num_lobes = 3.0 → 3 个正旁瓣 / 侧
//    │sinc(π·t)│ 归一化后在 LUT 中心产生主峰
//===============================================================
void DDS_GenerateSincLUT(uint16_t *lut, uint16_t amplitude, float num_lobes)
{
    if (num_lobes < 0.5f) num_lobes = 0.5f;
    if (num_lobes > 20.0f) num_lobes = 20.0f;

    double max_val = 0.0;
    double raw[WAVEFORM_RAM_SIZE];

    for (uint32_t i = 0; i < WAVEFORM_RAM_SIZE; i++)
    {
        double t = num_lobes * ((double)i - (double)(WAVEFORM_RAM_SIZE / 2))
                   / (double)(WAVEFORM_RAM_SIZE / 2);
        /* t = 0 at center → sinc(0) = 1 */

        double val;
        if (fabs(t) < 1e-9)
            val = 1.0;
        else
            val = fabs(sin(M_PI * t) / (M_PI * t));

        raw[i] = val;
        if (val > max_val) max_val = val;
    }

    /* normalize to [-1..+1] range */
    if (max_val < 1e-9) max_val = 1.0;
    for (uint32_t i = 0; i < WAVEFORM_RAM_SIZE; i++)
    {
        double norm = 2.0 * (raw[i] / max_val) - 1.0;   /* 0~max → -1~+1 */
        lut[i] = norm_to_dac(norm, amplitude);
    }
}

//===============================================================
// 8. Exponential Decay Pulse
//    y = A * exp(-t / tau)  where tau in cycles (0.001 ~ 1.0)
//    tau = 0.05 → decays to ~ e^-20 within one 1024-pt window
//===============================================================
void DDS_GenerateExpDecayLUT(uint16_t *lut, uint16_t amplitude, float tau)
{
    if (tau < 0.001f) tau = 0.001f;
    if (tau > 1.0f)   tau = 1.0f;

    double decay = 1.0 / ((double)WAVEFORM_RAM_SIZE * (double)tau);
    double hi_val = 2.0 * (double)amplitude;

    for (uint32_t i = 0; i < WAVEFORM_RAM_SIZE; i++)
    {
        double val = hi_val * exp(-decay * (double)i);
        lut[i] = clamp_10bit((int32_t)(val + 0.5));
    }
}

//===============================================================
// 9. Gaussian Pulse
//    y = A * exp(-(x - μ)² / (2σ²))
//    μ = N/2 (center), σ = WAVEFORM_RAM_SIZE * sigma
//    sigma = 0.05 → narrow peak, sigma = 0.3 → broad peak
//===============================================================
void DDS_GenerateGaussianLUT(uint16_t *lut, uint16_t amplitude, float sigma)
{
    if (sigma < 0.001f) sigma = 0.001f;
    if (sigma > 0.5f)   sigma = 0.5f;

    double center = (double)(WAVEFORM_RAM_SIZE / 2);
    double s = (double)WAVEFORM_RAM_SIZE * (double)sigma;
    double var2 = 2.0 * s * s;
    double hi_val = 2.0 * (double)amplitude;

    for (uint32_t i = 0; i < WAVEFORM_RAM_SIZE; i++)
    {
        double dx = (double)i - center;
        double val = hi_val * exp(-(dx * dx) / var2);
        lut[i] = clamp_10bit((int32_t)(val + 0.5));
    }
}

//===============================================================
// 10. Pseudo-Random Noise (Galois LFSR-16)
//     Polynomial: x^16 + x^14 + x^13 + x^11 + 1  (0xB400)
//     Uniform random → centered at amplitude ±amplitude
//===============================================================
void DDS_GenerateNoiseLUT(uint16_t *lut, uint16_t amplitude, uint32_t seed)
{
    uint16_t lfsr = (uint16_t)(seed & 0xFFFF);
    if (lfsr == 0) lfsr = 0xACE1u;   /* avoid all-zero lock-up */

    for (uint32_t i = 0; i < WAVEFORM_RAM_SIZE; i++)
    {
        /* Galois LFSR step */
        uint8_t bit = lfsr & 1u;
        lfsr >>= 1;
        if (bit)
            lfsr ^= 0xB400u;

        /* map 16-bit lfsr to bipolar [-ampl .. +ampl] centered at amplitude */
        int32_t offset = (int32_t)(((uint32_t)lfsr * (uint32_t)amplitude * 2u) >> 16);
        int32_t sample = (int32_t)amplitude + offset - (int32_t)(amplitude);
        lut[i] = clamp_10bit(sample + (int32_t)amplitude);
    }
}

//===============================================================
// 2. Waveform RAM Bulk Write (existing)
//===============================================================
void DDS_WriteWaveformRAM(const uint16_t *data, uint32_t count)
{
    DDS_DisableDAC();

    if (count > WAVEFORM_RAM_SIZE) count = WAVEFORM_RAM_SIZE;

    for (uint32_t i = 0; i < count; i++)
    {
        FPGA[WAVEFORM_RAM_BASE + i] = data[i];
    }
}

//===============================================================
// 3. FTW Computation (existing)
//===============================================================
uint32_t DDS_CalcFTW(double target_freq)
{
    if (target_freq < 0.0)  target_freq = 0.0;
    if (target_freq > DAC_SAMPLE_RATE / 2.0) target_freq = DAC_SAMPLE_RATE / 2.0;

    double ftw = target_freq * FTW_SCALE / DAC_SAMPLE_RATE;
    return (uint32_t)(ftw + 0.5);
}

//===============================================================
// 4. Atomic FTW Update (existing)
//===============================================================
void DDS_SetFrequency(double target_freq)
{
    uint32_t ftw = DDS_CalcFTW(target_freq);

    __disable_irq();
    FPGA[FTW_ADDR_LO] = (uint16_t)(ftw & 0xFFFF);
    FPGA[FTW_ADDR_HI] = (uint16_t)((ftw >> 16) & 0xFFFF);
    __DMB();
    FPGA[UPDATE_ADDR] = 0x0001;
    __enable_irq();
}

//===============================================================
// 5. Frequency Readback (existing)
//===============================================================
double DDS_ReadFrequency(void)
{
    uint16_t ftw_lo = FPGA[FTW_ADDR_LO];
    uint16_t ftw_hi = FPGA[FTW_ADDR_HI];
    uint32_t ftw    = ((uint32_t)ftw_hi << 16) | ftw_lo;

    return (double)ftw * DAC_SAMPLE_RATE / FTW_SCALE;
}

//===============================================================
// 6. DAC Output Control (existing)
//===============================================================
void DDS_EnableDAC(void)
{
    FPGA[DAC_CTRL_ADDR] = 0x0001;
}

void DDS_DisableDAC(void)
{
    FPGA[DAC_CTRL_ADDR] = 0x0000;
}

uint8_t DDS_GetDACState(void)
{
    uint16_t reg = FPGA[DAC_CTRL_ADDR];
    return (uint8_t)(reg & 0x01);
}

//===============================================================
// 7. Phase Accumulator Reset (existing)
//===============================================================
void DDS_PhaseReset(void)
{
    FPGA[PHASE_RST_ADDR] = 0x0001;
}

//===============================================================
// 8. Waveform RAM Verification (existing)
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
// 9. Checksum (existing)
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
// 10. Initialize DDS Subsystem (existing)
//===============================================================
void DDS_Init(void)
{
    DDS_GenerateSquareLUT(sine_lut, 511 ,20);
    DDS_WriteWaveformRAM(sine_lut, WAVEFORM_RAM_SIZE);
    DDS_SetFrequency(1000000.0);
    DDS_PhaseReset();
    DDS_EnableDAC();
}

//===============================================================
// 11. Load Waveform — convenience (write + phase reset)
//===============================================================
void DDS_LoadWaveform(const uint16_t *lut)
{
    DDS_WriteWaveformRAM(lut, WAVEFORM_RAM_SIZE);
    DDS_PhaseReset();
}

//===============================================================
// 12. Unified Waveform Switch
//===============================================================
void DDS_SetWaveform(WaveformType type, const WaveformParams *params)
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
                DDS_GenerateSquareLUT(lut_buffer, amp, duty);
            }
            break;

        case WAVE_RISING_SAWTOOTH:
            DDS_GenerateRisingSawtoothLUT(lut_buffer, amp);
            break;

        case WAVE_FALLING_SAWTOOTH:
            DDS_GenerateFallingSawtoothLUT(lut_buffer, amp);
            break;

        case WAVE_DC:
            DDS_GenerateDCLUT(lut_buffer, amp);
            break;

        case WAVE_SINC:
            {
                float lob = (params != NULL && params->pulse_param > 0.0f)
                            ? params->pulse_param : 3.0f;
                DDS_GenerateSincLUT(lut_buffer, amp, lob);
            }
            break;

        case WAVE_EXP_DECAY:
            {
                float tau = (params != NULL && params->pulse_param > 0.0f)
                            ? params->pulse_param : 0.05f;
                DDS_GenerateExpDecayLUT(lut_buffer, amp, tau);
            }
            break;

        case WAVE_GAUSSIAN:
            {
                float sig = (params != NULL && params->pulse_param > 0.0f)
                            ? params->pulse_param : 0.1f;
                DDS_GenerateGaussianLUT(lut_buffer, amp, sig);
            }
            break;

        case WAVE_NOISE:
            {
                uint32_t seed = (params != NULL && params->pulse_param > 0.0f)
                                ? (uint32_t)(params->pulse_param * 1e6f)
                                : 42u;
                DDS_GenerateNoiseLUT(lut_buffer, amp, seed);
            }
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
                    /* pad remainder with mid-scale */
                    for (uint32_t i = write_len; i < WAVEFORM_RAM_SIZE; i++)
                        lut_buffer[i] = 511;
                }
            }
            else
            {
                /* fallback: DC mid-scale */
                DDS_GenerateDCLUT(lut_buffer, 511);
            }
            break;

        default:
            /* unknown type → do nothing */
            return;
    }

    DDS_WriteWaveformRAM(lut_buffer, write_len);
    DDS_PhaseReset();
}
