#define HT16K33-ADAFRUIT

CON

    BUFFSZ          = (FB_WIDTH * FB_HEIGHT) / 8
    DEF_FB_WIDTH    = 8                             ' Can be 8 or 16
    DEF_FB_HEIGHT   = 8
    XMAX            = FB_WIDTH-1
    YMAX            = FB_HEIGHT-1
    MAX_COLOR       = 1

DAT

    drivername  byte    "HT16K33-ADAFRUIT", 0
