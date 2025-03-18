
;-------------------------------------------------------------------------------------
;INTERRUPT VECTORS

.segment "VECTORS"
    .word (NonMaskableInterrupt)
    .word (Start)
    .word (IrqScrollSplit)  ;unused

.segment "CODE"

.proc IrqScrollSplit
  pha
  phx
    MAPPER_IRQ_ACK
    ; 
    lda IrqPPUCTRL
    and #%00000001
    asl
    asl
    sta PPUADDR

    ; Y position to $2005.
    lda #32
    sta PPUSCROLL

    ; Prepare for the 2 later writes:
    ; We reuse new_x to hold (Y & $F8) << 2.
    and #%11111000
    asl
    asl
    ldx IrqNewScroll
    sta IrqNewScroll

DELAY_BASE = 15
.if ::MAPPER_MMC3
  lda #40 - DELAY_BASE
.elseif ::MAPPER_MMC5
  lda #15 - DELAY_BASE
.endif

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
  plx
  pla
  rti
.endproc

;-------------------------------------------------------------------------------------

.segment "FIXED"

.proc Start
  sei                          ;pretty standard 6502 type init here
  cld
  lda #%00010000               ;init PPU control register 1 
  sta PPUCTRL
  ldx #$ff                     ;reset stack pointer
  stx APU_FRAMECOUNTER         ; disable APU framecounter IRQ
  txs
: lda PPUSTATUS               ;wait two frames
  bpl :-
: lda PPUSTATUS
  bpl :-
  ldy #ColdBootOffset          ;load default cold boot pointer
  ldx #$05                     ;this is where we check for a warm boot
WBootCheck:
  lda TopScoreDisplay,x        ;check each score digit in the top score
  cmp #10                      ;to see if we have a valid digit
  bcs ColdBoot                 ;if not, give up and proceed with cold boot
  dex                      
  bpl WBootCheck
  lda WarmBootValidation       ;second checkpoint, check to see if 
  cmp #$a5                     ;another location has a specific value
  bne ColdBoot   
  ldy #WarmBootOffset          ;if passed both, load warm boot pointer
ColdBoot:
  jsr InitializeMemory         ;clear memory using pointer in Y
  sta SND_DELTA_REG+1          ;reset delta counter load register
  sta OperMode                 ;reset primary mode of operation
  ; for debugging, clear the sprite tile numbers so its easier to see in sprite viewers
  ldx #0
  lda #0
  :
    sta Sprite_Attributes,x
    sta Sprite_Tilenumber,x
    inx
    inx
    inx
    inx
    bne :-
  ; do mapper specific init
  jsr MapperInit
FinializeMarioInit:
  cli
  lda #$a5                     ;set warm boot flag
  sta WarmBootValidation     
  sta PseudoRandomBitReg       ;set seed for pseudorandom register
  ; lda #%00001111
  ; sta SND_MASTERCTRL_REG       ;enable all sound channels except dmc
  jsr AudioInit
  lda #%00000110
  sta PPUMASK            ;turn off clipping for OAM and background
  farcall MoveAllSpritesOffscreen
  farcall InitializeNameTables     ;initialize both name tables
  inc DisableScreenFlag        ;set flag to disable screen output
  lda Mirror_PPUCTRL
  ora #%10100000               ;enable NMIs and 8x16 sprites
  sta PPUCTRL              ;write contents of A to PPU register 1
  sta Mirror_PPUCTRL       ;and its mirror

  ; do a jsr to the main loop so we can profile it separately
  jsr IdleLoop
.endproc

;-------------------------------------------------------------------------------------
;$00 - vram buffer address table low
;$01 - vram buffer address table high

.segment "CODE"

clabel UpdateScreen

WriteBufferToScreen:
  sta PPUADDR           ;store high byte of vram address
  iny
  lda (NmiR0),y               ;load next byte (second)
  sta PPUADDR           ;store low byte of vram address
  iny
  lda (NmiR0),y               ;load next byte (third)
  asl                       ;shift to left and save in stack
  pha
    lda Mirror_PPUCTRL     ;load mirror of $2000,
    ora #%00000100            ;set ppu to increment by 32 by default
    bcs SetupWrites           ;if d7 of third byte was clear, ppu will
      and #%11111011            ;only increment by 1
