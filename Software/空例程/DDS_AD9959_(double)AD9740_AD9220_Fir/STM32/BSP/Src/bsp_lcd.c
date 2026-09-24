#include "bsp_lcd.h"
#include "math.h"

#define LCD_RST_WR(x)	HAL_GPIO_WritePin(LCD_RST_GPIO_Port, LCD_RST_Pin, x)
#define LCD_DC_WR(x)	HAL_GPIO_WritePin(LCD_DC_GPIO_Port,  LCD_DC_Pin,  x)
#define LCD_CS_WR(x)	HAL_GPIO_WritePin(LCD_CS_GPIO_Port,  LCD_CS_Pin,  x)

#define NUMARGS(...)	(sizeof((uint8_t[]){__VA_ARGS__}) / sizeof(uint8_t))

#define LCD_ConfigReg(__blcd__, ...) \
		LCD_WriteRegData(__blcd__, NUMARGS(__VA_ARGS__), __VA_ARGS__)

const uint8_t lcd_dir_code[4] = { 0x00, 0xC0, 0x60, 0xA0 };

const LCD_TypeDef LCD_1_69_inch = {
	.width   = 240,
	.height  = 280,
	.inverse = 0x21,
	.xBias   = {  0,  0, 20, 20 },
	.yBias   = { 20, 20,  0,  0 },
};

const LCD_TypeDef LCD_1_80_inch = {
	.width   = 128,
	.height  = 160,
	.inverse = 0x20,
	.xBias   = { 2, 2, 1, 1 },
	.yBias   = { 1, 1, 2, 2 },
};

const LCD_TypeDef LCD_2_00_inch = {
	.width   = 240,
	.height  = 320,
	.inverse = 0x21,
	.xBias   = { 0, 0, 0, 0 },
	.yBias   = { 0, 0, 0, 0 },
};

static void LCD_Transmit(LCD_HandleTypeDef *blcd, uint8_t *pData, uint16_t size)
{
	HAL_SPI_Transmit(blcd->hspi, pData, size, 0xFFFF);
}

static void LCD_WriteRegData(LCD_HandleTypeDef *blcd, uint32_t cnt, ...)
{
	va_list ap;
	va_start(ap, cnt);
	
	uint8_t *ptr = (uint8_t *)blcd->TxBuf;
	for (uint8_t i = 0; i < cnt; ++i)
		ptr[i] = va_arg(ap, uint32_t);
	
	LCD_DC_WR(0);
	LCD_Transmit(blcd, ptr, 1);
	
	LCD_DC_WR(1);
	if (--cnt) LCD_Transmit(blcd, ++ptr, cnt);
	
	va_end(ap);
}

void LCD_Init(LCD_HandleTypeDef *blcd, const LCD_FontTypeDef *font_en, const LCD_FontTypeDef *font_cn, LCD_ColorTypeDef fc, LCD_ColorTypeDef bc)
{
	switch (blcd->dir)
	{
		case LCD_DIR_TOP:
		case LCD_DIR_BOTTOM:
			blcd->xLen = blcd->Instance->width;
			blcd->yLen = blcd->Instance->height;
			break;
		
		case LCD_DIR_LEFT:
		case LCD_DIR_RIGHT:
			blcd->xLen = blcd->Instance->height;
			blcd->yLen = blcd->Instance->width;
			break;
	}
	
	LCD_RST_WR(0);
	LCD_RST_WR(1);
	HAL_Delay(5);
	
	LCD_CS_WR(0);
	LCD_ConfigReg(blcd, 0x11);
	HAL_Delay(5);
	
	LCD_ConfigReg(blcd, 0x36, lcd_dir_code[blcd->dir]);
	LCD_ConfigReg(blcd, 0x3A, 0x55);
	LCD_ConfigReg(blcd, blcd->Instance->inverse);
	LCD_ConfigReg(blcd, 0x29);
	
	LCD_ConfigFont(blcd, font_en, font_cn, fc, bc);
	LCD_Clear(blcd, bc);
}

