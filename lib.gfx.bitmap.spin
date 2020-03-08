{
    --------------------------------------------
    Filename: library.gfx.bitmap.spin
    Author: Jesse Burt
    Description: Library of generic bitmap-oriented graphics rendering routines
    Copyright (c) 2020
    Started May 19, 2019
    Updated Feb 8, 2020
    See end of file for terms of use.
    --------------------------------------------
}

CON


VAR

    long _row, _col, _row_max, _col_max
    long _font_width, _font_height, _font_addr
    long _fgcolor, _bgcolor

PUB BGColor (col)
' Set background color for subsequent drawing
    return _bgcolor := col

PUB Bitmap(bitmap_addr, bitmap_size, offset)
' Copy a bitmap to the display buffer
'   bitmap_addr:    Address of bitmap to copy
'   bitmap_size:    Number of bytes to copy
'   offset:         Offset within the display buffer to copy to
    bytemove(_draw_buffer + offset, bitmap_addr, bitmap_size)

PUB Box(x0, y0, x1, y1, color, filled) | x, y
' Draw a box
'   x0, y0: Start coordinates x0, y0
'   x1, y1: End coordinates
'   color:  Box color
'   filled: Flag to set whether to fill the box or not
    case filled
        FALSE:
            repeat x from x0 to x1
                Plot(x, y0, color)
                Plot(x, y1, color)
            repeat y from y0 to y1
                Plot(x0, y, color)
                Plot(x1, y, color)
        TRUE:
            repeat y from y0 to y1
                repeat x from x0 to x1
                    Plot(x, y, color)

PUB Char (ch) | glyph_col, glyph_row, glyph_data, x, y
' Write a character to the display
    repeat glyph_col from 0 to _font_width-1
        x := _col + glyph_col
        repeat glyph_row from 0 to _font_height-1
            glyph_data := byte[_font_addr][ch << 3 + glyph_col]
            y := _row + glyph_row
            if glyph_data & (1 << (glyph_row))
                Plot(x, y, _fgcolor)
            else
                Plot(x, y, _bgcolor)

PUB Circle(x0, y0, radius, color) | x, y, err, cdx, cdy
' Draw a circle
'   x0, y0: Coordinates
'   radius: Circle radius
'   color: Color to draw circle
    x := radius - 1
    y := 0
    cdx := 1
    cdy := 1
    err := cdx - (radius << 1)

    repeat while (x => y)
        Plot(x0 + x, y0 + y, color)
        Plot(x0 + y, y0 + x, color)
        Plot(x0 - y, y0 + x, color)
        Plot(x0 - x, y0 + y, color)
        Plot(x0 - x, y0 - y, color)
        Plot(x0 - y, y0 - x, color)
        Plot(x0 + y, y0 - x, color)
        Plot(x0 + x, y0 - y, color)

        if (err =< 0)
            y++
            err += cdy
            cdy += 2

        if (err > 0)
            x--
            cdx += 2
            err += cdx - (radius << 1)

PUB Clear
' Clear the display buffer
#ifdef IL3820
    bytefill(_draw_buffer, _bgcolor, _buff_sz)
#elseifdef SSD130X
    bytefill(_draw_buffer, _bgcolor, _buff_sz)
#elseifdef SSD1331
    wordfill(_draw_buffer, _bgcolor, _buff_sz/2)
#elseifdef NEOPIXEL
    longfill(_draw_buffer, _bgcolor, _buff_sz/4)
#elseifdef HT16K33-ADAFRUIT
    bytefill(_draw_buffer, _bgcolor, _buff_sz)
#elseifdef ST7735
    wordfill(_draw_buffer, _bgcolor, _buff_sz/2)
#endif

PUB ClearAll

    ClearAccel
    Clear
    Update

PUB Copy (sx, sy, ex, ey, dx, dy) | x, y, tmp
' Copy rectangular region at (sx, sy, ex, ey) to (dx, dy)
    repeat y from sy to ey
        repeat x from sx to ex
            tmp := Point(x, y)
            Plot((dx + x)-sx, (dy + y)-sy, tmp)

