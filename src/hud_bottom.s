
HUD_TEXT_ADDR = $2020

HUD_SCROLL_Y = 32           ;playfield scroll and how far sprites move up to match
HUD_IRQ_LINE = 207
HUD_SPLIT_Y = 0
.if MAPPER_MMC3
  HUD_SPLIT_DELAY = 42 - 15
.else
  HUD_SPLIT_DELAY = 15 - 15
.endif

; these hold the scroll split values for lag frames
.macro HudReserveRam
RESERVE HudPlayfieldScroll, 1
RESERVE HudPlayfieldCtrl, 1
.endmacro

.macro HudIrqHandler
  pha
  phx
    MAPPER_IRQ_ACK
    HudScrollSplit HUD_SPLIT_Y, HUD_SPLIT_DELAY
    ; Turn off sprites to make sprites disappear when falling into the HUD area
    lda Mirror_PPUMASK
    and #%11101111
    sta PPUMASK
  plx
  pla
  rti
.endmacro

.macro HudSetPlayfieldScroll
  lda HudPlayfieldCtrl
  and #%11111101              ;vertical name table 0
  sta PPUCTRL
  lda HudPlayfieldScroll
  sta PPUSCROLL
  lda #HUD_SCROLL_Y
  sta PPUSCROLL
.endmacro

.macro HudNmiLagFrame
    lda Mirror_PPUMASK
    and #%00011000
    beq :+
      SetScanlineIRQ #HUD_IRQ_LINE
      HudSetPlayfieldScroll
      lda Mirror_PPUMASK
      sta PPUMASK
    :
.endmacro

.macro HudNmiSetScroll
.local Latch, SkipSplit
  lda Mirror_PPUCTRL
  ldx HorizontalScroll
  ldy Sprite0HitDetectFlag
  bne Latch
    ldx #0
    and #%11111110
Latch:
  stx HudPlayfieldScroll
  sta HudPlayfieldCtrl
  and #%11111100              ;the status bar is in name table 0
  sta IrqPPUCTRL
  lda #0
  sta IrqNewScroll
  HudSetPlayfieldScroll
  tya
  beq SkipSplit
    SetScanlineIRQ #HUD_IRQ_LINE
    ; cli just in case NMI runs late
    cli
SkipSplit:
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
