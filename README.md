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

* P1/SPIN1: 35 bytes global var storage
* P2/SPIN2: 35 bytes global var storage

## Compiler Compatibility

| Processor | Language | Compiler               | Backend     | Status                |
|-----------|----------|------------------------|-------------|-----------------------|
| P1        | SPIN1    | FlexSpin (5.9.14-beta) | Bytecode    | OK                    |
| P1        | SPIN1    | FlexSpin (5.9.14-beta) | Native code | OK                    |
| P1        | SPIN1    | OpenSpin (1.00.81)     | Bytecode    | Untested (deprecated) |
| P2        | SPIN2    | FlexSpin (5.9.14-beta) | NuCode      | Untested              |
| P2        | SPIN2    | FlexSpin (5.9.14-beta) | Native code | OK                    |
| P1        | SPIN1    | Brad's Spin Tool (any) | Bytecode    | Unsupported           |
| P1, P2    | SPIN1, 2 | Propeller Tool (any)   | Bytecode    | Unsupported           |
| P1, P2    | SPIN1, 2 | PNut (any)             | Bytecode    | Unsupported           |

## Limitations

* Text rendering is s l o w; needs optimization
* Region scrolling not implemented fully on 1bpp displays

