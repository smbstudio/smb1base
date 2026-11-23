

.pushseg

; .segment "ZEROPAGE"
; safecall_ptr: .res 2

.segment "SHORTRAM"
safecall_a: .res 1
; safecall_x: .res 1
; safecall_y: .res 1
CurrentBank: .res 1
ReloadCHRBank: .res 1
CurrentCHRBank: .res 12
AreaChrBank := CurrentCHRBank + 8
PlayerChrBank := CurrentCHRBank + 0
EnemyChrBank := CurrentCHRBank + 2

.popseg


IRQ_STATUS = $5204

.macro MAPPER_IRQ_ACK
  bit IRQ_STATUS
.endmacro

MMC5_PRG_ROM = %10000000

MMC5_PRG_BANK_BASE = $5113
MMC5_PRG_BANK_6 = MMC5_PRG_BANK_BASE + 0
MMC5_PRG_BANK_8 = MMC5_PRG_BANK_BASE + 1
MMC5_PRG_BANK_A = MMC5_PRG_BANK_BASE + 2
MMC5_PRG_BANK_C = MMC5_PRG_BANK_BASE + 3
MMC5_PRG_BANK_E = MMC5_PRG_BANK_BASE + 4

MMC5_CHR_BANK_BASE = $5120
MMC5_CHR_SPR_BANK_00 = MMC5_CHR_BANK_BASE + 0
MMC5_CHR_SPR_BANK_04 = MMC5_CHR_BANK_BASE + 1
MMC5_CHR_SPR_BANK_08 = MMC5_CHR_BANK_BASE + 2
MMC5_CHR_SPR_BANK_0C = MMC5_CHR_BANK_BASE + 3
MMC5_CHR_SPR_BANK_10 = MMC5_CHR_BANK_BASE + 4
MMC5_CHR_SPR_BANK_14 = MMC5_CHR_BANK_BASE + 5
MMC5_CHR_SPR_BANK_18 = MMC5_CHR_BANK_BASE + 6
MMC5_CHR_SPR_BANK_1C = MMC5_CHR_BANK_BASE + 7
MMC5_CHR_BG_BANK_00 = MMC5_CHR_BANK_BASE + 8
MMC5_CHR_BG_BANK_04 = MMC5_CHR_BANK_BASE + 9
MMC5_CHR_BG_BANK_08 = MMC5_CHR_BANK_BASE + 10
MMC5_CHR_BG_BANK_0C = MMC5_CHR_BANK_BASE + 11


.macro BankSprCHR00 bank
  _BANK_INNER bank, MMC5_CHR_SPR_BANK_00
.endmacro

.macro BankSprCHR04 bank
  _BANK_INNER bank, MMC5_CHR_SPR_BANK_04
.endmacro

.macro BankSprCHR08 bank
  _BANK_INNER bank, MMC5_CHR_SPR_BANK_08
.endmacro

.macro BankSprCHR0C bank
  _BANK_INNER bank, MMC5_CHR_SPR_BANK_0C
.endmacro

.macro BankSprCHR10 bank
  _BANK_INNER bank, MMC5_CHR_SPR_BANK_10
.endmacro

.macro BankSprCHR14 bank
  _BANK_INNER bank, MMC5_CHR_SPR_BANK_14
.endmacro

.macro BankSprCHR18 bank
  _BANK_INNER bank, MMC5_CHR_SPR_BANK_18
.endmacro

.macro BankSprCHR1C bank
  _BANK_INNER bank, MMC5_CHR_SPR_BANK_1C
.endmacro

.macro BankBgCHR00 bank
  _BANK_INNER bank, MMC5_CHR_BG_BANK_00
.endmacro

.macro BankBgCHR04 bank
  _BANK_INNER bank, MMC5_CHR_BG_BANK_04
.endmacro

.macro BankBgCHR08 bank
  _BANK_INNER bank, MMC5_CHR_BG_BANK_08
.endmacro

.macro BankBgCHR0C bank
  _BANK_INNER bank, MMC5_CHR_BG_BANK_0C
.endmacro

.macro BankPRG6 bank
  _BANK_INNER bank, MMC5_PRG_BANK_6
.endmacro

.macro BankPRG8 bank
  _BANK_INNER bank, MMC5_PRG_BANK_8
.endmacro

.macro BankPRGA bank
  _BANK_INNER bank, MMC5_PRG_BANK_A
.endmacro

.macro BankPRGC bank
  _BANK_INNER bank, MMC5_PRG_BANK_C
.endmacro

.macro BankPRGE bank
  _BANK_INNER bank, MMC5_PRG_BANK_E
.endmacro


