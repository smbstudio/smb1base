; This amazing disassembly was created by doppelganger (doppelheathen@gmail.com) here https://www.romhacking.net/documents/344/
; Ported to CC65 by threecreepio (https://github.com/threecreepio)
; Massive changes to the code by jroweboy

.ifndef __COMMON_INC
__COMMON_INC = 1

; Global Labels named after the segment that they appear in
.macro labelled_segment s1,s2,s3,s4,s5,s6,s7,s8,s9,sa,sb,sc,sd
.ifblank s1
  ; First parameter is empty
  .exitmacro
.endif
.global .ident(.string(s1))
.ifdef _COMMON_DEFINE_SEGMENTS
.pushseg
.segment .string(s1)
.ident(.string(s1)):
.export .ident(.string(s1))
.popseg
.endif
labelled_segment s2,s3,s4,s5,s6,s7,s8,s9,sa,sb,sc,sd
.endmacro

labelled_segment OBJECT, PLAYER, MUSIC, LEVEL, CODE, COLLISION, RENDER, FIXED, TITLE, TITLE_MUSIC
labelled_segment DPCM_BANK0, LOWCODE, DECODE, MUSIC_ENGINE, METASPRITE

.macro ASSERT_PAGE label_
	.assert >(label_) = >*, error, "Page crossing in timing sensitive code detected! If you see this error then you need to rearrange the code so this branch doesn't cross a page"
.endmacro


.ifdef MMC5_PRG_ROM
BANK_ADJUST .set $80
.else
BANK_ADJUST .set $80
.endif

.macro phx
  txa
  pha
.endmacro

.macro plx
  pla
  tax
.endmacro

.macro phy
  tya
  pha
.endmacro

.macro ply
  pla
  tay
.endmacro

.macro abssub x1, x2, store, absstore
.scope
  lda x1
  sec
  sbc x2
.ifnblank store
  sta store
.endif
  bcs skipflip
    eor #$ff
    adc #1
skipflip:
.ifnblank absstore
  sta absstore
.endif
.endscope
.endmacro

.macro AllocSpr spr
.scope
.ident(.concat("AllocSpr_", .string(spr))):
  lda CurrentOAMOffset
  ; cmp #$ff - (spr * 4)
  ; bcc :+
  ;   rts
  ; :
  tay
  clc
  adc #(spr * 4)
  sta CurrentOAMOffset
.endscope
.endmacro

.macro ReserveSpr spr
.scope
.ident(.concat("ReserveSpr_", .string(spr))):
  ldy CurrentOAMOffset
  ; cpy #$ff - (spr * 4)
  ; bcc :+
  ;   rts
  ; :
.endmacro

.macro UpdateOAMPosition
  sty CurrentOAMOffset
.endscope
.endmacro


.macro clabel Name
.export .ident(.concat("_", .string(Name))) := Name
.endmacro

; Simple macro that makes both a proc and exports the name for C bindings
.macro cproc Name
.proc Name
.export .ident(.concat("_", .string(Name))) := Name
.endmacro

.macro endcproc
.endproc
.endmacro

.macro bankbyte s1,s2,s3,s4,s5,s6,s7,s8,s9,sa,sb,sc,sd,se,sf
.ifblank s1
  ; First parameter is empty
  .exitmacro
.endif
.byte .bank(s1)
bankbyte s2,s3,s4,s5,s6,s7,s8,s9,sa,sb,sc,sd,se,sf
.endmacro

.macro music_table s1,s2,s3,s4,s5,s6,s7,s8,s9,sa,sb,sc,sd,se,sf
.ifblank s1
  ; First parameter is empty
  .exitmacro
.endif
.byte MUSIC_TABLE_OP(.ident(.sprintf("music_data_%s_start", s1))) | BANK_ADJUST
music_table s2,s3,s4,s5,s6,s7,s8,s9,sa,sb,sc,sd,se,sf
.endmacro

.macro IncludeMusicData s1
.ifblank s1
  .exitmacro
.endif
.segment .concat("MUSIC_", s1)
.ident(.sprintf("music_data_%s_start", s1)):
.include .sprintf("%s/%s_%s.s", MUSIC_PATH, MUSIC_PROJECT_NAME, s1)
.endmacro

.macro macro_iterator iter,s1,s2,s3,s4,s5,s6,s7,s8,s9,sa,sb,sc,sd,se,sf
.if iter = 0
.define MUSIC_ITERATOR s1
.elseif iter = 1
.define MUSIC_ITERATOR s2
.elseif iter = 2
.define MUSIC_ITERATOR s3
.elseif iter = 3
.define MUSIC_ITERATOR s4
.elseif iter = 4
.define MUSIC_ITERATOR s5
.elseif iter = 5
.define MUSIC_ITERATOR s6
.elseif iter = 6
.define MUSIC_ITERATOR s7
.elseif iter = 7
.define MUSIC_ITERATOR s8
.elseif iter = 8
.define MUSIC_ITERATOR s9
.elseif iter = 9
.define MUSIC_ITERATOR sa
.elseif iter = 10
.define MUSIC_ITERATOR sb
.elseif iter = 11
.define MUSIC_ITERATOR sc
.elseif iter = 12
.define MUSIC_ITERATOR sd
.elseif iter = 13
.define MUSIC_ITERATOR se
.elseif iter = 14
.define MUSIC_ITERATOR sf
.endif

.endmacro

.endif ;__COMMON_INC
