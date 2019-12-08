# libgfxbitmap-spin
-------------------

This is a P8X32A/Propeller object for generic bitmap-oriented drawing routines.

## Salient Features

* Line, Circle (not ellipse), Box, Plot primitives
* Bitmap

## Requirements

* P1/SPIN1: N/A
* P2/SPIN2: N/A

## Compiler Compatibility

* P1/SPIN1: OpenSpin (tested with 1.00.81)
* P2/SPIN2: FastSpin (tested with 4.0.3)

## Limitations

* Very early in development - may malfunction, or outright fail to build
* Text rendering only implemented on 1bpp (e.g., SSD1306)

## TODO

- [x] Add fast V/H line decision-making to Line primitive
- [ ] Add beveled/rounded option to Box primitive
- [ ] Text rendering for other color depths
- [ ] Get/Put (buffer copy)
- [ ] Rotate bitmap
- [x] Scale bitmap

