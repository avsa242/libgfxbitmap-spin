{
    --------------------------------------------
    Filename: library.gfx.bitmap.spin
    Author: Jesse Burt
    Description: Library of generic bitmap-oriented graphics rendering routines
    Copyright (c) 2021
    Started May 19, 2019
    Updated Feb 3, 2021
    See end of file for terms of use.
    --------------------------------------------
}

CON


VAR

    long _row, _col, _row_max, _col_max
    long _font_width, _font_height, _font_addr, _fnt_scl
    long _fgcolor, _bgcolor

PUB BGColor(col): curr_clr
' Set background color for subsequent drawing
    return _bgcolor := col

#ifndef GFX_DIRECT
PUB Bitmap(bitmap_addr, bitmap_size, offset)
' Copy a bitmap to the display buffer
'   bitmap_addr:    Address of bitmap to copy
'   bitmap_size:    Number of bytes to copy
'   offset:         Offset within the display buffer to copy to
    bytemove(_ptr_drawbuffer + offset, bitmap_addr, bitmap_size)
#endif

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
#ifdef SSD130X
            repeat y from y0 to y1                          ' Temporary for 1bpp drivers
                repeat x from x0 to x1
                    Plot(x, y, color)
#elseifdef IL3820
            repeat y from y0 to y1
                repeat x from x0 to x1
                    Plot(x, y, color)
#elseifdef LEDMATRIX_CHARLIEPLEXED
            repeat y from y0 to y1
                repeat x from x0 to x1
                    Plot(x, y, color)
#elseifdef HT16K33-ADAFRUIT
            repeat y from y0 to y1
                repeat x from x0 to x1
                    Plot(x, y, color)
#else
#ifdef __FASTSPIN__
            if x0 => 0 and x0 =< _disp_width and y0 => 0 and y0 =< _disp_height and x1 => 0 and x1 =< _disp_width and y1 => 0 and y1 =< _disp_height
#else
            if lookdown(x0: 0.._disp_width) and lookdown(y0: 0.._disp_height) and lookdown(x1: 0.._disp_width) and lookdown(y1: 0.._disp_height)
#endif
                x := ||(x1-x0)
                if x1 < x0
                    repeat y from y0 to y1
                        memFill(x1, y, color, x)
                else
                    repeat y from y0 to y1
                        memFill(x0, y, color, x)
            else
                return FALSE
#endif

PUB Char(ch) | glyph_col, glyph_row, xs, ys, xe, ye, last_glyph_col, last_glyph_row, glyph, char_ht, char_wid
' Write a character to the display
    last_glyph_col := _font_width-1             ' last column of pixels in font
    last_glyph_row := _font_height-1            '   definition
    char_wid := _font_width * _fnt_scl          ' scaled character dimensions
    char_ht := _font_height * _fnt_scl          '

    case ch
        LF:                                     ' line feed
            _row += char_ht                     ' increment row by one char
            if _row > _disp_height-char_ht      ' if last row reached,
                _row -= char_ht                 '   don't go further; instead,
                repeat char_ht                  '   scroll up one text row
                    scrollup(0, 0, _disp_xmax, _disp_ymax)
        CR:                                     ' carriage return
            _col := 0

        32..127:                                ' printable characters
            ch <<= 3                            ' char position in font table
            case _fnt_scl
                0, 1:                           ' no scaling applied
                    repeat glyph_col from 0 to last_glyph_col
                        xs := _col + glyph_col  ' x-coord to draw dot from font
                        glyph := ch + glyph_col ' point to current glyph data
                        repeat glyph_row from 0 to last_glyph_row
                            if byte[_font_addr][glyph] & |< glyph_row
                                plot(xs, _row + glyph_row, _fgcolor)
                            else
                                plot(xs, _row + glyph_row, _bgcolor)
                2..8:                           ' scale 2..8x
                    repeat glyph_col from 0 to last_glyph_col
                        xs := _col + (glyph_col * _fnt_scl)
                        xe := xs + _fnt_scl
                        glyph := ch + glyph_col ' offs. in glyph definition
                        repeat glyph_row from 0 to last_glyph_row
                            ys := _row + (glyph_row * _fnt_scl)
                            ye := ys + _fnt_scl
                            if byte[_font_addr][glyph] & |< glyph_row
                                box(xs, ys, xe, ye, _fgcolor, true)
                            else
                                box(xs, ys, xe, ye, _bgcolor, true)

            _col += char_wid                    ' inc column after rendering
            if _col > _disp_xmax-char_wid       ' if last column reached,
                _col := 0                       '   return to col 0 and go to
                _row += char_ht                 '   the next row
            if _row > _disp_height-char_ht      ' if last row is reached,
                _row -= char_ht                 '   stay there and scroll up
                repeat char_ht                  '   the display
                    scrollup(0, 0, _disp_xmax, _disp_ymax)

