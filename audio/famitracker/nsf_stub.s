;
; NSF stub file, used to define compile constants
;

PACKAGE = 1
HAS_NSF_HEADER = 1
USE_AUX_DATA = 1
NAMCO_CHANNELS = 0

; path to NSF driver source
.include "driver/driver.s"
; path to NSF export source
.include "sample_songs.asm"