void LCD_ConfigFont(LCD_HandleTypeDef *blcd, const LCD_FontTypeDef *font_en, const LCD_FontTypeDef *font_cn, LCD_ColorTypeDef fc, LCD_ColorTypeDef bc)
{
	blcd->font_en   = font_en;
	blcd->font_cn   = font_cn;
	blcd->foreColor = fc;
	blcd->backColor = bc;
}

static void LCD_SetAddress(LCD_HandleTypeDef *blcd, uint16_t xpos, uint16_t ypos, uint16_t xsize, uint16_t ysize)
{
	uint16_t x1 = xpos + blcd->Instance->xBias[blcd->dir], x2 = x1 + xsize - 1;
	uint16_t y1 = ypos + blcd->Instance->yBias[blcd->dir], y2 = y1 + ysize - 1;
	LCD_ConfigReg(blcd, 0x2A, x1 >> 8, x1, x2 >> 8, x2);
	LCD_ConfigReg(blcd, 0x2B, y1 >> 8, y1, y2 >> 8, y2);
	LCD_ConfigReg(blcd, 0x2C);
}

void LCD_Clear(LCD_HandleTypeDef *blcd, LCD_ColorTypeDef color)
{
	LCD_Fill(blcd, 0, 0, blcd->xLen, blcd->yLen, color);
}

void LCD_Fill(LCD_HandleTypeDef *blcd, uint16_t xpos, uint16_t ypos, uint16_t xsize, uint16_t ysize, LCD_ColorTypeDef color)
{
	LCD_SetAddress(blcd, xpos, ypos, xsize, ysize);
	for (uint16_t i = 0; i < xsize; ++i)
		blcd->TxBuf[i] = color;
	for (uint16_t i = 0; i < ysize; ++i)
		LCD_Transmit(blcd, (uint8_t *)blcd->TxBuf, xsize * 2);
}

static void LCD_PrintChar_en(LCD_HandleTypeDef *blcd, uint16_t xpos, uint16_t ypos, char *ptr)
{
	if (xpos + blcd->font_en->xSize > blcd->xLen) return;
	if (ypos + blcd->font_en->ySize > blcd->yLen) return;
	
	uint8_t *addr = blcd->font_en->addr + blcd->font_en->nByte * (*ptr - 32);
	LCD_SetAddress(blcd, xpos, ypos, blcd->font_en->xSize, blcd->font_en->ySize);
	for (uint16_t i = 0; i < blcd->font_en->nByte * 8; ++i)
		blcd->TxBuf[i] = addr[i / 8] & (0x01 << (i % 8)) ? blcd->foreColor : blcd->backColor;
	LCD_Transmit(blcd, (uint8_t *)blcd->TxBuf, blcd->font_en->nByte * 16);
}

//static void LCD_PrintChar_cn(LCD_HandleTypeDef *blcd, uint16_t xpos, uint16_t ypos, char *ptr)
//{
//	if (xpos + blcd->font_cn->xSize > blcd->xLen) return;
//	if (ypos + blcd->font_cn->ySize > blcd->yLen) return;
//	
//	uint16_t idx = 0;
//	uint8_t *map = blcd->font_cn->map;
//	while (map[idx] && (map[idx] != ptr[0] || map[idx + 1] != ptr[1])) idx += 2;
//	if (map[idx] == NULL) return;
//	
//	uint8_t *addr = blcd->font_cn->addr + blcd->font_cn->nByte * idx / 2;
//	LCD_SetAddress(blcd, xpos, ypos, blcd->font_cn->xSize, blcd->font_cn->ySize);
//	for (uint16_t i = 0; i < blcd->font_cn->nByte * 8; ++i)
//		blcd->TxBuf[i] = addr[i / 8] & (0x01 << (i % 8)) ? blcd->foreColor : blcd->backColor;
//	LCD_Transmit(blcd, (uint8_t *)blcd->TxBuf, blcd->font_cn->nByte * 16);
//}


