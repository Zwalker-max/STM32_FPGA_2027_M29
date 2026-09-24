#ifndef __BSP_H__
#define __BSP_H__

#include "main.h"
#include "gpio.h"
#include "tim.h"
#include "usart.h"
#include "adc.h"
#include "spi.h"

#include <math.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

/* Macro for STM32H7 devices */
#define __ZI_AXI_SRAM	__attribute__((section(".bss.RAM_D1")))
#define __RW_AXI_SRAM	__attribute__((section(".data.RAM_D1")))

#define sweep 256

// 使用单精度浮点数提高STM32G4性能

void MainProcess(void);

#endif /* __BSP_H__ */
