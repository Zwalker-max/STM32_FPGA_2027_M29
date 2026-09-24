from machine import Pin, mem32, UART
from rp2 import PIO, StateMachine, asm_pio
from array import array
import math 
from uctypes import addressof
from random import random
from micropython import const
import machine
from time import sleep,ticks_ms, ticks_diff

import uasyncio as asyncio
#################################SETTINGS#######################################

DMA_BASE = const(0x50000000)

CH0_READ_ADDR = const(DMA_BASE+0x000)
CH0_WRITE_ADDR = const(DMA_BASE+0x004)
CH0_TRANS_COUNT = const(DMA_BASE+0x008)
CH0_CTRL_TRIG = const(DMA_BASE+0x00c)
CH0_AL1_CTRL = const(DMA_BASE+0x010)

CH1_READ_ADDR = const(DMA_BASE+0x040)
CH1_WRITE_ADDR = const(DMA_BASE+0x044)
CH1_TRANS_COUNT = const(DMA_BASE+0x048)
CH1_CTRL_TRIG = const(DMA_BASE+0x04c)
CH1_AL1_CTRL = const(DMA_BASE+0x050)

PIO0_BASE = const(0x50200000)
PIO0_TXF0 = const(PIO0_BASE+0x10)
PIO0_SM0_CLKDIV = const(PIO0_BASE+0xc8)

# 新增通道2-3寄存器
CH2_READ_ADDR = const(DMA_BASE+0x080)  # 通道2基址偏移0x080
CH2_WRITE_ADDR = const(DMA_BASE+0x084)
CH2_TRANS_COUNT = const(DMA_BASE+0x088)
CH2_CTRL_TRIG = const(DMA_BASE+0x08c)
CH2_AL1_CTRL = const(DMA_BASE+0x090)

CH3_READ_ADDR = const(DMA_BASE+0x0c0)  # 通道3基址偏移0x0c0
CH3_WRITE_ADDR = const(DMA_BASE+0x0c4)
CH3_TRANS_COUNT = const(DMA_BASE+0x0c8)
CH3_CTRL_TRIG = const(DMA_BASE+0x0cc)
CH3_AL1_CTRL = const(DMA_BASE+0x0d0)

PIO0_TXF1 = const(PIO0_BASE + 0x14)  # SM1 TX FIFO地址
PIO0_SM1_CLKDIV = const(PIO0_BASE + 0x0e0)  # SM1时钟分频
PIO0_CTRL = const(PIO0_BASE + 0x00)  # 控制寄存器地址

CHAN_ABORT =const(DMA_BASE + 0x444)   # DMA_CHAN_ABORT 寄存器地址

#超频到250Mhz，在高负载时内核电压会掉到1v左右，无法稳定运行，这里设置为1.2V
VREG= const(0x40064000) # 内核电压控制寄存器
current_value = machine.mem32[VREG] # 读取当前寄存器值
current_value &= ~(0xF << 4) # 清除原电压配置（保留其他位），默认为1.1V
new_value = current_value | (0xE << 4) # 设置新电压值：0xD（1.20V）
machine.mem32[VREG] = new_value # 写入新值

# clock frequency of the pico
fclock = const(250000000)  
dac_clock = int(fclock/2)
machine.freq(fclock)#将时钟超频到250Mhz

# make buffers for the waveform.
# large buffers give better results but are slower to fill
maxnsamp = const(4096)  # must be a multiple of 4. miximum size is 65536

# ====================== PIO程序 ======================
@asm_pio(sideset_init=(PIO.OUT_HIGH,),
         out_init=(PIO.OUT_HIGH,)*12,
         out_shiftdir=PIO.SHIFT_RIGHT,
         fifo_join=PIO.JOIN_TX,
         autopull=True,
         pull_thresh=24)
def stream():
    wrap_target()
    out(pins, 12) .side(0)
    nop() 		.side(1)
    wrap()

# 2-channel chained DMA. channel 0 does the transfer, channel 1 reconfigures
p0 = array('I', [0])  # global 1-element array
p1= array('I', [0])  # global 1-element array