//void LCD_Print(LCD_HandleTypeDef *blcd, uint16_t xpos, uint16_t ypos, const char *format, ...)
//{
//	char str[64];
//	va_list ap;
//	va_start(ap, format);
//	vsnprintf(str, sizeof(str), format, ap);
//	va_end(ap);
//	
//	char *ptr = str;
//	while (*ptr)
//	{
//		if (*ptr >= 0x20 && *ptr < 0x7F)
//		{
//			LCD_PrintChar_en(blcd, xpos, ypos, ptr);
//			xpos += blcd->font_en->xSize;
//			ptr += 1;
//		}
//		else if (blcd->font_cn && *ptr >= 0x80)
//		{
//			LCD_PrintChar_cn(blcd, xpos, ypos, ptr);
//			xpos += blcd->font_cn->xSize;
//			ptr += 2;
//		}
//	}
//}


static void LCD_PrintChar_cn(LCD_HandleTypeDef *blcd, uint16_t xpos, uint16_t ypos, char *ptr) 
{
    if (blcd->font_cn == NULL) return;
    if (xpos + blcd->font_cn->xSize > blcd->xLen) return;
    if (ypos + blcd->font_cn->ySize > blcd->yLen) return;  
    uint16_t idx = 0;
    uint8_t *map = blcd->font_cn->map;
    while (map[idx] != 0 && !(map[idx] == ptr[0] && map[idx+1] == ptr[1])) {
        idx += 2;
    }
    if (map[idx] == 0) return;  
    uint8_t *addr = blcd->font_cn->addr + blcd->font_cn->nByte * (idx/2);
    LCD_SetAddress(blcd, xpos, ypos, blcd->font_cn->xSize, blcd->font_cn->ySize);
    uint16_t buf_index = 0;
    for (uint16_t byte = 0; byte < blcd->font_cn->nByte; byte++) {
        uint8_t bits = addr[byte];
        for (uint8_t bit = 0; bit < 8; bit++) {

            if (blcd->font_cn->xSize == 12) {
                uint16_t col = (byte * 8 + bit) % 16;
                if (col >= 12) continue;  
            }           
            blcd->TxBuf[buf_index++] = (bits & (0x01 << bit)) 
                                       ? blcd->foreColor 
                                       : blcd->backColor;
        }
    }   
    uint32_t total_bytes = blcd->font_cn->xSize * blcd->font_cn->ySize * 2;
    LCD_Transmit(blcd, (uint8_t *)blcd->TxBuf, total_bytes);
}

void LCD_Print(LCD_HandleTypeDef *blcd, uint16_t xpos, uint16_t ypos, const char *format, ...)
{
    char str[64];
    va_list ap;
    va_start(ap, format);
    vsnprintf(str, sizeof(str), format, ap);
    va_end(ap);
    
    char *ptr = str;
    while (*ptr) {
        if (*ptr >= 0x20 && *ptr < 0x7F) {  
            LCD_PrintChar_en(blcd, xpos, ypos, ptr);
            xpos += blcd->font_en->xSize;
            ptr += 1;
        } else if (*ptr >= 0x80 && blcd->font_cn != NULL) { 
            LCD_PrintChar_cn(blcd, xpos, ypos, ptr); 
            xpos += blcd->font_cn->xSize;
            ptr += 2;
        } else {
            ptr++;
        }
    }
}

static int MIN(int A,int B)
{
	if(A<=B)
		return A;
	else
		return B;
}
static int MAX(int A,int B)
{
	if(A>=B)
		return A;
	else
		return B;
}

void LCD_DrawPoint(LCD_HandleTypeDef *blcd, uint16_t xpos, uint16_t ypos, LCD_ColorTypeDef color)
{
    // 检查坐标是否有效
    if (xpos >= blcd->xLen || ypos >= blcd->yLen) return;
    
    // 设置单点显示区域
    LCD_SetAddress(blcd, xpos, ypos, 1, 1);
    
    // 准备颜色数据 (2字节)
    uint8_t colorData[2] = {color >> 8, color & 0xFF};
    
    // 发送颜色数据
    LCD_DC_WR(1);
    LCD_Transmit(blcd, colorData, 2);
}

