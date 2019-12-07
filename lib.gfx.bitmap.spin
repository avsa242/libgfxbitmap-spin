{
    --------------------------------------------
    Filename: library.gfx.bitmap.spin2
    Author: Jesse Burt
    Description: Library of generic bitmap-oriented graphics rendering routines
    Copyright (c) 2019
    Started May 19, 2019
    Updated Dec 3, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON


VAR

    long _row, _col
    long _font_width, _font_height, _font_addr
    long _fgcolor, _bgcolor

PUB BGColor (col)
' Set background color for subsequent drawing
    return _bgcolor := col

PUB Bitmap(bitmap_addr, bitmap_size, offset)

    bytemove(_draw_buffer + offset, bitmap_addr, bitmap_size)

PUB Box(x0, y0, x1, y1, color, filled) | x, y

    x0 := 0 #> x0 <# _disp_width-1
    y0 := 0 #> y0 <# _disp_height-1
    x1 := 0 #> x1 <# _disp_width-1
    y1 := 0 #> y1 <# _disp_height-1

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

PUB Clear
' Clear the display buffer
    bytefill(_draw_buffer, $00, _buff_sz)

PUB ClearAll

    ClearAccel
    Clear
    Update

PUB Char (ch) | glyph_col
' Write a character to the display
    case MAX_COLOR
        1:
            repeat glyph_col from 0 to _font_height-1 
                byte[_draw_buffer][(_row * _disp_width) + (_col * _font_width) + glyph_col] := byte[_font_addr + 8 * ch + glyph_col]
        '65535: XXX To be implemented

PUB Circle(x0, y0, radius, color) | x, y, err, cdx, cdy
' Draw a circle at x0, y0
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

PUB Copy (sx, sy, ex, ey, dx, dy) | x, y, tmp
' Copy rectangular region at (sx, sy, ex, ey) to (dx, dy)
    repeat y from sy to ey
        repeat x from sx to ex
            tmp := Point(x, y)
            Plot((dx + x)-sx, (dy + y)-sy, tmp)

PUB Cut (sx, sy, ex, ey, dx, dy) | x, y, tmp
' Cut region of size width, height starting at sx, sy to dx, dy
'   Clears original region to background color
    repeat y from sy to ey
        repeat x from sx to ex
            tmp := Point(x, y)
            Plot((dx + x)-sx, (dy + y)-sy, tmp)             ' Copy to destination region
            Plot(x, y, _bgcolor)                            ' Cut the original region

PUB FGColor (col)

    return _fgcolor := col

PUB FontAddress(addr)
' Set address of font definition
    case addr
        $0004..$7FFFF:
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

PUB FontWidth
' Return the set font width
    return _font_width

PUB Line(x1, y1, x2, y2, c) | sx, sy, ddx, ddy, err, e2
' Draw line from x1, y1 to x2, y2, in color c
'   xxx add case for determining if a line is straight horiz or vert,
'       and add code to draw those lines faster than using Bresenham's algo below
    x1 := 0 #> x1 <# _disp_width-1
    y1 := 0 #> y1 <# _disp_height-1
    x2 := 0 #> x2 <# _disp_width-1
    y2 := 0 #> y2 <# _disp_height-1

    case x1 == x2 or y1 == y2
        TRUE:
            if x1 == x2                     ' X's are the same - use Plot to draw a straight V-line
                repeat sy from y1 to y2
                    Plot(x1, sy, c)
            if y1 == y2                     ' Y's are the same - use Plot to draw a straight H-line
                repeat sx from x1 to x2
                    Plot(sx, y1, c)
        FALSE:                              ' Both are different - use Bresenham's line algo to draw diag. line
            ddx := ||(x2-x1)
            ddy := ||(y2-y1)
            err := ddx-ddy

            sx := -1
            if (x1 < x2)
                sx := 1

            sy := -1
            if (y1 < y2)
                sy := 1

            case MAX_COLOR
                1:
                    case c
                        1:
                            repeat until ((x1 == x2) AND (y1 == y2))
                                byte[_draw_buffer][x1 + (y1>>3{/8})*_disp_width] |= (1 << (y1&7))

                                e2 := err << 1

                                if e2 > -ddy
                                    err := err - ddy
                                    x1 := x1 + sx

                                if e2 < ddx
                                    err := err + ddx
                                    y1 := y1 + sy

                        0:
                            repeat until ((x1 == x2) AND (y1 == y2))
                                byte[_draw_buffer][x1 + (y1>>3{/8})*_disp_width] &= (1 << (y1&7))

                                e2 := err << 1

                                if e2 > -ddy
                                    err := err - ddy
                                    x1 := x1 + sx

                                if e2 < ddx
                                    err := err + ddx
                                    y1 := y1 + sy
                        -1:
                            repeat until ((x1 == x2) AND (y1 == y2))
                                byte[_draw_buffer][x1 + (y1>>3{/8})*_disp_width] ^= (1 << (y1&7))

                                e2 := err << 1

                                if e2 > -ddy
                                    err := err - ddy
                                    x1 := x1 + sx

                                if e2 < ddx
                                    err := err + ddx
                                    y1 := y1 + sy

                        OTHER:
                            return
                65535:
                    repeat until ((x1 == x2) AND (y1 == y2))
                        word[_draw_buffer][x1 + (y1 * _disp_width)] := c

                            e2 := err << 1

                            if e2 > -ddy
                                err := err - ddy
                                x1 := x1 + sx

                            if e2 < ddx
                                err := err + ddx
                                y1 := y1 + sy

PUB Plot (x, y, color)
' Plot pixel at x, y, color c
    x := 0 #> x <# _disp_width-1
    y := 0 #> y <# _disp_height-1
    case MAX_COLOR
        1:
            case color
                1:
                    byte[_draw_buffer][x + (y>>3{/8})*_disp_width] |= (1 << (y&7))
                0:
                    byte[_draw_buffer][x + (y>>3{/8})*_disp_width] &= (1 << (y&7))
                -1:
                    byte[_draw_buffer][x + (y>>3{/8})*_disp_width] ^= (1 << (y&7))
                OTHER:
                    return
        65535:
            word[_draw_buffer][x + (y * _disp_width)] := color

PUB Point (x, y)
' Get color of pixel at x, y
    x := 0 #> x <# _disp_width-1
    y := 0 #> y <# _disp_height-1

    case MAX_COLOR
        1:
            result := byte[_draw_buffer][x + (y>>3{/8}) * _disp_width]
        65535:
            result := word[_draw_buffer][x + (y * _disp_width)]

PUB Position(col, row)
' Set text draw position, in character-cell col and row
'    _col := col &= (_disp_width / _font_width) - 1    'Clamp position based on
'    _row := row &= (_disp_height / _font_height) - 1   ' screen's dimensions
    col := 0 #> col <# (_disp_width / _font_width)-1
    row := 0 #> row <# (_disp_height / _font_height)-1
    _col := col
    _row := row

PUB Str (string_addr) | i
' Write string at string_addr to the display @ row and column.
'   NOTE: Wraps to the left at end of line and to the top-left at end of display
    repeat i from 0 to strsize(string_addr)-1
        Char(byte[string_addr][i])
        _col++
        if _col > (_disp_width / _font_width) - 1
            _col := 0
            _row++
            if _row > (_disp_height / _font_height) - 1
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