PUB Circle(x0, y0, radius, color, filled) | x, y, err, cdx, cdy, ht
' Draw a circle
'   x0, y0: Coordinates
'   radius: Circle radius
'   color: Color to draw circle
'   filled: Whether or not to draw a filled circle (0: no, nonzero: yes)
    case filled
        FALSE:
            x := radius - 1
            y := 0
            cdx := 1
            cdy := 1
            err := cdx - (radius << 1)

            repeat while (x >= y)
                plot(x0 + x, y0 + y, color)
                plot(x0 + y, y0 + x, color)
                plot(x0 - y, y0 + x, color)
                plot(x0 - x, y0 + y, color)
                plot(x0 - x, y0 - y, color)
                plot(x0 - y, y0 - x, color)
                plot(x0 + y, y0 - x, color)
                plot(x0 + x, y0 - y, color)

                if (err <= 0)
                    y++
                    err += cdy
                    cdy += 2

                if (err > 0)
                    x--
                    cdx += 2
                    err += cdx - (radius << 1)
        other:
            repeat x from -radius to radius
                ht := ^^((radius * radius) - (x * x))
                repeat y from -ht to ht-1
                    plot(x0 + x, y0 + y, color)

#ifndef GFX_DIRECT
PUB Clear{}
' Clear the display buffer
#ifdef IL3820
    bytefill(_ptr_drawbuffer, _bgcolor, _buff_sz)
#elseifdef SSD130X
    bytefill(_ptr_drawbuffer, _bgcolor, _buff_sz)
#elseifdef SSD1331
    wordfill(_ptr_drawbuffer, _bgcolor, _buff_sz/2)
#elseifdef NEOPIXEL
    longfill(_ptr_drawbuffer, _bgcolor, _buff_sz)
#elseifdef HT16K33-ADAFRUIT
    bytefill(_ptr_drawbuffer, _bgcolor, _buff_sz)
#elseifdef ST7735
    wordfill(_ptr_drawbuffer, _bgcolor, _buff_sz/2)
#elseifdef SSD1351
    wordfill(_ptr_drawbuffer, _bgcolor, _buff_sz/2)
#elseifdef LEDMATRIX_CHARLIEPLEXED
    bytefill(_ptr_drawbuffer, _bgcolor, _buff_sz)
#elseifdef VGABITMAP6BPP
    bytefill(_ptr_drawbuffer, _bgcolor, _buff_sz)
#endif
#endif

PUB ClearAll{}

'    clearaccel
    clear{}
    update{}

PUB Copy(sx, sy, ex, ey, dx, dy) | x, y, tmp
' Copy rectangular region at (sx, sy, ex, ey) to (dx, dy)
    repeat y from sy to ey
        repeat x from sx to ex
            tmp := point(x, y)
            plot((dx + x)-sx, (dy + y)-sy, tmp)

PUB Cut(sx, sy, ex, ey, dx, dy) | x, y, tmp
' Copy rectangular region at (sx, sy, ex, ey) to (dx, dy)
'   Subsequently clears original region (sx, sy, ex, ey) to background color
    repeat y from sy to ey
        repeat x from sx to ex
            tmp := point(x, y)
            plot((dx + x)-sx, (dy + y)-sy, tmp)             ' Copy to destination region
            plot(x, y, _bgcolor)                            ' Cut the original region

