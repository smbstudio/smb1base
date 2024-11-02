LEVEL_ID .set 0
.macro DefineLvl name
  ;.ident(.sprintf("FOREGROUND_LO_%d",LEVEL_ID)) = .concat(.concat("<",name),"_fg")
  ;.ident(.sprintf("FOREGROUND_HI_%d",LEVEL_ID)) = .concat(.concat(">",name),"_fg")
  ;.ident(.sprintf("BACKGROUND_LO_%d",LEVEL_ID)) = .concat(.concat("<",name),"_bg")
  ;.ident(.sprintf("BACKGROUND_HI_%d",LEVEL_ID)) = .concat(.concat(">",name),"_bg")
  LEVEL_ID .set LEVEL_ID + 1
.endmacro

; define your levels here!
DefineLvl "test"

ForegroundDataLo:
.byte <test_fg
;.repeat LEVEL_ID, I
;  .byte .ident(.sprintf("FOREGROUND_LO_%d",LEVEL_ID))
;.endrepeat
ForegroundDataHi:
.byte >test_fg
;.repeat LEVEL_ID, I
;  .byte .ident(.sprintf("FOREGROUND_HI_%d",LEVEL_ID))
;.endrepeat
ForegroundBanks:
.byte .bank(test_fg) | $80
BackgroundDataLo:
.byte <test_bg
;.repeat LEVEL_ID, I
;  .byte .ident(.sprintf("BACKGROUND_LO_%d",LEVEL_ID))
;.endrepeat
BackgroundDataHi:
.byte >test_bg
;.repeat LEVEL_ID, I
;  .byte .ident(.sprintf("BACKGROUND_HI_%d",LEVEL_ID))
;.endrepeat
BackgroundBanks:
.byte <.bank(test_bg)