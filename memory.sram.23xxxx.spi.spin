{
    --------------------------------------------
    Filename: memory.sram.23xxxx.spi.spin
    Author: Jesse Burt
    Description: Driver for 23xxxx series
        SPI SRAM
    Copyright (c) 2020
    Started May 20, 2019
    Updated Dec 27, 2020
    See end of file for terms of use.
    --------------------------------------------
}

CON

' Read/write operation modes
    ONEBYTE     = %00
    SEQ         = %01
    PAGE        = %10

' SPI transaction types
    TRANS_CMD   = 0
    TRANS_DATA  = 1

OBJ

    spi : "com.spi.fast"
    core: "core.con.23xxxx"
    time: "time"
    io  : "io"

PUB Null{}
' This is not a top-level object

PUB Start(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN): okay

    if okay := spi.start(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN)
        time.msleep(1)
        return okay

    return FALSE                                ' something above failed

PUB Stop{}

    spi.stop{}

PUB OpMode(mode): curr_mode
' Set read/write operation mode
'   Valid values:
'       ONEBYTE (%00): Single byte R/W access
'       SEQ (%01): Sequential R/W access (crosses page boundaries)
'       PAGE (%10): Single page R/W access
'   Any other value polls the chip and returns the current setting
    readreg(TRANS_CMD, core#RDMR, 1, @curr_mode)
    case mode
        ONEBYTE, SEQ, PAGE:
            mode := (mode << core#WR_MODE) & core#WRMR_MASK
        other:
            return (curr_mode >> core#WR_MODE) & core#WR_MODE_BITS

    writereg(TRANS_CMD, core#WRMR, 1, @mode)

PUB ReadByte(sram_addr): s_rdbyte
' Read a single byte from SRAM
'   Valid values:
'       sram_addr: 0..$01_FF_FF
'   Any other value is ignored
    opmode(ONEBYTE)
    readreg(TRANS_DATA, sram_addr, 1, @s_rdbyte)

PUB ReadBytes(sram_addr, nr_bytes, ptr_buff)
' Read multiple bytes from SRAM
'   Valid values:
'       sram_addr: 0..$01_FF_FF
'   Any other value is ignored
    readreg(TRANS_DATA, sram_addr, nr_bytes, ptr_buff)

PUB ReadPage(sram_page_nr, nr_bytes, ptr_buff)
' Read up to 32 bytes from SRAM page
'   Valid values:
'       sram_page_nr: 0..4095
'   Any other value is ignored
    case sram_page_nr
        0..4095:
'            opmode(PAGE)   ' This can be uncommented for simplicity, but page reads are much slower (~514uS vs ~243uS)
            readreg(TRANS_DATA, sram_page_nr << 5 {*32}, nr_bytes, ptr_buff)
            return
        other:
            return

PUB ResetIO{}
' Reset to SPI mode
    writereg(TRANS_CMD, core#RSTIO, 1, 0)

PUB WriteByte(sram_addr, val)
' Write a single byte to SRAM
'   Valid values:
'       sram_addr: 0..$01_FF_FF
'   Any other value is ignored
    opmode(ONEBYTE)
    val &= $FF
    writereg(TRANS_DATA, sram_addr, 1, @val)

PUB WriteBytes(sram_addr, nr_bytes, ptr_buff)
' Write multiple bytes to SRAM
'   Valid values:
'       sram_addr: 0..$01_FF_FF
'   Any other value is ignored
    opmode(SEQ)
    writereg(TRANS_DATA, sram_addr, nr_bytes, ptr_buff)

PUB WritePage(sram_page_nr, nr_bytes, ptr_buff)
' Write up to 32 bytes to SRAM page
'   Valid values:
'       sram_page_nr: 0..4095
'   Any other value is ignored
    case sram_page_nr
        0..4095:
'            opmode(PAGE)
            writereg(TRANS_DATA, sram_page_nr << 5 {*32}, nr_bytes, ptr_buff)
            return
        other:
            return

PRI readReg(trans_type, reg_nr, nr_bytes, ptr_buff) | cmd_pkt
' Read nr_bytes from device into ptr_buff
    case trans_type
        TRANS_CMD:
            case reg_nr
                core#RDMR:
                    spi.write(TRUE, @reg_nr, 1, FALSE)
                    spi.read(ptr_buff, 1)
                    return
        TRANS_DATA:
            case reg_nr
                0..$01_FF_FF:
                    cmd_pkt.byte[0] := core#READ
                    cmd_pkt.byte[1] := reg_nr.byte[2]
                    cmd_pkt.byte[2] := reg_nr.byte[1]
                    cmd_pkt.byte[3] := reg_nr.byte[0]

                    spi.write(TRUE, @cmd_pkt, 4, FALSE)
                    spi.read(ptr_buff, nr_bytes)
                    return
                other:
                    return
        other:
            return

PRI writeReg(trans_type, reg_nr, nr_bytes, ptr_buff) | cmd_pkt
' Write nr_bytes to device from ptr_buff
    case trans_type
        TRANS_CMD:
            case reg_nr
                core#WRMR:
                    cmd_pkt.byte[0] := reg_nr
                    cmd_pkt.byte[1] := byte[ptr_buff][0]
                    spi.write(TRUE, @cmd_pkt, 2, TRUE)
                    return
                core#EQIO, core#EDIO, core#RSTIO:
                    spi.write(TRUE, @reg_nr, 1, TRUE)
                    return

                other:
                    return
        TRANS_DATA:
            case reg_nr
                0..$01_FF_FF:
                    cmd_pkt.byte[0] := core#WRITE
                    cmd_pkt.byte[1] := reg_nr.byte[2]
                    cmd_pkt.byte[2] := reg_nr.byte[1]
                    cmd_pkt.byte[3] := reg_nr.byte[0]

                    spi.write(TRUE, @cmd_pkt, 4, FALSE)
                    spi.write(TRUE, ptr_buff, nr_bytes, TRUE)
                    return
                other:
                    return
        
        other:
            return

DAT
{
    --------------------------------------------------------------------------------------------------------
    TERMS OF USE: MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
    following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial
    portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
    LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    --------------------------------------------------------------------------------------------------------
}
