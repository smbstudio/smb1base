
.segment "LOWCODE"

;-------------------------------------------------------------------------------------
;$04 - address low to jump address
;$05 - address high to jump address
;$06 - jump address low
;$07 - jump address high
.proc JumpEngine
  asl          ;shift bit from contents of A
  tay
  pla          ;pull saved return address from stack
  sta R4       ;save to indirect
  pla
  sta R5 
  iny
  lda (R4),y  ;load pointer from indirect
  sta R6       ;note that if an RTS is performed in next routine
  iny          ;it will return to the execution before the sub
  lda (R4),y  ;that called this routine
  sta R7 
  jmp (R6)  ;jump to the address we loaded
.endproc

;-------------------------------------------------------------------------------------

.proc GetScreenPosition

  lda ScreenLeft_X_Pos    ;get coordinate of screen's left boundary
  clc
  adc #$ff                ;add 255 pixels
  sta ScreenRight_X_Pos   ;store as coordinate of screen's right boundary
  lda ScreenLeft_PageLoc  ;get page number where left boundary is
  adc #$00                ;add carry from before
  sta ScreenRight_PageLoc ;store as page number where right boundary is
  rts
.endproc

;-------------------------------------------------------------------------------------
clabel LoadAreaPointer
LoadAreaPointer:
  ; jroweboy inlined FindAreaPointer
  ldy WorldNumber        ;load offset from world variable
  lda WorldAddrOffsets,y
  clc                    ;add area number used to find data
  adc AreaNumber
  tay
  lda AreaAddrOffsets,y  ;from there we have our area pointer
  sta AreaPointer
GetAreaType:
  and #%01100000       ;mask out all but d6 and d5
  asl
  rol
  rol
  rol                  ;make %0xx00000 into %000000xx
  sta AreaType         ;save 2 MSB as area type
  tay

  LoadAreaTypeCHR

  rts

;-------------------------------------------------------------------------------------
;$00 - used in adding to get proper offset

.proc RelativePlayerPosition
  ldx #$00      ;set offsets for relative cooordinates
  ldy #$00      ;routine to correspond to player object
  jmp RelWOfs   ;get the coordinates
.endproc

RelativeFireballPosition:
  ldy #$00                    ;set for fireball offsets
  jsr GetProperObjOffset      ;modify X to get proper fireball offset
  ldy #$02
RelWOfs:
  jsr GetObjRelativePosition  ;get the coordinates
  ldx ObjectOffset            ;return original offset
  rts                         ;leave

.proc RelativeEnemyPosition
  lda #$01                     ;get coordinates of enemy object
  ldy #$01                     ;relative to the screen
  jmp VariableObjOfsRelPos
.endproc

RelativeBlockPosition:
  lda #$09                     ;get coordinates of one block object
  ldy #$04                     ;relative to the screen
  jsr VariableObjOfsRelPos
  inx                          ;adjust offset for other block object if any
  inx
  lda #$09
  iny                          ;adjust other and get coordinates for other one
  ; fall through
VariableObjOfsRelPos:
  stx R0                      ;store value to add to A here
  clc
  adc R0                      ;add A to value stored
  tax                         ;use as enemy offset
  jsr GetObjRelativePosition
  ldx ObjectOffset            ;reload old object offset and leave
  rts

GetObjRelativePosition:
  lda SprObject_Y_Position,x  ;load vertical coordinate low
  sta SprObject_Rel_YPos,y    ;store here
  lda SprObject_X_Position,x  ;load horizontal coordinate
  sec                         ;subtract left edge coordinate
  sbc ScreenLeft_X_Pos
  sta SprObject_Rel_XPos,y    ;store result here
  rts

;-------------------------------------------------------------------------------------
;$00 - used as temp variable to hold offscreen bits

.proc GetPlayerOffscreenBits
  ldx #$00                 ;set offsets for player-specific variables
  ldy #Player_OffscreenBits - SprObject_OffscrBits ;and get offscreen information about player
  jmp GetOffScreenBitsSet
.endproc


