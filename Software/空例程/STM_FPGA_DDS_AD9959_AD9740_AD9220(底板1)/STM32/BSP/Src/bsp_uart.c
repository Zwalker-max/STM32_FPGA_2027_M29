#include "bsp_uart.h"


void BSP_UART_Start_Receive_DMA(BSP_UART_HandleTypeDef *myhuart)
{
	HAL_UARTEx_ReceiveToIdle_DMA(myhuart->huart, (uint8_t *)myhuart->UART_RxBuf, UART_BufSize);
}

void BSP_UART_Transmit_DMA(BSP_UART_HandleTypeDef *myhuart, const char *format, ...) {
    uint32_t tickstart = HAL_GetTick();
    while (myhuart->huart->gState != HAL_UART_STATE_READY ||
           myhuart->huart->hdmatx->State != HAL_DMA_STATE_READY)
    {
        if ((HAL_GetTick() - tickstart) > 1000UL)
        {
            myhuart->huart->hdmatx->State = HAL_DMA_STATE_READY;
            myhuart->huart->gState = HAL_UART_STATE_READY;
            break;
        }
    }
    va_list ap;
    va_start(ap, format);
    int Size = vsnprintf(myhuart->UART_TxBuf, UART_BufSize, format, ap);
    if (Size <= 0) Error_Handler();
    va_end(ap);
    /* Clean D-Cache to ensure DMA sees latest CPU data */
    SCB_CleanDCache_by_Addr((uint32_t*)myhuart->UART_TxBuf, Size);
    if (HAL_UART_Transmit_DMA(myhuart->huart, (uint8_t *)myhuart->UART_TxBuf, Size) != HAL_OK)
    {
        Error_Handler();
    }
}

void BSP_UART_Receive_DMA(BSP_UART_HandleTypeDef *myhuart)
{
	memcpy(myhuart->UART_RxMsg, myhuart->UART_RxBuf, UART_BufSize);
	memset(myhuart->UART_RxBuf, 0, UART_BufSize);
}