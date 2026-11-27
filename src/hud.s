; The HUD is four tile rows split across both name tables (horizontal arrangement):
;   upper half: $2000 rows 28-29
;   lower half: $2400 rows 28-29
; The playfield is rows 0-25 of both name tables. Each frame has two scanline IRQs.
; We split up the HUD like this so that the scrolling code in 4 way scrolling has room
; for some garbage scanlines. We can hide scroll glitches properly because we use the IRQ
; to skip over these bad rows.

HUD_NT_Y = 224              ;scroll Y of name table row 28

.macro HudScrollSplit scrolly, delay
.local Loop, S4, S5, S6, DelayACycles
    sta PPUADDR

    ; Y position to $2005.
    lda #scrolly
    sta PPUSCROLL

    lda #delay
; copy pasted from the nesdev wiki
; 15-270 cycles of delay: delay=A+15; 0 <= A <= 255)
DelayACycles:
        sec
Loop:   sbc #5
        bcs Loop ;  6 6 6 6 6  FB FC FD FE FF
        adc #3  ;  2 2 2 2 2  FE FF 00 01 02
        bcc S4  ;  3 3 2 2 2  FE FF 00 01 02
        lsr     ;  - - 2 2 2  -- -- 00 00 01
        beq S5  ;  - - 3 3 2  -- -- 00 00 01
S4:     lsr     ;  2 2 - - 2  7F 7F -- -- 00
S5:     bcs S6  ;  2 3 2 3 2  7F 7F 00 00 00
S6:
; A page crossing adds a cycle to a taken branch, which would break the delay
.assert .hibyte(Loop) = .hibyte(S6), lderror, "IrqScrollSplit delay loop crosses a page"

    ; ((Y & $F8) << 2) | (X >> 3) in A for $2006 later.
    txa
    lsr
    lsr
    lsr
    ora #<((scrolly & $f8) << 2)

    ; The last two PPU writes must happen during hblank:
    stx PPUSCROLL
    sta PPUADDR
.endmacro

.macro HudSplitPlayfield scrolly, delay
    lda IrqPPUCTRL
    and #%00000001
    asl
    asl
    ldx IrqNewScroll
    HudScrollSplit scrolly, delay
.endmacro

; Split to one half of the HUD. nt is 0 for the upper half, 1 for the lower half.
.macro HudSplitHalf nt, delay
    ldx #0
    lda #nt << 2
    HudScrollSplit HUD_NT_Y, delay
.endmacro

.macro HudSetNextIRQ line, previous
.if MAPPER_MMC3
  SetScanlineIRQ #(line - previous - 1) ;the counter is relative to the current line
.else
  SetScanlineIRQ #line
.endif
.endmacro

.macro HudIrqHandler
.local Second, Done
  pha
  phx
    MAPPER_IRQ_ACK
    lda HudSplitPhase
    bne Second
      inc HudSplitPhase
      HudFirstSplit
      jmp Done
Second:
    HudSecondSplit
Done:
  plx
  pla
  rti
.endmacro

.macro HudStartSplits
  lda #0
  sta HudSplitPhase
  SetScanlineIRQ #HUD_IRQ_LINE
  ; cli because the NMI may still be running when the split is due
  cli
.endmacro

.macro HudNmiLagFrame
.local Off
    lda Mirror_PPUMASK
    and #%00011000
    beq Off
      HudSetFrameScroll
      lda Mirror_PPUMASK
      sta PPUMASK
      HudStartSplits
Off:
.endmacro

; Runs after the VRAM uploads to reset scroll before the frame starts
.macro HudNmiSetScroll
.local Latch, Off
  lda Mirror_PPUCTRL
  ldx HorizontalScroll
  ldy Sprite0HitDetectFlag  ;playfield stays unscrolled while this is clear
  bne Latch
    ldx #0
    and #%11111110
Latch:
  stx IrqNewScroll
  stx HudPlayfieldScroll
  sta IrqPPUCTRL
  HudSetFrameScroll
  lda Mirror_PPUMASK
  and #%00011000
  beq Off                   ;an IRQ must not touch the PPU while the screen is being loaded
    HudStartSplits
Off:
.endmacro

.if HUD_MODE = HUD_BOTTOM
.include "hud_bottom.s"
.else
.include "hud_top.s"
.endif

.macro HudReserveRam
RESERVE HudSplitPhase, 1
RESERVE HudPlayfieldScroll, 1    ;kept for lag frames
.endmacro