.proc GetMiscOffscreenBits
  ldy #$02                 ;set for misc object offsets
  jsr GetProperObjOffset   ;modify X to get proper misc object offset
  ldy #Misc_OffscreenBits - SprObject_OffscrBits ;set other offset for misc object's offscreen bits
  jmp GetOffScreenBitsSet  ;and get offscreen information about misc object
.endproc

.proc GetProperObjOffset
  txa                  ;move offset to A
  clc
  adc ObjOffsetData,y  ;add amount of bytes to offset depending on setting in Y
  tax                  ;put back in X and leave
  rts
ObjOffsetData:
  .byte $07, $16, $0d
.endproc

.proc GetEnemyOffscreenBits
  lda #$01                 ;set A to add 1 byte in order to get enemy offset
  ldy #Enemy_OffscreenBits - SprObject_OffscrBits ;set Y to put offscreen bits in Enemy_OffscreenBits
  jmp SetOffscrBitsOffset
.endproc

GetBlockOffscreenBits:
  lda #$09       ;set A to add 9 bytes in order to get block obj offset
  ldy #Block_OffscreenBits - SprObject_OffscrBits ;set Y to put offscreen bits in Block_OffscreenBits
  ; fallthrough
SetOffscrBitsOffset:
  stx R0 
  clc           ;add contents of X to A to get
  adc R0        ;appropriate offset, then give back to X
  tax
  ; fallthrough
GetOffScreenBitsSet:
  tya                         ;save offscreen bits offset to stack for now
  pha
    jsr GetXOffscreenBits  ;do subroutine here
    lsr                    ;move high nybble to low
    lsr
    lsr
    lsr
    sta R0                 ;store here
    jsr GetYOffscreenBits
    asl                         ;move low nybble to high nybble
    asl
    asl
    asl
    ora R0                      ;mask together with previously saved low nybble
    sta R0                      ;store both here
  pla                         ;get offscreen bits offset from stack
  tay
  lda R0                      ;get value here and store elsewhere
  sta SprObject_OffscrBits,y
  ldx ObjectOffset
  rts

;--------------------------------
;(these apply to these three subsections)
;$04 - used to store offset to sprite object data
;$05 - used as adder in DividePDiff
;$06 - used to store constant used to compare to pixel difference in $07
;$07 - used to store pixel difference between X positions of object and screen edges

.proc GetXOffscreenBits
  stx R4                      ;save position in buffer to here
  ldy #$01                    ;start with right side of screen
Loop:
    lda ScreenEdge_X_Pos,y      ;get pixel coordinate of edge
    sec                         ;get difference between pixel coordinate of edge
    sbc SprObject_X_Position,x  ;and pixel coordinate of object position
    sta R7                      ;store here
    lda ScreenEdge_PageLoc,y    ;get page location of edge
    sbc SprObject_PageLoc,x     ;subtract page location of object position from it
    ldx DefaultXOnscreenOfs,y   ;load offset value here
    cmp #$00
    bmi Continue                ;if beyond right edge or in front of left edge, branch
    ldx DefaultXOnscreenOfs+1,y ;if not, load alternate offset value here
    cmp #$01      
    bpl Continue                ;if one page or more to the left of either edge, branch
      lda #$38                    ;if no branching, load value here and store
      sta R6 
      lda #$08                    ;load some other value and execute subroutine
      ; jsr DividePDiff ; inlined
      sta R5        ;store current value in A here
      lda R7        ;get pixel difference
      cmp R6        ;compare to preset value
      bcs Continue   ;if pixel difference >= preset value, branch
      lsr           ;divide by eight to get tile difference
      lsr
      lsr
      and #$07      ;mask out all but 3 LSB
      cpy #$01      ;right side of the screen or top?
      bcs :+        ;if so, branch, use difference / 8 as offset
      adc R5        ;if not, add value to difference / 8
    :
      tax           ;use as offset
Continue:
    lda XOffscreenBitsData,x    ;get bits here
    ldx R4                      ;reobtain position in buffer
    cmp #$00                    ;if bits not zero, branch to leave
    bne ExXOfsBS
    dey                         ;otherwise, do left side of screen now
    bpl Loop                    ;branch if not already done with left side