SetupWrites:
    sta PPUCTRL         ;write contents of A to PPU register 1
    sta Mirror_PPUCTRL       ;and its mirror
  pla                       ;pull from stack and shift to left again
  asl
  bcc GetLength             ;if d6 of third byte was clear, do not repeat byte
    ora #%00000010            ;otherwise set d1 and increment Y
    iny
GetLength:
  lsr                       ;shift back to the right to get proper length
  lsr                       ;note that d1 will now be in carry
  tax
OutputToVRAM:
  bcs RepeatByte            ;if carry set, repeat loading the same byte
    iny                       ;otherwise increment Y to load next byte
RepeatByte:
  lda (NmiR0), y               ;load more data from buffer and write to vram
  sta PPUDATA
  dex                       ;done writing?
  bne OutputToVRAM
  sec          
  tya
  adc NmiR0                    ;add end length plus one to the indirect at $00
  sta NmiR0                    ;to allow this routine to read another set of updates
  lda #$00
  adc NmiR1
  sta NmiR1
UpdateScreen:
  ldx PPUSTATUS            ;reset flip-flop
  ldy #$00                  ;load first byte from indirect as a pointer
  lda (NmiR0),y  
  bne WriteBufferToScreen   ;if byte is zero we have no further updates to make here
InitScroll:
  sta PPUSCROLL        ;store contents of A into scroll registers
  sta PPUSCROLL        ;and end whatever subroutine led us here
  rts

.proc BankSwitchCHR
  lda ReloadCHRBank
  beq :+
    SwitchAreaCHR ; defined by the mapper
    ldx #0
    stx ReloadCHRBank
  :
  rts
.endproc

.segment "FIXED"
.proc NonMaskableInterrupt
  pha
  phx
  phy
  lda NmiDisable
  bpl ContinueNMI
    inc NmiSkipped
    ; lag frame, prevent the graphics from going bunk by still running
    ; the irq. also run audio to keep it sounding like we didn't lag
    ; Unless the screen is off, then we don't care
    lda DisableScreenFlag
    bne :+
      SetScanlineIRQ #$1f
      lda Mirror_PPUCTRL
      and #%11111110            ;alter name table address to be $2800
      sta PPUCTRL              ;(essentially $2000) but save other bits
      lda #0
      sta PPUSCROLL
      sta PPUSCROLL
    :
    ; Force the area/player sprite banks to switch even during lag frames
    jsr BankSwitchCHR
    jsr AudioUpdate
    ply
    plx
    pla
    rti
ContinueNMI:
  ; jroweboy disable NMI with a soft disable instead of turning off the NMI source from PPU
  dec NmiDisable
  
  ; jroweboy switch the nametable back to nmt0 and force NMI to be enabled
  lda Mirror_PPUCTRL
  and #%11111110            ;alter name table address to be $2800
  sta PPUCTRL              ;(essentially $2000) but save other bits
  lda Mirror_PPUMASK       ;disable OAM and background display by default
  and #%11100110
  ldy DisableScreenFlag     ;get screen disable flag
  bne ScreenOff             ;if set, used bits as-is
    lda Mirror_PPUMASK     ;otherwise reenable bits and save them
    ora #%00011110
ScreenOff:
  sta Mirror_PPUMASK       ;save bits for later but not in register at the moment
  and #%11100111            ;disable screen for now
  sta PPUMASK
  ; ldx PPUSTATUS            ;reset flip-flop and reset scroll registers to zero
  lda #$00
  ; sta PPUSCROLL
  ; sta PPUSCROLL
  sta OAMADDR          ;reset spr-ram address register

  ldx VRAM_Buffer_AddrCtrl  ;load control for pointer to buffer contents
  cpx #TitleScreenDataOffset
  bne :+
    BankPRGA #.bank(TITLE)
  :
  lda VRAM_AddrTable_Low,x  ;set indirect at $00 to pointer
  sta NmiR0
  lda VRAM_AddrTable_High,x
  sta NmiR1
  jsr UpdateScreen  ;update screen with buffer contents

  lda HorizontalScroll
  sta IrqNewScroll
  ; lda Mirror_PPUCTRL
  ; sta IrqScrollBit
  lda Sprite0HitDetectFlag  ;check for flag here
  beq SkipSprite0
    SetScanlineIRQ #$1f
    ; cli just in case NMI runs late
    cli