PUB FGColor(col): curr_clr
' Set foreground color of subsequent drawing operations
    return _fgcolor := col

PUB FontAddress(addr): curr_addr
' Set address of font definition
    case addr
        $0004..$7FFF:
            _font_addr := addr
        OTHER:
            return _font_addr

PUB FontHeight{}: curr_ht
' Return the set font height
    return _font_height

PUB FontScale(fntscale): curr_scl
' Set font rendering scale factor
'   Valid values: 1..8
'   Any other value returns the current scale
    case fntscale
        1..8:
            _fnt_scl := fntscale
        other:
            return _fnt_scl

PUB FontSize(width, height)
' Set expected dimensions of font glyphs, in pixels
'   NOTE: This doesn't have to be the same as the size of the font glyphs.
'       e.g., if you have a 5x8 font, you may want to set the width to 6 or 8.
'       This will affect the number of text columns
    _font_width := width
    _font_height := height
    if _disp_width // _font_width                           ' Ended up with a remainder of a column,
        _col_max := (_disp_width/_font_width) - 1           '   so subtract it out
    else
        _col_max := _disp_height/_font_width

    if _disp_height // _font_height
        _row_max := (_disp_height/_font_height) - 1
    else
        _row_max := _disp_height/_font_height

PUB FontWidth{}: curr_wid
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
                    err -= ddy
                    x1 += sx

                if e2 < ddx
                    err += ddx
                    y1 += sy
#ifndef GFX_DIRECT
PUB Plot(x, y, color)
' Plot pixel at x, y, color c
#ifdef __FASTSPIN__
    ifnot (x => 0 and x =< _disp_xmax) and (y => 0 and y =< _disp_ymax)
        return
#else
    ifnot lookdown(x: 0.._disp_xmax) and lookdown(y: 0.._disp_ymax)
        return
#endif

#ifdef IL3820
    case color
        1:
            byte[_ptr_drawbuffer][(x + y * _disp_width) >> 3] |= $80 >> (x & 7)
        0:
            byte[_ptr_drawbuffer][(x + y * _disp_width) >> 3] &= !($80 >> (x & 7))
        -1:
            byte[_ptr_drawbuffer][(x + y * _disp_width) >> 3] ^= $80 >> (x & 7)
        OTHER:
            return
#elseifdef SSD130X
    case color
        1:
            byte[_ptr_drawbuffer][x + (y>>3) * _disp_width] |= (|< (y&7))
        0:
            byte[_ptr_drawbuffer][x + (y>>3) * _disp_width] &= !(|< (y&7))
        -1:
            byte[_ptr_drawbuffer][x + (y>>3) * _disp_width] ^= (|< (y&7))
        OTHER:
            return
#elseifdef SSD1331
    word[_ptr_drawbuffer][x + (y * _disp_width)] := ((color >> 8) & $FF) | ((color << 8) & $FF00)
#elseifdef NEOPIXEL
    long[_ptr_drawbuffer][x + (y * _disp_width)] := color
#elseifdef HT16K33-ADAFRUIT
    x := x + 7
    x := x // 8

    case color
        1:
            byte[_ptr_drawbuffer][y] |= |< x
        0:
            byte[_ptr_drawbuffer][y] &= !(|< x)
        -1:
            byte[_ptr_drawbuffer][y] ^= |< x
        OTHER:
            return

#elseifdef ST7735
    word[_ptr_drawbuffer][x + (y * _disp_width)] := ((color >> 8) & $FF) | ((color << 8) & $FF00)
#elseifdef SSD1351
    word[_ptr_drawbuffer][x + (y * _disp_width)] := ((color >> 8) & $FF) | ((color << 8) & $FF00)
#elseifdef LEDMATRIX_CHARLIEPLEXED
    case color
        1:
            byte[_ptr_drawbuffer][x + (y>>3) * _disp_width] |= (|< (y&7))
        0:
            byte[_ptr_drawbuffer][x + (y>>3) * _disp_width] &= !(|< (y&7))
        -1:
            byte[_ptr_drawbuffer][x + (y>>3) * _disp_width] ^= (|< (y&7))
        OTHER:
            return
