
; Single entrypoint that includes files to make building this easier


.macpack longbranch
.macpack generic
.macpack common

.linecont on
.feature force_range


.include "options.s"
.include "segments.s"


.include "inc/nes2header.inc"

;--------------------------------
; NES2.0 header

.if MAPPER_MMC5
nes2mapper 5 ; mmc5
.elseif MAPPER_MMC3
nes2mapper 4 ; mmc3
.endif
nes2prg $20000
nes2chr $10000
nes2bram $2000
nes2mirror 'V'
nes2tv 'N'
nes2end



_COMMON_DEFINE_SEGMENTS = 1
.include "inc/common.inc"

.include "inc/charmap.inc"
.include "inc/constants.inc"
.include "memory.s"
.include "inc/vram.inc"

.if MAPPER_MMC5
.include "mmc5.s"
.endif
.if MAPPER_MMC3
.include "mmc3.s"
.endif

.include "metasprite_engine.s"
.include "metasprite.s"

.include "common.s"
.include "collision.s"
.include "level_common.s"
.if LEVEL_FORMAT_LDTK
.include "level_ldtk.s"
.else
.include "level_vanilla.s"
.endif
.include "reset.s"
.include "game.s"

.include "player.s"
.include "object.s"
.include "screen_render.s"
.include "sprite_render.s"


.include "music_drivers/audio.s"


; .segment "FIXED"

; FarcallTableLo:
; .repeat ::_FARCALL_COUNT, I
;   .byte .ident(.sprintf("_LEFT_%d_LO", I))
; .endrepeat
; FarcallTableHi:
; .repeat ::_FARCALL_COUNT, I
;   .byte .ident(.sprintf("METASPRITE_LEFT_%d_LO", I))
; .endrepeat
; FarcallTableBank:
; .repeat ::_FARCALL_COUNT, I
;   .byte .ident(.sprintf("METASPRITE_LEFT_%d_LO", I))
; .endrepeat

.segment "CHR"

; Water = 0
; Ground = 1
; UnderGround = 2
; Castle = 3

.incbin "chr/bg_common.chr"
.incbin "chr/bg_water.chr"
.incbin "chr/bg_common.chr"
.incbin "chr/bg_ground.chr"
.incbin "chr/bg_common.chr"
.incbin "chr/bg_underground.chr"
.incbin "chr/bg_common.chr"
.incbin "chr/bg_castle.chr"

.incbin "chr/sprites_mario.chr"
.incbin "chr/sprites_misc.chr"

; 1kb pages: CHR_SPR_ENEMY, CHR_SPR_ENEMY+1, CHR_SPR_EXTRA
.incbin "chr/sprites_enemies.chr"
; 1kb page: CHR_SPR_MOUSE
.incbin "chr/sprites_mouse.chr"

.incbin "chr/sprites_castle.chr"

.pushseg
.segment "TITLE"
TitleScreenData:
.incbin "chr/raw/titlescreen.bin"
.byte $00 ; add terminator byte in case the data editor didn't
.popseg