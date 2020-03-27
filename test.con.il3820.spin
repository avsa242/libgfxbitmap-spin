#define IL3820

CON

    BUFFSZ          = (FB_WIDTH * FB_HEIGHT) / 8
    DEF_FB_WIDTH    = 128
    DEF_FB_HEIGHT   = 296
    XMAX            = FB_WIDTH-1
    YMAX            = FB_HEIGHT-1
    MAX_COLOR       = 1

DAT

    drivername  byte    "IL3820", 0
