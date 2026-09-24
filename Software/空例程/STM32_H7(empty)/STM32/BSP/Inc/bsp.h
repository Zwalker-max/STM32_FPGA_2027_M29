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

/* H723 memory regions defined by BSP_fpga/FMC_DEMO.sct. */
#define BSP_AXI_SRAM	__attribute__((section(".axi_sram"), aligned(32)))
#define BSP_DMA_BUFFER	__attribute__((section(".dma_buffer"), aligned(32)))

#define sweep 256

/* BSP application entry point for STM32H723. */

void MainProcess(void);

#endif /* __BSP_H__ */
