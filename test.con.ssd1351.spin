#define SSD1351

    BUFFSZ          = (FB_WIDTH * FB_HEIGHT) * 2
    DEF_FB_WIDTH    = 128
    DEF_FB_HEIGHT   = 64                            ' Can be full 128 on P2/SPIN2
    XMAX            = FB_WIDTH-1
    YMAX            = FB_HEIGHT-1
    MAX_COLOR       = $FFFF
