# STM32 端固件使用说明

## 基于 STM32H723ZGTx 的任意波形发生器 / 信号采集系统

---

## 目录

1. [项目概述](#1-项目概述)
2. [硬件平台](#2-硬件平台)
3. [开发环境与构建](#3-开发环境与构建)
4. [固件架构](#4-固件架构)
5. [系统初始化流程](#5-系统初始化流程)
6. [模块详解](#6-模块详解)
   - [6.1 FPGA DDS 波形发生器 (BSP_fpga/dds)](#61-fpga-dds-波形发生器-bsp_fpgadds)
   - [6.2 FPGA ADC 采集控制器 (BSP_fpga/adc_capture)](#62-fpga-adc-采集控制器-bsp_fpgaadc_capture)
   - [6.3 AD9959 四通道 DDS (BSP/bsp_ad9959)](#63-ad9959-四通道-dds-bspbsp_ad9959)
   - [6.4 片内双 ADC (BSP/bsp_adc)](#64-片内双-adc-bspbsp_adc)
   - [6.5 LCD 显示驱动 (BSP/bsp_lcd)](#65-lcd-显示驱动-bspbsp_lcd)
   - [6.6 UART 串口驱动 (BSP/bsp_uart)](#66-uart-串口驱动-bspbsp_uart)
   - [6.7 GPIO 按键与 LED (BSP/bsp_gpio)](#67-gpio-按键与-led-bspbsp_gpio)
7. [FPGA 寄存器映射](#7-fpga-寄存器映射)
8. [内存映射与链接脚本](#8-内存映射与链接脚本)
9. [引脚分配表](#9-引脚分配表)
10. [常见问题与调试](#10-常见问题与调试)
11. [附录：API 速查表](#11-附录api-速查表)

---

## 1. 项目概述

本项目是一个 **混合 STM32 + FPGA** 架构的任意波形发生器与信号捕获系统。STM32 作为主控制器，通过 **FMC（Flexible Memory Controller）16 位并行总线** 与 FPGA 通信，实现高速波形生成与 ADC 数据采集。

### 核心功能

| 功能 | 描述 |
|------|------|
| **任意波形发生** | 通过 FPGA + AD9740 DAC 输出 10 种波形（正弦、三角、方波、锯齿、DC、Sinc、指数衰减、高斯、噪声、自定义），频率可调 |
| **高速 ADC 采集** | 通过 FPGA + AD9220 ADC 捕获外部模拟信号，最多 4080 点，经 MDMA 传输至内存 |
| **四通道 DDS** | 板载 AD9959 4 通道 DDS 芯片，经 SPI 控制，独立频率/相位/幅度 |
| **片内 ADC** | STM32H7 内置 ADC1 + ADC2 双通道同步采样，TIM6 触发，DMA 传输 |
| **显示** | 1.8" SPI 彩色 LCD（128×160），支持文字和基本绘图 |
| **通信** | USART1（调试输出）、USART2（命令交互），均支持 DMA |

---

## 2. 硬件平台

### 主控 MCU

| 参数 | 值 |
|------|-----|
| **型号** | STM32H723ZGTx |
| **内核** | Cortex-M7 @ 550 MHz |
| **Flash** | 1 MB (0x0800_0000) |
| **SRAM** | 128 KB DTCM (0x2000_0000) + 128 KB AXI SRAM (0x2400_0000) |
| **封装** | LQFP144 |

### 外部器件

| 器件 | 接口 | 功能 |
|------|------|------|
| **Altera Cyclone IV E** (FPGA) | FMC 16-bit @ 0x6000_0000 | DDS 引擎、ADC 控制器、波形 RAM |
| **AD9740** | FPGA → DAC (并行) | 10 位 DAC，125 MSPS 输出 |
| **AD9220** | FPGA → ADC (并行) | 12 位 ADC，外部信号采集 |
| **AD9959** | SPI (GPIO 模拟) | 4 通道 DDS，500 MHz 主频 |
| **1.8" LCD** | SPI4 + GPIO | 128×160 彩色显示屏 (ST7735 类) |
| **USB-UART** | USART1 | 调试串口 (115200 8N1) |
| **UART** | USART2 | 命令交互 |
| **按键 × 4** | GPIO 输入 | 用户交互（短按/长按） |
| **LED × 3** | GPIO 推挽输出 | 状态指示 |

> **注意**：AD9740 和 AD9220 并不直接连接 STM32 的引脚，而是连接至 FPGA，由 FPGA 内部的逻辑控制其时序。

---

## 3. 开发环境与构建

### 3.1 软件要求

| 工具 | 用途 |
|------|------|
| **Keil MDK-ARM v5** (μVision5) | STM32 固件编译、下载、调试 |
| **STM32CubeMX** (可选) | 重新生成 HAL 初始化代码（修改 `.ioc` 文件后使用） |
| **ARM Compiler v6** (或其他 Keil 内置编译器) | 编译链 |
| **ST-Link 调试器** | 下载与调试 |

### 3.2 打开与构建

1. 使用 Keil μVision5 打开项目文件：
   ```
   STM32/MDK-ARM/FMC_DEMO.uvprojx
   ```

2. 在 Keil 中点击 **Build (F7)** 编译。

3. 连接 ST-Link 调试器至 SWD 接口（SWDIO/SWCLK/GND）。

4. 点击 **Download (F8)** 下载至目标板。

### 3.3 项目文件说明

| 文件 | 说明 |
|------|------|
| `FMC_DEMO.uvprojx` | Keil 项目文件 |
| `FMC_DEMO.uvoptx` | 项目选项配置 |
| `startup_stm32h723xx.s` | 启动文件（向量表、栈/堆初始化） |
| `FMC_DEMO.sct` | 分散加载描述（链接脚本） |
| `FMC_DEMO.ioc` | STM32CubeMX 配置源文件 |

### 3.4 FPGA 固件

FPGA 端代码位于 `FPGA/` 目录，使用 **Altera Quartus II** 开发。STM32 正常工作前需确保 FPGA 已正确加载 `.sof` 或 `.pof` 配置。

---

## 4. 固件架构

```
STM32/
├── Core/                     ← HAL 驱动层（CubeMX 自动生成）
│   ├── Inc/                  外设配置头文件
│   └── Src/                  外设初始化 + main()
│
├── BSP/                      ← 板级支持包（应用逻辑）
│   ├── Inc/                  bsp.h, bsp_ad9959.h, bsp_adc.h,
│   │                          bsp_gpio.h, bsp_lcd.h, bsp_uart.h, bsp_font.h
│   └── Src/                  模块实现
│
├── BSP_fpga/                 ← FPGA 通信驱动
│   ├── Inc/                  dds.h, adc_capture.h
│   └── Src/                  dds.c, adc_capture.c
│
├── Drivers/                  ← ST 官方 HAL + CMSIS（勿修改）
│   ├── CMSIS/
│   └── STM32H7xx_HAL_Driver/
│
├── MDK-ARM/                  ← Keil 项目文件
│
└── FMC_DEMO.ioc              ← CubeMX 工程文件
```

### 层次关系

```
main()
  ├── MPU_Config()            ← 配置 FMC 内存区域为非缓存、可共享
  ├── HAL_Init()              ← HAL 库初始化
  ├── SystemClock_Config()    ← 系统时钟 550 MHz
  ├── MX_xxx_Init()           ← 各外设初始化（GPIO, DMA, FMC, SPI, UART, ADC, TIM, DAC）
  └── MainProcess()           ← 应用主流程（位于 BSP/bsp.c）
        ├── UART 测试        ← 打印启动横幅
        ├── LCD 测试          ← 初始化并显示文字
        ├── LED 测试          ← LED 闪烁
        ├── AD9959 初始化     ← 四通道 DDS 配置
        ├── 片内 ADC 测试    ← 双 ADC DMA 同步采集
        ├── DDS_Init()        ← FPGA DDS 初始化（写波形 RAM、设频率、使能 DAC）
        ├── FPGA 寄存器导出   ← 读取并打印 FPGA 寄存器内容
        └── AD9220 采集测试   ← 启动 ADC 采集 → MDMA 传输 → 打印采样值
```

---

## 5. 系统初始化流程

### 5.1 时钟配置

系统时钟源自 **HSI (64 MHz)**，经 PLL1 倍频至 **550 MHz**：

```
HSI (64 MHz) → PLL1 (M=32, N=275, P=1, R=2)
              → SYSCLK = 64 × 275 / 32 / 2 = 275 MHz? 
              → 实际 SYSCLK = 550 MHz (PLL1P=1, SYSCLK_DIV1)
```

总线分频：HCLK = SYSCLK / 2, APB1/2/3/4 = HCLK / 2。

ADC 专用时钟由 PLL2 提供：
```
PLL2 (M=4, N=25, P=4) → ADC 时钟
```

### 5.2 MPU 配置

FMC 地址空间 `0x6000_0000`（映射到 FPGA）配置为：
- **非缓存（Non-cacheable）**：防止 CPU 缓存导致 FPGA 寄存器读写不一致
- **可共享（Shareable）**：确保总线一致性
- **禁止执行（Execute Never）**：防止指令预取
- **大小**：256 MB

### 5.3 外设初始化顺序

```
1. MPU_Config()         ← 必须在使能 Cache 之前
2. SCB_EnableICache()
3. SCB_EnableDCache()
4. HAL_Init()           ← HAL 库初始化
5. SystemClock_Config() ← 系统时钟
6. PeriphCommonClock_Config() ← 外设时钟（ADC）
7. MX_GPIO_Init()       ← GPIO
8. MX_DMA_Init()        ← DMA1
9. MX_MDMA_Init()       ← MDMA
10. MX_FMC_Init()       ← FMC 总线（FPGA 通信）
11. MX_SPI4_Init()      ← LCD SPI
12. MX_USART1_UART_Init() ← 调试串口
13. MX_USART2_UART_Init() ← 命令串口
14. MX_ADC1_Init()      ← 片内 ADC1
15. MX_ADC2_Init()      ← 片内 ADC2
16. MX_TIM6_Init()      ← ADC 触发定时器
17. MX_DAC1_Init()      ← 片内 DAC
18. MX_TIM17_Init()     ← 周期性回调定时器（按键扫描）
19. MainProcess()       ← 应用入口
```

---

## 6. 模块详解

---

### 6.1 FPGA DDS 波形发生器 (`BSP_fpga/dds`)

通过 FMC 总线控制 FPGA 内部的 DDS 引擎，驱动 **AD9740 DAC** 输出模拟波形。

#### 6.1.1 支持的波形类型

| 枚举值 | 类型 | 关键参数 |
|--------|------|----------|
| `WAVE_SINE` | 正弦波 | amplitude |
| `WAVE_TRIANGLE` | 三角波 | amplitude |
| `WAVE_SQUARE` | 方波 | amplitude, duty_cycle (0~100%) |
| `WAVE_RISING_SAWTOOTH` | 上升锯齿波 | amplitude |
| `WAVE_FALLING_SAWTOOTH` | 下降锯齿波 | amplitude |
| `WAVE_DC` | 直流电平 | amplitude (用作电平值 0~1023) |
| `WAVE_SINC` | Sinc 脉冲 | amplitude, pulse_param (瓣数, 默认 3.0) |
| `WAVE_EXP_DECAY` | 指数衰减 | amplitude, pulse_param (tau, 默认 0.05) |
| `WAVE_GAUSSIAN` | 高斯脉冲 | amplitude, pulse_param (sigma, 默认 0.1) |
| `WAVE_NOISE` | 伪随机噪声 | amplitude, pulse_param (种子, 默认 42) |
| `WAVE_CUSTOM` | 用户自定义 | amplitude, custom_data, custom_length |

#### 6.1.2 关键参数说明

**DDS 物理常量：**
- DAC 采样率：**125 MHz**（由 FPGA 端提供）
- 相位累加器宽度：**32 bit**
- 频率调谐字 (FTW) = `target_freq × 2³² / 125_000_000`
- 输出频率范围：0 ~ 62.5 MHz (Nyquist)
- 波形 RAM 深度：**1024 点** × 10 bit

**WaveformParams 结构体：**

```c
typedef struct {
    uint16_t amplitude;           // 峰值幅度 (0~511，超出会被钳位至 1023)
    uint8_t  duty_cycle;          // 方波占空比 0~100% (仅 WAVE_SQUARE)
    float    pulse_param;         // 脉冲参数：tau/sigma/瓣数/种子（因波形而异）
    const uint16_t *custom_data;  // 自定义 LUT 指针 (仅 WAVE_CUSTOM)
    uint32_t custom_length;       // 自定义数据长度 (最大 1024)
} WaveformParams;
```

> **幅度说明**：DAC 是 10 位的（范围 0~1023）。幅度参数 `amplitude` 取值范围 0~511，表示峰值偏离中点的数值。例如 `amplitude=511` 对应满量程摆幅（0~1023），`amplitude=255` 对应半摆幅（256~767）。

#### 6.1.3 API 速查

```c
// === 初始化 ===
void DDS_Init(void);                    // 默认输出 1 kHz 方波（占空比 20%）

// === 单种波形生成（直接填 LUT） ===
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

// === 统一波形切换（生成 + 写入 + 相位复位） ===
void DDS_SetWaveform(WaveformType type, const WaveformParams *params);

// === 波形写 FPGA + 相位复位（简便方法） ===
void DDS_LoadWaveform(const uint16_t *lut);

// === 频率控制 ===
uint32_t DDS_CalcFTW(double target_freq);   // 频率 → FTW 值
void     DDS_SetFrequency(double target_freq);  // 设置输出频率
double   DDS_ReadFrequency(void);               // 读取当前频率

// === DAC 控制 ===
void     DDS_EnableDAC(void);
void     DDS_DisableDAC(void);
uint8_t  DDS_GetDACState(void);

// === 相位复位 ===
void     DDS_PhaseReset(void);

// === 验证与调试 ===
uint32_t DDS_VerifyWaveform(const uint16_t *expected, uint32_t count);
uint16_t DDS_CalcChecksum(uint32_t start, uint32_t count);
```

#### 6.1.4 使用示例

```c
// 1. 初始化（默认 1 kHz 方波）
DDS_Init();

// 2. 设置频率至 10 kHz
DDS_SetFrequency(10000.0);

// 3. 切换为 5 kHz 正弦波
WaveformParams params = {
    .amplitude = 400,     // 中等幅度
    .duty_cycle = 50,     // 仅方波有效
    .pulse_param = 3.0f,  // 脉冲参数
};
DDS_SetWaveform(WAVE_SINE, &params);
DDS_SetFrequency(5000.0);

// 4. 切换为占空比 30% 的方波
DDS_SetWaveform(WAVE_SQUARE, &(WaveformParams){ .amplitude=450, .duty_cycle=30 });

// 5. 加载自定义波形
uint16_t my_wave[1024];
for (int i = 0; i < 1024; i++)
    my_wave[i] = (i < 512) ? 0 : 1023;  // 简单方波
params.custom_data = my_wave;
params.custom_length = 1024;
DDS_SetWaveform(WAVE_CUSTOM, &params);
```

---

### 6.2 FPGA ADC 采集控制器 (`BSP_fpga/adc_capture`)

通过 FMC 总线控制 FPGA 内部的 ADC 采集逻辑，从 **AD9220** 读取采样数据，并通过 **MDMA** 高速传输至 STM32 内存。

#### 6.2.1 工作原理

1. 向 FPGA 写入采样点数 → 发送 START 命令
2. FPGA 逻辑控制 AD9220 完成指定点数的采集
3. 轮询 STATUS 寄存器直到 DONE 标志置位
4. 通过 MDMA 将 FPGA 内部采样 RAM 的数据一次性读入 STM32 内存
5. 因 AXI SRAM 被 Cache 缓存，读取后需 `SCB_InvalidateDCache`

#### 6.2.2 技术参数

| 参数 | 值 |
|------|-----|
| 最大采样点 | **4080** (`ADC_CAPTURE_MAX_POINTS`) |
| ADC 分辨率 | 12 bit (0~4095) |
| 采样 RAM 基址 | `0x1000`（FMC 16-bit 字偏移） |
| 数据传输 | MDMA 通道 0 |
| 采样缓冲区 | `adc_capture_buffer[4080]`，位于 AXI SRAM (`.axisram`) |
| FPGA 标识 | 寄存器 `0x1FF4` 应读出 `0x9220` |

#### 6.2.3 API 速查

```c
uint16_t ADC_CaptureReadId(void);              // 读 FPGA 标识 (期望 0x9220)
uint16_t ADC_CaptureReadStatus(void);           // 读状态寄存器
uint16_t ADC_CaptureReadActualCount(void);      // 读实际采集点数

HAL_StatusTypeDef ADC_CaptureClear(void);       // 清除采集状态
HAL_StatusTypeDef ADC_CaptureStart(uint16_t sample_count);  // 启动采集
HAL_StatusTypeDef ADC_CaptureStop(void);        // 停止采集
HAL_StatusTypeDef ADC_CaptureWaitDone(uint32_t timeout_ms); // 等待采集完成
HAL_StatusTypeDef ADC_CaptureReadMDMA(uint16_t *buffer, uint16_t sample_count,
                                      uint32_t timeout_ms); // MDMA 读取数据
```

#### 6.2.4 使用示例

```c
// 全局缓冲区（自动位于 AXI SRAM）
extern uint16_t adc_capture_buffer[ADC_CAPTURE_MAX_POINTS];

// 1. 校验 FPGA 逻辑是否存在
if (ADC_CaptureReadId() != ADC_CAPTURE_ID_VALUE) {
    // FPGA 未加载正确比特流
    Error_Handler();
}

// 2. 启动 1024 点采集
if (ADC_CaptureStart(1024) != HAL_OK) {
    // 启动失败
}

// 3. 等待完成（超时 100 ms）
if (ADC_CaptureWaitDone(100) != HAL_OK) {
    ADC_CaptureStop();
    Error_Handler();
}

// 4. 读取数据（MDMA 传输）
if (ADC_CaptureReadMDMA(adc_capture_buffer, 1024, 1000) == HAL_OK) {
    // adc_capture_buffer 中即为 1024 个 12-bit 采样值
    for (int i = 0; i < 16; i++) {
        printf("ADC[%d] = %u\n", i, adc_capture_buffer[i] & 0x0FFF);
    }
}
```

---

### 6.3 AD9959 四通道 DDS (`BSP/bsp_ad9959`)

通过 GPIO 模拟 SPI 协议控制 AD9959 四通道 DDS 芯片，每个通道可独立配置频率、相位和幅度。

#### 6.3.1 API 速查

```c
void AD9959_Init(void);    // 初始化（复位 → 配置全局参数）
void AD9959_Config(AD9959_ChannelTypeDef channel, float freq, float phase, uint32_t amp);
```

#### 6.3.2 通道枚举

```c
typedef enum {
    AD9959_CHANNEL_0 = 0x10U,  // 通道 0
    AD9959_CHANNEL_1 = 0x20U,  // 通道 1
    AD9959_CHANNEL_2 = 0x40U,  // 通道 2
    AD9959_CHANNEL_3 = 0x80U,  // 通道 3
} AD9959_ChannelTypeDef;
```

可多通道同时配置：`AD9959_CHANNEL_0 | AD9959_CHANNEL_1`。

#### 6.3.3 参数说明

| 参数 | 范围 | 说明 |
|------|------|------|
| `freq` | 0 ~ 250 MHz | 输出频率 (Hz)，MCLK = 500 MHz |
| `phase` | 0 ~ 360 | 相位偏移 (度) |
| `amp` | 0 ~ 1023 | 幅度 (10-bit DAC) |

#### 6.3.4 使用示例

```c
// 初始化
AD9959_Init();

// 配置 4 个通道
AD9959_Config(AD9959_CHANNEL_0, 10000.0f, 0.0f,   1023);  // 10 kHz, 0°, 满幅
AD9959_Config(AD9959_CHANNEL_1, 10000.0f, 90.0f,  800);   // 10 kHz, 90°, 80%
AD9959_Config(AD9959_CHANNEL_2, 10000.0f, 180.0f, 500);   // 10 kHz, 180°, 50%
AD9959_Config(AD9959_CHANNEL_3, 10000.0f, 270.0f, 250);   // 10 kHz, 270°, 25%
```

---

### 6.4 片内双 ADC (`BSP/bsp_adc`)

使用 STM32H7 内置的两个 ADC（ADC1 和 ADC2）进行同步采样，由 TIM6 定时器触发，通过 DMA 传输数据。

#### 6.4.1 数据结构

```c
// 单 ADC 模式
typedef struct {
    ADC_HandleTypeDef *hadc;
    TIM_HandleTypeDef *htim;
    volatile uint32_t ADC_Data[1024];
    __IOM bool ConvFinish;
} myADC_HandleTypeDef;

// 双 ADC 模式（主/从）
typedef struct {
    ADC_HandleTypeDef *hadc_master;  // ADC1
    ADC_HandleTypeDef *hadc_slave;   // ADC2
    TIM_HandleTypeDef *htim;         // TIM6 (触发源)
    uint16_t *ADC_MasterData;        // 主 ADC 数据缓冲区
    uint16_t *ADC_SlaveData;         // 从 ADC 数据缓冲区
    __IOM bool ConvFinish;
} myDualADC_HandleTypeDef;

// 预定义实例：myDualADC
extern myDualADC_HandleTypeDef myDualADC;
```

> **重要**：DMA 缓冲区必须位于 **AXI SRAM**（地址 `0x2400_0000`），因为 DMA1 无法访问 DTCM（`0x2000_0000`）。代码中已通过 `__attribute__((section(".ARM.__at_0x24000000")))` 强制指定。

#### 6.4.2 API 速查

```c
void myADC_Start_DMA(myADC_HandleTypeDef *myhadc);      // 单 ADC DMA 启动
void myADC_Stop_DMA(myADC_HandleTypeDef *myhadc);       // 单 ADC DMA 停止
void myADC_DualStart_DMA(myDualADC_HandleTypeDef *myhadc); // 双 ADC DMA 启动
void myADC_DualStop_DMA(myDualADC_HandleTypeDef *myhadc);  // 双 ADC DMA 停止
```

#### 6.4.3 使用示例

```c
// 启动双 ADC 同步采集
myDualADC.ConvFinish = false;
myADC_DualStart_DMA(&myDualADC);

// 等待转换完成（回调函数置位 ConvFinish）
while (!myDualADC.ConvFinish) {
    // 可选：检查溢出标志
}

// 停止 DMA
myADC_DualStop_DMA(&myDualADC);

// 因 DMA 写入 AXI SRAM，CPU 读取前需要作废 D-Cache
SCB_InvalidateDCache_by_Addr((uint32_t*)ADC_AXISRAM_Buf, sizeof(ADC_AXISRAM_Buf));

// 读取数据
for (int i = 0; i < ADC_MasterDataSize; i++) {
    printf("ADC1: %d, ADC2: %d\n",
           myDualADC.ADC_MasterData[i],
           myDualADC.ADC_SlaveData[i]);
}
```

#### 6.4.4 回调函数

```c
void HAL_ADC_ConvCpltCallback(ADC_HandleTypeDef *hadc)
{
    if (hadc == myDualADC.hadc_master) adc1_done = 1;
    if (hadc == myDualADC.hadc_slave)  adc2_done = 1;
    if (adc1_done && adc2_done)
        myDualADC.ConvFinish = true;
}
```

---

### 6.5 LCD 显示驱动 (`BSP/bsp_lcd`)

通过 SPI4 接口驱动 1.8" 彩色 LCD（ST7735 兼容控制器），支持文字打印和基本绘图。

#### 6.5.1 支持的 LCD 型号

| 型号 | 分辨率 | 声明 |
|------|--------|------|
| 1.69 英寸 | 240×280 | `LCD_1_69_inch` |
| **1.80 英寸** | **128×160** | **`LCD_1_80_inch`**（当前默认使用） |
| 2.00 英寸 | 240×320 | `LCD_2_00_inch` |

#### 6.5.2 颜色定义

预定义 RGB565 颜色（大端序）：

```c
BLACK=0x0000, RED=0x00F8, ORANGE=0x20FD, YELLOW=0xE0FF,
LIME=0xE007, AQUA=0xFF07, BLUE=0x1F00, FUCHSIA=0x1FF8,
WHITE=0xFFFF, SILVER=0x18C6, GRAY=0x1084
```

#### 6.5.3 显示方向

```c
LCD_DIR_TOP    = 0x01  // 竖屏正向
LCD_DIR_LEFT   = 0x02  // 横屏左向
LCD_DIR_RIGHT  = 0x03  // 横屏右向（默认）
LCD_DIR_BOTTOM = 0x00  // 竖屏倒向
```

#### 6.5.4 API 速查

```c
// === 初始化与配置 ===
void LCD_Init(LCD_HandleTypeDef *blcd,
              const LCD_FontTypeDef *font_en, const LCD_FontTypeDef *font_cn,
              LCD_ColorTypeDef fc, LCD_ColorTypeDef bc);
void LCD_ConfigFont(LCD_HandleTypeDef *blcd,
                    const LCD_FontTypeDef *font_en, const LCD_FontTypeDef *font_cn,
                    LCD_ColorTypeDef fc, LCD_ColorTypeDef bc);

// === 清屏与填充 ===
void LCD_Clear(LCD_HandleTypeDef *blcd, LCD_ColorTypeDef color);
void LCD_Fill(LCD_HandleTypeDef *blcd, uint16_t xpos, uint16_t ypos,
              uint16_t xsize, uint16_t ysize, LCD_ColorTypeDef color);

// === 文字打印 ===
void LCD_Print(LCD_HandleTypeDef *blcd, uint16_t xpos, uint16_t ypos,
               const char *format, ...);

// === 绘图 ===
void LCD_DrawPoint(LCD_HandleTypeDef *blcd, uint16_t xpos, uint16_t ypos,
                   LCD_ColorTypeDef color);
void LCD_DrawLine(LCD_HandleTypeDef *blcd, uint16_t x1, uint16_t y1,
                  uint16_t x2, uint16_t y2, LCD_ColorTypeDef color);
void LCD_DrawHLine(LCD_HandleTypeDef *blcd, uint16_t x, uint16_t y,
                   uint16_t len, LCD_ColorTypeDef color);
void LCD_DrawVLine(LCD_HandleTypeDef *blcd, uint16_t x, uint16_t y,
                   uint16_t len, LCD_ColorTypeDef color);
void LCD_DrawRect(LCD_HandleTypeDef *blcd, uint16_t x1, uint16_t y1,
                  uint16_t x2, uint16_t y2, LCD_ColorTypeDef color);
```

#### 6.5.5 字体支持

| 字体变量 | 描述 |
|----------|------|
| `LCD_Font_1206` | 6×12 英文 |
| `LCD_Font_1608` | 8×16 英文 |
| `LCD_Font_3216` | 16×32 英文 |
| `LCD_Font_1616` | 16×16 中文 |
| `LCD_Font_1212` | 12×12 中文 |
| `LCD_Font_2412` | 12×24 英文 |

#### 6.5.6 使用示例

```c
// 1. 定义 LCD 句柄（已在 bsp.c 中定义）
extern LCD_HandleTypeDef blcd;

// 2. 初始化（白字黑底，横屏右向）
LCD_Init(&blcd, &LCD_Font_1206, &LCD_Font_1212, WHITE, BLACK);

// 3. 打印文字
LCD_Print(&blcd, 8, 10, "STM32H723 550MHz");
LCD_Print(&blcd, 8, 30, "DDS v1.0");

// 4. 画矩形
LCD_DrawRect(&blcd, 10, 50, 100, 80, RED);
```

---

### 6.6 UART 串口驱动 (`BSP/bsp_uart`)

封装了 USART1 和 USART2 的 DMA 传输操作，提供格式化发送和接收功能。

#### 6.6.1 数据结构

```c
typedef struct {
    UART_HandleTypeDef *huart;           // HAL UART 句柄
    char UART_TxBuf[128];                // DMA 发送缓冲区
    char UART_RxBuf[128];                // DMA 接收缓冲区
    char UART_RxMsg[128];                // 接收消息体
    __IOM bool RxMsgUsed;                // 消息可用标志
} BSP_UART_HandleTypeDef;
```

#### 6.6.2 API 速查

```c
void BSP_UART_Start_Receive_DMA(BSP_UART_HandleTypeDef *myhuart);  // 启动 DMA 接收
void BSP_UART_Transmit_DMA(BSP_UART_HandleTypeDef *myhuart,
                           const char *format, ...);                // 格式化 DMA 发送
void BSP_UART_Receive_DMA(BSP_UART_HandleTypeDef *myhuart);        // 读取接收数据
```

#### 6.6.3 预定义实例

```c
extern BSP_UART_HandleTypeDef buart1;  // USART1 - 调试输出
extern BSP_UART_HandleTypeDef buart2;  // USART2 - 命令交互
```

#### 6.6.4 使用示例

```c
// 启动 DMA 接收
BSP_UART_Start_Receive_DMA(&buart1);

// 格式化输出（支持 printf 风格）
BSP_UART_Transmit_DMA(&buart1, "Hello, World!\n");
BSP_UART_Transmit_DMA(&buart1, "Value = %d, Freq = %.2f Hz\n", val, freq);

// 接收回调
void HAL_UARTEx_RxEventCallback(UART_HandleTypeDef *huart, uint16_t Size)
{
    if (huart == buart1.huart) {
        BSP_UART_Transmit_DMA(&buart1, "RxMsg: %s", buart1.UART_RxMsg);
    }
}
```

---

### 6.7 GPIO 按键与 LED (`BSP/bsp_gpio`)

提供 4 个按键（支持短按/长按检测）和 3 个 LED 的控制。

#### 6.7.1 LED 控制

```c
// 宏定义（低电平点亮）
#define LED_1_On()      HAL_GPIO_WritePin(LED_1_GPIO_Port, LED_1_Pin, GPIO_PIN_RESET)
#define LED_2_On()      HAL_GPIO_WritePin(LED_2_GPIO_Port, LED_2_Pin, GPIO_PIN_RESET)
#define LED_3_On()      HAL_GPIO_WritePin(LED_3_GPIO_Port, LED_3_Pin, GPIO_PIN_RESET)

#define LED_1_Off()     HAL_GPIO_WritePin(..., GPIO_PIN_SET)
#define LED_2_Off()     ...
#define LED_3_Off()     ...

#define LED_1_Toggle()  HAL_GPIO_TogglePin(...)
#define LED_2_Toggle()  ...
#define LED_3_Toggle()  ...
```

#### 6.7.2 按键检测

```c
// 按键事件枚举
typedef enum {
    KEY_NONE    = 0x00,
    KEY_S1_TAP  = 0x11, KEY_S2_TAP  = 0x12,  // 短按
    KEY_S3_TAP  = 0x14, KEY_S4_TAP  = 0x18,
    KEY_S1_HOLD = 0x21, KEY_S2_HOLD = 0x22,  // 长按
    KEY_S3_HOLD = 0x24, KEY_S4_HOLD = 0x28,
} KEY_LegalStatusTypeDef;

// 按键读数（定时调用，基于 TIM17 每 1 ms 中断）
uint8_t KEY_Read(void);
uint8_t KEYEx_Read(void);  // 增强版（支持双击检测）
```

按键阈值（在 `bsp_gpio.h` 中定义）：
- `KEY_TH_TAP = 10` → 10 ms 抖动消隐
- `KEY_TH_HOLD = 40` → 40 ms 判定为长按
- `KEY_TH_WAIT = 10` → 双击间隔时间

按键检测函数在 TIM17 中断中周期性调用：

```c
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
    if (htim == &htim17) {
        PeriodicProcess();  // 内含 KEY_Read()
    }
}
```

#### 6.7.3 按键与 LED 的默认行为

当前 `PeriodicProcess()` 实现的按键功能：

| 操作 | 行为 |
|------|------|
| S1 短按 | LED1 亮 |
| S1 长按 | LED1 灭 |
| S2 短按 | LED2 亮 |
| S2 长按 | LED2 灭 |
| S3 短按 | LED3 亮 |
| S3 长按 | LED3 灭 |
| S4 短按 | 三个 LED 同时翻转 |
| S4 长按 | 三个 LED 同时灭 |

---

## 7. FPGA 寄存器映射

通过 FMC 以 16-bit 字地址访问 FPGA（基址 `0x6000_0000`，每个字偏移 2 字节）。

### 7.1 DDS 引擎寄存器

| 名称 | 偏移地址 | 类型 | 说明 |
|------|----------|------|------|
| `WAVEFORM_RAM_BASE` | `0x0000` | R/W | 波形查找表 RAM（1024 × 10 bit，地址 `0x0000~0x03FF`） |
| `FTW_ADDR_LO` | `0x0400` | R/W | 频率调谐字低 16 位 [15:0] |
| `FTW_ADDR_HI` | `0x0401` | R/W | 频率调谐字高 16 位 [31:16] |
| `UPDATE_ADDR` | `0x0404` | W | 写 1 更新频率（原子操作） |
| `PHASE_RST_ADDR` | `0x0408` | W | 写 1 复位相位累加器 |
| `DAC_CTRL_ADDR` | `0x040C` | R/W | DAC 控制：bit0=1 正常输出，=0 中间电平 |

访问方式：`FPGA[REG_ADDR] = value;` 或 `value = FPGA[REG_ADDR];`

### 7.2 ADC 采集寄存器

| 名称 | 偏移地址 | 类型 | 说明 |
|------|----------|------|------|
| `ADC_SAMPLE_RAM_ADDR` | `0x1000` | R | 采样数据 RAM（最多 4080 × 12 bit，地址 `0x1000~0x1FEF`） |
| `ADC_CTRL_ADDR` | `0x1FF0` | W | 控制寄存器：写 `0x0001` 启动，`0x0002` 停止，`0x0004` 清除 |
| `ADC_COUNT_ADDR` | `0x1FF1` | W | 写期望采样点数 |
| `ADC_STATUS_ADDR` | `0x1FF2` | R | 状态：bit0=BUSY, bit1=DONE, bit2=OVERFLOW |
| `ADC_ACTUAL_COUNT_ADDR` | `0x1FF3` | R | 实际采集点数 |
| `ADC_ID_ADDR` | `0x1FF4` | R | FPGA 标识，期望值 `0x9220` |

---

## 8. 内存映射与链接脚本

### 8.1 内存分布

| 区域 | 起始地址 | 大小 | 用途 |
|------|----------|------|------|
| Flash | `0x0800_0000` | 1 MB | 代码 + 只读数据 |
| DTCM RAM | `0x2000_0000` | 128 KB | 栈、堆、全局变量 |
| AXI SRAM | `0x2400_0000` | 128 KB | DMA 缓冲区、大数组 |

### 8.2 链接脚本 (`FMC_DEMO.sct`)

```
LR_IROM1 0x08000000 0x00100000 {
  ER_IROM1 0x08000000 0x00100000 {
   *.o (RESET, +First)
   *(InRoot$$Sections)
   .ANY (+RO)
   .ANY (+XO)
  }
  RW_IRAM1 0x20000000 0x00020000 {  ; DTCM
   .ANY (+RW +ZI)
  }
  RW_IRAM2 0x24000000 0x00020000 {  ; AXI SRAM
   .ANY (+RW +ZI)
  }
}
```

### 8.3 特殊段声明

```c
// 强制变量放入 AXI SRAM（DMA 缓冲区必须在此区域）
__attribute__((section(".ARM.__at_0x24000000"), zero_init))
static uint16_t ADC_AXISRAM_Buf[...];

// 使用 BSP 提供的宏（需要链接脚本支持）
#define __ZI_AXI_SRAM  __attribute__((section(".bss.RAM_D1")))
#define __RW_AXI_SRAM  __attribute__((section(".data.RAM_D1")))

// adc_capture.c 中 ADC 采集缓冲区
__attribute__((section(".axisram"), aligned(32)))
uint16_t adc_capture_buffer[ADC_CAPTURE_MAX_POINTS];
```

---

## 9. 引脚分配表

### 9.1 FMC 总线（FPGA 通信）

| 引脚 | 功能 | 说明 |
|------|------|------|
| PC7 | FMC_NE1 | 片选 |
| PD0~PD1 | FMC_D2~D3 | 数据线 |
| PD4~PD5 | FMC_NOE, FMC_NWE | 读/写使能 |
| PD8~PD10 | FMC_D13~D15 | 数据线 |
| PD14~PD15 | FMC_D0~D1 | 数据线 |
| PE7~PE15 | FMC_D4~D12 | 数据线 |
| PF0~PF5 | FMC_A0~A5 | 地址线 |
| PF12~PF15 | FMC_A6~A9 | 地址线 |
| PG0~PG4 | FMC_A10~A14 | 地址线 |

### 9.2 外设引脚

| 引脚 | 功能 | 说明 |
|------|------|------|
| **LED** | | |
| PC13 | LED_1 | GPIO 推挽输出（低电平亮） |
| PC14 | LED_2 | GPIO 推挽输出（低电平亮） |
| PC15 | LED_3 | GPIO 推挽输出（低电平亮） |
| **按键** | | |
| PB4 | KEY_S1 | GPIO 输入（低电平有效） |
| PG15 | KEY_S2 | GPIO 输入（低电平有效） |
| PB3 | KEY_S3 | GPIO 输入（低电平有效） |
| PB5 | KEY_S4 | GPIO 输入（低电平有效） |
| **AD9959 (SPI 模拟)** | | |
| PA4 | AD9959_UPD | 更新引脚 |
| PA7 | AD9959_SCL | SPI 时钟 |
| PC4 | AD9959_RST | 复位 |
| PC5 | AD9959_CS | 片选 |
| PB0 | AD9959_SDA | 数据线 |
| **LCD (SPI4)** | | |
| PE3 | LCD_CS | 片选 |
| PE4 | LCD_DC | 数据/命令选择 |
| PE5 | LCD_RST | 复位 |

### 9.3 串口

| 接口 | TX | RX | 用途 |
|------|----|----|------|
| USART1 | (CubeMX 配置) | (CubeMX 配置) | 调试输出（115200 8N1） |
| USART2 | (CubeMX 配置) | (CubeMX 配置) | 命令交互 |

> 具体 TX/RX 引脚号请查阅 CubeMX `.ioc` 文件或 `stm32h7xx_hal_msp.c`。

---

## 10. 常见问题与调试

### 10.1 FPGA 通信问题

**症状**：DDS 或 ADC 寄存器读回全 `0` 或全 `F`。

**排查**：
- 确认 FPGA 已正确加载比特流（检查 FPGA DONE 指示灯）
- 检查 FMC 时序配置（`fmc.c` 中的 `AddressSetupTime`、`DataSetupTime` 等参数）
- 用示波器检查 FMC 总线上的片选 (NE1)、写使能 (NWE)、输出使能 (NOE) 信号

### 10.2 ADC 采集问题

**症状**：`ADC_CaptureReadId()` 返回值不是 `0x9220`。

**原因**：
- FPGA 逻辑中 ADC 模块未包含
- FMC 通信异常
- 解决方法：检查 FPGA 工程，确保包含 ADC 采集逻辑

**症状**：MDMA 传输超时。

**原因**：
- ADC 采集未完成
- 采样点数过多
- 解决方法：增加超时时间，检查 `ADC_CaptureWaitDone` 返回值

### 10.3 DMA 缓冲区问题

**关键**：STM32H7 的 DMA1 无法访问 DTCM RAM（`0x2000_0000`）。任何用于 DMA 传输的缓冲区**必须**位于 AXI SRAM（`0x2400_0000`）。

代码中已正确处理：
- 片内 ADC 缓冲区 → `__attribute__((section(".ARM.__at_0x24000000")))`
- ADC 采集缓冲区 → `__attribute__((section(".axisram")))`

### 10.4 Cache 一致性

当 CPU 通过 DMA 或 FPGA（经 FMC）读取/写入数据时，需要注意 D-Cache 一致性：

- **CPU 写 → DMA 读**：写后需 `SCB_CleanDCache_by_Addr()`
- **DMA 写 → CPU 读**：读前需 `SCB_InvalidateDCache_by_Addr()`
- **FPGA 寄存器**：FMC 区域已配置为 Non-cacheable，无需特殊处理

### 10.5 调试输出

USART1 在启动时会输出如下调试信息：

```
========================================
  DDS_AD9740  Arbitrary Waveform Gen
  UART TX: 115200 8N1  (output only)
========================================
!!!!!! MPU_InitStruct.SubRegionDisable = 0x00 !!!!!!
STM32H723VGT6
M22
Init DDS...

--- Control Registers ---
FTW_LO    (0x0400) = ...
FTW_HI    (0x0401) = ...
DAC_CTRL  (0x040C) = ENABLED

--- Waveform RAM [0..15] / 1024 ---
  RAM :  ...
--- End of Register Dump ---
```

如未看到这些输出，请检查：
- 串口配置：**115200, 8, N, 1**
- 串口终端软件连接的是 USART1 引脚
- MCU 是否正常启动（LED 有闪烁）

### 10.6 编译错误

| 错误 | 可能原因 |
|------|----------|
| `undefined symbol __section__` | 链接脚本 `.sct` 中缺少对应段定义 |
| `cannot access DTCM` | DMA 缓冲区地址配置错误，未使用 AXI SRAM |
| `HAL_Delay` 不工作 | SysTick 中断未启用或 HAL_Init 未调用 |

---

## 11. 附录：API 速查表

### DDS（FPGA 波形发生器）

```
DDS_Init()
DDS_SetWaveform(type, params)
DDS_LoadWaveform(lut)
DDS_SetFrequency(freq_hz)
DDS_ReadFrequency()
DDS_EnableDAC() / DDS_DisableDAC()
DDS_PhaseReset()
DDS_VerifyWaveform(expected, count)
DDS_CalcChecksum(start, count)
```

### ADC Capture（FPGA 采集）

```
ADC_CaptureReadId()
ADC_CaptureReadStatus()
ADC_CaptureReadActualCount()
ADC_CaptureClear()
ADC_CaptureStart(sample_count)
ADC_CaptureStop()
ADC_CaptureWaitDone(timeout_ms)
ADC_CaptureReadMDMA(buffer, count, timeout_ms)
```

### AD9959（四通道 DDS）

```
AD9959_Init()
AD9959_Config(channel, freq, phase, amp)
```

### 片内 ADC

```
myADC_Start_DMA(handle)
myADC_Stop_DMA(handle)
myADC_DualStart_DMA(handle)
myADC_DualStop_DMA(handle)
```

### LCD

```
LCD_Init(blcd, font_en, font_cn, fc, bc)
LCD_Clear(blcd, color)
LCD_Fill(blcd, x, y, w, h, color)
LCD_Print(blcd, x, y, format, ...)
LCD_DrawPoint(blcd, x, y, color)
LCD_DrawLine(blcd, x1, y1, x2, y2, color)
LCD_DrawHLine(blcd, x, y, len, color)
LCD_DrawVLine(blcd, x, y, len, color)
LCD_DrawRect(blcd, x1, y1, x2, y2, color)
```

### UART

```
BSP_UART_Start_Receive_DMA(huart)
BSP_UART_Transmit_DMA(huart, format, ...)
BSP_UART_Receive_DMA(huart)
```

### GPIO

```
LED_1_On() / LED_1_Off() / LED_1_Toggle()
LED_2_On() / LED_2_Off() / LED_2_Toggle()
LED_3_On() / LED_3_Off() / LED_3_Toggle()
KEY_Read()
KEYEx_Read()
```

---

*文档版本：v1.0 — 基于代码 commit 生成*
*MCU：STM32H723ZGTx @ 550 MHz*
*IDE：Keil MDK-ARM v5 (μVision5)*