void LCD_DrawHLine(LCD_HandleTypeDef *blcd, uint16_t x, uint16_t y, uint16_t len, LCD_ColorTypeDef color)
{
    if (y >= blcd->yLen) return;
    if (x >= blcd->xLen) return;
    
    // 调整长度防止越界
    if (x + len > blcd->xLen)
        len = blcd->xLen - x;
    
    // 设置水平线区域
    LCD_SetAddress(blcd, x, y, len, 1);
    
    // 准备颜色数据缓冲区
    uint16_t bufSize = len * 2;
    uint8_t *pBuf = (uint8_t*)blcd->TxBuf;
    
    // 填充缓冲区
    for (uint16_t i = 0; i < bufSize; i += 2)
    {
        pBuf[i] = color >> 8;
        pBuf[i+1] = color & 0xFF;
    }
    
    // 发送数据
    LCD_DC_WR(1);
    LCD_Transmit(blcd, pBuf, bufSize);
}

void LCD_DrawVLine(LCD_HandleTypeDef *blcd, uint16_t x, uint16_t y, uint16_t len, LCD_ColorTypeDef color)
{
    if (x >= blcd->xLen) return;
    if (y >= blcd->yLen) return;
    
    // 调整长度防止越界
    if (y + len > blcd->yLen)
        len = blcd->yLen - y;
    
    // 设置垂直线区域
    LCD_SetAddress(blcd, x, y, 1, len);
    
    // 准备颜色数据缓冲区
    uint16_t bufSize = len * 2;
    uint8_t *pBuf = (uint8_t*)blcd->TxBuf;
    
    // 填充缓冲区
    for (uint16_t i = 0; i < bufSize; i += 2)
    {
        pBuf[i] = color >> 8;
        pBuf[i+1] = color & 0xFF;
    }
    
    // 发送数据
    LCD_DC_WR(1);
    LCD_Transmit(blcd, pBuf, bufSize);
}

void LCD_DrawLine(LCD_HandleTypeDef *blcd, uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2, LCD_ColorTypeDef color)
{
    // 检查边界
    if (x1 >= blcd->xLen || x2 >= blcd->xLen || 
        y1 >= blcd->yLen || y2 >= blcd->yLen) 
        return;
    
    int dx = abs(x2 - x1);
    int dy = abs(y2 - y1);
    int sx = (x1 < x2) ? 1 : -1;
    int sy = (y1 < y2) ? 1 : -1;
    int err = dx - dy;
    
    // 特殊处理：水平线
    if (dy == 0)
    {
        LCD_DrawHLine(blcd, MIN(x1, x2), y1, dx + 1, color);
        return;
    }
    
    // 特殊处理：垂直线
    if (dx == 0)
    {
        LCD_DrawVLine(blcd, x1, MIN(y1, y2), dy + 1, color);
        return;
    }
    
    // Bresenham算法绘制斜线
    while (1)
    {
        LCD_DrawPoint(blcd, x1, y1, color);
        
        if (x1 == x2 && y1 == y2) break;
        
        int e2 = 2 * err;
        if (e2 > -dy)
        {
            err -= dy;
            x1 += sx;
        }
        if (e2 < dx)
        {
            err += dx;
            y1 += sy;
        }
    }
}

void LCD_DrawRect(LCD_HandleTypeDef *blcd, uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2, LCD_ColorTypeDef color)
{
    uint16_t minX = MIN(x1, x2);
    uint16_t maxX = MAX(x1, x2);
    uint16_t minY = MIN(y1, y2);
    uint16_t maxY = MAX(y1, y2);
    
    LCD_DrawHLine(blcd, minX, minY, maxX - minX + 1, color);
    LCD_DrawHLine(blcd, minX, maxY, maxX - minX + 1, color);
    LCD_DrawVLine(blcd, minX, minY, maxY - minY + 1, color);
    LCD_DrawVLine(blcd, maxX, minY, maxY - minY + 1, color);
}
