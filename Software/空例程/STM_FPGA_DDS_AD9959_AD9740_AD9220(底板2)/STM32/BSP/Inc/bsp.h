#ifndef __BSP_H__
#define __BSP_H__

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

#include "main.h"
#include "spi.h"
#include "tim.h"
#include "usart.h"
#include "adc.h" 


/* Macro for STM32H7 devices */
#define __ZI_AXI_SRAM	__attribute__((section(".bss.RAM_D1")))
#define __RW_AXI_SRAM	__attribute__((section(".data.RAM_D1")))

void MainProcess(void);

#endif /* __BSP_H__ */
