# 23xxxx-spin
-------------

This is a P8X32A/Propeller driver object for 23xxxx-series SRAM

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

* SPI connection at 20MHz W / 10MHz R (P1), up to 20MHz W / 20MHz R  (P2)
* Operations for reading and writing a single byte, up to a 32-byte page, or multiple bytes across page boundaries

## Requirements

P1/SPIN1:
* spin-standard-library
* 1 extra core/cog for the PASM SPI engine
* memory.common.spinh (provided by spin-standard-library)

P2/SPIN2:
* p2-spin-standard-library
* memory.common.spin2h (provided by p2-spin-standard-library)

## Compiler Compatibility

| Processor | Language | Compiler               | Backend      | Status                |
|-----------|----------|------------------------|--------------|-----------------------|
| P1        | SPIN1    | FlexSpin (6.1.1)       | Bytecode     | OK                    |
| P1        | SPIN1    | FlexSpin (6.1.1)       | Native/PASM  | OK                    |
| P2        | SPIN2    | FlexSpin (6.1.1)       | NuCode       | Not yet implemented   |
| P2        | SPIN2    | FlexSpin (6.1.1)       | Native/PASM2 | Not yet implemented   |

(other versions or toolchains not listed are __not supported__, and _may or may not_ work)


## Limitations

* Very early in development - may malfunction or outright fail to build
* Single-lane SPI only (i.e., no DSPI, QSPI)
* Tested only with Microchip 23LC1024 (may work with similar ONSemi and ISSI parts)
* Tested only with 1Mbit/128kbyte part