SkipSprite0:
  lda Mirror_PPUCTRL
  sta IrqPPUCTRL
  ; and also reset the flags for the HUD
  and #%11111100
  sta PPUCTRL

  lda Mirror_PPUMASK       ;copy mirror of $2001 to register
  sta PPUMASK

  ; If the main thread requested a CHR bank switch, do it before the timing window passes
  jsr BankSwitchCHR

.if ::USE_MOUSE_SUPPORT
  ; Store the previous frame's mouse buttons temporarily
  lda mouse + kMouseButtons
  sta NmiR2
  lda mouse + kMouseY
  sta NmiR0
  lda mouse + kMouseX
  sta NmiR1
.endif
  jsr OAMandReadJoypad

  ldy #$00
  ldx VRAM_Buffer_AddrCtrl  ;check for usage of $0341
  cpx #$06
  bne InitBuffer
    iny                       ;get offset based on usage
InitBuffer:
  ldx VRAM_Buffer_Offset,y
  lda #$00                  ;clear buffer header at last location
  sta VRAM_Buffer1_Offset,x        
  sta VRAM_Buffer1,x
  sta VRAM_Buffer_AddrCtrl  ;reinit address control to $0301


.if ::USE_MOUSE_SUPPORT
  ; This needs to happen later in NMI but before Audio as custom music can use the Nmi temp variables
  jsr UpdateMouseExtra
.endif
  jsr AudioUpdate
  
.if ::DEBUG_WORLD_SELECT
	dec DebugCooldown
	bpl OnCooldown
    inc DebugCooldown
    lda SavedJoypadBits
    and #Select_Button
    beq OnCooldown
      lda #10
      sta DebugCooldown
      lda SavedJoypadBits
      and #B_Button
      beq NextWorld
        ; TODO don't farcall in nmi
        BankPRGA #.bank(PrcNextA)
        jsr PrcNextA
        jmp OnCooldown
    NextWorld:
      jsr PlayerEndWorld
OnCooldown:
.endif

  BankPRGA CurrentBank
.if ::MAPPER_MMC3
  lda BankShadow
  sta BANK_SELECT
.endif
  ply
  plx
  pla
  rti                       ;we are done until the next frame!

.endproc

.segment "CODE"
;-------------------------------------------------------------------------------------
;$00 - vram buffer address table low, also used for pseudorandom bit
;$01 - vram buffer address table high

.define VRAM_AddrTable \
      VRAM_Buffer1, \
      WaterPaletteData, \
      GroundPaletteData, \
      UndergroundPaletteData, \
      CastlePaletteData, \
      VRAM_Buffer1_Offset, \
      VRAM_Buffer2, \
      VRAM_Buffer2, \
      BowserPaletteData, \
      DaySnowPaletteData, \
      NightSnowPaletteData, \
      MushroomPaletteData, \
      MarioThanksMessage, \
      LuigiThanksMessage, \
      MushroomRetainerSaved, \
      PrincessSaved1, \
      PrincessSaved2, \
      WorldSelectMessage1, \
      WorldSelectMessage2, \
      TitleScreenData

clabel VRAM_AddrTable_Low
clabel VRAM_AddrTable_High
VRAM_AddrTable_Low: .lobytes VRAM_AddrTable
VRAM_AddrTable_High: .hibytes VRAM_AddrTable

clabel VRAM_Buffer_Offset
VRAM_Buffer_Offset:
  .byte VRAM_Buffer1_PtrOffset, VRAM_Buffer2_PtrOffset

;-------------------------------------------------------------------------------------
;VRAM BUFFER DATA FOR LOCATIONS IN PRG-ROM

WaterPaletteData:
  .byte $3f, $00, $20
  .byte $0f, $15, $12, $25  
  .byte $0f, $3a, $1a, $0f
  .byte $0f, $30, $12, $0f
  .byte $0f, $27, $12, $0f
  .byte $22, $16, $27, $18
  .byte $0f, $10, $30, $27
  .byte $0f, $16, $30, $27
  .byte $0f, $0f, $30, $10
  .byte $00

GroundPaletteData:
  .byte $3f, $00, $20
  .byte $0f, $29, $1a, $0f
  .byte $0f, $36, $17, $0f
  .byte $0f, $30, $21, $0f
  .byte $0f, $27, $17, $0f
  .byte $0f, $16, $27, $18
  .byte $0f, $1a, $30, $27
  .byte $0f, $16, $30, $27
  .byte $0f, $0f, $36, $17
  .byte $00