PUB Cut (sx, sy, ex, ey, dx, dy) | x, y, tmp
' Copy rectangular region at (sx, sy, ex, ey) to (dx, dy)
'   Subsequently clears original region (sx, sy, ex, ey) to background color
    repeat y from sy to ey
        repeat x from sx to ex
            tmp := Point(x, y)
            Plot((dx + x)-sx, (dy + y)-sy, tmp)             ' Copy to destination region
            Plot(x, y, _bgcolor)                            ' Cut the original region

PUB FGColor (col)
' Set foreground color of subsequent drawing operations
    return _fgcolor := col

PUB FontAddress(addr)
' Set address of font definition
    case addr
        $0004..$7FFF:
            _font_addr := addr
        OTHER:
            return _font_addr

PUB FontHeight
' Return the set font height
    return _font_height

PUB FontSize(width, height)
' Set expected dimensions of font, in pixels
'   NOTE: This doesn't have to be the same as the size of the font glyphs.
'       e.g., if you have a 5x8 font, you may want to set the width to 6 or 8.
'       This will affect the number of text columns
    _font_width := width
    _font_height := height
    _col_max := _disp_xmax
    _row_max := _disp_ymax

PUB FontWidth
' Return the set font width
    return _font_width

PUB Line(x1, y1, x2, y2, c) | sx, sy, ddx, ddy, err, e2
' Draw line from x1, y1 to x2, y2, in color c
    case x1 == x2 or y1 == y2
        TRUE:
            if x1 == x2                     ' X's are the same - use Plot to draw a straight Vertical line
                repeat sy from y1 to y2
                    Plot(x1, sy, c)
            if y1 == y2                     ' Y's are the same - use Plot to draw a straight Horizontal line
                repeat sx from x1 to x2
                    Plot(sx, y1, c)
        FALSE:                              ' Both are different - use Bresenham's line algo. to draw diag. line
            ddx := ||(x2-x1)
            ddy := ||(y2-y1)
            err := ddx-ddy

            sx := -1
            if (x1 < x2)
                sx := 1

            sy := -1
            if (y1 < y2)
                sy := 1

            repeat until ((x1 == x2) AND (y1 == y2))
                Plot(x1, y1, c)
                e2 := err << 1

                if e2 > -ddy
                    err := err - ddy
                    x1 := x1 + sx

                if e2 < ddx
                    err := err + ddx
                    y1 := y1 + sy

PUB Plot (x, y, color)
' Plot pixel at x, y, color c
    if x => 0 and x =< _disp_xmax and y => 0 and y =< _disp_ymax
    ' Within bounds; continue on
    else
        return
#ifdef IL3820
    case color
        1:
            byte[_draw_buffer][(x + y * _disp_width) >> 3] |= $80 >> (x & 7)
        0:
            byte[_draw_buffer][(x + y * _disp_width) >> 3] &= !($80 >> (x & 7))
        -1:
            byte[_draw_buffer][(x + y * _disp_width) >> 3] ^= $80 >> (x & 7)
        OTHER:
            return
#elseifdef SSD130X
    case color
        1:
            byte[_draw_buffer][x + (y>>3) * _disp_width] |= (1 << (y&7))
        0:
            byte[_draw_buffer][x + (y>>3) * _disp_width] &= !(1 << (y&7))
        -1:
            byte[_draw_buffer][x + (y>>3) * _disp_width] ^= (1 << (y&7))
        OTHER:
            return
#elseifdef SSD1331
'    color.byte[3] := color.byte[0]
'    color.byte[0] := color.byte[1]
'    color.byte[1] := color.byte[3]
'    color.byte[3] := 0
'    word[_draw_buffer][x + (y * _disp_width)] := color
    word[_draw_buffer][x + (y * _disp_width)] := ((color >> 8) & $FF) | ((color << 8) & $FF00)
' ^TODO: Compare cost of both of these methods^
#elseifdef NEOPIXEL
    long[_draw_buffer][x + (y * _disp_width)] := color
