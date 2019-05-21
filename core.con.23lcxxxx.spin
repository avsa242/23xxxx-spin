{
    --------------------------------------------
    Filename: core.con.23lcxxxx.spin
    Author:
    Description:
    Copyright (c) 2019
    Started May 20, 2019
    Updated May 20, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON

' SPI Configuration
    CPOL                        = 0
    CLK_DELAY                   = 10
    MOSI_BITORDER               = 5             'MSBFIRST
    MISO_BITORDER               = 0             'MSBPRE

' Register definitions
    REG_NAME          = $00                   'Brief description of register

PUB Null
' This is not a top-level object
