# libgfxbitmap-spin
-------------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 library for generic bitmap-oriented drawing routines.

## Salient Features

* Line, Circle (not ellipse), Box, Plot primitives
* Text rendering (supported by 1bpp, 16bpp displays)
* Copy bitmap to display buffer, with optional offset
* Copy, cut, scale region
* Single-pixel scroll up region
* Supported displays: SSD1306/1309, SSD1331
* Preliminary support: IL3820, Neopixels (WS2811, WS2812, WS2812B, WS2813, SK6812 RGB and RGBW, TM1803), HT16K33 (Adafruit-variant 8x8 matrix only), ST7735, SSD1351
* P2-only display support: QVGA 8bpp

## Requirements

* P1/SPIN1: N/A
* P2/SPIN2: N/A

## Compiler Compatibility

* P1/SPIN1: ~~Propeller Tool~~ Unsupported - requires a compiler with preprocessor support
* P1/SPIN1: OpenSpin (tested with 1.00.81)
* P2/SPIN2: FastSpin (tested with 4.1.4-beta)

## Limitations

* Very early in development - may malfunction, or outright fail to build
* Text rendering is s l o w; needs optimization

## TODO

- [ ] Add methods to scroll display region in other directions
- [x] Add fast V/H line decision-making to Line primitive (WIP: need performance comparison)
- [ ] Add beveled/rounded option to Box primitive
- [ ] Add tri (or poly) primitive(s)
- [ ] Add fill option for other primitives
- [x] Text rendering for other color depths
- [x] Get/Put (buffer copy)
- [ ] Rotate bitmap
- [x] Scale bitmap