UndergroundPaletteData:
  .byte $3f, $00, $20
  .byte $0f, $29, $1a, $09
  .byte $0f, $3c, $1c, $0f
  .byte $0f, $30, $21, $1c
  .byte $0f, $27, $17, $1c
  .byte $0f, $16, $27, $18
  .byte $0f, $1c, $36, $17
  .byte $0f, $16, $30, $27
  .byte $0f, $0c, $3c, $1c
  .byte $00

CastlePaletteData:
  .byte $3f, $00, $20
  .byte $0f, $30, $10, $00
  .byte $0f, $30, $10, $00
  .byte $0f, $30, $16, $00
  .byte $0f, $27, $17, $00
  .byte $0f, $16, $27, $18
  .byte $0f, $1c, $36, $17
  .byte $0f, $16, $30, $27
  .byte $0f, $00, $30, $10
  .byte $00

DaySnowPaletteData:
  .byte $3f, $00, $04
  .byte $22, $30, $00, $10
  .byte $00

NightSnowPaletteData:
  .byte $3f, $00, $04
  .byte $0f, $30, $00, $10
  .byte $00

MushroomPaletteData:
  .byte $3f, $00, $04
  .byte $22, $27, $16, $0f
  .byte $00

BowserPaletteData:
  .byte $3f, $14, $04
  .byte $0f, $1a, $30, $27
  .byte $00

MarioThanksMessage:
  .byte $25, $48, $10
  .byte "THANK YOU MARIO!"
  .byte $00

LuigiThanksMessage:
  .byte $25, $48, $10
  .byte "THANK YOU LUIGI!"
  .byte $00

MushroomRetainerSaved:
  .byte $25, $c5, $16
  .byte "BUT OUR PRINCESS IS IN"
  .byte $26, $05, $0f
  .byte "ANOTHER CASTLE!"
  .byte $00

PrincessSaved1:
  .byte $25, $a7, $13
  .byte "YOUR QUEST IS OVER."
  .byte $00

PrincessSaved2:
  .byte $25, $e3, $1b
  .byte "WE PRESENT YOU A NEW QUEST."
  .byte $00

WorldSelectMessage1:
  .byte $26, $4a, $0d
  .byte "PUSH BUTTON B"
  .byte $00

WorldSelectMessage2:
  .byte $26, $88, $11
  .byte "TO SELECT A WORLD"
  .byte $00

;-------------------------------------------------------------------------------------
.segment "FIXED"
;$06 - RAM address low
;$07 - RAM address high
InitializeMemoryRAMLo = R6
InitializeMemoryRAMHi = R7
.proc InitializeMemory
  ldx #$07          ;set initial high byte to $0700-$07ff
  lda #$00          ;set initial low byte to start of page (at $00 of page)
  sta InitializeMemoryRAMLo
InitPageLoop:
    stx InitializeMemoryRAMHi
InitByteLoop:
      cpx #2            ; jroweboy: don't clear sprite ram
      beq SkipByte
      cpx #$01          ;check to see if we're on the stack ($0100-$01ff)
      bne InitByte      ;if not, go ahead anyway
      cpy #<StackClear  ;otherwise, check to see if we're at $0160-$01ff
      bcs SkipByte      ;if so, skip write
InitByte:
      sta (InitializeMemoryRAMLo),y       ;otherwise, initialize byte with current low byte in Y
SkipByte:
      dey
      cpy #$ff          ;do this until all bytes in page have been erased
      bne InitByteLoop
    dex               ;go onto the next page
    bpl InitPageLoop  ;do this until all pages of memory have been erased
    
.if ::ENABLE_C_CODE
; Reset the stack pointer for C code. Shame we lose the stack ...
; TODO Might wanna investigate a new InitMemory function
.importzp sp
  lda #<CStack
  sta sp
  lda #>CStack
  sta sp+1
.endif
.if ::USE_MOUSE_SUPPORT

  lda #1
  sta mouse_mask
.endif
  lda #0
  rts
.endproc

