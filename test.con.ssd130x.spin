#define SSD130X

    DEF_FB_WIDTH    = 128
    DEF_FB_HEIGHT   = 32                            ' Can be 32 or 64
    BUFFSZ          = (FB_WIDTH * FB_HEIGHT) / 8
    XMAX            = FB_WIDTH-1
    YMAX            = FB_HEIGHT-1
    MAX_COLOR       = 1