ExXOfsBS:
  rts

XOffscreenBitsData:
  .byte $7f, $3f, $1f, $0f, $07, $03, $01, $00
  .byte $80, $c0, $e0, $f0, $f8, $fc, $fe, $ff

DefaultXOnscreenOfs:
  .byte $07, $0f, $07
.endproc

;--------------------------------


.proc GetYOffscreenBits
  stx R4                       ;save position in buffer to here
  ldy #$01                     ;start with top of screen
Loop:
    lda HighPosUnitData,y        ;load coordinate for edge of vertical unit
    sec
    sbc SprObject_Y_Position,x   ;subtract from vertical coordinate of object
    sta R7                       ;store here
    lda #$01                     ;subtract one from vertical high byte of object
    sbc SprObject_Y_HighPos,x
    ldx DefaultYOnscreenOfs,y    ;load offset value here
    cmp #$00
    bmi Continue                 ;if under top of the screen or beyond bottom, branch
    ldx DefaultYOnscreenOfs+1,y  ;if not, load alternate offset value here
    cmp #$01
    bpl Continue                 ;if one vertical unit or more above the screen, branch
      lda #$20                     ;if no branching, load value here and store
      sta R6 
      lda #$04                     ;load some other value and execute subroutine
      ; jsr DividePDiff ; inlined
      sta R5        ;store current value in A here
      lda R7        ;get pixel difference
      cmp R6        ;compare to preset value
      bcs Continue   ;if pixel difference >= preset value, branch
      lsr           ;divide by eight to get tile difference
      lsr
      lsr
      and #$07      ;mask out all but 3 LSB
      cpy #$01      ;right side of the screen or top?
      bcs :+        ;if so, branch, use difference / 8 as offset
      adc R5        ;if not, add value to difference / 8
    :
      tax           ;use as offset
Continue:
  lda YOffscreenBitsData,x     ;get offscreen data bits using offset
  ldx R4                       ;reobtain position in buffer
  cmp #$00
  bne ExYOfsBS                 ;if bits not zero, branch to leave
  dey                          ;otherwise, do bottom of the screen now
  bpl Loop
ExYOfsBS:
  rts

YOffscreenBitsData:
  .byte $00, $08, $0c, $0e
  .byte $0f, $07, $03, $01
  .byte $00

DefaultYOnscreenOfs:
  .byte $04, $00, $04

HighPosUnitData:
  .byte $ff, $00

.endproc

;--------------------------------

.proc DividePDiff

  sta R5        ;store current value in A here
  lda R7        ;get pixel difference
  cmp R6        ;compare to preset value
  bcs ExDivPD   ;if pixel difference >= preset value, branch
  lsr           ;divide by eight to get tile difference
  lsr
  lsr
  and #$07      ;mask out all but 3 LSB
  cpy #$01      ;right side of the screen or top?
  bcs SetOscrO  ;if so, branch, use difference / 8 as offset
  adc R5        ;if not, add value to difference / 8
SetOscrO:
  tax           ;use as offset
ExDivPD:
  rts           ;leave
.endproc

.proc TransposePlayers
  sec                       ;set carry flag by default to end game
  lda NumberOfPlayers       ;if only a 1 player game, leave
  beq ExTrans
  lda OffScr_NumberofLives  ;does offscreen player have any lives left?
  bmi ExTrans               ;branch if not
  lda CurrentPlayer         ;invert bit to update
  eor #%00000001            ;which player is on the screen
  sta CurrentPlayer
  ldx #$06
TransLoop:
  lda OnscreenPlayerInfo,x    ;transpose the information
  pha                         ;of the onscreen player
    lda OffscreenPlayerInfo,x   ;with that of the offscreen player
    sta OnscreenPlayerInfo,x
  pla
  sta OffscreenPlayerInfo,x
  dex
  bpl TransLoop
  clc            ;clear carry flag to get game going
ExTrans:
  rts
.endproc

;--------------------------------

MaxSpdBlockData:
      .byte $06, $08