.macro _BANK_INNER bank, ADDRESS
.scope
  .if .match(bank, a)
    sta ADDRESS
  .elseif .match(bank, x)
    stx ADDRESS
  .elseif .match(bank, y)
    sty ADDRESS
  .else
    .if (.match (.left (1, {bank}), #))
      lda #.right (.tcount ({bank})-1, {bank}) | MMC5_PRG_ROM ; todo handle ram banking
    .else
      lda bank
    .endif
    sta ADDRESS
  .endif
.endscope
.endmacro

.macro SetScanlineIRQ val
.if (.match (.left (1, {val}), #))
  lda #.right (.tcount ({val})-1, {val})
.else
  lda val
.endif
  sta $5203
  lda #$80
  sta $5204
.endmacro

.macro SwitchAreaCHR
  .repeat 12, I
    lda CurrentCHRBank + I
    sta MMC5_CHR_BANK_BASE + I
  .endrepeat
.endmacro

.macro LoadAreaTypeCHR
  lda AreaTypeBankMap,y
  cmp AreaChrBank
  beq :+
    tax
  .repeat 4,I
    stx AreaChrBank+I
  .if I <> 3
    inx
  .endif
  .endrepeat
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

.segment "FIXED"

MapperInit:
  ; Set PRG mode to 4 8kb banks
  lda #3
  sta $5100
  ; set CHR mode to 4 1kb banks
  sta $5101
  ; allow writing PRG RAM
  lda #2
  sta $5102
  lda #1
  sta $5103
  ; setup vertical mirroring
  lda #$44
  sta $5105

  ; Nestopia requires SRAM to be explicitly inited
  lda #0
  sta MMC5_PRG_BANK_6

  ; Setup default banks
  lda #$80
  sta CurrentBank
  BankPRGA #.bank(PLAYER)
  BankPRGC #.bank(DPCM_BANK0)
  BankPRG8 #.bank(LOWCODE)
  BankPRGE #.bank(FIXED)

.import __SMCCODE_SIZE__, __SMCCODE_LOAD__, __SMCCODE_RUN__ 
  ; Copy the Self Modifying Code for super fast farcall bank switches
  ldx #__SMCCODE_SIZE__ - 1
  :
    lda __SMCCODE_LOAD__,x
    sta __SMCCODE_RUN__,x
    dex
    bpl :-


  ; now setup the CHR banks
  ; To prevent graphics glitches, they must always be written in this order
  ldx #0
  :
    lda CHRBankInitValues,x
    sta CurrentCHRBank,x
    sta MMC5_CHR_BANK_BASE,x
    inx
    cpx #12
    bcc :-
  rts
CHRBankInitValues:
; SPR bank init values
; Slots 4-7 are MMC5 only (SPRITE_BANK_4 - SPRITE_BANK_7). Anything drawn from them won't work on MMC3
  .byte CHR_SMALLMARIO, CHR_MISC, CHR_SPR_ENEMY, CHR_SPR_ENEMY+1
  .byte CHR_SPR_EXTRA, CHR_SPR_MOUSE, CHR_SPR_CASTLE, CHR_SPR_CASTLE+1

; BG bank init values
  .byte CHR_BG_GROUND, CHR_BG_GROUND+1, CHR_BG_GROUND+2, CHR_BG_GROUND+3


.segment "FIXED"
_FARCALL_COUNT .set 0

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
  lda #.bank(loc) | MMC5_PRG_ROM
.ifblank usejmp
  jsr FarCallCommon
.else
  jmp FarCallCommon
.endif

::_FARCALL_COUNT .set ::_FARCALL_COUNT + 1

.endscope
.endmacro

;; TODO - redo this macro too
.macro far loc
.scope
.assert .bank(*) = .bank(FIXED) || .bank(*) = .bank(LOWCODE), error, "Cannot use far to read data when not in the fixed bank"
.assert .bank(loc) <> .bank(*), error, "Attempting to farcall to the same bank!"
.assert .bank(loc) <> .bank(LOWCODE), error, "Attempting to farcall to the low bank!"
.assert .bank(loc) <> .bank(FIXED), error, "Attempting to farcall to the fixed bank!"

  sta safecall_a

  lda CurrentBank
  pha
    lda #.bank(loc) | MMC5_PRG_ROM
    sta CurrentBank
    sta MMC5_PRG_BANK_A
    lda safecall_a

.endmacro

.macro endfar
    sta safecall_a
    pla
  sta CurrentBank
  sta MMC5_PRG_BANK_A
  lda safecall_a
.endscope
.endmacro

.segment "SMCCODE"
SMCCODE:

; Put the bank switching routine into RAM for fastest farcalls

.include "smc.inc"

FarCallCommon:
  SMC_StoreValue NextBank, a
  lda CurrentBank
  pha
    SMC NextBank, { lda #SMC_Value }
    sta CurrentBank
    BankPRGA a
    SMC SafecallA, { lda #SMC_Value }
    SMC FarcallJmpTarget, { jsr SMC_AbsAdr }
    SMC_StoreValue SafereturnA, a
  pla
  sta CurrentBank
  BankPRGA a
  SMC SafereturnA, { lda #SMC_Value }
  rts
