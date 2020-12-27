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

PUB Null{}
' This is not a top-level object

PUB Start(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN): okay

    if okay := spi.start(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN)
        time.msleep(1)
        return okay

    return FALSE                                ' something above failed

PUB Stop{}

    spi.stop{}

PUB Defaults{}
' Factory default settings
    opmode(SEQ)

PUB OpMode(mode): curr_mode
' Set read/write operation mode
'   Valid values:
'       ONEBYTE (%00): Confine access to single address
'      *SEQ (%01): Entire SRAM accessible, no page boundaries
'           (address counter wraps to 00_00_00 after reaching
'           the end of the SRAM)
'       PAGE (%10): Confine access to single page
'           (address counter wraps to start of page address after reaching the
'           end of the page)
'   Any other value polls the chip and returns the current setting
    readreg(core#RDMR, 1, @curr_mode)
    case mode
        ONEBYTE, SEQ, PAGE:
            mode := (mode << core#WR_MODE) & core#WRMR_MASK
        other:
            return (curr_mode >> core#WR_MODE) & core#WR_MODE_BITS

    writereg(core#WRMR, 1, @mode)

PUB ReadByte(sram_addr): s_rdbyte
' Read a single byte from SRAM
'   Valid values:
'       sram_addr: 0..$01_FF_FF
'   Any other value is clamped to maximum address
    readsram(sram_addr, 1, @s_rdbyte)

PUB ReadBytes(sram_addr, nr_bytes, ptr_buff)
' Read multiple bytes from SRAM
'   Valid values:
'       sram_addr: 0..$01_FF_FF
'   Any other value is clamped to maximum address
    readsram(sram_addr, nr_bytes, ptr_buff)

PUB ReadPage(sram_page_nr, nr_bytes, ptr_buff)
' Read up to 32 bytes from SRAM page
'   Valid values:
'       sram_page_nr: 0..4095
'   Any other value is ignored
    case sram_page_nr
        0..4095:
            readsram(sram_page_nr << 5, nr_bytes, ptr_buff)
            return
        other:
            return

PUB ResetIO{}
' Reset to SPI mode
    writereg(core#RSTIO, 1, 0)

PUB WriteByte(sram_addr, val)
' Write a single byte to SRAM
'   Valid values:
'       sram_addr: 0..$01_FF_FF
'   Any other value is clamped to maximum address
    val &= $FF
    writesram(sram_addr, 1, @val)

PUB WriteBytes(sram_addr, nr_bytes, ptr_buff)
' Write multiple bytes to SRAM
'   Valid values:
'       sram_addr: 0..$01_FF_FF
'   Any other value is clamped to maximum address
    writesram(sram_addr, nr_bytes, ptr_buff)

PUB WritePage(sram_page_nr, nr_bytes, ptr_buff)
' Write up to 32 bytes to SRAM page
'   Valid values:
'       sram_page_nr: 0..4095
'   Any other value is ignored
    case sram_page_nr
        0..4095:
            writesram(sram_page_nr << 5 {*32}, nr_bytes, ptr_buff)
            return
        other:
            return

PRI readReg(reg_nr, nr_bytes, ptr_buff)
' Read nr_bytes from device into ptr_buff
    case reg_nr
        core#RDMR:
            spi.write(TRUE, @reg_nr, 1, FALSE)
            spi.read(ptr_buff, 1)
            return

PRI readSRAM(sram_addr, nr_bytes, ptr_buff) | cmd_pkt

    cmd_pkt.byte[0] := core#READ
    cmd_pkt.byte[1] := sram_addr.byte[2] & 1
    cmd_pkt.byte[2] := sram_addr.byte[1]
    cmd_pkt.byte[3] := sram_addr.byte[0]

    spi.write(TRUE, @cmd_pkt, 4, FALSE)
    spi.read(ptr_buff, nr_bytes)

PRI writeReg(reg_nr, nr_bytes, ptr_buff) | cmd_pkt
' Write nr_bytes to device from ptr_buff
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

PRI writeSRAM(sram_addr, nr_bytes, ptr_buff) | cmd_pkt

    cmd_pkt.byte[0] := core#WRITE
    cmd_pkt.byte[1] := sram_addr.byte[2] & 1
    cmd_pkt.byte[2] := sram_addr.byte[1]
    cmd_pkt.byte[3] := sram_addr.byte[0]

    spi.write(TRUE, @cmd_pkt, 4, FALSE)
    spi.write(TRUE, ptr_buff, nr_bytes, TRUE)

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