.if ENABLE_C_CODE
.importzp ptr4, tmp4
; This allows c code to reuse the farcall mechanism
cproc farcall_trampoline
  SMC_StoreValue SafecallA, a
  lda ptr4
  SMC_StoreLowByte FarcallJmpTarget, a
  lda ptr4+1
  SMC_StoreHighByte FarcallJmpTarget, a
  lda tmp4
  ora #MMC5_PRG_ROM
  jmp FarCallCommon
endcproc
.endif

.if DEBUG_ADD_EXTRA_LAG
;;;;;;;;;;;;;;;;;;;;;;;;
; Delays X*256+A clocks + overhead
; Clobbers A,X. Preserves Y.
; Depends on delay_a_25_clocks within short branch distance
; Time: X*256+A+30 clocks (including JSR)
;;;;;;;;;;;;;;;;;;;;;;;;
:      sbc #7    ; carry set by CMP
delay_256x_a_30_clocks_b:
       cmp #7    ; 2  2  2  2  2  2  2   00 01 02 03 04 05 06   0 0 0 0 0 0 0
       bcs :-    ; 2  2  2  2  2  2  2   00 01 02 03 04 05 06   0 0 0 0 0 0 0
       lsr       ; 2  2  2  2  2  2  2   00 00 01 01 02 02 03   0 1 0 1 0 1 0
       bcs @2    ; 2  3  2  3  2  3  2   00 00 01 01 02 02 03   0 1 0 1 0 1 0
@2:    beq @6    ; 3  3  2  2  2  2  2   00 00 01 01 02 02 03   0 1 0 1 0 1 0
       lsr       ;       2  2  2  2  2         00 00 01 01 01       1 1 0 0 1
       beq @do_x ;       3  3  2  2  2         00 00 01 01 01       1 1 0 0 1
       bcc @do_x ;             3  3  2               01 01 01           0 0 1
@6:    bne @do_x ; 2  2              3   00 00             01   0 1         0
@do_x: txa       ;2
       beq @rts  ;3
       ;4 cycles done. Must consume 256 cycles; 252 cycles remain.
       nop       ;2
       tya       ;2
        ldy #48  ;2
@l:     dey      ;2*48
        bne @l   ;3*48
       tay       ;2-1
       dex       ;2
       jmp @do_x ;3
@rts:  rts
.endif

;;;;;;;;----------------------------------------
.if ::USE_MOUSE_SUPPORT

.segment "ZEROPAGE"

; NOTE: These must be zero page and adjacent; the code relies on joypad1_down following mouse.
RESERVE_ZP mouse, 4
  kMouseZero = 0
  kMouseButtons = 1
  kMouseY = 2
  kMouseX = 3
RESERVE_ZP SavedJoypad1Bits, 1
RESERVE_ZP SavedJoypad2Bits, 1
mouse_mask: .res 1           ; Bitmask indicating which $4017 bit the mouse is on.

.segment "SHORTRAM"
; NOTE: These variables are not page-sensitive and can be absolute.
advance_sensitivity: .res 1  ; Bool.

.segment "OAMALIGNED"

.if ::MOUSE_READ_FROM_PORT = 1

MOUSE_PORT = $4016
CONTROLLER_PORT = $4017

.elseif ::MOUSE_READ_FROM_PORT = 2

MOUSE_PORT = $4017
CONTROLLER_PORT = $4016

.else
.error "Cannot read the snes mouse from any ports other than 1 or 2"
.endif

.proc OAMandReadJoypad
  ; Strobe the joypads.
  LDX #$00
  LDY #$01
  STY mouse
  STY JOYPAD_PORT1

 .if ::MOUSE_CONFIG_SENSITIVITY <> 0
  ; Clock official mouse sensitivity. NOTE: This can be removed if not needed.
  LDA advance_sensitivity
  BEQ :+
  LDA MOUSE_PORT
  STX advance_sensitivity
 :
 .endif

  STX JOYPAD_PORT1

  LDA #OAM
  STA OAM_DMA
 
  ; Desync cycles: 432, 576, 672, 848, 432*2-4 (860)

  ; DMC DMA:         ; PUT GET PUT GET        ; Starts: 0

 :
  LDA mouse_mask     ; get put get*     *576  ; Starts: 4, 158, 312, 466, [620]
  AND MOUSE_PORT   ; put get put GET
  CMP #$01           ; put get
  ROL mouse,X        ; put get put get* PUT GET  *432
  BCC :-             ; put get (put)

  INX                ; put get
  CPX #$04           ; put get
  STY mouse,X        ; put get put GET
  BNE :-             ; put get (put)

 :
  LDA CONTROLLER_PORT ; put get put GET        ; Starts: 619
  AND #$03           ; put get*         *672
  CMP #$01           ; put get
  ROL SavedJoypad1Bits ; put get put get put    ; This can desync, but we finish before it matters.
  BCC :-             ; get put (get)

 .if ::MOUSE_CONFIG_CONTROLLER_SIZE <> 1
  STY SavedJoypad1Bits+1 ; get put get
  NOP                ; put get
 :
  LDA CONTROLLER_PORT ; put get* put GET *848  ; Starts: 751, [879]
  AND #$03           ; put get
  CMP #$01           ; put get
  ROL SavedJoypad1Bits+1 ; put get put get put    ; This can desync, but we finish before it matters.
  BCC :-             ; get* put (get)   *860

  ; NEXT: 878
 .endif

  rts