#elseifdef HT16K33-ADAFRUIT
    x := x + 7
    x := x // 8

    case color
        1:
            byte[_draw_buffer][y] |= 1 << x
        0:
            byte[_draw_buffer][y] &= !(1 << x)
        -1:
            byte[_draw_buffer][y] ^= 1 << x
        OTHER:
            return

#elseifdef ST7735
    word[_draw_buffer][x + (y * _disp_width)] := ((color >> 8) & $FF) | ((color << 8) & $FF00)
#else
#warning "No supported display types defined!"
#endif

PUB Point (x, y)
' Get color of pixel at x, y
    x := 0 #> x <# _disp_xmax
    y := 0 #> y <# _disp_ymax

#ifdef IL3820
    result := byte[_draw_buffer][(x + y * _disp_width) >> 3]
#elseifdef SSD130X
    result := byte[_draw_buffer][x + (y>>3) * _disp_width] >> (y & 7)
#elseifdef SSD1331
    result := word[_draw_buffer][x + (y * _disp_width)]
#elseifdef NEOPIXEL
    result := long[_draw_buffer][x + (y * _disp_width)]
#elseifdef HT16K33-ADAFRUIT
    x := x + 7
    x := x // 8
    result := byte[_draw_buffer][y + (x >> 3) * _disp_width]
#elseifdef ST7735
    result := word[_draw_buffer][x + (y * _disp_width)]
#else
#warning "No supported display types defined!"
#endif

PUB Position(col, row)
' Set text draw position, in character-cell col and row
    col := 0 #> col <# _col_max
    row := 0 #> row <# _row_max
    _col := col * _font_width
    _row := row * _font_height

PUB RGBW8888_RGB32 (r, g, b, w)
' Return 32-bit long from discrete Red, Green, Blue, White color components (values 0..255)
    result.byte[3] := r
    result.byte[2] := g
    result.byte[1] := b
    result.byte[0] := w

PUB RGBW8888_RGB32_Brightness(r, g, b, w, level)
' -- r, g, b, and w are element levels, 0..255
' -- level is brightness, 0..255 (0..100%)
    if (level =< 0)
        return $00_00_00_00

    elseif (level => 255)
        return RGBW8888_RGB32(r, g, b, w)

    else
        r := r * level / 255                                        ' Apply level to RGBW
        g := g * level / 255
        b := b * level / 255
        w := w * level / 255
        return RGBW8888_RGB32(r, g, b, w)

PUB RGB565_R5 (rgb565)
' Return 5-bit red component of 16-bit RGB color
    return (((rgb565 & $F800) >> 11) * 527 + 23 ) >> 6

PUB RGB565_G6 (rgb565)
' Return 6-bit green component of 16-bit RGB color
    return (((rgb565 & $7E0) >> 5)  * 259 + 33 ) >> 6

PUB RGB565_B5 (rgb565)
' Return 5-bit blue component of 16-bit RGB color
    return ((rgb565 & $1F) * 527 + 23 ) >> 6

PUB Scale (sx, sy, ex, ey, offsx, offsy, size) | x, y, dx, dy, in
' Scale a region of the display up by size
    repeat y from sy to ey
        repeat x from sx to ex
            in := Point(x, y)
            dx := offsx + (x*size)-(sx*size)
            dy := offsy + (y*size)-(sy*size)
            Box(dx, dy, dx + size, dy + size, in, TRUE)

PUB Str (string_addr) | i
' Write string at string_addr to the display @ row and column.
'   NOTE: Wraps to the left at end of line and to the top-left at end of display
    repeat i from 0 to strsize(string_addr)-1
        Char(byte[string_addr][i])
        _col += _font_width     'XXX TODO: Move position handling to Char? Then the terminal lib
        if _col > _disp_xmax    '   could be #included and used in place of this, and also provide
            _col := 0           '   Bin, Dec, Hex, etc...
            _row += _font_height'   Not that Char needs to be any slower, than it is, though
            if _row > _disp_ymax
                _row := 0

DAT
{
    --------------------------------------------------------------------------------------------------------
    TERMS OF USE: MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
    following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial
    portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
    LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    --------------------------------------------------------------------------------------------------------
}
