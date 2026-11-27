
.macro HudScrollSplit scrolly, delay
    lda IrqPPUCTRL
    and #%00000001
    asl
    asl
    sta PPUADDR

    ; Y position to $2005.
    lda #scrolly
    sta PPUSCROLL

    ; Prepare for the 2 later writes:
    ; We reuse new_x to hold (Y & $F8) << 2.
    and #%11111000
    asl
    asl
    ldx IrqNewScroll
    sta IrqNewScroll

    lda #delay

; 15—270 cycles of delay: delay=A+15; 0 ≤ A ≤ 255)
DelayACycles:
        sec
@L:     sbc #5
        bcs @L  ;  6 6 6 6 6  FB FC FD FE FF
        adc #3  ;  2 2 2 2 2  FE FF 00 01 02
        bcc @4  ;  3 3 2 2 2  FE FF 00 01 02
        lsr     ;  - - 2 2 2  -- -- 00 00 01
        beq @5  ;  - - 3 3 2  -- -- 00 00 01
@4:     lsr     ;  2 2 - - 2  7F 7F -- -- 00
@5:     bcs @6  ;  2 3 2 3 2  7F 7F 00 00 00
@6:
; A page crossing adds a cycle to a taken branch, which would break the delay
.assert .hibyte(DelayACycles) = .hibyte(@6), lderror, "IrqScrollSplit delay loop crosses a page"

    ; ((Y & $F8) << 2) | (X >> 3) in A for $2006 later.
    txa
    lsr
    lsr
    lsr
    ora IrqNewScroll


    ; The last two PPU writes must happen during hblank:
    stx PPUSCROLL
    sta PPUADDR

    ; Restore new_x.
    stx IrqNewScroll
.endmacro

.if HUD_MODE = HUD_BOTTOM
.include "hud_bottom.s"
.else
.include "hud_top.s"
.endif