.endproc

.segment "FIXED"
.proc UpdateMouseExtra
  ; Check the report to see if we have a snes mouse plugged in
  lda mouse + kMouseButtons
  and #$0f
  cmp #$01
  beq :+
    ; no snes mouse, so leave the first field empty
    lda #0
    sta mouse + kMouseZero
    rts
  :
  ; convert the X/Y displacement into X/Y positions on the screen
  ldx #1
loop:
    lda mouse + kMouseY,x
    bpl :+
      ; subtract the negative number instead
      and #$7f
      sta mouse + kMouseZero ; reuse this value as a temp value
      lda NmiR0,x
      sec 
      sbc mouse + kMouseZero
      ; check if we underflowed
      bcc wrappednegative
      ; check the lower bounds
      cmp MouseBoundsMin,x
      bcs setvalue ; didn't wrap so set the value now
    wrappednegative:
      lda MouseBoundsMin,x
      jmp setvalue
    :
    ; add the positive number
    clc
    adc NmiR0,x
    ; check if we wrapped, set to the max bounds if we did
    bcs wrapped
    ; check the upper bounds
    cmp MouseBoundsMax,x
    bcc setvalue ; didn't wrap so set the value
wrapped:
    lda MouseBoundsMax,x
setvalue:
    sta mouse + kMouseY,x
    dex
    bpl loop

  ; calculate newly pressed buttons and shift it into byte zero
  lda NmiR2
  eor #%11000000
  and mouse + kMouseButtons
  rol
  ror mouse + kMouseZero
  rol
  ror mouse + kMouseZero
  
  ; calculate newly released buttons
  lda mouse + kMouseButtons
  eor #%11000000
  and NmiR2
  rol
  ror mouse + kMouseZero
  rol
  ror mouse + kMouseZero

  ; Set the connected bit
  sec
  ror mouse + kMouseZero

  rts
MouseBoundsMin:
  .byte MOUSE_Y_MINIMUM, MOUSE_X_MINIMUM
MouseBoundsMax:
  .byte MOUSE_Y_MAXIMUM, MOUSE_X_MAXIMUM
.endproc

.else

.segment "ZEROPAGE"
RESERVE_ZP SavedJoypad1Bits, 1
RESERVE_ZP SavedJoypad2Bits, 1

.segment "OAMALIGNED"
.proc OAMandReadJoypad
  lda #OAM
  sta OAM_DMA          ; ------ OAM DMA ------
  ldx #1             ; get put          <- strobe code must take an odd number of cycles total
  stx SavedJoypad1Bits ; get put get
  stx JOYPAD_PORT1   ; put get put get
  dex                ; put get
  stx JOYPAD_PORT1   ; put get put get
read_loop:
  lda JOYPAD_PORT2   ; put get put GET  <- loop code must take an even number of cycles total
  and #3             ; put get
  cmp #1             ; put get
  rol SavedJoypad2Bits, x ; put get put get put get (X = 0; waste 1 cycle and 0 bytes for alignment)
  lda JOYPAD_PORT1   ; put get put GET
  and #3             ; put get
  cmp #1             ; put get
  rol SavedJoypad1Bits ; put get put get put
  bcc read_loop      ; get put [get]    <- this branch must not be allowed to cross a page
ASSERT_PAGE read_loop
  rts
.endproc

.endif