#elseifdef VGABITMAP6BPP
    byte[_ptr_drawbuffer][x + (y * _disp_width)] := (color << 2) | $3
#else
#warning "No supported display types defined!"
#endif
#endif

PUB Point(x, y): pix_clr
' Get color of pixel at x, y
    x := 0 #> x <# _disp_xmax
    y := 0 #> y <# _disp_ymax

#ifdef IL3820
    return byte[_ptr_drawbuffer][(x + y * _disp_width) >> 3]
#elseifdef SSD130X
    return (byte[_ptr_drawbuffer][(x + (y >> 3) * _disp_width)] & (1 << (y & 7)) <> 0) * -1
#elseifdef SSD1331
    return word[_ptr_drawbuffer][x + (y * _disp_width)]
#elseifdef NEOPIXEL
    return long[_ptr_drawbuffer][x + (y * _disp_width)]
#elseifdef HT16K33-ADAFRUIT
    x := x + 7
    x := x // 8
    return byte[_ptr_drawbuffer][y + (x >> 3) * _disp_width]
#elseifdef ST7735
    return word[_ptr_drawbuffer][x + (y * _disp_width)]
#elseifdef SSD1351
    return word[_ptr_drawbuffer][x + (y * _disp_width)]
#elseifdef LEDMATRIX_CHARLIEPLEXED
    return (byte[_ptr_drawbuffer][(x + (y >> 3) * _disp_width)] & (1 << (y & 7)) <> 0) * -1
#elseifdef VGABITMAP6BPP
    return byte[_ptr_drawbuffer][x + (y * _disp_width)] >> 2
#else
#warning "No supported display types defined!"
#endif

PUB Position(col, row)
' Set text draw position, in character-cell col and row
    col := 0 #> col <# _col_max
    row := 0 #> row <# _row_max
    _col := col * (_font_width * _fnt_scl)
    _row := row * (_font_height * _fnt_scl)

