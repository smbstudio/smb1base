
.segment "FIXED"


.pushseg
.segment "SHORTRAM"
; TargetAddrJmp: .res 4 ; 3 ; increased to 4 to jsr/rts for debugging
; TargetAddress := TargetAddrJmp + 1
CurrentBank: .res 1
safecall_a: .res 1
BankShadow: .res 1
ReloadCHRBank: .res 1
CurrentCHRBank: .res 6
AreaChrBank := CurrentCHRBank
PlayerChrBank := CurrentCHRBank + 2
EnemyChrBank := CurrentCHRBank + 4
.popseg

; MMC3 registers / banking
PRG_FIXED_8 = (1 << 6)
BANK_SELECT = $8000
BANK_DATA   = $8001
NMT_MIRROR  = $a000
RAM_PROTECT = $a001
IRQLATCH    = $c000
IRQRELOAD   = $c001
IRQDISABLE  = $e000
IRQENABLE   = $e001


.macro MAPPER_IRQ_ACK
  sta IRQDISABLE
.endmacro

.macro BankCHR0 bank
  _BANK_INNER bank, 0
.endmacro

.macro BankCHR8 bank
  _BANK_INNER bank, 1
.endmacro

.macro BankCHR10 bank
  _BANK_INNER bank, 2
.endmacro

.macro BankCHR14 bank
  _BANK_INNER bank, 3
.endmacro

.macro BankCHR18 bank
  _BANK_INNER bank, 4
.endmacro

.macro BankCHR1C bank
  _BANK_INNER bank, 5
.endmacro

.macro BankPRGA bank
  _BANK_INNER bank, 7
.endmacro

.macro BankPRGC bank
  _BANK_INNER bank, 6
.endmacro

.macro _BANK_INNER bank, select
.scope
  ; set fixed $8000 bank bit
.if .match(bank, a)
  pha
  lda #select | PRG_FIXED_8
  sta BANK_SELECT
.else
  lda #select | PRG_FIXED_8
  sta BANK_SELECT
