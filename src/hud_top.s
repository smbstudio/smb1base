HUD_LABEL_ADDR = $2780      ;lower half, row 28
HUD_SCORE_ADDR = $27a0      ;lower half, row 29

; Scanlines 0-15 upper half, 16-31 lower half, 32-239 playfield
HUD_IRQ_LINE = 15
HUD_IRQ_LINE_2 = 31
.if MAPPER_MMC3
  HUD_SPLIT_DELAY_1 = 37 - 15
  HUD_SPLIT_DELAY_2 = 47 - 15
.else
  HUD_SPLIT_DELAY_1 = 15 - 15
  HUD_SPLIT_DELAY_2 = 21 - 15
.endif

.macro HudFirstSplit
    HudSetNextIRQ HUD_IRQ_LINE_2, HUD_IRQ_LINE
    HudSplitHalf 1, HUD_SPLIT_DELAY_1
.endmacro

.macro HudSecondSplit
    HudSplitPlayfield 0, HUD_SPLIT_DELAY_2
.endmacro

; upper half of the HUD
.macro HudSetFrameScroll
  lda IrqPPUCTRL
  and #%11111100            ;name table 0
  sta PPUCTRL
  lda #0
  sta PPUSCROLL
  lda #HUD_NT_Y
  sta PPUSCROLL
.endmacro

; The playfield is drawn at its world Y, so sprites are not moved
.macro HudShiftSpriteY
.endmacro

.macro HudShiftOamY
.endmacro

.macro HudShiftMetaspriteY yhi
.endmacro

.macro HudStoreFloateyY ylo, yhi
  sta ylo
  lda #1
  sta yhi
.endmacro