ImposeGravityBlock:
      ldy #$01       ;set offset for maximum speed
      lda #$50       ;set movement amount here
      sta R0 
      lda MaxSpdBlockData,y    ;get maximum speed

ImposeGravitySprObj:
      sta R2             ;set maximum speed here
      lda #$00           ;set value to move downwards
      jmp ImposeGravity  ;jump to the code that actually moves it

;-------------------------------------------------------------------------------------
;$00 - used for downward force
;$01 - used for upward force
;$07 - used as adder for vertical position

.proc ImposeGravity

  pha                          ;push value to stack
    lda Player_YMoveForceFractional,x
    clc                          ;add value in movement force to contents of dummy variable
    adc SprObject_Y_MoveForce,x
    sta Player_YMoveForceFractional,x
    ldy #$00                     ;set Y to zero by default
    lda SprObject_Y_Speed,x      ;get current vertical speed
    bpl AlterYP                  ;if currently moving downwards, do not decrement Y
    dey                          ;otherwise decrement Y
AlterYP:
    sty R7                       ;store Y here
    adc SprObject_Y_Position,x   ;add vertical position to vertical speed plus carry
    sta SprObject_Y_Position,x   ;store as new vertical position
    lda SprObject_Y_HighPos,x
    adc R7                       ;add carry plus contents of $07 to vertical high byte
    sta SprObject_Y_HighPos,x    ;store as new vertical high byte
    lda SprObject_Y_MoveForce,x
    clc
    adc R0                       ;add downward movement amount to contents of $0433
    sta SprObject_Y_MoveForce,x
    lda SprObject_Y_Speed,x      ;add carry to vertical speed and store
    adc #$00
    sta SprObject_Y_Speed,x
    cmp R2                       ;compare to maximum speed
    bmi ChkUpM                   ;if less than preset value, skip this part
    lda SprObject_Y_MoveForce,x
    cmp #$80                     ;if less positively than preset maximum, skip this part
    bcc ChkUpM
    lda R2 
    sta SprObject_Y_Speed,x      ;keep vertical speed within maximum value
    lda #$00
    sta SprObject_Y_MoveForce,x  ;clear fractional
ChkUpM:
  pla                          ;get value from stack
  beq ExVMove                  ;if set to zero, branch to leave
  lda R2 
  eor #%11111111               ;otherwise get two's compliment of maximum speed
  tay
  iny
  sty R7                       ;store two's compliment here
  lda SprObject_Y_MoveForce,x
  sec                          ;subtract upward movement amount from contents
  sbc R1                       ;of movement force, note that $01 is twice as large as $00,
  sta SprObject_Y_MoveForce,x  ;thus it effectively undoes add we did earlier
  lda SprObject_Y_Speed,x
  sbc #$00                     ;subtract borrow from vertical speed and store
  sta SprObject_Y_Speed,x
  cmp R7                       ;compare vertical speed to two's compliment
  bpl ExVMove                  ;if less negatively than preset maximum, skip this part
  lda SprObject_Y_MoveForce,x
  cmp #$80                     ;check if fractional part is above certain amount,
  bcs ExVMove                  ;and if so, branch to leave
  lda R7 
  sta SprObject_Y_Speed,x      ;keep vertical speed within maximum value
  lda #$ff
  sta SprObject_Y_MoveForce,x  ;clear fractional
ExVMove:
  rts                          ;leave!
.endproc

;--------------------------------
;$00 - used to hold horizontal difference between player and enemy

.proc PlayerEnemyDiff
  lda Enemy_X_Position,x  ;get distance between enemy object's
  sec                     ;horizontal coordinate and the player's
  sbc Player_X_Position   ;horizontal coordinate
  sta R0                  ;and store here
  lda Enemy_PageLoc,x
  sbc Player_PageLoc      ;subtract borrow, then leave
  rts
.endproc

Bitmasks:
  .byte %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

;-------------------------------------------------------------------------------------
;$00 - used to store high nybble of horizontal speed as adder
;$01 - used to store low nybble of horizontal speed
;$02 - used to store adder to page location

