# 23lcxxxx-spin 
---------------

This is a P8X32A/Propeller driver object for Microchip 23LCxxxx-series SRAM

## Salient Features

* SPI connection at a fixed 20MHz (writes) and 10MHz (reads)
* Operations for reading and writing a single byte, up to a 32-byte page, or multiple bytes across page boundaries

## Requirements

* 1 extra core/cog for the PASM SPI driver

## Compiler Compatibility

- P1/SPIN1: OpenSpin (tested with 1.00.81)

## Limitations

* Very early in development - may malfunction or outright fail to build
* Single-lane SPI only (i.e., no DSPI, QSPI)

## TODO

- [x] Port to 20MHz SPI driver
- [ ] Add more extensive demos
