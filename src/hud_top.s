
HUD_TEXT_ADDR = $2040

HUD_IRQ_LINE = $1f
HUD_SPLIT_Y = 32
.if MAPPER_MMC3
  HUD_SPLIT_DELAY = 40 - 15
.else
  HUD_SPLIT_DELAY = 15 - 15
.endif

.macro HudReserveRam
.endmacro

.macro HudIrqHandler
  pha
  phx
    MAPPER_IRQ_ACK
    HudScrollSplit HUD_SPLIT_Y, HUD_SPLIT_DELAY
  plx
  pla
  rti
.endmacro

.macro HudNmiLagFrame
    lda DisableScreenFlag
    bne :+
      SetScanlineIRQ #HUD_IRQ_LINE
      lda Mirror_PPUCTRL
      and #%11111110            ;alter name table address to be $2800
      sta PPUCTRL              ;(essentially $2000) but save other bits
      lda #0
      sta PPUSCROLL
      sta PPUSCROLL
    :
.endmacro

.macro HudNmiSetScroll
.local SkipSplit
  lda HorizontalScroll
  sta IrqNewScroll
  ; lda Mirror_PPUCTRL
  ; sta IrqScrollBit
  lda Sprite0HitDetectFlag  ;check for flag here
  beq SkipSplit
    SetScanlineIRQ #HUD_IRQ_LINE
    ; cli just in case NMI runs late
    cli
SkipSplit:
  lda Mirror_PPUCTRL
  sta IrqPPUCTRL
  ; and also reset the flags for the HUD
  and #%11111100
  sta PPUCTRL
.endmacro

; The playfield is not moved, so sprites keep their world Y
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
