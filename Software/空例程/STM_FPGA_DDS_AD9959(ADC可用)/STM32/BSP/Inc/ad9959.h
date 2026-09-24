//
// Created by 24016 on 2023/4/17.
//

#ifndef STM32H7_2019D_AD9959_H
#define STM32H7_2019D_AD9959_H

#include "stdint.h"
#include "main.h"
//AD9959寄存器地址定义
#define CSR_ADD   0x00   //CSR 通道选择寄存器
#define FR1_ADD   0x01   //FR1 功能寄存器1
#define FR2_ADD   0x02   //FR2 功能寄存器2
#define CFR_ADD   0x03   //CFR 通道功能寄存器
#define CFTW0_ADD 0x04   //CTW0 通道频率转换字寄存器
#define CPOW0_ADD 0x05   //CPW0 通道相位转换字寄存器
#define ACR_ADD   0x06   //ACR 幅度控制寄存器
#define LSRR_ADD  0x07   //LSR 通道线性扫描寄存器
#define RDW_ADD   0x08   //RDW 通道线性向上扫描寄存器
#define FDW_ADD   0x09   //FDW 通道线性向下扫描寄存器
//AD9959管脚宏定义

#define CS_Pin			    GPIO_PIN_7
#define CS_Port		    GPIOB
#define SCLK_Pin		    GPIO_PIN_8
#define SCLK_Port	    GPIOB
#define UPDATE_Pin	        GPIO_PIN_6
#define UPDATE_Port	    GPIOB
#define PS0_Pin             GPIO_PIN_10
#define PS0_Port        GPIOG
#define PS1_Pin			    GPIO_PIN_12
#define PS1_Port	    GPIOG
#define PS2_Pin			    GPIO_PIN_13
#define PS2_Port	    GPIOG
#define PS3_Pin			    GPIO_PIN_14
#define PS3_Port	    GPIOG
#define SDIO0_Pin		    GPIO_PIN_9
#define SDIO0_Port	    GPIOB
#define SDIO1_Pin		    GPIO_PIN_2
#define SDIO1_Port	    GPIOE
#define SDIO2_Pin		    GPIO_PIN_3
#define SDIO2_Port	    GPIOE
#define SDIO3_Pin		    GPIO_PIN_4
#define SDIO3_Port	    GPIOE
#define AD9959_PWR_Pin	    GPIO_PIN_6
#define AD9959_PWR_Port	GPIOE
#define Reset_Pin		    GPIO_PIN_5
#define Reset_Port		GPIOE

void delay1 (uint32_t length);
void IntReset(void);	  //AD9959复位
void IO_Update(void);   //AD9959更新数据
void Intserve(void);		   //IO口初始化
void WriteData_AD9959(uint8_t RegisterAddress, uint8_t NumberofRegisters, uint8_t *RegisterData,uint8_t temp);
void Init_AD9959(void);
void Write_frequence(uint8_t Channel,uint32_t Freq);
void Write_Amplitude(uint8_t Channel, uint16_t Ampli);
void Write_Phase(uint8_t Channel,uint16_t Phase);



#endif //STM32H7_2019D_AD9959_H