def startDMA(channel, ar, nword):
    if channel==0:
        mem32[CH0_CTRL_TRIG] = 0
        mem32[CH1_CTRL_TRIG] = 0
        mem32[CH0_READ_ADDR] = addressof(ar)
        mem32[CH0_WRITE_ADDR] = PIO0_TXF0
        mem32[CH0_TRANS_COUNT] = nword
        CTRL0 = ((0x1 << 21) | (0x00 << 15) | (1 << 11) | (0 << 10) | (0 << 9) | 
                (0 << 5) | (1 << 4) | (2 << 2) | (0 << 1) | 1)
        mem32[CH0_CTRL_TRIG] = CTRL0
        
        # 链式DMA配置
        p0[0] = addressof(ar)
        # data = f"p0: {p0}\n".encode('utf-8')
        # UartCmd.uart.write(data)
        mem32[CH1_READ_ADDR] = addressof(p0)
        mem32[CH1_WRITE_ADDR] = CH0_READ_ADDR
        mem32[CH1_TRANS_COUNT] = 1
        CTRL1 = ((0x1 << 21) | (0x3f << 15) | (0 << 11) | (0 << 10) | (0 << 9) | 
                (0 << 5) | (0 << 4) | (2 << 2) | (0 << 1) | 1)
        mem32[CH1_CTRL_TRIG] = CTRL1

    # setup second DMA which reconfigures the first channel
    else :
        mem32[CH2_CTRL_TRIG] = 0
        mem32[CH3_CTRL_TRIG] = 0
        mem32[CH2_READ_ADDR] = addressof(ar)
        mem32[CH2_WRITE_ADDR] = PIO0_TXF1
        mem32[CH2_TRANS_COUNT] = nword
        CTRL2 = ((0x1 << 21) | (0x01 << 15) | (3 << 11) | (0 << 10) | (0 << 9) | 
                (0 << 5) | (1 << 4) | (2 << 2) | (1 << 1) | 1)
        mem32[CH2_CTRL_TRIG] = CTRL2
        
        # 链式DMA配置
        p1[0] = addressof(ar)
        # data = f"p1: {p1}\n".encode('utf-8')
        # UartCmd.uart.write(data)
        mem32[CH3_READ_ADDR] = addressof(p1)
        mem32[CH3_WRITE_ADDR] = CH2_READ_ADDR
        mem32[CH3_TRANS_COUNT] = 1
        CTRL3 =( (0x1 << 21) | (0x3f << 15) | (2 << 11) | (0 << 10) | (0 << 9) | 
                (0 << 5) | (0 << 4) | (2 << 2) | (1 << 1) | 1)
        mem32[CH3_CTRL_TRIG] = CTRL3

def setupwave(buf, Signal):
    
    div = dac_clock/(Signal.fre*maxnsamp)
    if div < 1.0:
        dup = int(1.0/div)
        Signal.nsamp = int((maxnsamp*div*dup+0.5)/4)*4
        clkdiv = 1
    else:
        clkdiv = int(div)+1
        Signal.nsamp = int((maxnsamp*div/clkdiv+0.5)/4)*4
        dup = 1
    
    phase=float(Signal.phase)
    offset=Signal.offset

    if Signal.type == 'dco' : offset=0
    #相位设置范围0-360°，转换为0-2pi
    if(phase > 360) or (phase < 0):
        phase=phase%360
    phase=phase*math.pi/180

    # data = f"phase: {phase}\n".encode('utf-8')
    # UartCmd.uart.write(data)
    for iword in range(int(Signal.nsamp/2)):
        val1 = int(Signal.amp * waveform_generator(Signal,dup * iword*2 / Signal.nsamp,phase)) + offset
        val2 = int(Signal.amp * waveform_generator(Signal,dup * (iword*2+1) / Signal.nsamp,phase)) + offset

        word = val1 + (val2 << 12)
        buf[iword*4+0] = (word & (255 << 0)) >> 0
        buf[iword*4+1] = (word & (255 << 8)) >> 8
        buf[iword*4+2] = (word & (255 << 16)) >> 16
        buf[iword*4+3] = (word & (255 << 24)) >> 24
    
    clkdiv_int = min(clkdiv, 65535)
    clkdiv_frac = 0  # fractional clock division results in jitter
    # 设置对应状态机的时钟
    if Signal.channel==0:
        mem32[PIO0_SM0_CLKDIV] = (clkdiv_int << 16) | (clkdiv_frac << 8)
    else:
        mem32[PIO0_SM1_CLKDIV] = (clkdiv_int << 16) | (clkdiv_frac << 8)
    
    startDMA(Signal.channel,buf, int(Signal.nsamp/2))    

