#include "bsp_uart.h"

HAL_StatusTypeDef BSP_UART_ReceiveToIdle_DMA(BSP_UART_HandleTypeDef *buart)
{
	if ((buart == NULL) || (buart->huart == NULL) ||
	    (buart->huart->hdmarx == NULL) || (buart->pRxMsg == NULL)) {
		return HAL_ERROR;
	}
	memset(buart->pRxMsg, 0, UART_BUF_SIZE);
	HAL_StatusTypeDef status = HAL_UARTEx_ReceiveToIdle_DMA(
		buart->huart, (uint8_t *)buart->pRxMsg, UART_BUF_SIZE - 1U);
	if (status != HAL_OK) {
		return status;
	}
	__HAL_DMA_DISABLE_IT(buart->huart->hdmarx, DMA_IT_HT);
	return HAL_OK;
}

HAL_StatusTypeDef BSP_UART_Transmit_DMA(BSP_UART_HandleTypeDef *buart,
                                        const char *format, ...)
{
	va_list ap;
	int length;

	if ((buart == NULL) || (buart->huart == NULL) ||
	    (buart->huart->hdmatx == NULL) || (buart->pTxMsg == NULL) ||
	    (format == NULL)) {
		return HAL_ERROR;
	}
	if ((buart->huart->gState != HAL_UART_STATE_READY) ||
	    (buart->huart->hdmatx->State != HAL_DMA_STATE_READY)) {
		return HAL_BUSY;
	}

	va_start(ap, format);
	length = vsnprintf(buart->pTxMsg, UART_BUF_SIZE, format, ap);
	va_end(ap);

	if (length < 0) {
		return HAL_ERROR;
	}
	if (length >= (int)UART_BUF_SIZE) {
		length = (int)UART_BUF_SIZE - 1;
	}
	return HAL_UART_Transmit_DMA(buart->huart, (uint8_t *)buart->pTxMsg,
	                             (uint16_t)length);
}
