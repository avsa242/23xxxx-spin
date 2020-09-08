# 23lcxxxx-spin 
---------------

This is a P8X32A/Propeller driver object for 23xxxx-series SRAM

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) ~~or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P)~~. Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

* SPI connection at a fixed 20MHz (writes) and 10MHz (reads)
* Operations for reading and writing a single byte, up to a 32-byte page, or multiple bytes across page boundaries

## Requirements

P1/SPIN1:
* spin-standard-library
* 1 extra core/cog for the PASM SPI driver

~~P2/SPIN2:~~
* ~~p2-spin-standard-library~~

## Compiler Compatibility

* P1/SPIN1: OpenSpin (tested with 1.00.81)
* ~~P2/SPIN2: FastSpin (tested with 4.1.10-beta)~~ _(not implemented yet)_
* ~~BST~~ (incompatible - no preprocessor)
* ~~Propeller Tool~~ (incompatible - no preprocessor)
* ~~PNut~~ (incompatible - no preprocessor)

## Limitations

* Very early in development - may malfunction or outright fail to build
* Single-lane SPI only (i.e., no DSPI, QSPI)

## TODO

- [x] Port to 20MHz SPI driver
- [ ] Add more extensive demos
- [ ] Port to P2/SPIN2