MoveEnemyHorizontally:
      inx                         ;increment offset for enemy offset
      jsr MoveObjectHorizontally  ;position object horizontally according to
      ldx ObjectOffset            ;counters, return with saved value in A,
      rts                         ;put enemy offset back in X and leave

MovePlayerHorizontally:
      lda JumpspringAnimCtrl  ;if jumpspring currently animating,
      bne ExXMove             ;branch to leave
      tax                     ;otherwise set zero for offset to use player's stuff

MoveObjectHorizontally:
          lda SprObject_X_Speed,x     ;get currently saved value (horizontal
          asl                         ;speed, secondary counter, whatever)
          asl                         ;and move low nybble to high
          asl
          asl
          sta R1                      ;store result here
          lda SprObject_X_Speed,x     ;get saved value again
          lsr                         ;move high nybble to low
          lsr
          lsr
          lsr
          cmp #$08                    ;if < 8, branch, do not change
          bcc SaveXSpd
          ora #%11110000              ;otherwise alter high nybble
SaveXSpd: sta R0                      ;save result here
          ldy #$00                    ;load default Y value here
          cmp #$00                    ;if result positive, leave Y alone
          bpl UseAdder
          dey                         ;otherwise decrement Y
UseAdder: sty R2                      ;save Y here
          lda SprObject_X_MoveForce,x ;get whatever number's here
          clc
          adc R1                      ;add low nybble moved to high
          sta SprObject_X_MoveForce,x ;store result here
          lda #$00                    ;init A
          rol                         ;rotate carry into d0
          pha                         ;push onto stack
          ror                         ;rotate d0 back onto carry
          lda SprObject_X_Position,x
          adc R0                      ;add carry plus saved value (high nybble moved to low
          sta SprObject_X_Position,x  ;plus $f0 if necessary) to object's horizontal position
          lda SprObject_PageLoc,x
          adc R2                      ;add carry plus other saved value to the
          sta SprObject_PageLoc,x     ;object's page location and save
          pla
          clc                         ;pull old carry from stack and add
          adc R0                      ;to high nybble moved to low
ExXMove:  rts                         ;and leave

;--------------------------------

MoveD_EnemyVertically:
      ldy #$3d           ;set quick movement amount downwards
      lda Enemy_State,x  ;then check enemy state
      cmp #$05           ;if not set to unique state for spiny's egg, go ahead
      bne ContVMove      ;and use, otherwise set different movement amount, continue on

MoveFallingPlatform:
           ldy #$20       ;set movement amount
ContVMove: jmp SetHiMax   ;jump to skip the rest of this

;--------------------------------

MoveDropPlatform:
      ldy #$7f      ;set movement amount for drop platform
      bne SetMdMax  ;skip ahead of other value set here

MoveEnemySlowVert:
          ldy #$0f         ;set movement amount for bowser/other objects
SetMdMax: lda #$02         ;set maximum speed in A
          bne SetXMoveAmt  ;unconditional branch

;--------------------------------

MoveJ_EnemyVertically:
             ldy #$1c                ;set movement amount for podoboo/other objects
SetHiMax:    lda #$03                ;set maximum speed in A
SetXMoveAmt: sty R0                  ;set movement amount here
             inx                     ;increment X for enemy offset
             jsr ImposeGravitySprObj ;do a sub to move enemy object downwards
             ldx ObjectOffset        ;get enemy object buffer offset and leave
             rts

;--------------------------------

MovePlatformDown:
  lda #$00    ;save value to stack (if branching here, execute next
  .byte $2c     ;part as BIT instruction)
MovePlatformUp:
  lda #$01        ;save value to stack
  pha
    ldy Enemy_ID,x  ;get enemy object identifier
    inx             ;increment offset for enemy object
    lda #$05        ;load default value here
SetDplSpd:
    sta R0          ;save downward movement amount here
    lda #$0a        ;save upward movement amount here
    sta R1 
    lda #$03        ;save maximum vertical speed here
    sta R2 
  pla             ;get value from stack
  tay             ;use as Y, then move onto code shared by red koopa

