{
----------------------------------------------------------------------------------------------------
    Filename:       23XXXX-Demo.spin
    Description:    Demo of the 23XXXX SRAM driver
        * Memory hexdump display
    Author:         Jesse Burt
    Started:        May 20, 2019
    Updated:        Sep 7, 2024
    Copyright (c) 2024 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

CON

    _clkmode    = xtal1+pll16x
    _xinfreq    = 5_000_000

' -- User-modifiable constants
    PART        = 1024                          ' memory size (kbits)
' --

    MEMSIZE     = (PART / 8) * 1024
    CLK_FREQ    = (_clkmode >> 6) * _xinfreq    ' extract P1 clock freq
    CYCLES_USEC = CLK_FREQ / 1_000_000          ' calc # cycles in 1 microsec


OBJ

    time:   "time"
    math:   "math.int"
    ser:    "com.serial.terminal.ansi" | SER_BAUD=115_200
    mem:    "memory.sram.23xxxx" | CS=0, SCK=1, MOSI=2, MISO=3


VAR

    long _pagesize, _lastpage
    byte _pg_buff[32]


PUB main() | base_page, offs

    setup()

    ser.set_attrs(ser.ECHO)
    _pagesize := mem.page_size()                ' convert page number to address
    _lastpage := (MEMSIZE / _pagesize)-1
    base_page := 0

    bytefill(@_pg_buff, 0, _pagesize)           ' clear out buffer and read in the first RAM page
    mem.rd_block_lsbf(@_pg_buff, base_page, _pagesize)
    offs := pg2byte_offs(base_page)

    ser.pos_xy(0, 4)
    ser.printf1(@"Page size: %d\n\r", _pagesize)
    ser.strln(@"Keys:")
    ser.strln(@"[, ]: go back, forward a page in memory")
    ser.strln(@"a: go to specific address (hexdump will round down to page start address)")
    ser.strln(@"s, e: go to the first, last page")
    ser.strln(@"w: write test: fill current page with random value")
    ser.strln(@"x: erase test: fill the current page with the erase value")
    ser.strln(@"   (varies among memory types)")
    repeat
        ser.pos_xy(0, 13)
        { display a hexdump of the current page of memory, but limit it to one page at a time }
        ser.hexdump(@_pg_buff, offs, 6, _pagesize, 16)

        case ser.getchar()
            "[":                                ' go back a page in memory
                base_page--
                if (base_page < 0)
                    base_page := 0
            "]":                                ' go forward a page
                base_page++
                if (base_page > _lastpage)
                    base_page := _lastpage
            "a":
                ser.str(@"Enter address (hex): ")
                base_page := ser.gethex() / _pagesize
                ser.newline()
            "e":                                ' go to the last page
                base_page := _lastpage
            "s":                                ' go to the first page
                base_page := 0
            "w":                                ' fill page w/test value
                cycle_time(write_test(offs))
            "x":                                ' erase the current page
                cycle_time(erase_test(offs))
            other:
        offs := pg2byte_offs(base_page)
        cycle_time(read_test(offs))


PUB erase_test(st_addr): etime | stime
' Erase memory page
    ser.str(@"Erasing page...")

    { fill working buffer with erase character }
    bytefill(@_pg_buff, mem.ERASE_CELL, _pagesize)

    { write the buffer to memory, and track how long it takes }
    stime := cnt
    mem.wr_block_lsbf(st_addr, @_pg_buff, _pagesize)
    etime := cnt-stime


PUB read_test(st_addr): etime | stime
' Read memory page
    bytefill(@_pg_buff, 0, _pagesize)
    ser.str(@"Reading page...")

    { read memory page to buffer }
    stime := cnt
    mem.rd_block_lsbf(@_pg_buff, st_addr, _pagesize)
    etime := cnt-stime


PUB write_test(st_addr): etime | stime
' Write a random test value to memory page
    ser.str(@"Writing page...")
    bytefill(@_pg_buff, math.rndi(255), _pagesize)

    { fill page with test character }
    stime := cnt
    mem.wr_block_lsbf(st_addr, @_pg_buff, _pagesize)
    etime := cnt-stime


PRI cycle_time(cycles)
' Display elapsed time in cycles and microseconds
    ser.printf2(@"%d cycles (%dusec)", cycles, (cycles / CYCLES_USEC))
    ser.clear_ln()
    ser.newline()


PRI pg2byte_offs(page_nr): b
' Get start of page number as a byte offset
    return (page_nr * _pagesize)


PUB setup()

    ser.start()
    time.msleep(30)
    ser.clear()
    ser.strln(@"Serial terminal started")

    if ( mem.start() )
        ser.strln(@"23XXXX driver started")
    else
        ser.strln(@"23XXXX driver failed to start - halting")
        repeat


DAT
{
Copyright 2024 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

