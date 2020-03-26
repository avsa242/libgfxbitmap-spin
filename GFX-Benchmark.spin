{
    --------------------------------------------
    Filename: GFX-Benchmark.spin
    Description: Benchmark utility for bitmap graphics library
    Author: Jesse Burt
    Copyright (c) 2020
    Created: Mar 26, 2020
    Updated: Mar 26, 2020
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

' Uncomment one display type #include line below:
#include "test.con.ssd130x.spin"
'#include "test.con.ssd1331.spin"
'#include "test.con.ssd1351.spin"
'#include "test.con.st7735.spin"
'#include "test.con.il3820.spin"
'#include "test.con.ht16k33-adafruit.spin"
'#include "test.con.neopixel.spin"

' Optionally modify framebuffer width and height
    FB_WIDTH    = DEF_FB_WIDTH
    FB_HEIGHT   = DEF_FB_HEIGHT

    SER_RX      = 31
    SER_TX      = 30
    SER_BAUD    = 115_200

    LED         = cfg#LED1

OBJ

    cfg         : "core.con.boardcfg.quickstart"
    ser         : "com.serial.terminal.ansi"
    time        : "time"
    io          : "io"
    int         : "string.integer"
    fnt5x8      : "font.5x8"

VAR

    long _timer_set
    long _draw_buffer, _buff_sz, _disp_xmax, _disp_ymax, _disp_width, _disp_height
    long _stack_timer[50]
    byte _framebuff[BUFFSZ]
    byte _ser_cog

PUB Main | r, ttime

    Setup

    TestBox (5000)
    TestChar (5000)
    TestCircle (5000)
    TestCopy (5000)
    TestCut (5000)
    TestDiagLineMax (5000)
    TestPlot (5000)
    TestPoint (5000)
    TestScale (5000)
    TestStraightHLineMax (5000)
    TestStraightVLineMax (5000)

    FlashLED(LED, 100)

PUB TestBox(testtime) | iteration

    ser.str(string("TestBox - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        Box (0, 0, XMAX, YMAX, 1, FALSE)
        iteration++

    Report(testtime, iteration)
    return iteration

PUB TestChar(testtime) | iteration

    ser.str(string("TestChar - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        Char($08)
        iteration++

    Report(testtime, iteration)
    return iteration

PUB TestCircle(testtime) | iteration, x, y

    x := XMAX/2
    y := YMAX/2
    ser.str(string("TestCircle - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        Circle(x, y, y, 1)
        iteration++

    Report(testtime, iteration)
    return iteration

PUB TestCopy(testtime) | iteration, dx, dy, sx1, sy1, sx2, sy2

    sx1 := 0
    sy1 := 0
    sx2 := XMAX/2
    sy2 := YMAX

    dx := XMAX/2
    dy := 0

    ser.str(string("TestCopy - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        Copy (sx1, sy1, sx2, sy2, dx, dy)
        iteration++

    Report(testtime, iteration)
    return iteration

PUB TestCut(testtime) | iteration, dx, dy, sx1, sy1, sx2, sy2

    sx1 := 0
    sy1 := 0
    sx2 := XMAX/2
    sy2 := YMAX

    dx := XMAX/2
    dy := 0

    ser.str(string("TestCut - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        Cut (sx1, sy1, sx2, sy2, dx, dy)
        iteration++

    Report(testtime, iteration)
    return iteration

PUB TestDiagLineMax(testtime) | iteration

    ser.str(string("TestDiagLineMax - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        Line(0, 0, XMAX, YMAX, 1)
        iteration++

    Report(testtime, iteration)
    return iteration

PUB TestPlot(testtime) | iteration

    ser.str(string("TestPlot - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        Plot(0, 0, 1)
        iteration++

    Report(testtime, iteration)
    return iteration

PUB TestPoint(testtime) | iteration, tmp

    ser.str(string("TestPoint - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        tmp := Point(0, 0)
        iteration++

    Report(testtime, iteration)
    return iteration

PUB TestScale(testtime) | iteration, sx, sy, ex, ey, offsx, offsy, size

    sx := 0
    sy := 0
    ex := XMAX/4
    ey := YMAX/4
    offsx := ex
    offsy := 0
    size := 2
    ser.str(string("TestScale - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        Scale (sx, sy, ex, ey, offsx, offsy, size)
        iteration++

    Report(testtime, iteration)
    return iteration

PUB TestStraightHLineMax(testtime) | iteration

    ser.str(string("TestStraightHLineMax - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        Line(0, 0, XMAX, 0, 1)
        iteration++

    Report(testtime, iteration)
    return iteration

PUB TestStraightVLineMax(testtime) | iteration

    ser.str(string("TestStraightVLineMax - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        Line(0, 0, 0, YMAX, 1)                                                                          
        iteration++

    Report(testtime, iteration)
    return iteration

PRI Report(testtime, iterations) 

    ser.str(string("Total iterations: "))
    ser.dec(iterations)

    ser.str(string(", Iterations/sec: "))
    ser.dec(iterations / (testtime/1000))

    ser.str(string(", Iterations/ms: "))
    Decimal( (iterations * 1_000) / testtime, 1_000)
    ser.newline

PUB ClearAccel
'   Dummy method

PUB Update
'   Dummy method

PUB Decimal(scaled, divisor) | whole[4], part[4], places, tmp
' Display a fixed-point scaled up number in decimal-dot notation - scale it back down by divisor
'   e.g., Decimal (314159, 100000) would display 3.14159 on the termainl
'   scaled: Fixed-point scaled up number
'   divisor: Divide scaled-up number by this amount
    whole := scaled / divisor
    tmp := divisor
    places := 0

    repeat
        tmp /= 10
        places++
    until tmp == 1
    part := int.DecZeroed(||(scaled // divisor), places)

    ser.Dec (whole)
    ser.Char (".")
    ser.Str (part)

PRI cog_Timer | time_left

    repeat
        repeat until _timer_set
        time_left := _timer_set

        repeat
            time_left--
            time.MSleep(1)
        while time_left > 0
        _timer_set := 0

PUB Setup

    repeat until ser.StartRXTX (SER_RX, SER_TX, %0000, SER_BAUD)
    time.MSleep(30)
    ser.Clear
    ser.Str (string("Serial terminal started", ser#CR, ser#LF))
    cognew(cog_Timer, @_stack_timer)

    _buff_sz := BUFFSZ
    _disp_width := FB_WIDTH
    _disp_height := FB_HEIGHT
    _disp_xmax := _disp_width-1
    _disp_ymax := _disp_height-1
    _draw_buffer := @_framebuff
    FontSize(6, 8)

#include "lib.utility.spin"
#include "lib.gfx.bitmap.spin"

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