RedPTroopaGrav:
  jsr ImposeGravity  ;do a sub to move object gradually
  ldx ObjectOffset   ;get enemy object offset and leave
  rts

;------------------------------------------------
; Moved from object handler since this is common code
InitVStf:
  lda #$00                    ;initialize vertical speed
  sta Enemy_Y_Speed,x         ;and movement force
  sta Enemy_Y_MoveForce,x
  rts

;--------------------------------
;$00 - used to store enemy identifier in KillEnemies
.proc KillEnemies
  sta R0            ;store identifier here
  lda #$00
  ldx #$04          ;check for identifier in enemy object buffer
KillELoop:
    ldy Enemy_ID,x
    cpy R0            ;if not found, branch
    bne :+
      sta EnemyMetasprite,x
      sta EnemyVerticalFlip,x
      sta Enemy_Flag,x  ;if found, deactivate enemy object flag
  :
    dex               ;do this until all slots are checked
    bpl KillELoop
  rts
.endproc

;-------------------------------------------------------------------------------------

EraseEnemyObject:
  lda #$00                 ;clear all enemy object variables
  sta Enemy_Flag,x
  sta Enemy_ID,x
  sta Enemy_State,x
  sta FloateyNum_Control,x
  sta EnemyIntervalTimer,x
  sta ShellChainCounter,x
  sta Enemy_SprAttrib,x
  sta EnemyFrameTimer,x
  sta EnemyMetasprite,x
  sta EnemyVerticalFlip,x
  rts

WorldAddrOffsets:
  .byte World1Areas-AreaAddrOffsets, World2Areas-AreaAddrOffsets
  .byte World3Areas-AreaAddrOffsets, World4Areas-AreaAddrOffsets
  .byte World5Areas-AreaAddrOffsets, World6Areas-AreaAddrOffsets
  .byte World7Areas-AreaAddrOffsets, World8Areas-AreaAddrOffsets

AreaAddrOffsets:
World1Areas: .byte $25, $29, $c0, $26, $60
World2Areas: .byte $28, $29, $01, $27, $62
World3Areas: .byte $24, $35, $20, $63
World4Areas: .byte $22, $29, $41, $2c, $61
World5Areas: .byte $2a, $31, $26, $62
World6Areas: .byte $2e, $23, $2d, $60
World7Areas: .byte $33, $29, $01, $27, $64
World8Areas: .byte $30, $32, $21, $65


;-------------------------------------------------------------------------------------

MusicSelectData:
      .byte WaterMusic, GroundMusic, UndergroundMusic, CastleMusic
      .byte CloudMusic, PipeIntroMusic

.proc GetAreaMusic
  lda OperMode           ;if in title screen mode, leave
  beq ExitGetM
  lda AltEntranceControl ;check for specific alternate mode of entry
  cmp #$02               ;if found, branch without checking starting position
  beq ChkAreaType        ;from area object data header
  ldy #$05               ;select music for pipe intro scene by default
  lda PlayerEntranceCtrl ;check value from level header for certain values
  cmp #$06
  beq StoreMusic         ;load music for pipe intro scene if header
  cmp #$07               ;start position either value $06 or $07
  beq StoreMusic
ChkAreaType:
  ldy AreaType           ;load area type as offset for music bit
  lda CloudTypeOverride
  beq StoreMusic         ;check for cloud type override
  ldy #$04               ;select music for cloud type level if found
StoreMusic:
  lda MusicSelectData,y  ;otherwise select appropriate music for level type
  sta AreaMusicQueue     ;store in queue and leave
ExitGetM:
  rts
.endproc

; used in both frenzy and bowser code
.proc SetFlameTimer
  ldy BowserFlameTimerCtrl  ;load counter as offset
  inc BowserFlameTimerCtrl  ;increment
  lda BowserFlameTimerCtrl  ;mask out all but 3 LSB
  and #%00000111            ;to keep in range of 0-7
  sta BowserFlameTimerCtrl
  lda FlameTimerData,y      ;load value to be used then leave
ExFl:
  rts

FlameTimerData:
  .byte $bf, $40, $bf, $bf, $bf, $40, $40, $bf
.endproc
