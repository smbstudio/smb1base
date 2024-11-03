
; Single entrypoint that includes files to make building this easier


.macpack longbranch
.macpack generic

.linecont on
.feature force_range


.include "options.s"


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
.include "bcd16.s"
.include "level_handling.s"
.if USE_TILED_LEVELS
.include "huffmunch.s"
.include "tiled_level_handling.s"
.else
.include "vanilla_level_handling.s"
.endif
.include "reset.s"
.include "game.s"

.include "player.s"
.include "object.s"
.include "screen_render.s"
.include "sprite_render.s"

.include "metatiles.s"

.segment "AUDIO"

.include "music_drivers/audio.s"

.if USE_TILED_LEVELS
.include "tiled_levels/generated/segments.inc"
.endif

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

.if MAPPER_MMC5
.incbin "chr/mmc5/bg_water.chr"
.incbin "chr/mmc5/bg_ground.chr"
.incbin "chr/mmc5/bg_underground.chr"
.incbin "chr/mmc5/bg_castle.chr"

.incbin "chr/mmc5/sprites_mario.chr"
.incbin "chr/mmc5/sprites_misc.chr"
.incbin "chr/mmc5/sprites_enemies.chr"

.else

.incbin "chr/mmc5/bg_water.chr"
.incbin "chr/mmc5/bg_ground.chr"
.incbin "chr/mmc5/bg_underground.chr"
.incbin "chr/mmc5/bg_castle.chr"

.incbin "chr/mmc3/sprites_mario.chr"
.incbin "chr/mmc3/sprites_misc.chr"

.incbin "chr/mmc3/sprites_water.chr"
.incbin "chr/mmc3/sprites_overworld.chr"
.incbin "chr/mmc3/sprites_underground.chr"
.incbin "chr/mmc3/sprites_castle.chr"

.endif

.pushseg
.segment "TITLE"
TitleScreenData:
.incbin "chr/raw/titlescreen.bin"
.popseg