#计算波形参数，输入波形数据与时间
def waveform_generator(Signal, t,phase=0.0):
    #正弦波 
    if Signal.type == 'sin':
        return math.sin(2 * math.pi* t + phase)
    #方波
    elif Signal.type == 'sqe':
        return 1.0 if (math.sin(2 * math.pi * t + phase) >= 0) else -1.0
    #三角波
    elif Signal.type == 'trg':
        saw = 2 * (t % 1.0) - 1.0
        return 2 * abs(saw) - 1.0
    #锯齿波
    elif Signal.type == 'sth':
        return 2 * (t % 1.0) - 1.0
    #直流
    elif Signal.type == 'dco':
        return 1
    elif isinstance(Signal.type, list):
        # 合成波处理（最多支持4个谐波）
        total = 0.0
        for component in Signal.type:
            total += component['amp'] * waveform_generator(
                Signal(0, component['type'],component['freq_ratio'], 
                       component['amp'], component['phase'], 0),t
            )
        return total / len(Signal.type)   
    else:
        raise ValueError("不支持的波形类型")

#创建信号类，参数包括通道号、信号类型、频率、幅值，相位
class Signal:
    def __init__(self, channel,setpin,outpin,fre=1000,type='sin',amp=2047,phase=0,offset=2048,nsamp=0):
        self.channel = channel
        self.type = type
        self.fre = fre
        self.amp = amp
        self.phase = phase
        self.offset=offset
        self.nsamp = nsamp
        self.sm = StateMachine(channel, stream, freq=fclock,sideset_base=Pin(setpin), out_base=Pin(outpin))
        self.wavbuf = {0:bytearray(maxnsamp*2),1:bytearray(maxnsamp*2)}
    def GenWave(self):
        setupwave(self.wavbuf[0], self)
        

SignalA = Signal(channel=0,setpin=14, outpin=2)
SignalB = Signal(channel=1,setpin=28, outpin=16)
def Singal_Default(signal):
    """信号默认配置"""
    signal.type = 'sin'
    signal.fre = 1000
    signal.amp = 2047
    signal.phase = 0
    signal.offset=2048

#同步启动两个状态机
def Sync_Start_Sm():
    for sig in [SignalA, SignalB]:
        sig.sm.restart()
        sig.sm.exec("pull()")
        sig.sm.exec("mov(osr, isr)")
    SM0_ENABLE = 0x01 << 0        # SM0启用位掩码
    SM1_ENABLE = 0x01 << 1        # SM1启用位掩码
    machine.mem32[PIO0_CTRL] = 0
    machine.mem32[PIO0_CTRL] =  SM0_ENABLE|SM1_ENABLE # 单次写入启用多个状态机