.endif
  .if .match(bank, a)
    pla
    sta BANK_DATA
  .elseif .match(bank, x)
    stx BANK_DATA
  .elseif .match(bank, y)
    sty BANK_DATA
  .else
    .if (.match (.left (1, {arg}), #))
      lda #bank
    .else
      lda bank
    .endif
    sta BANK_DATA
  .endif
.endscope
.endmacro

.macro SwitchAreaCHR
    ldx #PRG_FIXED_8
  .repeat 6, I
    stx BANK_SELECT
    lda CurrentCHRBank + I
    sta BANK_DATA
  .if I <> 5
    inx
  .endif
  .endrepeat
.endmacro

.macro LoadAreaTypeCHR
  lda AreaTypeBankMap,y
  cmp AreaChrBank
  beq :+
    tax
    stx AreaChrBank+0
    inx
    inx
    stx AreaChrBank+1
  :
  ; Always reset the enemy pages, since SwapCastleEndCHR changes them when bowser dies
  ldx AreaTypeEnemyBankMap,y
  stx EnemyChrBank+0
  inx
  stx EnemyChrBank+1
  inc ReloadCHRBank
  lda AreaType
  rts
AreaTypeBankMap:
  .byte CHR_BG_WATER, CHR_BG_GROUND, CHR_BG_UNDERGROUND, CHR_BG_CASTLE
AreaTypeEnemyBankMap:
  .byte CHR_SPR_ENEMY, CHR_SPR_ENEMY, CHR_SPR_ENEMY, CHR_SPR_CASTLE

.endmacro

.macro farcall loc, usejmp
.scope
.assert .bank(loc) <> .bank(*), error, "Attempting to farcall to the same bank!"
.assert .bank(loc) <> .bank(LOWCODE), error, "Attempting to farcall to the low bank!"
.assert .bank(loc) <> .bank(FIXED), error, "Attempting to farcall to the fixed bank!"
  SMC_StoreValue SafecallA, a
  lda #.lobyte(loc)
  SMC_StoreLowByte FarcallJmpTarget, a
  lda #.hibyte(loc)
  SMC_StoreHighByte FarcallJmpTarget, a
  lda #.bank(loc)
.ifblank usejmp
  jsr FarCallCommon
.else
  jmp FarCallCommon
.endif
.endscope
.endmacro

.macro far loc
.scope
.assert .bank(*) = .bank(FIXED) || .bank(*) = .bank(LOWCODE), error, "Cannot use far to read data when not in the fixed bank"
.assert .bank(loc) <> .bank(*), error, "Attempting to farcall to the same bank!"
.assert .bank(loc) <> .bank(LOWCODE), error, "Attempting to farcall to the low bank!"
.assert .bank(loc) <> .bank(FIXED), error, "Attempting to farcall to the fixed bank!"

.ident(.concat("farblock_", .string(loc))):
  sta safecall_a
  lda CurrentBank
  pha
    lda #7 | PRG_FIXED_8
    sta BankShadow
    sta BANK_SELECT
    lda #.bank(loc)
    sta BANK_DATA
    sta CurrentBank
    lda safecall_a
.endmacro

.macro endfar
    sta safecall_a
    lda #7 | PRG_FIXED_8
    sta BankShadow
    sta BANK_SELECT
  pla
  sta BANK_DATA
  sta CurrentBank
  lda safecall_a
.endscope
.endmacro


.macro SetScanlineIRQ line
  .if .match(line, x)
    stx IRQLATCH
    stx IRQRELOAD
    stx IRQENABLE
  .elseif .match(line, y)
    sty IRQLATCH
    sty IRQRELOAD
    sty IRQENABLE
  .else
    .if (.match (.left (1, {arg}), #))
      lda #line
    .else
      lda line
    .endif
    sta IRQLATCH
    sta IRQRELOAD
    sta IRQENABLE
  .endif
.endmacro


BankInitValues:
  .byte CHR_BG_GROUND, CHR_BG_GROUND+2, CHR_SMALLMARIO, CHR_MISC, CHR_SPR_ENEMY, CHR_SPR_ENEMY+1

MapperInit:
  ldx #5
  CHRBankInitLoop:
    txa
    ora PRG_FIXED_8
    sta BANK_SELECT
    lda BankInitValues,x
    sta CurrentCHRBank,x
    sta BANK_DATA
    dex
    bpl CHRBankInitLoop

  ; Now set the initial A bank
  BankPRGA #.bank(PLAYER)
  ; The custom audio driver runs from the $C000 bank, so it must start on a DPCM bank
  BankPRGC #.bank(DPCM_BANK0)
  lda #.bank(PLAYER)
  sta CurrentBank
  lda #0
  sta NmiSkipped
  lda #7 | PRG_FIXED_8
  sta BankShadow
  ; fallthrough
FarcallInit:
.import __SMCCODE_SIZE__, __SMCCODE_LOAD__, __SMCCODE_RUN__ 
  ; Copy the Self Modifying Code for super fast farcall bank switches
  ldx #__SMCCODE_SIZE__ - 1
  :
    lda __SMCCODE_LOAD__,x
    sta __SMCCODE_RUN__,x
    dex
    bpl :-

  ; disable scanline counter, and IRQ
  lda #0
  sta NMT_MIRROR
  sta IRQDISABLE
  ; enable on board WRAM
  lda #%10000000
  sta RAM_PROTECT

  rts

.segment "SMCCODE"
SMCCODE:

; Put the bank switching routine into RAM for fastest farcalls

.include "smc.inc"

FarCallCommon:
  SMC_StoreValue NextBank, a
  lda CurrentBank
  pha
    lda #7 | PRG_FIXED_8
    sta BankShadow
    sta BANK_SELECT
    SMC NextBank, { lda #SMC_Value }
    sta CurrentBank
    sta BANK_DATA
    SMC SafecallA, { lda #SMC_Value }
    SMC FarcallJmpTarget, { jsr SMC_AbsAdr }
    SMC_StoreValue SafereturnA, a
    lda #7 | PRG_FIXED_8
    sta BankShadow
    sta BANK_SELECT
  pla
  sta CurrentBank
  sta BANK_DATA
  SMC SafereturnA, { lda #SMC_Value }
  rts
