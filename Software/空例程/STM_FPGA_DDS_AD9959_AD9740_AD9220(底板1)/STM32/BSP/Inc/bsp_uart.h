#ifndef __BSP_UART_H__
#define __BSP_UART_H__

#include "bsp.h"


#define UART_BufSize	128		// No more than 255

typedef struct {
	UART_HandleTypeDef *huart;
	char UART_TxBuf[UART_BufSize];
	char UART_RxBuf[UART_BufSize];
	char UART_RxMsg[UART_BufSize];
	__IOM bool RxMsgUsed;
} BSP_UART_HandleTypeDef;

void BSP_UART_Start_Receive_DMA(BSP_UART_HandleTypeDef *myhuart);
void BSP_UART_Transmit_DMA(BSP_UART_HandleTypeDef *myhuart, const char *format, ...);
void BSP_UART_Receive_DMA(BSP_UART_HandleTypeDef *myhuart);

#endif /* __BSP_UART_H__ */
