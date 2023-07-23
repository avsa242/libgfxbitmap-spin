# libgfxbitmap-spin
-------------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 library for generic bitmap-oriented drawing routines.

## Salient Features

* Line, Circle (not ellipse), Box, Plot primitives
* Text rendering (uses terminal.common.spin[2]h to provide str(), hex(), bin(), printf(), etc)
* Copy bitmap to display buffer, with optional offset
* Copy, cut, scale region
* Single-pixel scroll up region
* Integration with most any dot-matrix type display


## Requirements

P1/SPIN1:
* 78 bytes global var storage
* terminal.common.spinh (provided by spin-standard-library)

P2/SPIN2:
* 78 bytes global var storage
* terminal.common.spin2h (provided by p2-spin-standard-library)


## Compiler Compatibility

| Processor | Language | Compiler               | Backend      | Status                |
|-----------|----------|------------------------|--------------|-----------------------|
| P1        | SPIN1    | FlexSpin (6.2.1)       | Bytecode     | OK                    |
| P1        | SPIN1    | FlexSpin (6.2.1)       | Native/PASM  | OK                    |
| P2        | SPIN2    | FlexSpin (6.2.1)       | NuCode       | FTBFS                 |
| P2        | SPIN2    | FlexSpin (6.2.1)       | Native/PASM2 | OK                    |

(other versions or toolchains not listed are __not supported__, and _may or may not_ work)


## Limitations

* Text rendering is s l o w; needs optimization
* Region scrolling not implemented fully on 1bpp displays

