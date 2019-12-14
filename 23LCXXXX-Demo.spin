{
    --------------------------------------------
    Filename: 23LCXXXX-Test.spin
    Author:
    Description:
    Copyright (c) 2019
    Started May 20, 2019
    Updated May 20, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq
    CLK_FREQ    = ((_clkmode - xtal1) >> 6) * _xinfreq

    TICKS_USEC  = CLK_FREQ / 1_000_000

    LED         = cfg#LED1

    CS_PIN      = 4
    SCK_PIN     = 2
    MOSI_PIN    = 1
    MISO_PIN    = 0

    RAMSIZE     = 131072
    RAMEND      = RAMSIZE-1

OBJ

    cfg     : "core.con.boardcfg.flip"
    ser     : "com.serial.terminal.ansi"
    time    : "time"
    io      : "io"
    sram    : "memory.sram.23lcxxxx.spi"

VAR

    byte _ser_cog, _sram_cog
    byte _sram_buff[32]

PUB Main | base, s, e

    Setup

    base := 0
    repeat
        s := cnt
        sram.ReadPage(base, 32, @_sram_buff)
        e := cnt-s
        Hexdump(@_sram_buff, base << 5, 32, 8, 0, 5)
        ser.Str(string(ser#CR, ser#LF, "Reading done ("))
        ser.Dec(usec(e))
        ser.Str(string("us)", ser#CR, ser#LF))

        case ser.CharIn
            "[":
                base := base - 1
                if base < 0
                    base := 0
            "]":
                base := base + 1
                if base > 4095
                    base := 4095
            "e":
                base := 4095
            "s":
                base := 0
            "w":
                WriteTest(base)
            "q":
                ser.Str(string("Halting", ser#CR, ser#LF))
                quit
            OTHER:

    FlashLED(LED, 100)

PUB WriteTest(base) | tmp, i

    tmp.byte[0] := $DE
    tmp.byte[1] := $AD
    tmp.byte[2] := $BE
    tmp.byte[3] := $EF

    repeat i from 0 to 3
        sram.WriteByte(i, tmp.byte[i])

PUB usec(ticks)

    return ticks / TICKS_USEC

PUB Setup

    repeat until _ser_cog := ser.Start (115_200)
    time.MSleep(100)
    ser.Clear
    ser.Str(string("Serial terminal started", ser#CR, ser#LF))
    if _sram_cog := sram.Start (CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN)
        ser.Str(string("23LCXXXX driver started", ser#CR, ser#LF))
    else
        ser.Str(string("23LCXXXX driver failed to start - halting", ser#CR, ser#LF))
        Stop

PUB Stop

    time.MSleep (5)
    ser.Stop
    sram.Stop
    FlashLED (LED, 100)

#include "lib.utility.spin"
#include "lib.termwidgets.spin"

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