PUB RGB222_RGB6(r, g, b)
' Return 6-bit color from discrete Red, Green, Blue color components
'   Valid values:
'       r, g, b: 0..3
'   NOTE: The least-significant two bits are a requirement of the 6bpp VGA display driver
    return ((((r <# 3) #> 0) << 6) | (((g <# 3) #> 0) << 4) | (((b <# 3) #> 0) << 2) | $3)

PUB RGBW8888_RGB32(r, g, b, w): rgb32
' Return 32-bit long from discrete Red, Green, Blue, White color components (values 0..255)
    rgb32.byte[3] := r
    rgb32.byte[2] := g
    rgb32.byte[1] := b
    rgb32.byte[0] := w

PUB RGBW8888_RGB32_Brightness(r, g, b, w, level): rgb32
' Return 32-bit long from discrete Red, Green, Blue, White color components
'   and clamp all color channels to maximum level or brightness
'   Valid values:
'       r, g, b, w: 0..255
'       level: 0..100 (%)
    if (level =< 0)
        return 0

    elseif (level => 255)
        return RGBW8888_RGB32(r, g, b, w)

    else
        r := r * level / 255                    ' Apply level to RGBW
        g := g * level / 255
        b := b * level / 255
        w := w * level / 255
        return RGBW8888_RGB32(r, g, b, w)

PUB RGB565_R8(rgb565): r8
' Isolate red component of 16-bit RGB565 color and return value scaled to 8-bit range
    return (((rgb565 & $F800) >> 11) * 527 + 23 ) >> 6

PUB RGB565_G8(rgb565): g8
' Isolate green component of 16-bit RGB565 color and return value scaled to 8-bit range
    return (((rgb565 & $7E0) >> 5)  * 259 + 33 ) >> 6

PUB RGB565_B8(rgb565): b8
' Isolate blue component of 16-bit RGB565 color and return value scaled to 8-bit range
    return ((rgb565 & $1F) * 527 + 23 ) >> 6

PUB Scale(sx, sy, ex, ey, offsx, offsy, size) | x, y, dx, dy, in
' Scale a region of the display up by size
    repeat y from sy to ey
        repeat x from sx to ex
            in := Point(x, y)
            dx := offsx + (x*size)-(sx*size)
            dy := offsy + (y*size)-(sy*size)
            Box(dx, dy, dx + size, dy + size, in, TRUE)

PUB ScrollDown(sx, sy, ex, ey) | scr_width, src, dest, x, y
' Scroll a region of the display down by 1 pixel
    scr_width := ex-sx
    repeat y from ey-1 to sy

#ifdef IL3820
        copy(sx, y, ex, y, sx, y+1)             ' Use Copy() for monochrome
#elseifdef SSD130X                              ' display types, until a more
        copy(sx, y, ex, y, sx, y+1)             ' efficient method can be
#elseifdef SSD1331                              ' devised
        src := sx + (y * BYTESPERLN)
        dest := sx + ((y+1) * BYTESPERLN)
        wordmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef NEOPIXEL
        src := sx + (y * BYTESPERLN)
        dest := sx + ((y+1) * BYTESPERLN)
        longmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef HT16K33-ADAFRUIT
        copy(sx, y, ex, y, sx, y+1)
#elseifdef ST7735
        src := sx + (y * BYTESPERLN)
        dest := sx + ((y+1) * BYTESPERLN)
        wordmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef SSD1351
        src := sx + (y * BYTESPERLN)
        dest := sx + ((y+1) * BYTESPERLN)
        wordmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef VGABITMAP6BPP
        src := sx + (y * _disp_width)
        dest := sx + ((y+1) * _disp_width)
        bytemove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef LEDMATRIX_CHARLIEPLEXED
        copy(sx, y, ex, y, sx, y+1)
#else
#warning "No supported display types defined!"
#endif

PUB ScrollLeft(sx, sy, ex, ey) | scr_width, src, dest, x, y
' Scroll a region of the display left by 1 pixel
    scr_width := ex-sx
    repeat y from sy to ey

#ifdef IL3820
        copy(sx, y, ex, y, sx-1, y)
#elseifdef SSD130X
        copy(sx, y, ex, y, sx-1, y)
#elseifdef SSD1331
        src := sx + (y * BYTESPERLN)
        dest := (sx-BYTESPERPX) + (y * BYTESPERLN)
        wordmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef NEOPIXEL
        src := sx + (y * BYTESPERLN)
        dest := (sx-BYTESPERPX) + (y * BYTESPERLN)
        longmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef HT16K33-ADAFRUIT
        copy(sx, y, ex, y, sx-1, y)
#elseifdef ST7735
        src := sx + (y * BYTESPERLN)
        dest := (sx-BYTESPERPX) + (y * BYTESPERLN)
        wordmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef SSD1351
        src := sx + (y * BYTESPERLN)
        dest := (sx-BYTESPERPX) + (y * BYTESPERLN)
        wordmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef VGABITMAP6BPP
        src := sx + (y * _disp_width)
        dest := (sx-1) + (y * _disp_width)
        bytemove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef LEDMATRIX_CHARLIEPLEXED
        copy(sx, y, ex, y, sx-1, y)
#else
#warning "No supported display types defined!"
#endif

PUB ScrollRight(sx, sy, ex, ey) | scr_width, src, dest, y
' Scroll a region of the display right by 1 pixel
    scr_width := ex-sx
    repeat y from sy to ey

#ifdef IL3820
        copy(sx, y, ex, y, sx+1, y)
#elseifdef SSD130X
        copy(sx, y, ex, y, sx+1, y)
#elseifdef SSD1331
        src := sx + (y * BYTESPERLN)
        dest := (sx+BYTESPERPX) + (y * BYTESPERLN)
        wordmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef NEOPIXEL
        src := sx + (y * BYTESPERLN)
        dest := (sx+BYTESPERPX) + (y * BYTESPERLN)
        longmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef HT16K33-ADAFRUIT
        copy(sx, y, ex, y, sx+1, y)
#elseifdef ST7735
        src := sx + (y * BYTESPERLN)
        dest := (sx+BYTESPERPX) + (y * BYTESPERLN)
        wordmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef SSD1351
        src := sx + (y * BYTESPERLN)
        dest := (sx+BYTESPERPX) + (y * BYTESPERLN)
        wordmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef VGABITMAP6BPP
        src := sx + (y * _disp_width)
        dest := (sx+1) + (y * _disp_width)
        bytemove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef LEDMATRIX_CHARLIEPLEXED
        copy(sx, y, ex, y, sx+1, y)
#else
#warning "No supported display types defined!"
#endif

PUB ScrollUp(sx, sy, ex, ey) | scr_width, src, dest, x, y
' Scroll a region of the display up by 1 pixel
    scr_width := ex-sx
    repeat y from sy+1 to ey

#ifdef IL3820
        copy(sx, y, ex, y, sx, y-1)
#elseifdef SSD130X
        copy(sx, y, ex, y, sx, y-1)
#elseifdef SSD1331
        src := sx + (y * BYTESPERLN)
        dest := sx + ((y-1) * BYTESPERLN)
        wordmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef NEOPIXEL
        src := sx + (y * BYTESPERLN)
        dest := sx + ((y-1) * BYTESPERLN)
        longmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef HT16K33-ADAFRUIT
        copy(sx, y, ex, y, sx, y-1)
#elseifdef ST7735
        src := sx + (y * BYTESPERLN)
        dest := sx + ((y-1) * BYTESPERLN)
        wordmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef SSD1351
        src := sx + (y * BYTESPERLN)
        dest := sx + ((y-1) * BYTESPERLN)
        wordmove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef VGABITMAP6BPP
        src := sx + (y * _disp_width)
        dest := sx + ((y-1) * _disp_width)
        bytemove(_ptr_drawbuffer + dest, _ptr_drawbuffer + src, scr_width)
#elseifdef LEDMATRIX_CHARLIEPLEXED
        copy(sx, y, ex, y, sx, y-1)
#else
#warning "No supported display types defined!"
#endif

PUB TextCols{}: cols
' Returns number of displayable text columns, based on set display width, font width, and scale
    return (_disp_width / _font_width) / _fnt_scl

PUB TextRows{}: rows
' Returns number of displayable text rows, based on set display height, font height, and scale
    return (_disp_height / _font_height) / _fnt_scl

PRI memFill(xs, ys, val, count)
' Fill region of display buffer memory
'   xs, ys: Start of region
'   val: Color
'   count: Number of consecutive memory locations to write
#ifdef IL3820
    bytefill(_ptr_drawbuffer + (xs + (ys * BYTESPERLN)), val, count)
#elseifdef SSD130X
    bytefill(_ptr_drawbuffer + (xs + (ys * BYTESPERLN)), val, count)
#elseifdef SSD1331
    wordfill(_ptr_drawbuffer + ((xs << 1) + (ys * BYTESPERLN)), ((val >> 8) & $FF) | ((val << 8) & $FF00), count)
#elseifdef NEOPIXEL
    longfill(_ptr_drawbuffer + ((xs << 1) + (ys * BYTESPERLN)), ((val >> 8) & $FF) | ((val << 8) & $FF00), count)
#elseifdef HT16K33-ADAFRUIT
    bytefill(_ptr_drawbuffer + (xs + (ys * BYTESPERLN)), val, count)
#elseifdef ST7735
    wordfill(_ptr_drawbuffer + ((xs << 1) + (ys * BYTESPERLN)), ((val >> 8) & $FF) | ((val << 8) & $FF00), count)
#elseifdef SSD1351
    wordfill(_ptr_drawbuffer + ((xs << 1) + (ys * BYTESPERLN)), ((val >> 8) & $FF) | ((val << 8) & $FF00), count)
#elseifdef LEDMATRIX_CHARLIEPLEXED
    bytefill(ptr_start, val, count)
#elseifdef VGABITMAP6BPP
    bytefill(_ptr_drawbuffer + (xs + (ys * BYTESPERLN)), (val << 2) | $3, count)
#endif
#include "lib.terminal.spin"

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
