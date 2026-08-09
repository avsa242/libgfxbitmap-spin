# libgfxbitmap-spin
-------------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 library for generic bitmap-oriented drawing routines.

## Salient Features

* Drawing primitives
    * Line:
        * arbitrary start-end coordinates (Bresenham)
        * horizontal
        * vertical
    * Circle (not ellipse), Box, Plot primitives
    * Text:
        * Uses terminal.common.spin[2]h to provide str(), hex(), bin(), printf(), etc
        * 0 or 90 degree-rotated font bitmaps, up to 32px wide glyphs
        * Character cell-level or pixel-level positioning (build-time)
        * Internal or custom user-provided putchar function pointer
* Bitmap:
    * Copy to display buffer
* Copy, cut, scale region
* Scrolling:
    * Single-pixel region scroll (up, down, left, right)
    * n-pixel full-screen scroll (up, down)
* Integration with most any dot-matrix type display
* Rotation:
    * Whole-display (0, 90, 180, 270 degree)


## Requirements

P1/SPIN1:
* 69 bytes global var RAM for settings, configuration
* terminal.common.spinh (provided by spin-standard-library)

P2/SPIN2:
* 69 bytes global var RAM for settings, configuration
* terminal.common.spin2h (provided by p2-spin-standard-library)


## Compiler Compatibility

| Processor | Language | Compiler               | Backend      | Status                |
|-----------|----------|------------------------|--------------|-----------------------|
| P1        | SPIN1    | FlexSpin (7.7.0)       | Bytecode     | OK                    |
| P1        | SPIN1    | FlexSpin (7.7.0)       | Native/PASM  | OK                    |
| P2        | SPIN2    | FlexSpin (7.7.0)       | NuCode       | Runtime issues        |
| P2        | SPIN2    | FlexSpin (7.7.0)       | Native/PASM2 | OK                    |

(other versions or toolchains not listed are __not supported__, and _may or may not_ work)


## Limitations

* Text rendering is s l o w; needs optimization
* Region scrolling not implemented fully on 1bpp displays