# UART0配置（GPIO0/1）
class CommandParser:
    def __init__(self):
        self.uart = UART(0, baudrate=115200, tx=Pin(0), rx=Pin(1))
        self.buffer = bytearray(128)
        self.idx = 0
    async def run(self):
        """异步接收任务"""
        while True:
            if self.uart.any():
                data = self.uart.read(self.uart.any())
                self._process_data(data)
            await asyncio.sleep_ms(10)
    def _process_data(self, data):
        for byte in data:
            if byte == ord('\n'):  # 以换行符为指令结束
                self._parse_command(self.buffer[:self.idx].decode().strip())
                self.idx = 0
            else:
                if self.idx < len(self.buffer)-1:
                    self.buffer[self.idx] = byte
                    self.idx +=1

    def _parse_command(self, raw):
        """解析指令，支持同步和读取功能"""
        try:
            parts = [p.strip() for p in raw.split(',') if p]
            if not parts:
                return
            cmd = parts[0].lower()
            #同步指令
            if cmd == 'sync':
                self._handle_sync()
                return
            #读取指令
            elif cmd == 'read':
                self._handle_read(parts[1:])
                return
            #默认状态
            elif cmd == 'default':
                Singal_Default(SignalA)
                Singal_Default(SignalB)
                SignalA.GenWave()
                SignalB.GenWave()
                Sync_Start_Sm()
                self.uart.write("Default configuration successful\n")
                return
            # 原始配置指令处理逻辑
            elif cmd =='a' or cmd == 'b' or cmd == 'ab':  
                self._handle_configuration(parts)
            #复位指令
            elif cmd =='rst':
                machine.reset()
            else :
                self.uart.write(f"Unknown command: {cmd}\n".encode())
                return
                
        except Exception as e:
            err_msg = f"_parse_command ERR: {str(e)}\n"
            self.uart.write(err_msg.encode())
    
    def _handle_sync(self):
        """同步AB通道输出"""
        # 停止状态机
        machine.mem32[PIO0_CTRL] = 0
        # 1. 中止所有通道
        mem32[CHAN_ABORT] = 0xFFFFFFFF  # CHAN_ABORT
        # 2. 禁用并重置每个通道
        for chan in range(4):
            CTRL_TRIG = DMA_BASE + 0x00 + 0x40 * chan
            mem32[CTRL_TRIG] = 0  # 禁用通道
            mem32[DMA_BASE + 0x04 + 0x40 * chan] = 0  # READ_ADDR
            mem32[DMA_BASE + 0x08 + 0x40 * chan] = 0  # WRITE_ADDR
            mem32[DMA_BASE + 0x0C + 0x40 * chan] = 0  # TRANS_COUNT
        # 3. 清除中断标志
        mem32[DMA_BASE + 0x410] = 0xFFFFFFFF  # INTS0
        mem32[DMA_BASE + 0x414] = 0xFFFFFFFF  # INTS1
        # 4. 禁用中断
        mem32[DMA_BASE + 0x400] = 0  # INTE0
        mem32[DMA_BASE + 0x404] = 0  # INTE1
        # 重新配置DMA，直接使用之前生成的波形
        startDMA(SignalA.channel,SignalA.wavbuf[0], int(SignalA.nsamp/2))
        startDMA(SignalB.channel,SignalB.wavbuf[0], int(SignalB.nsamp/2))     
        #同步启动两个状态机
        Sync_Start_Sm()
        self.uart.write("Sync successful \n")

    def _handle_read(self, channel_parts):
        """处理读取配置请求"""
        channels = []
        # 解析通道参数
        for part in channel_parts:
            for c in part.upper():
                if c == 'A' and SignalA not in channels:
                    channels.append(SignalA)
                elif c == 'B' and SignalB not in channels:
                    channels.append(SignalB)
        # 默认读取所有通道
        if not channels:
            channels = [SignalA, SignalB]
        
        response = []
        for sig in channels:
            # 获取通道标识
            ch = 'A' if sig is SignalA else 'B'
            # 收集参数
            params = [
                f"type:{getattr(sig, 'type', '未设置')}",
                f"freq:{getattr(sig, 'fre', '未设置')}",
                f"amp:{getattr(sig, 'amp', '未设置')}",
                f"phase:{getattr(sig, 'phase', '未设置')}",
                f"offset:{getattr(sig, 'offset', '未设置')}"
            ]
            response.append(f"{ch},{','.join(params)}\n")
        self.uart.write(''.join(response).encode())

    def _handle_configuration(self, parts):
        """解析指令示例: A,type:sine,freq:1000,amp:2048,phase:90,offset:2048"""
        try:       
            # 解析通道
            ch = parts[0].upper()
            signals = []
            if 'A' in ch:
                signals.append(SignalA)
            if 'B' in ch:
                signals.append(SignalB)
            if not signals:
                self.uart.write("Invalid channel\n")
                return
            
            # 解析参数键值对
            params = {}
            for part in parts[1:]:
                k, _, v = part.partition(':')
                key = k.strip().lower()
                val = v.strip()
                
                if key == 'type':
                    params['type'] = val
                elif key in ('freq', 'fre'):
                    params['fre'] = int(val)
                elif key == 'amp':
                    params['amp'] = max(0, min(int(val), 4095))
                elif key == 'phase':
                    params['phase'] = int(val)
                elif key == 'offset':
                    params['offset'] = max(0, min(int(val), 4095))
                else:
                    self.uart.write(f"Ignore unknown parameters: {k}")
            
            # 更新信号配置
            for sig in signals:
                for k, v in params.items():
                    setattr(sig, k, v)
                sig.GenWave()  # 生成新波形      
            for sig in signals:
                sig.sm.active(1)   

            self.uart.write(f"Self configuration successful\n")
            
        except Exception as e:
            err_msg = f"_handle_configuration ERR: {str(e)}\n"       
            self.uart.write(err_msg.encode())



UartCmd = CommandParser()
async def main():
    UartCmd.uart.write(b'rp2040 start\n')
    #创建一个异步任务来接收串口指令
    asyncio.create_task(UartCmd.run())
    #创建一个异步LED状态指示任务
    led= Pin(29, Pin.OUT) 
    while True:   
        led.toggle() # 切换LED状态
        await asyncio.sleep_ms(500)
# 启动事件循环       
if __name__ == "__main__":
    asyncio.run(main())

    
    
