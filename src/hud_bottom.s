HUD_LABEL_ADDR = $23a0      ;upper half, row 29
HUD_SCORE_ADDR = $2780      ;lower half, row 28

HUD_SCROLL_Y = 32

HUD_IRQ_LINE = 207
HUD_IRQ_LINE_2 = 223
.if MAPPER_MMC3
  HUD_SPLIT_DELAY_1 = 37 - 15
  HUD_SPLIT_DELAY_2 = 57 - 15
.else
  HUD_SPLIT_DELAY_1 = 15 - 15
  HUD_SPLIT_DELAY_2 = 30 - 15
.endif

.macro HudFirstSplit
    HudSetNextIRQ HUD_IRQ_LINE_2, HUD_IRQ_LINE
    HudSplitHalf 0, HUD_SPLIT_DELAY_1
    ; Turn off sprites to make sprites disappear when falling into the HUD area
    lda Mirror_PPUMASK
    and #%11101111
    sta PPUMASK
.endmacro

.macro HudSecondSplit
    HudSplitHalf 1, HUD_SPLIT_DELAY_2
.endmacro

; Scroll at the top of the frame: the playfield
.macro HudSetFrameScroll
  lda IrqPPUCTRL
  and #%11111101            ;vertical name table 0
  sta PPUCTRL
  lda HudPlayfieldScroll
  sta PPUSCROLL
  lda #0
  sta PPUSCROLL
.endmacro

; Offset the sprite by the HUD position if its been moved.
; Sprites above the top of the screen are hidden.
.macro HudShiftSpriteY
.local Visible
  sec
  sbc #HUD_SCROLL_Y
  bcs Visible
    lda #$f8
Visible:
.endmacro

.macro HudShiftOamY
.local Hidden
  lda Sprite_Y_Position,y
  cmp #$f8
  beq Hidden
    HudShiftSpriteY
    sta Sprite_Y_Position,y
Hidden:
.endmacro

; A position above the top of the screen leaves page 1, so the renderer culls it
.macro HudShiftMetaspriteY yhi
.local SamePage
  sec
  sbc #HUD_SCROLL_Y
  bcs SamePage
    dec yhi
SamePage:
.endmacro

.macro HudStoreFloateyY ylo, yhi
  sec
  sbc #HUD_SCROLL_Y
  sta ylo
  lda #1
  sbc #0
  sta yhi
.endmacro
