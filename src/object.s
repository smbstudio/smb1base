
.segment "OBJECT"

;-------------------------------------------------------------------------------------
.proc EnemiesAndLoopsCore
  lda Enemy_Flag,x         ;check data here for MSB set
  bmi ChkBowserF           ;if MSB set in enemy flag, branch ahead of jumps
  beq ChkAreaTsk           ;if data zero, branch
    jmp RunEnemyObjectsCore  ;otherwise, jump to run enemy subroutines
ChkAreaTsk:
  lda AreaParserTaskNum    ;check number of tasks to perform
  and #$07
  cmp #$07                 ;if at a specific task, jump and leave
  beq ExitELCore
    farcall ProcLoopCommand, jmp ;otherwise, jump to process loop command/load enemies
ChkBowserF:
  and #%00001111           ;mask out high nybble
  tay
  lda Enemy_Flag,y         ;use as pointer and load same place with different offset
  bne ExitELCore
  sta Enemy_Flag,x         ;if second enemy flag not set, also clear first one
ExitELCore:
  rts
.endproc

;-------------------------------------------------------------------------------------

RunEnemyObjectsCore:
  ldx ObjectOffset  ;get offset for enemy object buffer
  lda #$00          ;load value 0 for jump engine by default
  ldy Enemy_ID,x
  cpy #$15          ;if enemy object < $15, use default value
  bcc JmpEO
  tya               ;otherwise subtract $14 from the value and use
  sbc #$14          ;as value for jump engine
JmpEO:
  jsr JumpEngine
  .word RunNormalEnemies  ;for objects $00-$14

  .word RunBowserFlame    ;for objects $15-$1f
  .word RunFireworks
  .word NoRunCode
  .word NoRunCode
  .word NoRunCode
  .word NoRunCode
  .word RunFirebarObj
  .word RunFirebarObj
  .word RunFirebarObj
  .word RunFirebarObj
  .word RunFirebarObj

  .word RunFirebarObj     ;for objects $20-$2f
  .word RunFirebarObj
  .word RunFirebarObj
  .word NoRunCode
  .word RunLargePlatform
  .word RunLargePlatform
  .word RunLargePlatform
  .word RunLargePlatform
  .word RunLargePlatform
  .word RunLargePlatform
  .word RunLargePlatform
  .word RunSmallPlatform
  .word RunSmallPlatform
  .word RunBowser
  .word PowerUpObjHandler
  .word VineObjectHandler

  .word NoRunCode         ;for objects $30-$35
  .word RunStarFlagObj
  .word JumpspringHandler
  .word NoRunCode
  .word WarpZoneObject
  .word RunRetainerObj

CheckpointEnemyID:
  lda Enemy_ID,x
  cmp #$15                     ;check enemy object identifier for $15 or greater
  bcs InitEnemyRoutines        ;and branch straight to the jump engine if found
    tay                          ;save identifier in Y register for now
    lda Enemy_Y_Position,x
    adc #$08                     ;add eight pixels to what will eventually be the
    sta Enemy_Y_Position,x       ;enemy object's vertical coordinate ($00-$14 only)
    lda #$01
    sta EnemyOffscrBitsMasked,x  ;set offscreen masked bit
    tya                          ;get identifier back and use as offset for jump engine

InitEnemyRoutines:
  jsr JumpEngine

;jump engine table for newly loaded enemy objects
  .word InitNormalEnemy  ;for objects $00-$0f
  .word InitNormalEnemy
  .word InitNormalEnemy
  .word InitRedKoopa
  .word NoInitCode
  .word InitHammerBro
  .word InitGoomba
  .word InitBloober
  .word InitBulletBill
  .word NoInitCode
  .word InitCheepCheep
  .word InitCheepCheep
  .word InitPodoboo
  .word InitPiranhaPlant
  .word InitJumpGPTroopa
  .word InitRedPTroopa

  .word InitHorizFlySwimEnemy  ;for objects $10-$1f
  .word InitLakitu
  .word InitEnemyFrenzy
  .word NoInitCode
  .word InitEnemyFrenzy
  .word InitEnemyFrenzy
  .word InitEnemyFrenzy
  .word InitEnemyFrenzy
  .word EndFrenzy
  .word NoInitCode
  .word NoInitCode
  .word InitShortFirebar
  .word InitShortFirebar
  .word InitShortFirebar
  .word InitShortFirebar
  .word InitLongFirebar

  .word NoInitCode ;for objects $20-$2f
  .word NoInitCode
  .word NoInitCode
  .word NoInitCode
  .word InitBalPlatform
  .word InitVertPlatform
  .word LargeLiftUp
  .word LargeLiftDown
  .word InitHoriPlatform
  .word InitDropPlatform
  .word InitHoriPlatform
  .word PlatLiftUp
  .word PlatLiftDown
  .word InitBowser
  .word PwrUpJmp   ;possibly dummy value
  .word Setup_Vine

  .word NoInitCode ;for objects $30-$36
  .word NoInitCode
  .word NoInitCode
  .word NoInitCode
  .word NoInitCode
  .word InitRetainerObj
  .word EndOfEnemyInitCode

;--------------------------------

InitBloober:
  lda #$00               ;initialize horizontal speed
  sta BlooperMoveSpeed,x
SmallBBox:
  lda #$09               ;set specific bounding box size control
  bne SetBBox            ;unconditional branch

;--------------------------------

InitRedPTroopa:
  ldy #$30                    ;load central position adder for 48 pixels down
  lda Enemy_Y_Position,x      ;set vertical coordinate into location to
  sta RedPTroopaOrigXPos,x    ;be used as original vertical coordinate
  bpl GetCent                 ;if vertical coordinate < $80
  ldy #$e0                    ;if => $80, load position adder for 32 pixels up
GetCent:
  tya                         ;send central position adder to A
  adc Enemy_Y_Position,x      ;add to current vertical coordinate
  sta RedPTroopaCenterYPos,x  ;store as central vertical coordinate
TallBBox:
  lda #$03                    ;set specific bounding box size control
SetBBox:
  sta Enemy_BoundBoxCtrl,x    ;set bounding box control here
  lda #$02                    ;set moving direction for left
  sta Enemy_MovingDir,x
  jmp InitVStf ; jroweboy: Added this jmp to common code

;-------------------------------------------------------------------------------------

MiscObjectsCore:
  ldx #$08          ;set at end of misc object buffer
MiscLoop:
    stx ObjectOffset  ;store misc object offset here
    lda Misc_State,x  ;check misc object state
    beq MiscLoopBack  ;branch to check next slot
    asl               ;otherwise shift d7 into carry
    bcc ProcJumpCoin  ;if d7 not set, jumping coin, thus skip to rest of code here
    jsr ProcHammerObj ;otherwise go to process hammer,
    jmp MiscLoopBack  ;then check next slot

;--------------------------------
;$00 - used to set downward force
;$01 - used to set upward force (residual)
;$02 - used to set maximum speed

ProcJumpCoin:
  ldy Misc_State,x          ;check misc object state
  dey                       ;decrement to see if it's set to 1
  beq JCoinRun              ;if so, branch to handle jumping coin
    ; remove the jumping coin metasprite now
    lda #0
    sta MiscMetasprite,x
    inc Misc_State,x          ;otherwise increment state to either start off or as timer
    lda Misc_X_Position,x     ;get horizontal coordinate for misc object
    clc                       ;whether its jumping coin (state 0 only) or floatey number
    adc ScrollAmount          ;add current scroll speed
    sta Misc_X_Position,x     ;store as new horizontal coordinate
    lda Misc_PageLoc,x        ;get page location
    adc #$00                  ;add carry
    sta Misc_PageLoc,x        ;store as new page location
    lda Misc_State,x
    cmp #$30                  ;check state of object for preset value
    bne RunJCSubs             ;if not yet reached, branch to subroutines
      lda #$00
      sta Misc_State,x          ;otherwise nullify object state
      jmp MiscLoopBack          ;and move onto next slot
JCoinRun:
    txa             
    clc                       ;add 13 bytes to offset for next subroutine
    adc #$0d
    tax
    lda #$50                  ;set downward movement amount
    sta R0 
    lda #$06                  ;set maximum vertical speed
    sta R2 
    lsr                       ;divide by 2 and set
    sta R1                    ;as upward movement amount (apparently residual)
    lda #$00                  ;set A to impose gravity on jumping coin
    jsr ImposeGravity         ;do sub to move coin vertically and impose gravity on it
    ldx ObjectOffset          ;get original misc object offset
    lda Misc_Y_Speed,x        ;check vertical speed
    cmp #$05
    bne RunJCSubs             ;if not moving downward fast enough, keep state as-is
      inc Misc_State,x          ;otherwise increment state to change to floatey number
RunJCSubs:
    jsr GetMiscOffscreenBits  ;get offscreen information
    jsr JCoinGfxHandler       ;draw the coin or floatey number

MiscLoopBack: 
    dex                       ;decrement misc object offset
    bpl MiscLoop              ;loop back until all misc objects handled
  rts                       ;then leave


;--------------------------------
;$00 - used to set downward force
;$01 - used to set upward force (residual)
;$02 - used to set maximum speed
ProcHammerObj:
  lda TimerControl           ;if master timer control set
  bne RunHSubs               ;skip all of this code and go to last subs at the end
    lda Misc_State,x           ;otherwise get hammer's state
    and #%01111111             ;mask out d7
    ldy HammerEnemyOffset,x    ;get enemy object offset that spawned this hammer
    cmp #$02                   ;check hammer's state
    beq SetHSpd                ;if currently at 2, branch
    bcs SetHPos                ;if greater than 2, branch elsewhere
      txa
      clc                        ;add 13 bytes to use
      adc #$0d                   ;proper misc object
      tax                        ;return offset to X
      lda #$10
      sta R0                     ;set downward movement force
      lda #$0f
      sta R1                     ;set upward movement force (not used)
      lda #$04
      sta R2                     ;set maximum vertical speed
      lda #$00                   ;set A to impose gravity on hammer
      jsr ImposeGravity          ;do sub to impose gravity on hammer and move vertically
      jsr MoveObjectHorizontally ;do sub to move it horizontally
      ldx ObjectOffset           ;get original misc object offset
      jmp RunAllH                ;branch to essential subroutines
SetHSpd:
    lda #$fe
    sta Misc_Y_Speed,x         ;set hammer's vertical speed
    lda Enemy_State,y          ;get enemy object state
    and #%11110111             ;mask out d3
    sta Enemy_State,y          ;store new state
    ldx Enemy_MovingDir,y      ;get enemy's moving direction
    dex                        ;decrement to use as offset
    lda HammerXSpdData,x       ;get proper speed to use based on moving direction
    ldx ObjectOffset           ;reobtain hammer's buffer offset
    sta Misc_X_Speed,x         ;set hammer's horizontal speed
SetHPos:
    dec Misc_State,x           ;decrement hammer's state
    lda Enemy_X_Position,y     ;get enemy's horizontal position
    clc
    adc #$02                   ;set position 2 pixels to the right
    sta Misc_X_Position,x      ;store as hammer's horizontal position
    lda Enemy_PageLoc,y        ;get enemy's page location
    adc #$00                   ;add carry
    sta Misc_PageLoc,x         ;store as hammer's page location
    lda Enemy_Y_Position,y     ;get enemy's vertical position
    sec
    sbc #$0a                   ;move position 10 pixels upward
    sta Misc_Y_Position,x      ;store as hammer's vertical position
    lda #$01
    sta Misc_Y_HighPos,x       ;set hammer's vertical high byte
    bne RunHSubs               ;unconditional branch to skip first routine
RunAllH:
      jsr PlayerHammerCollision  ;handle collisions
RunHSubs: 
    jsr GetMiscOffscreenBits   ;get offscreen information
    lda Misc_OffscreenBits
    and #%11111100              ;check offscreen bits
    beq NoHOffscr               ;if all bits clear, leave object alone
      lda #$00
      sta Misc_State,x            ;otherwise nullify misc object state
      sta MiscMetasprite,x
      rts
NoHOffscr:
  jsr RelativeMiscPosition   ;get relative coordinates
  jsr GetMiscBoundBox        ;get bounding box coordinates
  jmp DrawHammer             ;draw the hammer


;-------------------------------------------------------------------------------------

SpawnHammerObj:
  lda PseudoRandomBitReg+1 ;get pseudorandom bits from
  and #%00000111           ;second part of LSFR
  bne SetMOfs              ;if any bits are set, branch and use as offset
  lda PseudoRandomBitReg+1
  and #%00001000           ;get d3 from same part of LSFR
SetMOfs:
  tay                      ;use either d3 or d2-d0 for offset here
  lda Misc_State,y         ;if any values loaded in
  bne NoHammer             ;$2a-$32 where offset is then leave with carry clear
  ldx HammerEnemyOfsData,y ;get offset of enemy slot to check using Y as offset
  lda Enemy_Flag,x         ;check enemy buffer flag at offset
  bne NoHammer             ;if buffer flag set, branch to leave with carry clear
  ldx ObjectOffset         ;get original enemy object offset
  txa
  sta HammerEnemyOffset,y  ;save here
  lda #$90
  sta Misc_State,y         ;save hammer's state here
  lda #$07
  sta Misc_BoundBoxCtrl,y  ;set something else entirely, here
  sec                      ;return with carry set
  rts
NoHammer:
  ldx ObjectOffset         ;get original enemy object offset
  clc                      ;return with carry clear
  rts

HammerEnemyOfsData:
      .byte $04, $04, $04, $05, $05, $05
      .byte $06, $06, $06

HammerXSpdData:
      .byte $10, $f0

;--------------------------------
.proc DuplicateEnemyObj
  ldy #$ff                ;start at beginning of enemy slots
FSLoop:
  iny                     ;increment one slot
  lda Enemy_Flag,y        ;check enemy buffer flag for empty slot
  bne FSLoop              ;if set, branch and keep checking
  sty DuplicateObj_Offset ;otherwise set offset here
  txa                     ;transfer original enemy buffer offset
  ora #%10000000          ;store with d7 set as flag in new enemy
  sta Enemy_Flag,y        ;slot as well as enemy offset
  lda Enemy_PageLoc,x
  sta Enemy_PageLoc,y     ;copy page location and horizontal coordinates
  lda Enemy_X_Position,x  ;from original enemy to new enemy
  sta Enemy_X_Position,y
  lda #$01
  sta Enemy_Flag,x        ;set flag as normal for original enemy
  sta Enemy_Y_HighPos,y   ;set high vertical byte for new enemy
  lda Enemy_Y_Position,x
  sta Enemy_Y_Position,y  ;copy vertical coordinate from original to new
FlmEx:
  rts                     ;and then leave
.endproc

;--------------------------------
.proc RunRetainerObj
  lda WorldNumber
  cmp #World8
  bcs AfterWorld7
    ldy #METASPRITE_TOAD_STANDING
    bne WriteMetasprite
AfterWorld7:
  ldy #METASPRITE_PEACH_STANDING
WriteMetasprite:
  tya
  sta EnemyMetasprite,x
  lda Enemy_State,x
  and #%00100000
  beq Exit
    ; Dead toads get flipped.
    lda #MSPR_VERTICAL_FLIP
    sta EnemyVerticalFlip,x
    jsr GetEnemyOffscreenBits
    ; jsr RelativeEnemyPosition
    jsr MoveNormalEnemy
    jmp SprObjectOffscrChk
Exit:
  rts
.endproc

;--------------------------------

RunNormalEnemies:
          lda #$00                  ;init sprite attributes
          sta Enemy_SprAttrib,x
          jsr GetEnemyOffscreenBits
          jsr RelativeEnemyPosition
          jsr EnemyGraphicsEngine
          ; jsr EnemyGfxHandler
          jsr GetEnemyBoundBox
          jsr EnemyToBGCollisionDet
          jsr EnemiesCollision
          jsr PlayerEnemyCollision
          ldy TimerControl          ;if master timer control set, skip to last routine
          bne SkipMove
          jsr EnemyMovementSubs
SkipMove: jmp OffscreenBoundsCheck

EnemyMovementSubs:
      lda Enemy_ID,x
      jsr JumpEngine

      .word MoveNormalEnemy      ;only objects $00-$14 use this table
      .word MoveNormalEnemy
      .word MoveNormalEnemy
      .word MoveNormalEnemy
      .word MoveNormalEnemy
      .word ProcHammerBro
      .word MoveNormalEnemy
      .word MoveBloober
      .word MoveBulletBill
      .word NoMoveCode
      .word MoveSwimmingCheepCheep
      .word MoveSwimmingCheepCheep
      .word MovePodoboo
      .word MovePiranhaPlant
      .word MoveJumpingEnemy
      .word ProcMoveRedPTroopa
      .word MoveFlyGreenPTroopa
      .word MoveLakitu
      .word MoveNormalEnemy
      .word NoMoveCode   ;dummy
      .word MoveFlyingCheepCheep

;--------------------------------

NoMoveCode:
NoInitCode:
EndOfEnemyInitCode:
NoRunCode:
      rts

;-------------------------------------------------------------------------------------
;$00 - page location of extended left boundary
;$01 - extended left boundary position
;$02 - page location of extended right boundary
;$03 - extended right boundary position

OffscreenBoundsCheck:
          lda Enemy_ID,x          ;check for cheep-cheep object
          cmp #FlyingCheepCheep   ;branch to leave if found
          beq ExScrnBd
          lda ScreenLeft_X_Pos    ;get horizontal coordinate for left side of screen
          ldy Enemy_ID,x
          cpy #HammerBro          ;check for hammer bro object
          beq LimitB
          cpy #PiranhaPlant       ;check for piranha plant object
          bne ExtendLB            ;these two will be erased sooner than others if too far left
LimitB:   adc #$38                ;add 56 pixels to coordinate if hammer bro or piranha plant
ExtendLB: sbc #$48                ;subtract 72 pixels regardless of enemy object
          sta R1                  ;store result here
          lda ScreenLeft_PageLoc
          sbc #$00                ;subtract borrow from page location of left side
          sta R0                  ;store result here
          lda ScreenRight_X_Pos   ;add 72 pixels to the right side horizontal coordinate
          adc #$48
          sta R3                  ;store result here
          lda ScreenRight_PageLoc     
          adc #$00                ;then add the carry to the page location
          sta R2                  ;and store result here
          lda Enemy_X_Position,x  ;compare horizontal coordinate of the enemy object
          cmp R1                  ;to modified horizontal left edge coordinate to get carry
          lda Enemy_PageLoc,x
          sbc R0                  ;then subtract it from the page coordinate of the enemy object
          bmi TooFar              ;if enemy object is too far left, branch to erase it
          lda Enemy_X_Position,x  ;compare horizontal coordinate of the enemy object
          cmp R3                  ;to modified horizontal right edge coordinate to get carry
          lda Enemy_PageLoc,x
          sbc R2                  ;then subtract it from the page coordinate of the enemy object
          bmi ExScrnBd            ;if enemy object is on the screen, leave, do not erase enemy
          lda Enemy_State,x       ;if at this point, enemy is offscreen to the right, so check
          cmp #HammerBro          ;if in state used by spiny's egg, do not erase
          beq ExScrnBd
          cpy #PiranhaPlant       ;if piranha plant, do not erase
          beq ExScrnBd
          cpy #FlagpoleFlagObject ;if flagpole flag, do not erase
          beq ExScrnBd
          cpy #StarFlagObject     ;if star flag, do not erase
          beq ExScrnBd
          cpy #JumpspringObject   ;if jumpspring, do not erase
          beq ExScrnBd            ;erase all others too far to the right
TooFar:   jmp EraseEnemyObject    ;erase object if necessary
ExScrnBd: rts ; TODO check this RTS can be removed                     ;leave

.proc RelativeMiscPosition
  ldy #$02                ;set for misc object offsets
  jsr GetProperObjOffset  ;modify X to get proper misc object offset
  ldy #$06
  jmp RelWOfs             ;get the coordinates
.endproc


;-------------------------------------------------------------------------------------

PlayerHammerCollision:
        lda FrameCounter          ;get frame counter
        lsr                       ;shift d0 into carry
        bcc ExPHC                 ;branch to leave if d0 not set to execute every other frame
        lda TimerControl          ;if either master timer control
        ora Misc_OffscreenBits    ;or any offscreen bits for hammer are set,
        bne ExPHC                 ;branch to leave
        txa
        asl                       ;multiply misc object offset by four
        asl
        clc
        adc #$24                  ;add 36 or $24 bytes to get proper offset
        tay                       ;for misc object bounding box coordinates
        jsr PlayerCollisionCore   ;do player-to-hammer collision detection
        ldx ObjectOffset          ;get misc object offset
        bcc ClHCol                ;if no collision, then branch
        lda Misc_Collision_Flag,x ;otherwise read collision flag
        bne ExPHC                 ;if collision flag already set, branch to leave
        lda #$01
        sta Misc_Collision_Flag,x ;otherwise set collision flag now
        lda Misc_X_Speed,x
        eor #$ff                  ;get two's compliment of
        clc                       ;hammer's horizontal speed
        adc #$01
        sta Misc_X_Speed,x        ;set to send hammer flying the opposite direction
        lda StarInvincibleTimer   ;if star mario invincibility timer set,
        bne ExPHC                 ;branch to leave
        jmp InjurePlayer          ;otherwise jump to hurt player, do not return
ClHCol: lda #$00                  ;clear collision flag
        sta Misc_Collision_Flag,x
ExPHC:  rts

;--------------------------------

NormalXSpdData:
      .byte $f8, $f4

InitNormalEnemy:
         ldy #$01              ;load offset of 1 by default
         lda PrimaryHardMode   ;check for primary hard mode flag set
         bne GetESpd
         dey                   ;if not set, decrement offset
GetESpd: lda NormalXSpdData,y  ;get appropriate horizontal speed
SetESpd: sta Enemy_X_Speed,x   ;store as speed for enemy object
         jmp TallBBox          ;branch to set bounding box control and other data


;--------------------------------
;$00 - used to store adder for movement, also used as adder for platform
;$01 - used to store maximum value for secondary counter

MoveFlyGreenPTroopa:
        jsr XMoveCntr_GreenPTroopa ;do sub to increment primary and secondary counters
        jsr MoveWithXMCntrs        ;do sub to move green paratroopa accordingly, and horizontally
        ldy #$01                   ;set Y to move green paratroopa down
        lda FrameCounter
        and #%00000011             ;check frame counter 2 LSB for any bits set
        bne NoMGPT                 ;branch to leave if set to move up/down every fourth frame
        lda FrameCounter
        and #%01000000             ;check frame counter for d6 set
        bne YSway                  ;branch to move green paratroopa down if set
        ldy #$ff                   ;otherwise set Y to move green paratroopa up
YSway:  sty R0                     ;store adder here
        lda Enemy_Y_Position,x
        clc                        ;add or subtract from vertical position
        adc R0                     ;to give green paratroopa a wavy flight
        sta Enemy_Y_Position,x
NoMGPT: rts                        ;leave!

XMoveCntr_GreenPTroopa:
         lda #$13                    ;load preset maximum value for secondary counter

XMoveCntr_Platform:
         sta R1                      ;store value here
         lda FrameCounter
         and #%00000011              ;branch to leave if not on
         bne NoIncXM                 ;every fourth frame
         ldy XMoveSecondaryCounter,x ;get secondary counter
         lda XMovePrimaryCounter,x   ;get primary counter
         lsr
         bcs DecSeXM                 ;if d0 of primary counter set, branch elsewhere
         cpy R1                      ;compare secondary counter to preset maximum value
         beq IncPXM                  ;if equal, branch ahead of this part
         inc XMoveSecondaryCounter,x ;increment secondary counter and leave
NoIncXM: rts
IncPXM:  inc XMovePrimaryCounter,x   ;increment primary counter and leave
         rts
DecSeXM: tya                         ;put secondary counter in A
         beq IncPXM                  ;if secondary counter at zero, branch back
         dec XMoveSecondaryCounter,x ;otherwise decrement secondary counter and leave
         rts

MoveWithXMCntrs:
         lda XMoveSecondaryCounter,x  ;save secondary counter to stack
         pha
         ldy #$01                     ;set value here by default
         lda XMovePrimaryCounter,x
         and #%00000010               ;if d1 of primary counter is
         bne XMRight                  ;set, branch ahead of this part here
         lda XMoveSecondaryCounter,x
         eor #$ff                     ;otherwise change secondary
         clc                          ;counter to two's compliment
         adc #$01
         sta XMoveSecondaryCounter,x
         ldy #$02                     ;load alternate value here
XMRight: pha
         tya
         sta Enemy_MovingDir,x        ;store as moving direction
         pla
         jsr MoveEnemyHorizontally
         sta R0                       ;save value obtained from sub here
         pla                          ;get secondary counter from stack
         sta XMoveSecondaryCounter,x  ;and return to original place
         rts

;--------------------------------

InitRetainerObj:
      lda #$b8                ;set fixed vertical position for
      sta Enemy_Y_Position,x  ;princess/mushroom retainer object
      rts


;--------------------------------

InitHorizFlySwimEnemy:
      lda #$00        ;initialize horizontal speed
      jmp SetESpd



;--------------------------------

InitJumpGPTroopa:
           lda #$02                  ;set for movement to the left
           sta Enemy_MovingDir,x
           lda #$f8                  ;set horizontal speed
           sta Enemy_X_Speed,x
TallBBox2: lda #$03                  ;set specific value for bounding box control
SetBBox2:  sta Enemy_BoundBoxCtrl,x  ;set bounding box control then leave
           rts

;--------------------------------

BlooberBitmasks:
      .byte %00111111, %00000011


MoveBloober:
        lda Enemy_State,x
        and #%00100000             ;check enemy state for d5 set
        bne MoveDefeatedBloober    ;branch if set to move defeated bloober
        ldy SecondaryHardMode      ;use secondary hard mode flag as offset
        lda PseudoRandomBitReg+1,x ;get LSFR
        and BlooberBitmasks,y      ;mask out bits in LSFR using bitmask loaded with offset
        bne BlooberSwim            ;if any bits set, skip ahead to make swim
        txa
        lsr                        ;check to see if on second or fourth slot (1 or 3)
        bcc FBLeft                 ;if not, branch to figure out moving direction
        ldy Player_MovingDir       ;otherwise, load player's moving direction and
        bcs SBMDir                 ;do an unconditional branch to set
FBLeft: ldy #$02                   ;set left moving direction by default
        jsr PlayerEnemyDiff        ;get horizontal difference between player and bloober
        bpl SBMDir                 ;if enemy to the right of player, keep left
        dey                        ;otherwise decrement to set right moving direction
SBMDir: pha
        tya
        sta Enemy_MovingDir,x      ;set moving direction of bloober, then continue on here
        pla

BlooberSwim:
       jsr ProcSwimmingB        ;execute sub to make bloober swim characteristically
       lda Enemy_Y_Position,x   ;get vertical coordinate
       sec
       sbc Enemy_Y_MoveForce,x  ;subtract movement force
       cmp #$20                 ;check to see if position is above edge of status bar
       bcc SwimX                ;if so, don't do it
       sta Enemy_Y_Position,x   ;otherwise, set new vertical position, make bloober swim
SwimX: ldy Enemy_MovingDir,x    ;check moving direction
       dey
       bne LeftSwim             ;if moving to the left, branch to second part
       lda Enemy_X_Position,x
       clc                      ;add movement speed to horizontal coordinate
       adc BlooperMoveSpeed,x
       sta Enemy_X_Position,x   ;store result as new horizontal coordinate
       lda Enemy_PageLoc,x
       adc #$00                 ;add carry to page location
       sta Enemy_PageLoc,x      ;store as new page location and leave
       rts

LeftSwim:
      lda Enemy_X_Position,x
      sec                      ;subtract movement speed from horizontal coordinate
      sbc BlooperMoveSpeed,x
      sta Enemy_X_Position,x   ;store result as new horizontal coordinate
      lda Enemy_PageLoc,x
      sbc #$00                 ;subtract borrow from page location
      sta Enemy_PageLoc,x      ;store as new page location and leave
      rts

MoveDefeatedBloober:
      jmp MoveEnemySlowVert    ;jump to move defeated bloober downwards

ProcSwimmingB:
        lda BlooperMoveCounter,x  ;get enemy's movement counter
        and #%00000010            ;check for d1 set
        bne ChkForFloatdown       ;branch if set
        lda FrameCounter
        and #%00000111            ;get 3 LSB of frame counter
        pha                       ;and save it to the stack
        lda BlooperMoveCounter,x  ;get enemy's movement counter
        lsr                       ;check for d0 set
        bcs SlowSwim              ;branch if set
        pla                       ;pull 3 LSB of frame counter from the stack
        bne BSwimE                ;branch to leave, execute code only every eighth frame
        lda Enemy_Y_MoveForce,x
        clc                       ;add to movement force to speed up swim
        adc #$01
        sta Enemy_Y_MoveForce,x   ;set movement force
        sta BlooperMoveSpeed,x    ;set as movement speed
        cmp #$02
        bne BSwimE                ;if certain horizontal speed, branch to leave
        inc BlooperMoveCounter,x  ;otherwise increment movement counter
BSwimE: rts

SlowSwim:
       pla                      ;pull 3 LSB of frame counter from the stack
       bne NoSSw                ;branch to leave, execute code only every eighth frame
       lda Enemy_Y_MoveForce,x
       sec                      ;subtract from movement force to slow swim
       sbc #$01
       sta Enemy_Y_MoveForce,x  ;set movement force
       sta BlooperMoveSpeed,x   ;set as movement speed
       bne NoSSw                ;if any speed, branch to leave
       inc BlooperMoveCounter,x ;otherwise increment movement counter
       lda #$02
       sta EnemyIntervalTimer,x ;set enemy's timer
NoSSw: rts                      ;leave

ChkForFloatdown:
      lda EnemyIntervalTimer,x ;get enemy timer
      beq ChkNearPlayer        ;branch if expired

Floatdown:
      lda FrameCounter        ;get frame counter
      lsr                     ;check for d0 set
      bcs NoFD                ;branch to leave on every other frame
      inc Enemy_Y_Position,x  ;otherwise increment vertical coordinate
NoFD: rts                     ;leave

ChkNearPlayer:
      lda Enemy_Y_Position,x    ;get vertical coordinate
      adc #$10                  ;add sixteen pixels
      cmp Player_Y_Position     ;compare result with player's vertical coordinate
      bcc Floatdown             ;if modified vertical less than player's, branch
      lda #$00
      sta BlooperMoveCounter,x  ;otherwise nullify movement counter
      rts


;--------------------------------

.proc InitBowser
  jsr DuplicateEnemyObj     ;jump to create another bowser object
  stx BowserFront_Offset    ;save offset of first here
  lda #$00
  sta BowserBodyControls    ;initialize bowser's body controls
  sta BridgeCollapseOffset  ;and bridge collapse offset
  lda Enemy_X_Position,x
  sta BowserOrigXPos        ;store original horizontal position here
  lda #$df
  sta BowserFireBreathTimer ;store something here
  sta Enemy_MovingDir,x     ;and in moving direction
  lda #$20
  sta BowserFeetCounter     ;set bowser's feet timer and in enemy timer
  sta EnemyFrameTimer,x
  lda #$05
  sta BowserHitPoints       ;give bowser 5 hit points
  lsr
  sta BowserMovementSpeed   ;set default movement speed here
  rts
.endproc

;--------------------------------

RunBowserFlame:
  jsr ProcBowserFlame
  jsr GetEnemyOffscreenBits
  jsr RelativeEnemyPosition
  jsr GetEnemyBoundBox
  jsr PlayerEnemyCollision
  jmp OffscreenBoundsCheck

;-------------------------------------------------------------------------------------
;$04-$05 - used to store name table address in little endian order
BridgeCollapse:
  ldx #BubbleMetasprite - EnemyMetasprite
  :
    lda EnemyMetasprite,x
    cmp #Bowser
    beq Skip
    lda #0
    sta EnemyMetasprite,x
  Skip:
    dex
    bpl :-

  ldx BowserFront_Offset    ;get enemy offset for bowser
  lda Enemy_ID,x            ;check enemy object identifier for bowser
  cmp #Bowser               ;if not found, branch ahead,
  bne SetM2                 ;metatile removal not necessary
  stx ObjectOffset          ;store as enemy offset here
  lda Enemy_State,x         ;if bowser in normal state, skip all of this
  beq RemoveBridge
  and #%01000000            ;if bowser's state has d6 clear, skip to silence music
  beq SetM2
  lda Enemy_Y_Position,x    ;check bowser's vertical coordinate
  cmp #$e0                  ;if bowser not yet low enough, skip this part ahead
  bcc MoveD_Bowser
SetM2:
  lda #Silence              ;silence music
  sta EventMusicQueue
  inc OperMode_Task         ;move onto next secondary mode in autoctrl mode
  jmp KillAllEnemies        ;jump to empty all enemy slots and then leave  

MoveD_Bowser:
  jsr MoveEnemySlowVert     ;do a sub to move bowser downwards
  jmp BowserGfxHandler      ;jump to draw bowser's front and rear, then leave

RemoveBridge:
  dec BowserFeetCounter     ;decrement timer to control bowser's feet
  bne NoBFall               ;if not expired, skip all of this
  lda #$04
  sta BowserFeetCounter     ;otherwise, set timer now
  lda BowserBodyControls
  eor #$01                  ;invert bit to control bowser's feet
  sta BowserBodyControls
  lda #$22                  ;put high byte of name table address here for now
  sta R5 
  ldy BridgeCollapseOffset  ;get bridge collapse offset here
  lda BridgeCollapseData,y  ;load low byte of name table address and store here
  sta R4 
  ldy VRAM_Buffer1_Offset   ;increment vram buffer offset
  iny
  ldx #$0c                  ;set offset for tile data for sub to draw blank metatile
  farcall RemBridge             ;do sub here to remove bowser's bridge metatiles
  ldx ObjectOffset          ;get enemy offset
  farcall MoveVOffset       ;set new vram buffer offset
  lda #Sfx_Blast            ;load the fireworks/gunfire sound into the square 2 sfx
  sta Square2SoundQueue     ;queue while at the same time loading the brick
  lda #Sfx_BrickShatter     ;shatter sound into the noise sfx queue thus
  sta NoiseSoundQueue       ;producing the unique sound of the bridge collapsing 
  inc BridgeCollapseOffset  ;increment bridge collapse offset
  lda BridgeCollapseOffset
  cmp #$0f                  ;if bridge collapse offset has not yet reached
  bne NoBFall               ;the end, go ahead and skip this part
  jsr InitVStf              ;initialize whatever vertical speed bowser has
  lda #%01000000
  sta Enemy_State,x         ;set bowser's state to one of defeated states (d6 set)
  lda #Sfx_BowserFall
  sta Square2SoundQueue     ;play bowser defeat sound
NoBFall:
  jmp BowserGfxHandler      ;jump to code that draws bowser

;--------------------------------

BridgeCollapseData:
  .byte $1a ;axe
  .byte $58 ;chain
  .byte $98, $96, $94, $92, $90, $8e, $8c ;bridge
  .byte $8a, $88, $86, $84, $82, $80
PRandomRange:
  .byte $21, $41, $11, $31

RunBowser:

  lda Enemy_State,x       ;if d5 in enemy state is not set
  and #%00100000          ;then branch elsewhere to run bowser
  beq BowserControl
  lda Enemy_Y_Position,x  ;otherwise check vertical position
  cmp #$e0                ;if above a certain point, branch to move defeated bowser
  jcc MoveD_Bowser        ;otherwise proceed to KillAllEnemies

KillAllEnemies:
  ldx #$04              ;start with last enemy slot
KillLoop:
    jsr EraseEnemyObject  ;branch to kill enemy objects
    dex                   ;move onto next enemy slot
    bpl KillLoop          ;do this until all slots are emptied
  sta EnemyFrenzyBuffer ;empty frenzy buffer
  ldx ObjectOffset      ;get enemy object offset and leave
  rts

BowserControl:
  lda #$00
  sta EnemyFrenzyBuffer      ;empty frenzy buffer
  lda TimerControl           ;if master timer control not set,
  beq ChkMouth               ;skip jump and execute code here
  jmp SkipToFB               ;otherwise, jump over a bunch of code
ChkMouth:
  lda BowserBodyControls     ;check bowser's mouth
  bpl FeetTmr                ;if bit clear, go ahead with code here
  jmp HammerChk              ;otherwise skip a whole section starting here
FeetTmr:
  dec BowserFeetCounter      ;decrement timer to control bowser's feet
  bne ResetMDr               ;if not expired, skip this part
  lda #$20                   ;otherwise, reset timer
  sta BowserFeetCounter        
  lda BowserBodyControls     ;and invert bit used
  eor #%00000001             ;to control bowser's feet
  sta BowserBodyControls
ResetMDr:
  lda FrameCounter           ;check frame counter
  and #%00001111             ;if not on every sixteenth frame, skip
  bne B_FaceP                ;ahead to continue code
  lda #$02                   ;otherwise reset moving/facing direction every
  sta Enemy_MovingDir,x      ;sixteen frames
B_FaceP:
  lda EnemyFrameTimer,x      ;if timer set here expired,
  beq GetPRCmp               ;branch to next section
  jsr PlayerEnemyDiff        ;get horizontal difference between player and bowser,
  bpl GetPRCmp               ;and branch if bowser to the right of the player
  lda #$01
  sta Enemy_MovingDir,x      ;set bowser to move and face to the right
  lda #$02
  sta BowserMovementSpeed    ;set movement speed
  lda #$20
  sta EnemyFrameTimer,x      ;set timer here
  sta BowserFireBreathTimer  ;set timer used for bowser's flame
  lda Enemy_X_Position,x        
  cmp #$c8                   ;if bowser to the right past a certain point,
  bcs HammerChk              ;skip ahead to some other section
GetPRCmp:
  lda FrameCounter           ;get frame counter
  and #%00000011
  bne HammerChk              ;execute this code every fourth frame, otherwise branch
  lda Enemy_X_Position,x
  cmp BowserOrigXPos         ;if bowser not at original horizontal position,
  bne GetDToO                ;branch to skip this part
  lda PseudoRandomBitReg,x
  and #%00000011             ;get pseudorandom offset
  tay
  lda PRandomRange,y         ;load value using pseudorandom offset
  sta MaxRangeFromOrigin     ;and store here
GetDToO:
  lda Enemy_X_Position,x
  clc                        ;add movement speed to bowser's horizontal
  adc BowserMovementSpeed    ;coordinate and save as new horizontal position
  sta Enemy_X_Position,x
  ldy Enemy_MovingDir,x
  cpy #$01                   ;if bowser moving and facing to the right, skip ahead
  beq HammerChk
  ldy #$ff                   ;set default movement speed here (move left)
  sec                        ;get difference of current vs. original
  sbc BowserOrigXPos         ;horizontal position
  bpl CompDToO               ;if current position to the right of original, skip ahead
  eor #$ff
  clc                        ;get two's compliment
  adc #$01
  ldy #$01                   ;set alternate movement speed here (move right)
CompDToO:
  cmp MaxRangeFromOrigin     ;compare difference with pseudorandom value
  bcc HammerChk              ;if difference < pseudorandom value, leave speed alone
  sty BowserMovementSpeed    ;otherwise change bowser's movement speed
HammerChk:
  lda EnemyFrameTimer,x      ;if timer set here not expired yet, skip ahead to
  bne MakeBJump              ;some other section of code
  jsr MoveEnemySlowVert      ;otherwise start by moving bowser downwards
  lda WorldNumber            ;check world number
  cmp #World6
  bcc SetHmrTmr              ;if world 1-5, skip this part (not time to throw hammers yet)
  lda FrameCounter
  and #%00000011             ;check to see if it's time to execute sub
  bne SetHmrTmr              ;if not, skip sub, otherwise
  jsr SpawnHammerObj         ;execute sub on every fourth frame to spawn misc object (hammer)
SetHmrTmr:
  lda Enemy_Y_Position,x     ;get current vertical position
  cmp #$80                   ;if still above a certain point
  bcc ChkFireB               ;then skip to world number check for flames
  lda PseudoRandomBitReg,x
  and #%00000011             ;get pseudorandom offset
  tay
  lda PRandomRange,y         ;get value using pseudorandom offset
  sta EnemyFrameTimer,x      ;set for timer here
SkipToFB:
  jmp ChkFireB               ;jump to execute flames code
MakeBJump:
  cmp #$01                   ;if timer not yet about to expire,
  bne ChkFireB               ;skip ahead to next part
  dec Enemy_Y_Position,x     ;otherwise decrement vertical coordinate
  jsr InitVStf               ;initialize movement amount
  lda #$fe
  sta Enemy_Y_Speed,x        ;set vertical speed to move bowser upwards
ChkFireB:
  lda WorldNumber            ;check world number here
  cmp #World8                ;world 8?
  beq SpawnFBr               ;if so, execute this part here
  cmp #World6                ;world 6-7?
  bcs BowserGfxHandler       ;if so, skip this part here
SpawnFBr:
  lda BowserFireBreathTimer  ;check timer here
  bne BowserGfxHandler       ;if not expired yet, skip all of this
  lda #$20
  sta BowserFireBreathTimer  ;set timer here
  lda BowserBodyControls
  eor #%10000000             ;invert bowser's mouth bit to open
  sta BowserBodyControls     ;and close bowser's mouth
  bmi ChkFireB               ;if bowser's mouth open, loop back
  jsr SetFlameTimer          ;get timing for bowser's flame
  ldy SecondaryHardMode
  beq SetFBTmr               ;if secondary hard mode flag not set, skip this
  sec
  sbc #$10                   ;otherwise subtract from value in A
SetFBTmr:
  sta BowserFireBreathTimer  ;set value as timer here
  lda #BowserFlame           ;put bowser's flame identifier
  sta EnemyFrenzyBuffer      ;in enemy frenzy buffer


;--------------------------------

BowserGfxHandler:
  jsr ProcessBowserHalf    ;do a sub here to process bowser's front
  ldy #$10                 ;load default value here to position bowser's rear
  lda Enemy_MovingDir,x    ;check moving direction
  lsr
  bcc CopyFToR             ;if moving left, use default
  ldy #$f0                 ;otherwise load alternate positioning value here
CopyFToR:
  tya                      ;move bowser's rear object position value to A
  clc
  adc Enemy_X_Position,x   ;add to bowser's front object horizontal coordinate
  ldy DuplicateObj_Offset  ;get bowser's rear object offset
  sta Enemy_X_Position,y   ;store A as bowser's rear horizontal coordinate
  lda Enemy_Y_Position,x
  clc                      ;add eight pixels to bowser's front object
  adc #$08                 ;vertical coordinate and store as vertical coordinate
  sta Enemy_Y_Position,y   ;for bowser's rear
  lda Enemy_State,x
  sta Enemy_State,y        ;copy enemy state directly from front to rear
  lda Enemy_MovingDir,x
  sta Enemy_MovingDir,y    ;copy moving direction also
  lda ObjectOffset         ;save enemy object offset of front to stack
  pha
  ldx DuplicateObj_Offset  ;put enemy object offset of rear as current
  stx ObjectOffset
  lda #Bowser              ;set bowser's enemy identifier
  sta Enemy_ID,x           ;store in bowser's rear object
  jsr ProcessBowserHalf    ;do a sub here to process bowser's rear
  pla
  sta ObjectOffset         ;get original enemy object offset
  tax
  lda #$00                 ;nullify bowser's front/rear graphics flag
  sta BowserGfxFlag
ExBGfxH:
  rts                      ;leave!

ExitEarly:
  rts

ProcessBowserHalf:
  inc BowserGfxFlag         ;increment bowser's graphics flag, then run subroutines
  jsr ChooseBowserMetasprite
  jsr SprObjectOffscrChk
  jsr GetEnemyOffscreenBits
  jsr RelativeEnemyPosition
  lda Enemy_State,x
  bne ExitEarly ;if either enemy object not in normal state, branch to leave
  lda #$0a
  sta Enemy_BoundBoxCtrl,x  ;set bounding box size control
  jsr GetEnemyBoundBox      ;get bounding box coordinates
  jmp PlayerEnemyCollision  ;do player-to-enemy collision detection

.proc ChooseBowserMetasprite
  ; 1 == drawing front. 2 == drawing rear
  lda BowserGfxFlag
  lsr
  bcs BowserFront
    ; Drawing bowsers rear
    ldy #METASPRITE_BOWSER_REAR_WALK_1
    ; branch if d0 not set (control's bowser's feet)
    lda BowserBodyControls
    and #1
    beq WriteMetasprite
      ldy #METASPRITE_BOWSER_REAR_WALK_2
      bne WriteMetasprite ; unconditional
BowserFront:
    ldy #METASPRITE_BOWSER_FRONT_MOUTH_OPEN
    ;branch if d7 not set (control's bowser's mouth)
    lda BowserBodyControls
    bpl WriteMetasprite
      ldy #METASPRITE_BOWSER_FRONT_MOUTH_CLOSED
WriteMetasprite:
  tya
  sta EnemyMetasprite,x
  lda Enemy_State,x
  and #%00100000
  beq BowserNotDefeated
    ; if bowser is defeated set the vertical flip flag
    lda BowserGfxFlag
    lsr
    lda #MetaspriteOffset{-8} | MSPR_VERTICAL_FLIP
    bcs DontOffsetBowserFrontHalf
      ; when the back side flips, it moves up 16px
      lda #MetaspriteOffset{-24} | MSPR_VERTICAL_FLIP
  DontOffsetBowserFrontHalf:
    sta EnemyVerticalFlip,x
BowserNotDefeated:
  rts
.endproc

;-------------------------------------------------------------------------------------
;$00 - used to hold movement force and tile number
;$01 - used to hold sprite attribute data

FlameTimerData:
      .byte $bf, $40, $bf, $bf, $bf, $40, $40, $bf

SetFlameTimer:
      ldy BowserFlameTimerCtrl  ;load counter as offset
      inc BowserFlameTimerCtrl  ;increment
      lda BowserFlameTimerCtrl  ;mask out all but 3 LSB
      and #%00000111            ;to keep in range of 0-7
      sta BowserFlameTimerCtrl
      lda FlameTimerData,y      ;load value to be used then leave
ExFl: rts

ProcBowserFlame:
         lda TimerControl            ;if master timer control flag set,
         bne SetGfxF                 ;skip all of this
         lda #$40                    ;load default movement force
         ldy SecondaryHardMode
         beq SFlmX                   ;if secondary hard mode flag not set, use default
         lda #$60                    ;otherwise load alternate movement force to go faster
SFlmX:   sta R0                      ;store value here
         lda Enemy_X_MoveForce,x
         sec                         ;subtract value from movement force
         sbc R0 
         sta Enemy_X_MoveForce,x     ;save new value
         lda Enemy_X_Position,x
         sbc #$01                    ;subtract one from horizontal position to move
         sta Enemy_X_Position,x      ;to the left
         lda Enemy_PageLoc,x
         sbc #$00                    ;subtract borrow from page location
         sta Enemy_PageLoc,x
         ldy BowserFlamePRandomOfs,x ;get some value here and use as offset
         lda Enemy_Y_Position,x      ;load vertical coordinate
         cmp FlameYPosData,y         ;compare against coordinate data using $0417,x as offset
         beq SetGfxF                 ;if equal, branch and do not modify coordinate
         clc
         adc Enemy_Y_MoveForce,x     ;otherwise add value here to coordinate and store
         sta Enemy_Y_Position,x      ;as new vertical coordinate
SetGfxF: 
  lda Enemy_State,x
  bne ExFlmeD
    jmp DrawBowserFlame
ExFlmeD: rts                        ;leave

.proc DrawBowserFlame
  ; implicit a == 0
  sta Enemy_SprAttrib,x
  lda FrameCounter
  and #%00000010
  beq :+
    ; invert vertical flip bit every 2 frames
    lda #OAM_FLIP_V
    sta Enemy_SprAttrib,x
  :
  lda #METASPRITE_BOWSER_FLAME
  sta EnemyMetasprite,x
  rts
.endproc

;--------------------------------

FlameYPosData:
  .byte $90, $80, $70, $90

FlameYMFAdderData:
  .byte $ff, $01

InitBowserFlame:
        lda FrenzyEnemyTimer        ;if timer not expired yet, branch to leave
        bne ExFlmeD
        sta Enemy_Y_MoveForce,x     ;reset something here
        lda NoiseSoundQueue
        ora #Sfx_BowserFlame        ;load bowser's flame sound into queue
        sta NoiseSoundQueue
        ldy BowserFront_Offset      ;get bowser's buffer offset
        lda Enemy_ID,y              ;check for bowser
        cmp #Bowser
        beq SpawnFromMouth          ;branch if found
        jsr SetFlameTimer           ;get timer data based on flame counter
        clc
        adc #$20                    ;add 32 frames by default
        ldy SecondaryHardMode
        beq SetFrT                  ;if secondary mode flag not set, use as timer setting
        sec
        sbc #$10                    ;otherwise subtract 16 frames for secondary hard mode
SetFrT: sta FrenzyEnemyTimer        ;set timer accordingly
        lda PseudoRandomBitReg,x
        and #%00000011              ;get 2 LSB from first part of LSFR
        sta BowserFlamePRandomOfs,x ;set here
        tay                         ;use as offset
        lda FlameYPosData,y         ;load vertical position based on pseudorandom offset

PutAtRightExtent:
      sta Enemy_Y_Position,x    ;set vertical position
      lda ScreenRight_X_Pos
      clc
      adc #$20                  ;place enemy 32 pixels beyond right side of screen
      sta Enemy_X_Position,x
      lda ScreenRight_PageLoc
      adc #$00                  ;add carry
      sta Enemy_PageLoc,x
      jmp FinishFlame           ;skip this part to finish setting values

SpawnFromMouth:
       lda Enemy_X_Position,y    ;get bowser's horizontal position
       sec
       sbc #$0e                  ;subtract 14 pixels
       sta Enemy_X_Position,x    ;save as flame's horizontal position
       lda Enemy_PageLoc,y
       sta Enemy_PageLoc,x       ;copy page location from bowser to flame
       lda Enemy_Y_Position,y
       clc                       ;add 8 pixels to bowser's vertical position
       adc #$08
       sta Enemy_Y_Position,x    ;save as flame's vertical position
       lda PseudoRandomBitReg,x
       and #%00000011            ;get 2 LSB from first part of LSFR
       sta Enemy_YMoveForceFractional,x     ;save here
       tay                       ;use as offset
       lda FlameYPosData,y       ;get value here using bits as offset
       ldy #$00                  ;load default offset
       cmp Enemy_Y_Position,x    ;compare value to flame's current vertical position
       bcc SetMF                 ;if less, do not increment offset
       iny                       ;otherwise increment now
SetMF: lda FlameYMFAdderData,y   ;get value here and save
       sta Enemy_Y_MoveForce,x   ;to vertical movement force
       lda #$00
       sta EnemyFrenzyBuffer     ;clear enemy frenzy buffer

FinishFlame:
      lda #$08                 ;set $08 for bounding box control
      sta Enemy_BoundBoxCtrl,x
      lda #$01                 ;set high byte of vertical and
      sta Enemy_Y_HighPos,x    ;enemy buffer flag
      sta Enemy_Flag,x
      lsr
      sta Enemy_X_MoveForce,x  ;initialize horizontal movement force, and
      sta Enemy_State,x        ;enemy state
      rts

;--------------------------------

InitEnemyFrenzy:
      lda Enemy_ID,x        ;load enemy identifier
      sta EnemyFrenzyBuffer ;save in enemy frenzy buffer
      sec
      sbc #$12              ;subtract 12 and use as offset for jump engine
      jsr JumpEngine

;frenzy object jump table
      .word LakituAndSpinyHandler
      .word NoFrenzyCode
      .word InitFlyingCheepCheep
      .word InitBowserFlame
      .word InitFireworks
      .word BulletBillCheepCheep

;--------------------------------

NoFrenzyCode:
      rts

;--------------------------------

Enemy17YPosData:
      .byte $40, $30, $90, $50, $20, $60, $a0, $70

SwimCC_IDData:
      .byte $0a, $0b

BulletBillCheepCheep:
         lda FrenzyEnemyTimer      ;if timer not expired yet, branch to leave
         bne ExF17
         lda AreaType              ;are we in a water-type level?
         bne DoBulletBills         ;if not, branch elsewhere
         cpx #$03                  ;are we past third enemy slot?
         bcs ExF17                 ;if so, branch to leave
         ldy #$00                  ;load default offset
         lda PseudoRandomBitReg,x
         cmp #$aa                  ;check first part of LSFR against preset value
         bcc ChkW2                 ;if less than preset, do not increment offset
         iny                       ;otherwise increment
ChkW2:   lda WorldNumber           ;check world number
         cmp #World2
         beq Get17ID               ;if we're on world 2, do not increment offset
         iny                       ;otherwise increment
Get17ID: tya
         and #%00000001            ;mask out all but last bit of offset
         tay
         lda SwimCC_IDData,y       ;load identifier for cheep-cheeps
Set17ID: sta Enemy_ID,x            ;store whatever's in A as enemy identifier
         lda BitMFilter
         cmp #$ff                  ;if not all bits set, skip init part and compare bits
         bne GetRBit
         lda #$00                  ;initialize vertical position filter
         sta BitMFilter
GetRBit: lda PseudoRandomBitReg,x  ;get first part of LSFR
         and #%00000111            ;mask out all but 3 LSB
ChkRBit: tay                       ;use as offset
         lda Bitmasks,y            ;load bitmask
         bit BitMFilter            ;perform AND on filter without changing it
         beq AddFBit
         iny                       ;increment offset
         tya
         and #%00000111            ;mask out all but 3 LSB thus keeping it 0-7
         jmp ChkRBit               ;do another check
AddFBit: ora BitMFilter            ;add bit to already set bits in filter
         sta BitMFilter            ;and store
         lda Enemy17YPosData,y     ;load vertical position using offset
         jsr PutAtRightExtent      ;set vertical position and other values
         sta Enemy_YMoveForceFractional,x     ;initialize dummy variable
         lda #$20                  ;set timer
         sta FrenzyEnemyTimer
         jmp CheckpointEnemyID     ;process our new enemy object

DoBulletBills:
          ldy #$ff                   ;start at beginning of enemy slots
BB_SLoop: iny                        ;move onto the next slot
          cpy #$05                   ;branch to play sound if we've done all slots
          bcs FireBulletBill
          lda Enemy_Flag,y           ;if enemy buffer flag not set,
          beq BB_SLoop               ;loop back and check another slot
          lda Enemy_ID,y
          cmp #BulletBill_FrenzyVar  ;check enemy identifier for
          bne BB_SLoop               ;bullet bill object (frenzy variant)
ExF17:    rts                        ;if found, leave

FireBulletBill:
      lda Square2SoundQueue
      ora #Sfx_Blast            ;play fireworks/gunfire sound
      sta Square2SoundQueue
      lda #BulletBill_FrenzyVar ;load identifier for bullet bill object
      bne Set17ID               ;unconditional branch


;--------------------------------

InitLakitu:
      lda EnemyFrenzyBuffer      ;check to see if an enemy is already in
      bne KillLakitu             ;the frenzy buffer, and branch to kill lakitu if so

SetupLakitu:
      lda #$00                   ;erase counter for lakitu's reappearance
      sta LakituReappearTimer
      jsr InitHorizFlySwimEnemy  ;set $03 as bounding box, set other attributes
      jmp TallBBox2              ;set $03 as bounding box again (not necessary) and leave

KillLakitu:
      jmp EraseEnemyObject

;--------------------------------
;$01-$03 - used to hold pseudorandom difference adjusters

PRDiffAdjustData:
      .byte $26, $2c, $32, $38
      .byte $20, $22, $24, $26
      .byte $13, $14, $15, $16

LakituAndSpinyHandler:
          lda FrenzyEnemyTimer    ;if timer here not expired, leave
          bne ExLSHand
          cpx #$05                ;if we are on the special use slot, leave
          bcs ExLSHand
          lda #$80                ;set timer
          sta FrenzyEnemyTimer
          ldy #$04                ;start with the last enemy slot
ChkLak:   lda Enemy_ID,y          ;check all enemy slots to see
          cmp #Lakitu             ;if lakitu is on one of them
          beq CreateSpiny         ;if so, branch out of this loop
          dey                     ;otherwise check another slot
          bpl ChkLak              ;loop until all slots are checked
          inc LakituReappearTimer ;increment reappearance timer
          lda LakituReappearTimer
          cmp #$07                ;check to see if we're up to a certain value yet
          bcc ExLSHand            ;if not, leave
          ldx #$04                ;start with the last enemy slot again
ChkNoEn:  lda Enemy_Flag,x        ;check enemy buffer flag for non-active enemy slot
          beq CreateL             ;branch out of loop if found
          dex                     ;otherwise check next slot
          bpl ChkNoEn             ;branch until all slots are checked
          bmi RetEOfs             ;if no empty slots were found, branch to leave
CreateL:  lda #$00                ;initialize enemy state
          sta Enemy_State,x
          lda #Lakitu             ;create lakitu enemy object
          sta Enemy_ID,x
          jsr SetupLakitu         ;do a sub to set up lakitu
          lda #$20
          jsr PutAtRightExtent    ;finish setting up lakitu
RetEOfs:  ldx ObjectOffset        ;get enemy object buffer offset again and leave
ExLSHand: rts

;--------------------------------

CreateSpiny:
          lda Player_Y_Position      ;if player above a certain point, branch to leave
          cmp #$2c
          bcc ExLSHand
          lda Enemy_State,y          ;if lakitu is not in normal state, branch to leave
          bne ExLSHand
          lda Enemy_PageLoc,y        ;store horizontal coordinates (high and low) of lakitu
          sta Enemy_PageLoc,x        ;into the coordinates of the spiny we're going to create
          lda Enemy_X_Position,y
          sta Enemy_X_Position,x
          lda #$01                   ;put spiny within vertical screen unit
          sta Enemy_Y_HighPos,x
          lda Enemy_Y_Position,y     ;put spiny eight pixels above where lakitu is
          sec
          sbc #$08
          sta Enemy_Y_Position,x
          lda PseudoRandomBitReg,x   ;get 2 LSB of LSFR and save to Y
          and #%00000011
          tay
          ldx #$02
DifLoop:  lda PRDiffAdjustData,y     ;get three values and save them
          sta R1 ,x                  ;to $01-$03
          iny
          iny                        ;increment Y four bytes for each value
          iny
          iny
          dex                        ;decrement X for each one
          bpl DifLoop                ;loop until all three are written
          ldx ObjectOffset           ;get enemy object buffer offset
          jsr PlayerLakituDiff       ;move enemy, change direction, get value - difference
          ldy Player_X_Speed         ;check player's horizontal speed
          cpy #$08
          bcs SetSpSpd               ;if moving faster than a certain amount, branch elsewhere
          tay                        ;otherwise save value in A to Y for now
          lda PseudoRandomBitReg+1,x
          and #%00000011             ;get one of the LSFR parts and save the 2 LSB
          beq UsePosv                ;branch if neither bits are set
          tya
          eor #%11111111             ;otherwise get two's compliment of Y
          tay
          iny
UsePosv:  tya                        ;put value from A in Y back to A (they will be lost anyway)
SetSpSpd: jsr SmallBBox              ;set bounding box control, init attributes, lose contents of A
          ldy #$02                   ;(putting this call elsewhere will preserve A)
          sta Enemy_X_Speed,x        ;set horizontal speed to zero because previous contents
          cmp #$00                   ;of A were lost...branch here will never be taken for
          bmi SpinyRte               ;the same reason
          dey
SpinyRte: pha
          tya
          sta Enemy_MovingDir,x      ;set moving direction to the right
          pla
          lda #$fd
          sta Enemy_Y_Speed,x        ;set vertical speed to move upwards
          lda #$01
          sta Enemy_Flag,x           ;enable enemy object by setting flag
          lda #$05
          sta Enemy_State,x          ;put spiny in egg state and leave
ChpChpEx: rts


;--------------------------------
;$00-$01 - used to hold pseudorandom bits

FlyCCXPositionData:
      .byte $80, $30, $40, $80
      .byte $30, $50, $50, $70
      .byte $20, $40, $80, $a0
      .byte $70, $40, $90, $68

FlyCCXSpeedData:
      .byte $0e, $05, $06, $0e
      .byte $1c, $20, $10, $0c
      .byte $1e, $22, $18, $14

FlyCCTimerData:
      .byte $10, $60, $20, $48

InitFlyingCheepCheep:
         lda FrenzyEnemyTimer       ;if timer here not expired yet, branch to leave
         bne ChpChpEx
         jsr SmallBBox              ;jump to set bounding box size $09 and init other values
         lda PseudoRandomBitReg+1,x
         and #%00000011             ;set pseudorandom offset here
         tay
         lda FlyCCTimerData,y       ;load timer with pseudorandom offset
         sta FrenzyEnemyTimer
         ldy #$03                   ;load Y with default value
         lda SecondaryHardMode
         beq MaxCC                  ;if secondary hard mode flag not set, do not increment Y
         iny                        ;otherwise, increment Y to allow as many as four onscreen
MaxCC:   sty R0                     ;store whatever pseudorandom bits are in Y
         cpx R0                     ;compare enemy object buffer offset with Y
         bcs ChpChpEx               ;if X => Y, branch to leave
         lda PseudoRandomBitReg,x
         and #%00000011             ;get last two bits of LSFR, first part
         sta R0                     ;and store in two places
         sta R1 
         lda #$fb                   ;set vertical speed for cheep-cheep
         sta Enemy_Y_Speed,x
         lda #$00                   ;load default value
         ldy Player_X_Speed         ;check player's horizontal speed
         beq GSeed                  ;if player not moving left or right, skip this part
         lda #$04
         cpy #$19                   ;if moving to the right but not very quickly,
         bcc GSeed                  ;do not change A
         asl                        ;otherwise, multiply A by 2
GSeed:   pha                        ;save to stack
         clc
         adc R0                     ;add to last two bits of LSFR we saved earlier
         sta R0                     ;save it there
         lda PseudoRandomBitReg+1,x
         and #%00000011             ;if neither of the last two bits of second LSFR set,
         beq RSeed                  ;skip this part and save contents of $00
         lda PseudoRandomBitReg+2,x
         and #%00001111             ;otherwise overwrite with lower nybble of
         sta R0                     ;third LSFR part
RSeed:   pla                        ;get value from stack we saved earlier
         clc
         adc R1                     ;add to last two bits of LSFR we saved in other place
         tay                        ;use as pseudorandom offset here
         lda FlyCCXSpeedData,y      ;get horizontal speed using pseudorandom offset
         sta Enemy_X_Speed,x
         lda #$01                   ;set to move towards the right
         sta Enemy_MovingDir,x
         lda Player_X_Speed         ;if player moving left or right, branch ahead of this part
         bne D2XPos1
         ldy R0                     ;get first LSFR or third LSFR lower nybble
         tya                        ;and check for d1 set
         and #%00000010
         beq D2XPos1                ;if d1 not set, branch
         lda Enemy_X_Speed,x
         eor #$ff                   ;if d1 set, change horizontal speed
         clc                        ;into two's compliment, thus moving in the opposite
         adc #$01                   ;direction
         sta Enemy_X_Speed,x
         inc Enemy_MovingDir,x      ;increment to move towards the left
D2XPos1: tya                        ;get first LSFR or third LSFR lower nybble again
         and #%00000010
         beq D2XPos2                ;check for d1 set again, branch again if not set
         lda Player_X_Position      ;get player's horizontal position
         clc
         adc FlyCCXPositionData,y   ;if d1 set, add value obtained from pseudorandom offset
         sta Enemy_X_Position,x     ;and save as enemy's horizontal position
         lda Player_PageLoc         ;get player's page location
         adc #$00                   ;add carry and jump past this part
         jmp FinCCSt
D2XPos2: lda Player_X_Position      ;get player's horizontal position
         sec
         sbc FlyCCXPositionData,y   ;if d1 not set, subtract value obtained from pseudorandom
         sta Enemy_X_Position,x     ;offset and save as enemy's horizontal position
         lda Player_PageLoc         ;get player's page location
         sbc #$00                   ;subtract borrow
FinCCSt: sta Enemy_PageLoc,x        ;save as enemy's page location
         lda #$01
         sta Enemy_Flag,x           ;set enemy's buffer flag
         sta Enemy_Y_HighPos,x      ;set enemy's high vertical byte
         lda #$f8
         sta Enemy_Y_Position,x     ;put enemy below the screen, and we are done
         rts


;--------------------------------

InitCheepCheep:
      jsr SmallBBox              ;set vertical bounding box, speed, init others
      lda PseudoRandomBitReg,x   ;check one portion of LSFR
      and #%00010000             ;get d4 from it
      sta CheepCheepMoveMFlag,x  ;save as movement flag of some sort
      lda Enemy_Y_Position,x
      sta CheepCheepOrigYPos,x   ;save original vertical coordinate here
      rts

;--------------------------------

FireworksXPosData:
      .byte $00, $30, $60, $60, $00, $20

FireworksYPosData:
      .byte $60, $40, $70, $40, $60, $30

InitFireworks:
          lda FrenzyEnemyTimer         ;if timer not expired yet, branch to leave
          bne ExitFWk
          lda #$20                     ;otherwise reset timer
          sta FrenzyEnemyTimer
          dec FireworksCounter         ;decrement for each explosion
          ldy #$06                     ;start at last slot
StarFChk: dey
          lda Enemy_ID,y               ;check for presence of star flag object
          cmp #StarFlagObject          ;if there isn't a star flag object,
          bne StarFChk                 ;routine goes into infinite loop = crash
          lda Enemy_X_Position,y
          sec                          ;get horizontal coordinate of star flag object, then
          sbc #$30                     ;subtract 48 pixels from it and save to
          pha                          ;the stack
          lda Enemy_PageLoc,y
          sbc #$00                     ;subtract the carry from the page location
          sta R0                       ;of the star flag object
          lda FireworksCounter         ;get fireworks counter
          clc
          adc Enemy_State,y            ;add state of star flag object (possibly not necessary)
          tay                          ;use as offset
          pla                          ;get saved horizontal coordinate of star flag - 48 pixels
          clc
          adc FireworksXPosData,y      ;add number based on offset of fireworks counter
          sta Enemy_X_Position,x       ;store as the fireworks object horizontal coordinate
          lda R0 
          adc #$00                     ;add carry and store as page location for
          sta Enemy_PageLoc,x          ;the fireworks object
          lda FireworksYPosData,y      ;get vertical position using same offset
          sta Enemy_Y_Position,x       ;and store as vertical coordinate for fireworks object
          lda #$01
          sta Enemy_Y_HighPos,x        ;store in vertical high byte
          sta Enemy_Flag,x             ;and activate enemy buffer flag
          lsr
          sta ExplosionGfxCounter,x    ;initialize explosion counter
          lda #$08
          sta ExplosionTimerCounter,x  ;set explosion timing counter
ExitFWk:  rts


.segment "OBJECT"

;--------------------------------

HBroWalkingTimerData:
      .byte $80, $50

InitHammerBro:
      lda #$00                    ;init horizontal speed and timer used by hammer bro
      sta HammerThrowingTimer,x   ;apparently to time hammer throwing
      sta Enemy_X_Speed,x
      ldy SecondaryHardMode       ;get secondary hard mode flag
      lda HBroWalkingTimerData,y
      sta EnemyIntervalTimer,x    ;set value as delay for hammer bro to walk left
      lda #$0b                    ;set specific value for bounding box size control
      jmp SetBBox


;--------------------------------
;$00 - used in HammerBroJumpCode as bitmask

HammerThrowTmrData:
      .byte $30, $1c

XSpeedAdderData:
      .byte $00, $e8, $00, $18

RevivedXSpeed:
      .byte $08, $f8, $0c, $f4

ProcHammerBro:
       lda Enemy_State,x          ;check hammer bro's enemy state for d5 set
       and #%00100000
       beq ChkJH                  ;if not set, go ahead with code
       jmp MoveDefeatedEnemy      ;otherwise jump to something else
ChkJH: lda HammerBroJumpTimer,x   ;check jump timer
       beq HammerBroJumpCode      ;if expired, branch to jump
       dec HammerBroJumpTimer,x   ;otherwise decrement jump timer
       lda Enemy_OffscreenBits
       and #%00001100             ;check offscreen bits
       bne MoveHammerBroXDir      ;if hammer bro a little offscreen, skip to movement code
       lda HammerThrowingTimer,x  ;check hammer throwing timer
       bne DecHT                  ;if not expired, skip ahead, do not throw hammer
       ldy SecondaryHardMode      ;otherwise get secondary hard mode flag
       lda HammerThrowTmrData,y   ;get timer data using flag as offset
       sta HammerThrowingTimer,x  ;set as new timer
       jsr SpawnHammerObj         ;do a sub here to spawn hammer object
       bcc DecHT                  ;if carry clear, hammer not spawned, skip to decrement timer
       lda Enemy_State,x
       ora #%00001000             ;set d3 in enemy state for hammer throw
       sta Enemy_State,x
       jmp MoveHammerBroXDir      ;jump to move hammer bro
DecHT: dec HammerThrowingTimer,x  ;decrement timer
       jmp MoveHammerBroXDir      ;jump to move hammer bro

HammerBroJumpLData:
      .byte $20, $37

HammerBroJumpCode:
       lda Enemy_State,x           ;get hammer bro's enemy state
       and #%00000111              ;mask out all but 3 LSB
       cmp #$01                    ;check for d0 set (for jumping)
       beq MoveHammerBroXDir       ;if set, branch ahead to moving code
       lda #$00                    ;load default value here
       sta R0                      ;save into temp variable for now
       ldy #$fa                    ;set default vertical speed
       lda Enemy_Y_Position,x      ;check hammer bro's vertical coordinate
       bmi SetHJ                   ;if on the bottom half of the screen, use current speed
       ldy #$fd                    ;otherwise set alternate vertical speed
       cmp #$70                    ;check to see if hammer bro is above the middle of screen
       inc R0                      ;increment preset value to $01
       bcc SetHJ                   ;if above the middle of the screen, use current speed and $01
       dec R0                      ;otherwise return value to $00
       lda PseudoRandomBitReg+1,x  ;get part of LSFR, mask out all but LSB
       and #$01
       bne SetHJ                   ;if d0 of LSFR set, branch and use current speed and $00
       ldy #$fa                    ;otherwise reset to default vertical speed
SetHJ: sty Enemy_Y_Speed,x         ;set vertical speed for jumping
       lda Enemy_State,x           ;set d0 in enemy state for jumping
       ora #$01
       sta Enemy_State,x
       lda R0                      ;load preset value here to use as bitmask
       and PseudoRandomBitReg+2,x  ;and do bit-wise comparison with part of LSFR
       tay                         ;then use as offset
       lda SecondaryHardMode       ;check secondary hard mode flag
       bne HJump
       tay                         ;if secondary hard mode flag clear, set offset to 0
HJump: lda HammerBroJumpLData,y    ;get jump length timer data using offset from before
       sta EnemyFrameTimer,x       ;save in enemy timer
       lda PseudoRandomBitReg+1,x
       ora #%11000000              ;get contents of part of LSFR, set d7 and d6, then
       sta HammerBroJumpTimer,x    ;store in jump timer

MoveHammerBroXDir:
         ldy #$fc                  ;move hammer bro a little to the left
         lda FrameCounter
         and #%01000000            ;change hammer bro's direction every 64 frames
         bne Shimmy
         ldy #$04                  ;if d6 set in counter, move him a little to the right
Shimmy:  sty Enemy_X_Speed,x       ;store horizontal speed
         ldy #$01                  ;set to face right by default
         jsr PlayerEnemyDiff       ;get horizontal difference between player and hammer bro
         bmi SetShim               ;if enemy to the left of player, skip this part
         iny                       ;set to face left
         lda EnemyIntervalTimer,x  ;check walking timer
         bne SetShim               ;if not yet expired, skip to set moving direction
         lda #$f8
         sta Enemy_X_Speed,x       ;otherwise, make the hammer bro walk left towards player
SetShim: pha
         tya
         sta Enemy_MovingDir,x     ;set moving direction
         pla

MoveNormalEnemy:
       ldy #$00                   ;init Y to leave horizontal movement as-is 
       lda Enemy_State,x
       and #%01000000             ;check enemy state for d6 set, if set skip
       bne FallE                  ;to move enemy vertically, then horizontally if necessary
       lda Enemy_State,x
       asl                        ;check enemy state for d7 set
       bcs SteadM                 ;if set, branch to move enemy horizontally
       lda Enemy_State,x
       and #%00100000             ;check enemy state for d5 set
       bne MoveDefeatedEnemy      ;if set, branch to move defeated enemy object
       lda Enemy_State,x
       and #%00000111             ;check d2-d0 of enemy state for any set bits
       beq SteadM                 ;if enemy in normal state, branch to move enemy horizontally
       cmp #$05
       beq FallE                  ;if enemy in state used by spiny's egg, go ahead here
       cmp #$03
       bcs ReviveStunned          ;if enemy in states $03 or $04, skip ahead to yet another part
FallE: jsr MoveD_EnemyVertically  ;do a sub here to move enemy downwards
       ldy #$00
       lda Enemy_State,x          ;check for enemy state $02
       cmp #$02
       beq MEHor                  ;if found, branch to move enemy horizontally
       and #%01000000             ;check for d6 set
       beq SteadM                 ;if not set, branch to something else
       lda Enemy_ID,x
       cmp #PowerUpObject         ;check for power-up object
       beq SteadM
       bne SlowM                  ;if any other object where d6 set, jump to set Y
MEHor: jmp MoveEnemyHorizontally  ;jump here to move enemy horizontally for <> $2e and d6 set

SlowM:  ldy #$01                  ;if branched here, increment Y to slow horizontal movement
SteadM: lda Enemy_X_Speed,x       ;get current horizontal speed
        pha                       ;save to stack
        bpl AddHS                 ;if not moving or moving right, skip, leave Y alone
        iny
        iny                       ;otherwise increment Y to next data
AddHS:  clc
        adc XSpeedAdderData,y     ;add value here to slow enemy down if necessary
        sta Enemy_X_Speed,x       ;save as horizontal speed temporarily
        jsr MoveEnemyHorizontally ;then do a sub to move horizontally
        pla
        sta Enemy_X_Speed,x       ;get old horizontal speed from stack and return to
        rts                       ;original memory location, then leave

ReviveStunned:
         lda EnemyIntervalTimer,x  ;if enemy timer not expired yet,
         bne ChkKillGoomba         ;skip ahead to something else
         sta Enemy_State,x         ;otherwise initialize enemy state to normal
         lda FrameCounter
         and #$01                  ;get d0 of frame counter
         tay                       ;use as Y and increment for movement direction
         iny
         tya
         sta Enemy_MovingDir,x     ;store as pseudorandom movement direction
         dey                       ;decrement for use as pointer
         lda PrimaryHardMode       ;check primary hard mode flag
         beq SetRSpd               ;if not set, use pointer as-is
         iny
         iny                       ;otherwise increment 2 bytes to next data
SetRSpd: lda RevivedXSpeed,y       ;load and store new horizontal speed
         sta Enemy_X_Speed,x       ;and leave
         rts

MoveDefeatedEnemy:
      jsr MoveD_EnemyVertically      ;execute sub to move defeated enemy downwards
      jmp MoveEnemyHorizontally      ;now move defeated enemy horizontally

ChkKillGoomba:
        cmp #$0e              ;check to see if enemy timer has reached
        bne NKGmba            ;a certain point, and branch to leave if not
        lda Enemy_ID,x
        cmp #Goomba           ;check for goomba object
        bne NKGmba            ;branch if not found
        jmp EraseEnemyObject  ;otherwise, kill this goomba object
NKGmba: rts ; TODO check this RTS can be removed                   ;leave!


;--------------------------------

EndFrenzy:
           ldy #$05               ;start at last slot
LakituChk: lda Enemy_ID,y         ;check enemy identifiers
           cmp #Lakitu            ;for lakitu
           bne NextFSlot
           lda #$01               ;if found, set state
           sta Enemy_State,y
NextFSlot: dey                    ;move onto the next slot
           bpl LakituChk          ;do this until all slots are checked
           lda #$00
           sta EnemyFrenzyBuffer  ;empty enemy frenzy buffer
           sta Enemy_Flag,x       ;disable enemy buffer flag for this object
           rts

;--------------------------------
;$00 - used to hold horizontal difference
;$01-$03 - used to hold difference adjusters

LakituDiffAdj:
      .byte $15, $30, $40

MoveLakitu:
         lda Enemy_State,x          ;check lakitu's enemy state
         and #%00100000             ;for d5 set
         beq ChkLS                  ;if not set, continue with code
         jmp MoveD_EnemyVertically  ;otherwise jump to move defeated lakitu downwards
ChkLS:   lda Enemy_State,x          ;if lakitu's enemy state not set at all,
         beq Fr12S                  ;go ahead and continue with code
         lda #$00
         sta LakituMoveDirection,x  ;otherwise initialize moving direction to move to left
         sta EnemyFrenzyBuffer      ;initialize frenzy buffer
         lda #$10
         bne SetLSpd                ;load horizontal speed and do unconditional branch
Fr12S:   lda #Spiny
         sta EnemyFrenzyBuffer      ;set spiny identifier in frenzy buffer
         ldy #$02
LdLDa:   lda LakituDiffAdj,y        ;load values
         sta a:R1,y                ;store in zero page
         dey
         bpl LdLDa                  ;do this until all values are stired
         jsr PlayerLakituDiff       ;execute sub to set speed and create spinys
SetLSpd: sta LakituMoveSpeed,x      ;set movement speed returned from sub
         ldy #$01                   ;set moving direction to right by default
         lda LakituMoveDirection,x
         and #$01                   ;get LSB of moving direction
         bne SetLMov                ;if set, branch to the end to use moving direction
         lda LakituMoveSpeed,x
         eor #$ff                   ;get two's compliment of moving speed
         clc
         adc #$01
         sta LakituMoveSpeed,x      ;store as new moving speed
         iny                        ;increment moving direction to left
SetLMov: pha
         tya
         sta Enemy_MovingDir,x      ;store moving direction
         pla
         jmp MoveEnemyHorizontally  ;move lakitu horizontally

PlayerLakituDiff:
           ldy #$00                   ;set Y for default value
           jsr PlayerEnemyDiff        ;get horizontal difference between enemy and player
           bpl ChkLakDif              ;branch if enemy is to the right of the player
           iny                        ;increment Y for left of player
           lda R0 
           eor #$ff                   ;get two's compliment of low byte of horizontal difference
           clc
           adc #$01                   ;store two's compliment as horizontal difference
           sta R0 
ChkLakDif: lda R0                     ;get low byte of horizontal difference
           cmp #$3c                   ;if within a certain distance of player, branch
           bcc ChkPSpeed
           lda #$3c                   ;otherwise set maximum distance
           sta R0 
           lda Enemy_ID,x             ;check if lakitu is in our current enemy slot
           cmp #Lakitu
           bne ChkPSpeed              ;if not, branch elsewhere
           tya                        ;compare contents of Y, now in A
           cmp LakituMoveDirection,x  ;to what is being used as horizontal movement direction
           beq ChkPSpeed              ;if moving toward the player, branch, do not alter
           lda LakituMoveDirection,x  ;if moving to the left beyond maximum distance,
           beq SetLMovD               ;branch and alter without delay
           dec LakituMoveSpeed,x      ;decrement horizontal speed
           lda LakituMoveSpeed,x      ;if horizontal speed not yet at zero, branch to leave
           bne ExMoveLak
SetLMovD:  tya                        ;set horizontal direction depending on horizontal
           sta LakituMoveDirection,x  ;difference between enemy and player if necessary
ChkPSpeed: lda R0 
           and #%00111100             ;mask out all but four bits in the middle
           lsr                        ;divide masked difference by four
           lsr
           sta R0                     ;store as new value
           ldy #$00                   ;init offset
           lda Player_X_Speed
           beq SubDifAdj              ;if player not moving horizontally, branch
           lda ScrollAmount
           beq SubDifAdj              ;if scroll speed not set, branch to same place
           iny                        ;otherwise increment offset
           lda Player_X_Speed
           cmp #$19                   ;if player not running, branch
           bcc ChkSpinyO
           lda ScrollAmount
           cmp #$02                   ;if scroll speed below a certain amount, branchLakituDiffAdj
           bcc ChkSpinyO              ;to same place
           iny                        ;otherwise increment once more
ChkSpinyO: lda Enemy_ID,x             ;check for spiny object
           cmp #Spiny
           bne ChkEmySpd              ;branch if not found
           lda Player_X_Speed         ;if player not moving, skip this part
           bne SubDifAdj
ChkEmySpd: lda Enemy_Y_Speed,x        ;check vertical speed
           bne SubDifAdj              ;branch if nonzero
           ldy #$00                   ;otherwise reinit offset
SubDifAdj: lda a:R1,y                 ;get one of three saved values from earlier
           ldy R0                     ;get saved horizontal difference
SPixelLak: sec                        ;subtract one for each pixel of horizontal difference
           sbc #$01                   ;from one of three saved values
           dey
           bpl SPixelLak              ;branch until all pixels are subtracted, to adjust difference
ExMoveLak: rts                        ;leave!!!

.segment "OBJECT"

;--------------------------------

InitBulletBill:
      lda #$02                  ;set moving direction for left
      sta Enemy_MovingDir,x
      lda #$09                  ;set bounding box control for $09
      sta Enemy_BoundBoxCtrl,x
      rts

;--------------------------------

MoveBulletBill:
         lda Enemy_State,x          ;check bullet bill's enemy object state for d5 set
         and #%00100000
         beq NotDefB                ;if not set, continue with movement code
         jmp MoveJ_EnemyVertically  ;otherwise jump to move defeated bullet bill downwards
NotDefB: lda #$e8                   ;set bullet bill's horizontal speed
         sta Enemy_X_Speed,x        ;and move it accordingly (note: this bullet bill
         jmp MoveEnemyHorizontally  ;object occurs in frenzy object $17, not from cannons)

;-------------------------------------------------------------------------------------

CannonBitmasks:
      .byte %00001111, %00000111

ProcessCannons:
           lda AreaType                ;get area type
           beq ExCannon                ;if water type area, branch to leave
           ldx #$02
ThreeSChk: stx ObjectOffset            ;start at third enemy slot
           lda Enemy_Flag,x            ;check enemy buffer flag
           bne Chk_BB                  ;if set, branch to check enemy
           lda PseudoRandomBitReg+1,x  ;otherwise get part of LSFR
           ldy SecondaryHardMode       ;get secondary hard mode flag, use as offset
           and CannonBitmasks,y        ;mask out bits of LSFR as decided by flag
           cmp #$06                    ;check to see if lower nybble is above certain value
           bcs Chk_BB                  ;if so, branch to check enemy
           tay                         ;transfer masked contents of LSFR to Y as pseudorandom offset
           lda Cannon_PageLoc,y        ;get page location
           beq Chk_BB                  ;if not set or on page 0, branch to check enemy
           lda Cannon_Timer,y          ;get cannon timer
           beq FireCannon              ;if expired, branch to fire cannon
           sbc #$00                    ;otherwise subtract borrow (note carry will always be clear here)
           sta Cannon_Timer,y          ;to count timer down
           jmp Chk_BB                  ;then jump ahead to check enemy

FireCannon:
          lda TimerControl           ;if master timer control set,
          bne Chk_BB                 ;branch to check enemy
          lda #$0e                   ;otherwise we start creating one
          sta Cannon_Timer,y         ;first, reset cannon timer
          lda Cannon_PageLoc,y       ;get page location of cannon
          sta Enemy_PageLoc,x        ;save as page location of bullet bill
          lda Cannon_X_Position,y    ;get horizontal coordinate of cannon
          sta Enemy_X_Position,x     ;save as horizontal coordinate of bullet bill
          lda Cannon_Y_Position,y    ;get vertical coordinate of cannon
          sec
          sbc #$08                   ;subtract eight pixels (because enemies are 24 pixels tall)
          sta Enemy_Y_Position,x     ;save as vertical coordinate of bullet bill
          lda #$01
          sta Enemy_Y_HighPos,x      ;set vertical high byte of bullet bill
          sta Enemy_Flag,x           ;set buffer flag
          lsr                        ;shift right once to init A
          sta Enemy_State,x          ;then initialize enemy's state
          lda #$09
          sta Enemy_BoundBoxCtrl,x   ;set bounding box size control for bullet bill
          lda #BulletBill_CannonVar
          sta Enemy_ID,x             ;load identifier for bullet bill (cannon variant)
          jmp Next3Slt               ;move onto next slot
Chk_BB:   lda Enemy_ID,x             ;check enemy identifier for bullet bill (cannon variant)
          cmp #BulletBill_CannonVar
          bne Next3Slt               ;if not found, branch to get next slot
          jsr OffscreenBoundsCheck   ;otherwise, check to see if it went offscreen
          lda Enemy_Flag,x           ;check enemy buffer flag
          beq Next3Slt               ;if not set, branch to get next slot
          jsr GetEnemyOffscreenBits  ;otherwise, get offscreen information
          jsr BulletBillHandler      ;then do sub to handle bullet bill
Next3Slt: dex                        ;move onto next slot
          bpl ThreeSChk              ;do this until first three slots are checked
ExCannon: rts                        ;then leave

;--------------------------------

BulletBillXSpdData:
      .byte $18, $e8

BulletBillHandler:
           lda TimerControl          ;if master timer control set,
           bne RunBBSubs             ;branch to run subroutines except movement sub
           lda Enemy_State,x
           bne ChkDSte               ;if bullet bill's state set, branch to check defeated state
           lda Enemy_OffscreenBits   ;otherwise load offscreen bits
           and #%00001100            ;mask out bits
           cmp #%00001100            ;check to see if all bits are set
           beq KillBB                ;if so, branch to kill this object
           ldy #$01                  ;set to move right by default
           jsr PlayerEnemyDiff       ;get horizontal difference between player and bullet bill
           bmi SetupBB               ;if enemy to the left of player, branch
           iny                       ;otherwise increment to move left
SetupBB:   tya
           sta Enemy_MovingDir,x     ;set bullet bill's moving direction
           dey                       ;decrement to use as offset
           lda BulletBillXSpdData,y  ;get horizontal speed based on moving direction
           sta Enemy_X_Speed,x       ;and store it
           lda R0                    ;get horizontal difference
           adc #$28                  ;add 40 pixels
           cmp #$50                  ;if less than a certain amount, player is too close
           bcc KillBB                ;to cannon either on left or right side, thus branch
           lda #$01
           sta Enemy_State,x         ;otherwise set bullet bill's state
           lda #$0a
           sta EnemyFrameTimer,x     ;set enemy frame timer
           lda #Sfx_Blast
           sta Square2SoundQueue     ;play fireworks/gunfire sound
ChkDSte:   lda Enemy_State,x         ;check enemy state for d5 set
           and #%00100000
           beq BBFly                 ;if not set, skip to move horizontally
           jsr MoveD_EnemyVertically ;otherwise do sub to move bullet bill vertically
BBFly:     jsr MoveEnemyHorizontally ;do sub to move bullet bill horizontally
RunBBSubs: jsr GetEnemyOffscreenBits ;get offscreen information
           jsr RelativeEnemyPosition ;get relative coordinates
           jsr GetEnemyBoundBox      ;get bounding box coordinates
           jsr PlayerEnemyCollision  ;handle player to enemy collisions
           jmp ProcessBulletBill
      ;      jmp EnemyGraphicsEngine
           ; rts
      ;      jmp EnemyGfxHandler       ;draw the bullet bill and leave
KillBB:    jmp EraseEnemyObject      ;kill bullet bill and leave


;--------------------------------
;$02 - used to hold preset values
;$03 - used to hold enemy state

SwimCCXMoveData:
      .byte $40, $80
      .byte $04, $04 ;residual data, not used

MoveSwimmingCheepCheep:
        lda Enemy_State,x         ;check cheep-cheep's enemy object state
        and #%00100000            ;for d5 set
        beq CCSwim                ;if not set, continue with movement code
        jmp MoveEnemySlowVert     ;otherwise jump to move defeated cheep-cheep downwards
CCSwim: sta R3                    ;save enemy state in $03
        lda Enemy_ID,x            ;get enemy identifier
        sec
        sbc #$0a                  ;subtract ten for cheep-cheep identifiers
        tay                       ;use as offset
        lda SwimCCXMoveData,y     ;load value here
        sta R2 
        lda Enemy_X_MoveForce,x   ;load horizontal force
        sec
        sbc R2                    ;subtract preset value from horizontal force
        sta Enemy_X_MoveForce,x   ;store as new horizontal force
        lda Enemy_X_Position,x    ;get horizontal coordinate
        sbc #$00                  ;subtract borrow (thus moving it slowly)
        sta Enemy_X_Position,x    ;and save as new horizontal coordinate
        lda Enemy_PageLoc,x
        sbc #$00                  ;subtract borrow again, this time from the
        sta Enemy_PageLoc,x       ;page location, then save
        lda #$20
        sta R2                    ;save new value here
        cpx #$02                  ;check enemy object offset
        bcc ExSwCC                ;if in first or second slot, branch to leave
        lda CheepCheepMoveMFlag,x ;check movement flag
        cmp #$10                  ;if movement speed set to $00,
        bcc CCSwimUpwards         ;branch to move upwards
        lda Enemy_YMoveForceFractional,x
        clc
        adc R2                    ;add preset value to dummy variable to get carry
        sta Enemy_YMoveForceFractional,x     ;and save dummy
        lda Enemy_Y_Position,x    ;get vertical coordinate
        adc R3                    ;add carry to it plus enemy state to slowly move it downwards
        sta Enemy_Y_Position,x    ;save as new vertical coordinate
        lda Enemy_Y_HighPos,x
        adc #$00                  ;add carry to page location and
        jmp ChkSwimYPos           ;jump to end of movement code

CCSwimUpwards:
        lda Enemy_YMoveForceFractional,x
        sec
        sbc R2                    ;subtract preset value to dummy variable to get borrow
        sta Enemy_YMoveForceFractional,x     ;and save dummy
        lda Enemy_Y_Position,x    ;get vertical coordinate
        sbc R3                    ;subtract borrow to it plus enemy state to slowly move it upwards
        sta Enemy_Y_Position,x    ;save as new vertical coordinate
        lda Enemy_Y_HighPos,x
        sbc #$00                  ;subtract borrow from page location

ChkSwimYPos:
        sta Enemy_Y_HighPos,x     ;save new page location here
        ldy #$00                  ;load movement speed to upwards by default
        lda Enemy_Y_Position,x    ;get vertical coordinate
        sec
        sbc CheepCheepOrigYPos,x  ;subtract original coordinate from current
        bpl YPDiff                ;if result positive, skip to next part
        ldy #$10                  ;otherwise load movement speed to downwards
        eor #$ff
        clc                       ;get two's compliment of result
        adc #$01                  ;to obtain total difference of original vs. current
YPDiff: cmp #$0f                  ;if difference between original vs. current vertical
        bcc ExSwCC                ;coordinates < 15 pixels, leave movement speed alone
        tya
        sta CheepCheepMoveMFlag,x ;otherwise change movement speed
ExSwCC: rts                       ;leave

;--------------------------------
; NOTE: due to a bug in the vanilla code, this part is read out of bounds
; so we keep the original values including the bytes that it might read
; from the code.
PRandomSubtracter:
      .byte $f8, $a0, $70, $bd
      .byte $00, $20, $20, $20
      .byte $00, $00, $b5, $1e
      .byte $29, $20, $f0, $08

MoveFlyingCheepCheep:
        ; Added a check to see if the cheepcheep is below the screen since this
        ; used to be done in the graphics handler.
        lda Enemy_Y_HighPos,x
        cmp #2
        jcs EraseEnemyObject
        lda Enemy_State,x          ;check cheep-cheep's enemy state
        and #%00100000             ;for d5 set
        beq FlyCC                  ;branch to continue code if not set
        ; lda #$00
        ; sta Enemy_SprAttrib,x      ;otherwise clear sprite attributes
        jmp MoveJ_EnemyVertically  ;and jump to move defeated cheep-cheep downwards
FlyCC:  jsr MoveEnemyHorizontally  ;move cheep-cheep horizontally based on speed and force
        ldy #$0d                   ;set vertical movement amount
        lda #$05                   ;set maximum speed
        jsr SetXMoveAmt            ;branch to impose gravity on flying cheep-cheep
        lda Enemy_Y_MoveForce,x
        lsr                        ;get vertical movement force and
        lsr                        ;move high nybble to low
        lsr
        lsr
        tay                        ;save as offset (note this tends to go into reach of code)
        lda Enemy_Y_Position,x     ;get vertical position
        sec                        ;subtract pseudorandom value based on offset from position
        sbc PRandomSubtracter,y
        bpl AddCCF                  ;if result within top half of screen, skip this part
        eor #$ff
        clc                        ;otherwise get two's compliment
        adc #$01
AddCCF: cmp #$08                   ;if result or two's compliment greater than eight,
        bcs BPGet                  ;skip to the end without changing movement force
        lda Enemy_Y_MoveForce,x
        clc
        adc #$10                   ;otherwise add to it
        sta Enemy_Y_MoveForce,x
BPGet:
        rts                        ;drawing it next frame), then leave

;-------------------------------------------------------------------------------------
;$00 - used to store downward movement force in FireballObjCore
;$02 - used to store maximum vertical speed in FireballObjCore
;$07 - used to store pseudorandom bit in BubbleCheck

.proc ProcFireball_Bubble
  lda PlayerStatus           ;check player's status
  cmp #$02
  bcc ProcAirBubbles         ;if not fiery, branch
  lda A_B_Buttons
  and #B_Button              ;check for b button pressed
  beq ProcFireballs          ;branch if not pressed
  and PreviousA_B_Buttons
  bne ProcFireballs          ;if button pressed in previous frame, branch
  lda FireballCounter        ;load fireball counter
  and #%00000001             ;get LSB and use as offset for buffer
  tax
  lda Fireball_State,x       ;load fireball state
  bne ProcFireballs          ;if not inactive, branch
  ldy Player_Y_HighPos       ;if player too high or too low, branch
  dey
  bne ProcFireballs
  lda CrouchingFlag          ;if player crouching, branch
  bne ProcFireballs
  lda Player_State           ;if player's state = climbing, branch
  cmp #$03
  beq ProcFireballs
  lda #Sfx_Fireball          ;play fireball sound effect
  sta Square1SoundQueue
  lda #$02                   ;load state
  sta Fireball_State,x
  ldy PlayerAnimTimerSet     ;copy animation frame timer setting
  sty FireballThrowingTimer  ;into fireball throwing timer
  dey
  sty PlayerAnimTimer        ;decrement and store in player's animation timer
  inc FireballCounter        ;increment fireball counter

ProcFireballs:
  ldx #$00
  jsr FireballObjCore  ;process first fireball object
  ldx #$01
  jsr FireballObjCore  ;process second fireball object, then do air bubbles

ProcAirBubbles:
  ; lda AreaType                ;if not water type level, skip the rest of this
  ; bne BublExit
  lda SwimmingFlag
  beq NotSwimming
    ldx #$02                    ;otherwise load counter and use as offset
  AirBubbleLoop:
      stx ObjectOffset            ;store offset
      jsr BubbleCheck             ;check timers and coordinates, create air bubble
      ldy Player_Y_HighPos        ;if player's vertical high position
      dey                         ;not within screen, skip all of this
      bne SkipBubble
        ldy #METASPRITE_MISC_BUBBLE
        lda Bubble_Y_Position,x 
        cmp #$f0
        bcc :+
          ; Clear the metasprite if the bubble is offscreen
          ldy #0
        :
        tya
        sta BubbleMetasprite,x
    SkipBubble:
      dex
      bpl AirBubbleLoop                ;do this until all three are handled
  ; Fall through and check if the fireball needs to be cleared because we took damage
  ; rts
NotSwimming:
  lda PlayerStatus           ;check player's status
  cmp #$02
  bcs Exit
    ; Not fiery state anymore, so kill fireball
    lda #0
    sta FireballMetasprite
    sta FireballMetasprite+1
Exit:
  rts                         ;then leave
.endproc

FireballExplosion:
  jsr RelativeFireballPosition
  jmp DrawExplosion_Fireball

.proc FireballObjCore
  stx ObjectOffset             ;store offset as current object
  lda Fireball_State,x         ;check for d7 = 1
  asl
  bcs FireballExplosion        ;if so, branch to get relative coordinates and draw explosion
  ldy Fireball_State,x         ;if fireball inactive, branch to leave
  beq NoFBall
  dey                          ;if fireball state set to 1, skip this part and just run it
  beq RunFB
  lda Player_X_Position        ;get player's horizontal position
  adc #$04                     ;add four pixels and store as fireball's horizontal position
  sta Fireball_X_Position,x
  lda Player_PageLoc           ;get player's page location
  adc #$00                     ;add carry and store as fireball's page location
  sta Fireball_PageLoc,x
  lda Player_Y_Position        ;get player's vertical position and store
  sta Fireball_Y_Position,x
  lda #$01                     ;set high byte of vertical position
  sta Fireball_Y_HighPos,x
  ldy PlayerFacingDir          ;get player's facing direction
  dey                          ;decrement to use as offset here
  lda FireballXSpdData,y       ;set horizontal speed of fireball accordingly
  sta Fireball_X_Speed,x
  lda #$04                     ;set vertical speed of fireball
  sta Fireball_Y_Speed,x
  lda #$07
  sta Fireball_BoundBoxCtrl,x  ;set bounding box size control for fireball
  dec Fireball_State,x         ;decrement state to 1 to skip this part from now on
RunFB:
  txa                          ;add 7 to offset to use
  clc                          ;as fireball offset for next routines
  adc #$07
  tax
  lda #$50                     ;set downward movement force here
  sta R0
  lda #$03                     ;set maximum speed here
  sta R2
  lda #$00
  jsr ImposeGravity            ;do sub here to impose gravity on fireball and move vertically
  jsr MoveObjectHorizontally   ;do another sub to move it horizontally
  ldx ObjectOffset             ;return fireball offset to X
  jsr RelativeFireballPosition ;get relative coordinates
  jsr GetFireballOffscreenBits ;get offscreen information
  jsr GetFireballBoundBox      ;get bounding box coordinates
  jsr FireballBGCollision      ;do fireball to background collision detection
  lda FBall_OffscreenBits      ;get fireball offscreen bits
  and #%11001100               ;mask out certain bits
  bne EraseFB                  ;if any bits still set, branch to kill fireball
  jsr FireballEnemyCollision   ;do fireball to enemy collision detection and deal with collisions
  jmp DrawFireball             ;draw fireball appropriately and leave
EraseFB:
  lda #$00                     ;erase fireball state
  sta Fireball_State,x
  sta FireballMetasprite,x
NoFBall:
  rts                          ;leave

FireballXSpdData:
	.byte $40, $c0
.endproc

BubbleCheck:
  lda PseudoRandomBitReg+1,x  ;get part of LSFR
  and #$01
  sta R7                     ;store pseudorandom bit here
  lda Bubble_Y_Position,x     ;get vertical coordinate for air bubble
  cmp #$f8                    ;if offscreen coordinate not set,
  bne MoveBubl                ;branch to move air bubble
    lda AirBubbleTimer          ;if air bubble timer not expired,
    bne ExitBubl                ;branch to leave, otherwise create new air bubble
SetupBubble:
  ldy #$00                 ;load default value here
  lda PlayerFacingDir      ;get player's facing direction
  lsr                      ;move d0 to carry
  bcc :+              ;branch to use default value if facing left
    ldy #$08                 ;otherwise load alternate value here
: tya                      ;use value loaded as adder
  adc Player_X_Position    ;add to player's horizontal position
  sta Bubble_X_Position,x  ;save as horizontal position for airbubble
  lda Player_PageLoc
  adc #$00                 ;add carry to player's page location
  sta Bubble_PageLoc,x     ;save as page location for airbubble
  lda Player_Y_Position
  clc                      ;add eight pixels to player's vertical position
  adc #$08
  sta Bubble_Y_Position,x  ;save as vertical position for air bubble
  lda #$01
  sta Bubble_Y_HighPos,x   ;set vertical high byte for air bubble
  ldy R7                  ;get pseudorandom bit, use as offset
  lda BubbleTimerData,y    ;get data for air bubble timer
  sta AirBubbleTimer       ;set air bubble timer
MoveBubl:
  ldy R7                  ;get pseudorandom bit again, use as offset
  lda Bubble_YMoveForceFractional,x
  sec                      ;subtract pseudorandom amount from dummy variable
  sbc Bubble_MForceData,y
  sta Bubble_YMoveForceFractional,x   ;save dummy variable
  lda Bubble_Y_Position,x
  sbc #$00                 ;subtract borrow from airbubble's vertical coordinate
  cmp #$20                 ;if below the status bar,
  bcs :+               ;branch to go ahead and use to move air bubble upwards
    lda #$f8                 ;otherwise set offscreen coordinate
: sta Bubble_Y_Position,x  ;store as new vertical coordinate for air bubble
ExitBubl: rts                      ;leave

Bubble_MForceData:
  .byte $ff, $50

BubbleTimerData:
  .byte $40, $20

;------------------------sw-------------------------------------------------------------

.proc GetFireballOffscreenBits
  ldy #$00                 ;set for fireball offsets
  jsr GetProperObjOffset   ;modify X to get proper fireball offset
  ldy #$02                 ;set other offset for fireball's offscreen bits
  jmp GetOffScreenBitsSet  ;and get offscreen information about fireball
.endproc


;-------------------------------------------------------------------------------------
ExplosionTiles:
  .byte METASPRITE_EXPLOSION_FRAME_1
  .byte METASPRITE_EXPLOSION_FRAME_2
  .byte METASPRITE_EXPLOSION_FRAME_3

DrawExplosion_Fireball:
  ; ldy Alt_SprDataOffset,x  ;get OAM data offset of alternate sort for fireball's explosion
  lda Fireball_State,x     ;load fireball state
  inc Fireball_State,x     ;increment state for next frame
  lsr                      ;divide by 2
  and #%00000111           ;mask out all but d3-d1
  cmp #$03                 ;check to see if time to kill fireball
  bcs KillFireBall         ;branch if so, otherwise continue to draw explosion
  ;fallthrough
  tay                         ;use whatever's in A for offset
  lda ExplosionTiles,y        ;get tile number using offset
  sta FireballMetasprite,x
  ; prevent rotation of the fireball from bleeding into the explosion
  lda #0
  sta Fireball_SprAttrib,x
  rts                         ;we are done

KillFireBall:
  lda #$00                    ;clear fireball state to kill it
  sta Fireball_State,x
  sta FireballMetasprite,x
  rts


;-------------------------------------------------------------------------------------
;$01 - enemy buffer offset

.proc FireballEnemyCollision
  lda Fireball_State,x  ;check to see if fireball state is set at all
  beq ExitFBallEnemy    ;branch to leave if not
  asl
  bcs ExitFBallEnemy    ;branch to leave also if d7 in state is set
  lda FrameCounter
  lsr                   ;get LSB of frame counter
  bcs ExitFBallEnemy    ;branch to leave if set (do routine every other frame)
  txa
  asl                   ;multiply fireball offset by four
  asl
  clc
  adc #$1c              ;then add $1c or 28 bytes to it
  tay                   ;to use fireball's bounding box coordinates

  ; Check the extra enemy slot as well since we let enemies spawn there now
  ldx #$05

FireballEnemyCDLoop:
  stx R1                     ;store enemy object offset here
  tya
  pha                         ;push fireball offset to the stack
    lda Enemy_State,x
    and #%00100000              ;check to see if d5 is set in enemy state
    bne NoFToECol               ;if so, skip to next enemy slot
    lda Enemy_Flag,x            ;check to see if buffer flag is set
    beq NoFToECol               ;if not, skip to next enemy slot
    lda Enemy_ID,x              ;check enemy identifier
    cmp #$24
    bcc GoombaDie               ;if < $24, branch to check further
    cmp #$2b
    bcc NoFToECol               ;if in range $24-$2a, skip to next enemy slot
GoombaDie:
  cmp #Goomba                 ;check for goomba identifier
  bne NotGoomba               ;if not found, continue with code
    lda Enemy_State,x           ;otherwise check for defeated state
    cmp #$02                    ;if stomped or otherwise defeated,
    bcs NoFToECol               ;skip to next enemy slot
NotGoomba:
  lda EnemyOffscrBitsMasked,x ;if any masked offscreen bits set,
  bne NoFToECol               ;skip to next enemy slot
    txa
    asl                         ;otherwise multiply enemy offset by four
    asl
    clc
    adc #$04                    ;add 4 bytes to it
    tax                         ;to use enemy's bounding box coordinates
    jsr SprObjectCollisionCore  ;do fireball-to-enemy collision detection
    ldx ObjectOffset            ;return fireball's original offset
    bcc NoFToECol               ;if carry clear, no collision, thus do next enemy slot
      lda #%10000000
      sta Fireball_State,x        ;set d7 in enemy state
      ldx R1                     ;get enemy offset
      jsr HandleEnemyFBallCol     ;jump to handle fireball to enemy collision
NoFToECol:
  pla                         ;pull fireball offset from stack
  tay                         ;put it in Y
  ldx R1                     ;get enemy object offset
  dex                         ;decrement it
  bpl FireballEnemyCDLoop     ;loop back until collision detection done on all enemies

ExitFBallEnemy:
  ldx ObjectOffset                 ;get original fireball offset and leave
  rts
.endproc

;--------------------------------

FirebarSpinSpdData:
      .byte $28, $38, $28, $38, $28

FirebarSpinDirData:
      .byte $00, $00, $10, $10, $00

InitLongFirebar:
      jsr DuplicateEnemyObj       ;create enemy object for long firebar

InitShortFirebar:
      lda #$00                    ;initialize low byte of spin state
      sta FirebarSpinState_Low,x
      lda Enemy_ID,x              ;subtract $1b from enemy identifier
      sec                         ;to get proper offset for firebar data
      sbc #$1b
      tay
      lda FirebarSpinSpdData,y    ;get spinning speed of firebar
      sta FirebarSpinSpeed,x
      lda FirebarSpinDirData,y    ;get spinning direction of firebar
      sta FirebarSpinDirection,x
      lda Enemy_Y_Position,x
      clc                         ;add four pixels to vertical coordinate
      adc #$04
      sta Enemy_Y_Position,x
      lda Enemy_X_Position,x
      clc                         ;add four pixels to horizontal coordinate
      adc #$04
      sta Enemy_X_Position,x
      lda Enemy_PageLoc,x
      adc #$00                    ;add carry to page location
      sta Enemy_PageLoc,x
      jmp TallBBox2               ;set bounding box control (not used) and leave

;--------------------------------

RunFirebarObj:
      jsr ProcFirebar
      jmp OffscreenBoundsCheck

;--------------------------------
;$00 - used as counter for firebar parts
;$01 - used for oscillated high byte of spin state or to hold horizontal adder
;$02 - used for oscillated high byte of spin state or to hold vertical adder
;$03 - used for mirror data
;$04 - used to store player's sprite 1 X coordinate
;$05 - used to evaluate mirror data
;$06 - used to store either screen X coordinate or sprite data offset
;$07 - used to store screen Y coordinate
;$ed - used to hold maximum length of firebar
;$ef - used to hold high byte of spinstate

;horizontal adder is at first byte + high byte of spinstate,
;vertical adder is same + 8 bytes, two's compliment
;if greater than $08 for proper oscillation
FirebarPosLookupTbl:
      .byte $00, $01, $03, $04, $05, $06, $07, $07, $08
      .byte $00, $03, $06, $09, $0b, $0d, $0e, $0f, $10
      .byte $00, $04, $09, $0d, $10, $13, $16, $17, $18
      .byte $00, $06, $0c, $12, $16, $1a, $1d, $1f, $20
      .byte $00, $07, $0f, $16, $1c, $21, $25, $27, $28
      .byte $00, $09, $12, $1b, $21, $27, $2c, $2f, $30
      .byte $00, $0b, $15, $1f, $27, $2e, $33, $37, $38
      .byte $00, $0c, $18, $24, $2d, $35, $3b, $3e, $40
      .byte $00, $0e, $1b, $28, $32, $3b, $42, $46, $48
      .byte $00, $0f, $1f, $2d, $38, $42, $4a, $4e, $50
      .byte $00, $11, $22, $31, $3e, $49, $51, $56, $58

FirebarMirrorData:
      .byte $01, $03, $02, $00

FirebarTblOffsets:
      .byte $00, $09, $12, $1b, $24, $2d
      .byte $36, $3f, $48, $51, $5a, $63

FirebarYPos:
      .byte $0c, $18

;-------------------------------------------------------------------------------------
;$07 - spinning speed

FirebarSpin:
      sta R7                      ;save spinning speed here
      lda FirebarSpinDirection,x  ;check spinning direction
      bne SpinCounterClockwise    ;if moving counter-clockwise, branch to other part
      ; ldy #$18                    ;possibly residual ldy
      lda FirebarSpinState_Low,x
      clc                         ;add spinning speed to what would normally be
      adc R7                      ;the horizontal speed
      sta FirebarSpinState_Low,x
      lda FirebarSpinState_High,x ;add carry to what would normally be the vertical speed
      adc #$00
      rts

SpinCounterClockwise:
      ; ldy #$08                    ;possibly residual ldy
      lda FirebarSpinState_Low,x
      sec                         ;subtract spinning speed to what would normally be
      sbc R7                      ;the horizontal speed
      sta FirebarSpinState_Low,x
      lda FirebarSpinState_High,x ;add carry to what would normally be the vertical speed
      sbc #$00
      rts

ProcFirebar:
          jsr GetEnemyOffscreenBits   ;get offscreen information
          lda Enemy_OffscreenBits     ;check for d3 set
          and #%00001000              ;if so, branch to leave
          jne SkipFBar
          lda TimerControl            ;if master timer control set, branch
          bne SusFbar                 ;ahead of this part
          lda FirebarSpinSpeed,x      ;load spinning speed of firebar
          jsr FirebarSpin             ;modify current spinstate
          and #%00011111              ;mask out all but 5 LSB
          sta FirebarSpinState_High,x ;and store as new high byte of spinstate
SusFbar:  lda FirebarSpinState_High,x ;get high byte of spinstate
          ldy Enemy_ID,x              ;check enemy identifier
          cpy #$1f
          bcc SetupGFB                ;if < $1f (long firebar), branch
          cmp #$08                    ;check high byte of spinstate
          beq SkpFSte                 ;if eight, branch to change
          cmp #$18
          bne SetupGFB                ;if not at twenty-four branch to not change
SkpFSte:  clc
          adc #$01                    ;add one to spinning thing to avoid horizontal state
          sta FirebarSpinState_High,x
SetupGFB: sta Local_ef                     ;save high byte of spinning thing, modified or otherwise
          jsr RelativeEnemyPosition   ;get relative coordinates to screen
      ;     AllocSpr 1
      ReserveSpr 1
      ;     jsr GetFirebarPosition      ;do a sub here (residual, too early to be used now)
      ;     ldy Enemy_SprDataOffset,x   ;get OAM data offset
          lda Enemy_Rel_YPos          ;get relative vertical coordinate
          sta R7                      ;also save here
          sec
          sbc #4
          sta Sprite_Y_Position,y     ;store as Y in OAM data
          lda Enemy_Rel_XPos          ;get relative horizontal coordinate
          sta Sprite_X_Position,y     ;store as X in OAM data
          sta R6                      ;also save here
          lda #$01
          sta R0                      ;set $01 value here (not necessary)
          jsr FirebarCollision        ;draw fireball part and do collision detection
          ldy #$05                    ;load value for short firebars by default
          lda Enemy_ID,x
          cmp #$1f                    ;are we doing a long firebar?
          bcc SetMFbar                ;no, branch then
          ldy #$0b                    ;otherwise load value for long firebars
SetMFbar: sty Local_ed                     ;store maximum value for length of firebars
          lda #$00
          sta R0                      ;initialize counter here
DrawFbar: lda Local_ef                     ;load high byte of spinstate
          jsr GetFirebarPosition      ;get fireball position data depending on firebar part
          jsr DrawFirebar_Collision   ;position it properly, draw it and do collision detection
      ;     lda R0                      ;check which firebar part
      ;     cmp #$04
      ;     bne NextFbar
      ;     lda OriginalOAMOffset
      ;     AllocSpr 6
          
      ;     sty R6
NextFbar: inc R0                      ;move onto the next firebar part
          lda R0 
          cmp Local_ed                     ;if we end up at the maximum part, go on and leave
          bcc DrawFbar                ;otherwise go back and do another
          ldy R6
      UpdateOAMPosition 
SkipFBar: rts

DrawFirebar_Collision:
         lda R3                   ;store mirror data elsewhere
         sta R5           
         ldy R6                   ;load OAM data offset for firebar
         lda R1                   ;load horizontal adder we got from position loader
         lsr R5                   ;shift LSB of mirror data
         bcs AddHA                ;if carry was set, skip this part
         eor #$ff
         adc #$01                 ;otherwise get two's compliment of horizontal adder
AddHA:   clc                      ;add horizontal coordinate relative to screen to
         adc Enemy_Rel_XPos       ;horizontal adder, modified or otherwise
         sta Sprite_X_Position,y  ;store as X coordinate here
         sta R6                   ;store here for now, note offset is saved in Y still
         cmp Enemy_Rel_XPos       ;compare X coordinate of sprite to original X of firebar
         bcs SubtR1               ;if sprite coordinate => original coordinate, branch
         lda Enemy_Rel_XPos
         sec                      ;otherwise subtract sprite X from the
         sbc R6                   ;original one and skip this part
         jmp ChkFOfs
SubtR1:  sec                      ;subtract original X from the
         sbc Enemy_Rel_XPos       ;current sprite X
ChkFOfs: cmp #$59                 ;if difference of coordinates within a certain range,
         bcc VAHandl              ;continue by handling vertical adder
         lda #$f8                 ;otherwise, load offscreen Y coordinate
         bne SetVFbr              ;and unconditionally branch to move sprite offscreen
VAHandl: lda Enemy_Rel_YPos       ;if vertical relative coordinate offscreen,
         cmp #$f8                 ;skip ahead of this part and write into sprite Y coordinate
         beq SetVFbr
         lda R2                   ;load vertical adder we got from position loader
         lsr R5                   ;shift LSB of mirror data one more time
         bcs AddVA                ;if carry was set, skip this part
         eor #$ff
         adc #$01                 ;otherwise get two's compliment of second part
AddVA:   clc                      ;add vertical coordinate relative to screen to 
         adc Enemy_Rel_YPos       ;the second data, modified or otherwise
SetVFbr: 
         sta R7                   ;also store here for now
         sec
         sbc #4                   ; offset the drawn sprite by 4 to account for 8x16 sprite position
         sta Sprite_Y_Position,y  ;store as Y coordinate here

FirebarCollision:
         jsr DrawSingleFireball   ;run sub here to draw current tile of firebar
         tya                      ;return OAM data offset and save
         pha                      ;to the stack for now
         lda StarInvincibleTimer  ;if star mario invincibility timer
         ora TimerControl         ;or master timer controls set
         bne NoColFB              ;then skip all of this
         sta R5                   ;otherwise initialize counter
         ldy Player_Y_HighPos
         dey                      ;if player's vertical high byte offscreen,
         bne NoColFB              ;skip all of this
         ldy Player_Y_Position    ;get player's vertical position
         lda PlayerSize           ;get player's size
         bne AdjSm                ;if player small, branch to alter variables
         lda CrouchingFlag
         beq BigJp                ;if player big and not crouching, jump ahead
AdjSm:   inc R5                   ;if small or big but crouching, execute this part
         inc R5                   ;first increment our counter twice (setting $02 as flag)
         tya
         clc                      ;then add 24 pixels to the player's
         adc #$18                 ;vertical coordinate
         tay
BigJp:   tya                      ;get vertical coordinate, altered or otherwise, from Y
FBCLoop: sec                      ;subtract vertical position of firebar
         sbc R7                   ;from the vertical coordinate of the player
         bpl ChkVFBD              ;if player lower on the screen than firebar, 
         eor #$ff                 ;skip two's compliment part
         clc                      ;otherwise get two's compliment
         adc #$01
ChkVFBD: cmp #$08                 ;if difference => 8 pixels, skip ahead of this part
         bcs Chk2Ofs
         lda R6                   ;if firebar on far right on the screen, skip this,
         cmp #$f0                 ;because, really, what's the point?
         bcs Chk2Ofs
         lda Player_Rel_XPos
         clc
         adc #$04                 ;add four pixels
         sta R4                   ;store here
         sec                      ;subtract horizontal coordinate of firebar
         sbc R6                   ;from the X coordinate of player's sprite 1
         bpl ChkFBCl              ;if modded X coordinate to the right of firebar
         eor #$ff                 ;skip two's compliment part
         clc                      ;otherwise get two's compliment
         adc #$01
ChkFBCl: cmp #$08                 ;if difference < 8 pixels, collision, thus branch
         bcc ChgSDir              ;to process
Chk2Ofs: lda R5                   ;if value of $02 was set earlier for whatever reason,
         cmp #$02                 ;branch to increment OAM offset and leave, no collision
         beq NoColFB
         ldy R5                   ;otherwise get temp here and use as offset
         lda Player_Y_Position
         clc
         adc FirebarYPos,y        ;add value loaded with offset to player's vertical coordinate
         inc R5                   ;then increment temp and jump back
         jmp FBCLoop
ChgSDir: ldx #$01                 ;set movement direction by default
         lda R4                   ;if OAM X coordinate of player's sprite 1
         cmp R6                   ;is greater than horizontal coordinate of firebar
         bcs SetSDir              ;then do not alter movement direction
         inx                      ;otherwise increment it
SetSDir: stx Enemy_MovingDir      ;store movement direction here
         ldx #$00
         lda R0                   ;save value written to $00 to stack
         pha
         jsr InjurePlayer         ;perform sub to hurt or kill player
         pla
         sta R0                   ;get value of $00 from stack
NoColFB: pla                      ;get OAM data offset
         clc                      ;add four to it and save
         adc #$04
         sta R6 
         ldx ObjectOffset         ;get enemy object buffer offset and leave
         rts

GetFirebarPosition:
           pha                        ;save high byte of spinstate to the stack
           and #%00001111             ;mask out low nybble
           cmp #$09
           bcc GetHAdder              ;if lower than $09, branch ahead
           eor #%00001111             ;otherwise get two's compliment to oscillate
           clc
           adc #$01
GetHAdder: sta R1                     ;store result, modified or not, here
           ldy R0                     ;load number of firebar ball where we're at
           lda FirebarTblOffsets,y    ;load offset to firebar position data
           clc
           adc R1                     ;add oscillated high byte of spinstate
           tay                        ;to offset here and use as new offset
           lda FirebarPosLookupTbl,y  ;get data here and store as horizontal adder
           sta R1 
           pla                        ;pull whatever was in A from the stack
           pha                        ;save it again because we still need it
           clc
           adc #$08                   ;add eight this time, to get vertical adder
           and #%00001111             ;mask out high nybble
           cmp #$09                   ;if lower than $09, branch ahead
           bcc GetVAdder
           eor #%00001111             ;otherwise get two's compliment
           clc
           adc #$01
GetVAdder: sta R2                     ;store result here
           ldy R0 
           lda FirebarTblOffsets,y    ;load offset to firebar position data again
           clc
           adc R2                     ;this time add value in $02 to offset here and use as offset
           tay
           lda FirebarPosLookupTbl,y  ;get data here and store as vertica adder
           sta R2 
           pla                        ;pull out whatever was in A one last time
           lsr                        ;divide by eight or shift three to the right
           lsr
           lsr
           tay                        ;use as offset
           lda FirebarMirrorData,y    ;load mirroring data here
           sta R3                     ;store
           rts

;--------------------------------

RunFireworks:
  dec ExplosionTimerCounter,x ;decrement explosion timing counter here
  bne SetupExpl               ;if not expired, skip this part
    lda #$08
    sta ExplosionTimerCounter,x ;reset counter
    inc ExplosionGfxCounter,x   ;increment explosion graphics counter
    lda ExplosionGfxCounter,x
    cmp #$03                    ;check explosion graphics counter
    bcs FireworksSoundScore     ;if at a certain point, branch to kill this object
SetupExpl:
  ; jsr RelativeEnemyPosition   ;get relative coordinates of explosion
  ; lda Enemy_Rel_YPos          ;copy relative coordinates
  ; sta Fireball_Rel_YPos       ;from the enemy object to the fireball object
  ; lda Enemy_Rel_XPos          ;first vertical, then horizontal
  ; sta Fireball_Rel_XPos
;      ldy Enemy_SprDataOffset,x   ;get OAM data offset
  ; AllocSpr 4
  ldy ExplosionGfxCounter,x   ;get explosion graphics counter
  lda ExplosionTiles,y        ;get tile number using offset
  sta EnemyMetasprite,x
  ; prevent rotation of the fireball from bleeding into the explosion
  lda #0
  sta Enemy_SprAttrib,x
  rts
  ; jmp DrawExplosion_Fireworks ;do a sub to draw the explosion then leave
FireworksSoundScore:
  lda #$00               ;disable enemy buffer flag
  sta Enemy_Flag,x
  sta EnemyMetasprite,x
  lda #Sfx_Blast         ;play fireworks/gunfire sound
  sta Square2SoundQueue
  lda #$05               ;set part of score modifier for 500 points
  sta DigitModifier+PlayerScoreLastIndex-1
  jmp EndAreaPoints     ;jump to award points accordingly then leave

;--------------------------------

; StarFlagYPosAdder:
;   .byte $00, $00, $08, $08

; StarFlagXPosAdder:
;   .byte $00, $08, $00, $08

; StarFlagTileData:
;   .byte STAR_FLAG_TOP_LEFT, STAR_FLAG_TOP_RIGHT, STAR_FLAG_BOT_LEFT, STAR_FLAG_BOT_RIGHT

RunStarFlagObj:
      lda #$00                 ;initialize enemy frenzy buffer
      sta EnemyFrenzyBuffer
      lda StarFlagTaskControl  ;check star flag object task number here
      cmp #$05                 ;if greater than 5, branch to exit
      bcs StarFlagExit
      jsr JumpEngine           ;otherwise jump to appropriate sub
      
      .word StarFlagExit
      .word GameTimerFireworks
      .word AwardGameTimerPoints
      .word RaiseFlagSetoffFWorks
      .word DelayToAreaEnd

GameTimerFireworks:
        ldy #$05               ;set default state for star flag object
        lda GameTimerDisplay+2 ;get game timer's last digit
        cmp #$01
        beq SetFWC             ;if last digit of game timer set to 1, skip ahead
        ldy #$03               ;otherwise load new value for state
        cmp #$03
        beq SetFWC             ;if last digit of game timer set to 3, skip ahead
        ldy #$00               ;otherwise load one more potential value for state
        cmp #$06
        beq SetFWC             ;if last digit of game timer set to 6, skip ahead
        lda #$ff               ;otherwise set value for no fireworks
SetFWC: sta FireworksCounter   ;set fireworks counter here
        sty Enemy_State,x      ;set whatever state we have in star flag object

IncrementSFTask1:
      inc StarFlagTaskControl  ;increment star flag object task number

StarFlagExit:
      rts                      ;leave

AwardGameTimerPoints:
         lda GameTimerDisplay   ;check all game timer digits for any intervals left
         ora GameTimerDisplay+1
         ora GameTimerDisplay+2
         beq IncrementSFTask1   ;if no time left on game timer at all, branch to next task
         lda FrameCounter
         and #%00000100         ;check frame counter for d2 set (skip ahead
         beq NoTTick            ;for four frames every four frames) branch if not set
         lda #Sfx_TimerTick
         sta Square2SoundQueue  ;load timer tick sound
         ; set offset here to subtract from game timer's last digit
NoTTick: ldy #(GameTimerDisplay + GameTimerLastIndex - DisplayDigits)
         lda #$ff               ;set adder here to $ff, or -1, to subtract one
         sta DigitModifier+GameTimerLastIndex    ;from the last digit of the game timer
         ldx #GameTimerLastIndex
         jsr DigitsMathRoutine  ;subtract digit
         lda #$05               ;set now to add 50 points
         sta DigitModifier+PlayerScoreLastIndex    ;per game timer interval subtracted
EndAreaPoints:
         ; load offset for mario's score by default
         ldy #(Player1ScoreDisplay + PlayerScoreLastIndex - DisplayDigits)
         lda CurrentPlayer      ;check player on the screen
         beq ELPGive            ;if mario, do not change
         ; otherwise load offset for luigi's score
         ldy #(Player1ScoreDisplay + PlayerScoreLastIndex - DisplayDigits)
ELPGive: ldx #PlayerScoreLastIndex
         jsr DigitsMathRoutine  ;award 50 points per game timer interval
         lda CurrentPlayer      ;get player on the screen (or 500 points per
         asl                    ;fireworks explosion if branched here from there)
         asl                    ;shift to high nybble
         asl
         asl
         ora #%00000100         ;add four to set nybble for game timer
         farcall UpdateNumber, jmp ;jump to print the new score and game timer

RaiseFlagSetoffFWorks:
         lda Enemy_Y_Position,x  ;check star flag's vertical position
         cmp #$72                ;against preset value
         bcc SetoffF             ;if star flag higher vertically, branch to other code
         dec Enemy_Y_Position,x  ;otherwise, raise star flag by one pixel
         jmp DrawStarFlag        ;and skip this part here
SetoffF: lda FireworksCounter    ;check fireworks counter
         beq DrawFlagSetTimer    ;if no fireworks left to go off, skip this part
         bmi DrawFlagSetTimer    ;if no fireworks set to go off, skip this part
         lda #Fireworks
         sta EnemyFrenzyBuffer   ;otherwise set fireworks object in frenzy queue

DrawStarFlag:
;   jsr RelativeEnemyPosition  ;get relative coordinates of star flag
;   ReserveSpr 4
;   ldx #$03                   ;do four sprites
; DSFLoop:
;     lda Enemy_Rel_YPos         ;get relative vertical coordinate
;     clc
;     adc StarFlagYPosAdder,x    ;add Y coordinate adder data
;     sta Sprite_Y_Position,y    ;store as Y coordinate
;     lda StarFlagTileData,x     ;get tile number
;     sta Sprite_Tilenumber,y    ;store as tile number
;     lda #$22                   ;set palette and background priority bits
;     sta Sprite_Attributes,y    ;store as attributes
;     lda Enemy_Rel_XPos         ;get relative horizontal coordinate
;     clc
;     adc StarFlagXPosAdder,x    ;add X coordinate adder data
;     sta Sprite_X_Position,y    ;store as X coordinate
;     iny
;     iny                        ;increment OAM data offset four bytes
;     iny                        ;for next sprite
;     iny
;     dex                        ;move onto next sprite
;     bpl DSFLoop                ;do this until all sprites are done
;   UpdateOAMPosition
;   ldx ObjectOffset           ;get enemy object offset and leave
  lda #METASPRITE_MISC_STAR_FLAG
  sta EnemyMetasprite,x
  lda #OAM_BACKGROUND_PRIORTY
  sta Enemy_SprAttrib,x
  lda #1
  sta Enemy_MovingDir,x
  rts

DrawFlagSetTimer:
  jsr DrawStarFlag          ;do sub to draw star flag
  lda #$06
  sta EnemyIntervalTimer,x  ;set interval timer here

IncrementSFTask2:
  inc StarFlagTaskControl   ;move onto next task
  rts

DelayToAreaEnd:
  jsr DrawStarFlag          ;do sub to draw star flag
  lda EnemyIntervalTimer,x  ;if interval timer set in previous task
  bne StarFlagExit2         ;not yet expired, branch to leave
  lda EventMusicBuffer      ;if event music buffer empty,
  beq IncrementSFTask2      ;branch to increment task

StarFlagExit2:
  rts                       ;otherwise leave


;-------------------------------------------------------------------------------------

JumpspringHandler:
	farcall JumpspringHandlerBanked, jmp

.pushseg
.segment "MORE_OBJECT"

Jumpspring_Y_PosData:
      .byte $08, $10, $08, $00
	



.proc DrawJumpSpring
  ldy JumpspringAnimCtrl
  lda JumpspringFrameOffsets,y
  sta EnemyMetasprite,x 
  rts

JumpspringFrameOffsets:
  .byte METASPRITE_JUMPSPRING_FRAME_1
  .byte METASPRITE_JUMPSPRING_FRAME_2
  .byte METASPRITE_JUMPSPRING_FRAME_3
  .byte METASPRITE_JUMPSPRING_FRAME_2
  .byte METASPRITE_JUMPSPRING_FRAME_1
.endproc

.popseg

;--------------------------------

InitPiranhaPlant:
      lda #$01                     ;set initial speed
      sta PiranhaPlant_Y_Speed,x
      lsr
      sta Enemy_State,x            ;initialize enemy state and what would normally
      sta PiranhaPlant_MoveFlag,x  ;be used as vertical speed, but not in this case
      lda Enemy_Y_Position,x
      sta PiranhaPlantDownYPos,x   ;save original vertical coordinate here
      sec
      sbc #$18
      sta PiranhaPlantUpYPos,x     ;save original vertical coordinate - 24 pixels here
      lda #$09
      jmp SetBBox2                 ;set specific value for bounding box control

;--------------------------------
;$00 - used to store horizontal difference between player and piranha plant

MovePiranhaPlant:
      lda Enemy_State,x           ;check enemy state
      bne Exit               ;if set at all, branch to leave
      lda EnemyFrameTimer,x       ;check enemy's timer here
      bne Exit               ;branch to end if not yet expired
      lda PiranhaPlant_MoveFlag,x ;check movement flag
      bne SetupToMovePPlant       ;if moving, skip to part ahead
      lda PiranhaPlant_Y_Speed,x  ;if currently rising, branch 
      bmi ReversePlantSpeed       ;to move enemy upwards out of pipe
      jsr PlayerEnemyDiff         ;get horizontal difference between player and
      bpl ChkPlayerNearPipe       ;piranha plant, and branch if enemy to right of player
      lda R0                      ;otherwise get saved horizontal difference
      eor #$ff
      clc                         ;and change to two's compliment
      adc #$01
      sta R0                      ;save as new horizontal difference

ChkPlayerNearPipe:
      lda R0                      ;get saved horizontal difference
      cmp #$21
      bcc Exit               ;if player within a certain distance, branch to leave

ReversePlantSpeed:
      lda PiranhaPlant_Y_Speed,x  ;get vertical speed
      eor #$ff
      clc                         ;change to two's compliment
      adc #$01
      sta PiranhaPlant_Y_Speed,x  ;save as new vertical speed
      inc PiranhaPlant_MoveFlag,x ;increment to set movement flag

SetupToMovePPlant:
      lda PiranhaPlantDownYPos,x  ;get original vertical coordinate (lowest point)
      ldy PiranhaPlant_Y_Speed,x  ;get vertical speed
      bpl RiseFallPiranhaPlant    ;branch if moving downwards
      lda PiranhaPlantUpYPos,x    ;otherwise get other vertical coordinate (highest point)

RiseFallPiranhaPlant:
      sta R0                      ;save vertical coordinate here
      lda FrameCounter            ;get frame counter
      lsr
      bcc Exit               ;branch to leave if d0 set (execute code every other frame)
      lda TimerControl            ;get master timer control
      bne Exit               ;branch to leave if set (likely not necessary)
      lda Enemy_Y_Position,x      ;get current vertical coordinate
      clc
      adc PiranhaPlant_Y_Speed,x  ;add vertical speed to move up or down
      sta Enemy_Y_Position,x      ;save as new vertical coordinate
      cmp R0                      ;compare against low or high coordinate
      bne Exit               ;branch to leave if not yet reached
      lda #$00
      sta PiranhaPlant_MoveFlag,x ;otherwise clear movement flag
      lda #$40
      sta EnemyFrameTimer,x       ;set timer to delay piranha plant movement

Exit:
      rts                         ;then leave

;--------------------------------

InitBalPlatform:
        dec Enemy_Y_Position,x    ;raise vertical position by two pixels
        dec Enemy_Y_Position,x
        ldy SecondaryHardMode     ;if secondary hard mode flag not set,
        bne AlignP                ;branch ahead
        ldy #$02                  ;otherwise set value here
        jsr PosPlatform           ;do a sub to add or subtract pixels
AlignP: ldy #$ff                  ;set default value here for now
        lda BalPlatformAlignment  ;get current balance platform alignment
        sta Enemy_State,x         ;set platform alignment to object state here
        bpl SetBPA                ;if old alignment $ff, put $ff as alignment for negative
        txa                       ;if old contents already $ff, put
        tay                       ;object offset as alignment to make next positive
SetBPA: sty BalPlatformAlignment  ;store whatever value's in Y here
        lda #$00
        sta Enemy_MovingDir,x     ;init moving direction
        tay                       ;init Y
        jsr PosPlatform           ;do a sub to add 8 pixels, then run shared code here

;--------------------------------

InitDropPlatform:
      lda #$ff
      sta PlatformCollisionFlag,x  ;set some value here
      jmp CommonPlatCode           ;then jump ahead to execute more code

;--------------------------------

InitHoriPlatform:
      lda #$00
      sta XMoveSecondaryCounter,x  ;init one of the moving counters
      jmp CommonPlatCode           ;jump ahead to execute more code

;--------------------------------

InitVertPlatform:
       ldy #$40                    ;set default value here
       lda Enemy_Y_Position,x      ;check vertical position
       bpl SetYO                   ;if above a certain point, skip this part
       eor #$ff
       clc                         ;otherwise get two's compliment
       adc #$01
       ldy #$c0                    ;get alternate value to add to vertical position
SetYO: sta YPlatformTopYPos,x      ;save as top vertical position
       tya
       clc                         ;load value from earlier, add number of pixels 
       adc Enemy_Y_Position,x      ;to vertical position
       sta YPlatformCenterYPos,x   ;save result as central vertical position

;--------------------------------

CommonPlatCode: 
        jsr InitVStf              ;do a sub to init certain other values 
SPBBox: lda #$05                  ;set default bounding box size control
        ldy AreaType
        cpy #$03                  ;check for castle-type level
        beq CasPBB                ;use default value if found
        ldy SecondaryHardMode     ;otherwise check for secondary hard mode flag
        bne CasPBB                ;if set, use default value
        lda #$06                  ;use alternate value if not castle or secondary not set
CasPBB: sta Enemy_BoundBoxCtrl,x  ;set bounding box size control here and leave
        rts

;--------------------------------

LargeLiftUp:
      jsr PlatLiftUp       ;execute code for platforms going up
      jmp LargeLiftBBox    ;overwrite bounding box for large platforms

LargeLiftDown:
      jsr PlatLiftDown     ;execute code for platforms going down

LargeLiftBBox:
      jmp SPBBox           ;jump to overwrite bounding box size control

;--------------------------------

PlatLiftUp:
      lda #$10                 ;set movement amount here
      sta Enemy_Y_MoveForce,x
      lda #$ff                 ;set moving speed for platforms going up
      sta Enemy_Y_Speed,x
      jmp CommonSmallLift      ;skip ahead to part we should be executing

;--------------------------------

PlatLiftDown:
      lda #$f0                 ;set movement amount here
      sta Enemy_Y_MoveForce,x
      lda #$00                 ;set moving speed for platforms going down
      sta Enemy_Y_Speed,x

;--------------------------------

CommonSmallLift:
      ldy #$01
      jsr PosPlatform           ;do a sub to add 12 pixels due to preset value  
      lda #$04
      sta Enemy_BoundBoxCtrl,x  ;set bounding box control for small platforms
      rts

;--------------------------------

PlatPosDataLow:
      .byte $08,$0c,$f8

PlatPosDataHigh:
      .byte $00,$00,$ff

PosPlatform:
      lda Enemy_X_Position,x  ;get horizontal coordinate
      clc
      adc PlatPosDataLow,y    ;add or subtract pixels depending on offset
      sta Enemy_X_Position,x  ;store as new horizontal coordinate
      lda Enemy_PageLoc,x
      adc PlatPosDataHigh,y   ;add or subtract page location depending on offset
      sta Enemy_PageLoc,x     ;store as new page location
      rts                     ;and go back

;--------------------------------

RunSmallPlatform:
      jsr GetEnemyOffscreenBits
      jsr RelativeEnemyPosition
      jsr SmallPlatformBoundBox
      jsr SmallPlatformCollision
      jsr RelativeEnemyPosition
      jsr DrawSmallPlatform
      jsr MoveSmallPlatform
      jmp OffscreenBoundsCheck


;--------------------------------

RunLargePlatform:
        jsr GetEnemyOffscreenBits
        jsr RelativeEnemyPosition
        jsr LargePlatformBoundBox
        jsr LargePlatformCollision
        lda TimerControl             ;if master timer control set,
        bne SkipPT                   ;skip subroutine tree
        jsr LargePlatformSubroutines
SkipPT: jsr RelativeEnemyPosition
        jsr DrawLargePlatform
        jmp OffscreenBoundsCheck

;-------------------------------------------------------------------------------------
;$00 - vertical position of platform

LargePlatformCollision:
       lda #$ff                     ;save value here
       sta PlatformCollisionFlag,x
       lda TimerControl             ;check master timer control
       bne ExLPC                    ;if set, branch to leave
       lda Enemy_State,x            ;if d7 set in object state,
       bmi ExLPC                    ;branch to leave
       lda Enemy_ID,x
       cmp #$24                     ;check enemy object identifier for
       bne ChkForPlayerC_LargeP     ;balance platform, branch if not found
       lda Enemy_State,x
       tax                          ;set state as enemy offset here
       jsr ChkForPlayerC_LargeP     ;perform code with state offset, then original offset, in X

ChkForPlayerC_LargeP:
       jsr CheckPlayerVertical      ;figure out if player is below a certain point
       bcs ExLPC                    ;or offscreen, branch to leave if true
       txa
       jsr GetEnemyBoundBoxOfsArg   ;get bounding box offset in Y
       lda Enemy_Y_Position,x       ;store vertical coordinate in
       sta R0                       ;temp variable for now
       txa                          ;send offset we're on to the stack
       pha
       jsr PlayerCollisionCore      ;do player-to-platform collision detection
       pla                          ;retrieve offset from the stack
       tax
       bcc ExLPC                    ;if no collision, branch to leave
       jsr ProcLPlatCollisions      ;otherwise collision, perform sub
ExLPC: ldx ObjectOffset             ;get enemy object buffer offset and leave
       rts


;--------------------------------

LargePlatformSubroutines:
      lda Enemy_ID,x  ;subtract $24 to get proper offset for jump table
      sec
      sbc #$24
      jsr JumpEngine

      .word BalancePlatform   ;table used by objects $24-$2a
      .word YMovingPlatform
      .word MoveLargeLiftPlat
      .word MoveLargeLiftPlat
      .word XMovingPlatform
      .word DropPlatform
      .word RightPlatform

;-------------------------------------------------------------------------------------
;$00 - used to hold collision flag, Y movement force + 5 or low byte of name table for rope
;$01 - used to hold high byte of name table for rope
;$02 - used to hold page location of rope

BalancePlatform:
       lda Enemy_Y_HighPos,x       ;check high byte of vertical position
       cmp #$03
       bne DoBPl
       jmp EraseEnemyObject        ;if far below screen, kill the object
DoBPl: lda Enemy_State,x           ;get object's state (set to $ff or other platform offset)
       bpl CheckBalPlatform        ;if doing other balance platform, branch to leave
       rts

CheckBalPlatform:
       tay                         ;save offset from state as Y
       lda PlatformCollisionFlag,x ;get collision flag of platform
       sta R0                      ;store here
       lda Enemy_MovingDir,x       ;get moving direction
       beq ChkForFall
       jmp PlatformFall            ;if set, jump here

ChkForFall:
       lda #$2d                    ;check if platform is above a certain point
       cmp Enemy_Y_Position,x
       bcc ChkOtherForFall         ;if not, branch elsewhere
       cpy R0                      ;if collision flag is set to same value as
       beq MakePlatformFall        ;enemy state, branch to make platforms fall
       clc
       adc #$02                    ;otherwise add 2 pixels to vertical position
       sta Enemy_Y_Position,x      ;of current platform and branch elsewhere
       jmp StopPlatforms           ;to make platforms stop

MakePlatformFall:
       jmp InitPlatformFall        ;make platforms fall

ChkOtherForFall:
       cmp Enemy_Y_Position,y      ;check if other platform is above a certain point
       bcc ChkToMoveBalPlat        ;if not, branch elsewhere
       cpx R0                      ;if collision flag is set to same value as
       beq MakePlatformFall        ;enemy state, branch to make platforms fall
       clc
       adc #$02                    ;otherwise add 2 pixels to vertical position
       sta Enemy_Y_Position,y      ;of other platform and branch elsewhere
       jmp StopPlatforms           ;jump to stop movement and do not return

ChkToMoveBalPlat:
        lda Enemy_Y_Position,x      ;save vertical position to stack
        pha
        lda PlatformCollisionFlag,x ;get collision flag
        bpl ColFlg                  ;branch if collision
        lda Enemy_Y_MoveForce,x
        clc                         ;add $05 to contents of moveforce, whatever they be
        adc #$05
        sta R0                      ;store here
        lda Enemy_Y_Speed,x
        adc #$00                    ;add carry to vertical speed
        bmi PlatDn                  ;branch if moving downwards
        bne PlatUp                  ;branch elsewhere if moving upwards
        lda R0 
        cmp #$0b                    ;check if there's still a little force left
        bcc PlatSt                  ;if not enough, branch to stop movement
        bcs PlatUp                  ;otherwise keep branch to move upwards
ColFlg: cmp ObjectOffset            ;if collision flag matches
        beq PlatDn                  ;current enemy object offset, branch
PlatUp: jsr MovePlatformUp          ;do a sub to move upwards
        jmp DoOtherPlatform         ;jump ahead to remaining code
PlatSt: jsr StopPlatforms           ;do a sub to stop movement
        jmp DoOtherPlatform         ;jump ahead to remaining code
PlatDn: jsr MovePlatformDown        ;do a sub to move downwards

DoOtherPlatform:
       ldy Enemy_State,x           ;get offset of other platform
       pla                         ;get old vertical coordinate from stack
       sec
       sbc Enemy_Y_Position,x      ;get difference of old vs. new coordinate
       clc
       adc Enemy_Y_Position,y      ;add difference to vertical coordinate of other
       sta Enemy_Y_Position,y      ;platform to move it in the opposite direction
       lda PlatformCollisionFlag,x ;if no collision, skip this part here
       bmi DrawEraseRope
       tax                         ;put offset which collision occurred here
       jsr PositionPlayerOnVPlat   ;and use it to position player accordingly

DrawEraseRope:
         ldy ObjectOffset            ;get enemy object offset
         lda Enemy_Y_Speed,y         ;check to see if current platform is
         ora Enemy_Y_MoveForce,y     ;moving at all
         beq ExitRp                  ;if not, skip all of this and branch to leave
         ldx VRAM_Buffer1_Offset     ;get vram buffer offset
         cpx #$20                    ;if offset beyond a certain point, go ahead
         bcs ExitRp                  ;and skip this, branch to leave
         lda Enemy_Y_Speed,y
         pha                         ;save two copies of vertical speed to stack
         pha
         jsr SetupPlatformRope       ;do a sub to figure out where to put new bg tiles
         lda R1                      ;write name table address to vram buffer
         sta VRAM_Buffer1,x          ;first the high byte, then the low
         lda R0 
         sta VRAM_Buffer1+1,x
         lda #$02                    ;set length for 2 bytes
         sta VRAM_Buffer1+2,x
         lda Enemy_Y_Speed,y         ;if platform moving upwards, branch 
         bmi EraseR1                 ;to do something else
         lda #BALANCE_PLATFORM_ROPE_1
         sta VRAM_Buffer1+3,x        ;otherwise put tile numbers for left
         lda #BALANCE_PLATFORM_ROPE_2 ;and right sides of rope in vram buffer
         sta VRAM_Buffer1+4,x
         jmp OtherRope               ;jump to skip this part
EraseR1: lda #$24                    ;put blank tiles in vram buffer
         sta VRAM_Buffer1+3,x        ;to erase rope
         sta VRAM_Buffer1+4,x

OtherRope:
         lda Enemy_State,y           ;get offset of other platform from state
         tay                         ;use as Y here
         pla                         ;pull second copy of vertical speed from stack
         eor #$ff                    ;invert bits to reverse speed
         jsr SetupPlatformRope       ;do sub again to figure out where to put bg tiles  
         lda R1                      ;write name table address to vram buffer
         sta VRAM_Buffer1+5,x        ;this time we're doing putting tiles for
         lda R0                      ;the other platform
         sta VRAM_Buffer1+6,x
         lda #$02
         sta VRAM_Buffer1+7,x        ;set length again for 2 bytes
         pla                         ;pull first copy of vertical speed from stack
         bpl EraseR2                 ;if moving upwards (note inversion earlier), skip this
         lda #BALANCE_PLATFORM_ROPE_1
         sta VRAM_Buffer1+8,x        ;otherwise put tile numbers for left
         lda #BALANCE_PLATFORM_ROPE_2 ;and right sides of rope in vram
         sta VRAM_Buffer1+9,x        ;transfer buffer
         jmp EndRp                   ;jump to skip this part
EraseR2: lda #$24                    ;put blank tiles in vram buffer
         sta VRAM_Buffer1+8,x        ;to erase rope
         sta VRAM_Buffer1+9,x
EndRp:   lda #$00                    ;put null terminator at the end
         sta VRAM_Buffer1+10,x
         lda VRAM_Buffer1_Offset     ;add ten bytes to the vram buffer offset
         clc                         ;and store
         adc #10
         sta VRAM_Buffer1_Offset
ExitRp:  ldx ObjectOffset            ;get enemy object buffer offset and leave
         rts

SetupPlatformRope:
        pha                     ;save second/third copy to stack
        lda Enemy_X_Position,y  ;get horizontal coordinate
        clc
        adc #$08                ;add eight pixels
        ldx SecondaryHardMode   ;if secondary hard mode flag set,
        bne GetLRp              ;use coordinate as-is
        clc
        adc #$10                ;otherwise add sixteen more pixels
GetLRp: pha                     ;save modified horizontal coordinate to stack
        lda Enemy_PageLoc,y
        adc #$00                ;add carry to page location
        sta R2                  ;and save here
        pla                     ;pull modified horizontal coordinate
        and #%11110000          ;from the stack, mask out low nybble
        lsr                     ;and shift three bits to the right
        lsr
        lsr
        sta R0                  ;store result here as part of name table low byte
        ldx Enemy_Y_Position,y  ;get vertical coordinate
        pla                     ;get second/third copy of vertical speed from stack
        bpl GetHRp              ;skip this part if moving downwards or not at all
        txa
        clc
        adc #$08                ;add eight to vertical coordinate and
        tax                     ;save as X
GetHRp: txa                     ;move vertical coordinate to A
        ldx VRAM_Buffer1_Offset ;get vram buffer offset
        asl
        rol                     ;rotate d7 to d0 and d6 into carry
        pha                     ;save modified vertical coordinate to stack
        rol                     ;rotate carry to d0, thus d7 and d6 are at 2 LSB
        and #%00000011          ;mask out all bits but d7 and d6, then set
        ora #%00100000          ;d5 to get appropriate high byte of name table
        sta R1                  ;address, then store
        lda R2                  ;get saved page location from earlier
        and #$01                ;mask out all but LSB
        asl
        asl                     ;shift twice to the left and save with the
        ora R1                  ;rest of the bits of the high byte, to get
        sta R1                  ;the proper name table and the right place on it
        pla                     ;get modified vertical coordinate from stack
        and #%11100000          ;mask out low nybble and LSB of high nybble
        clc
        adc R0                  ;add to horizontal part saved here
        sta R0                  ;save as name table low byte
        lda Enemy_Y_Position,y
        cmp #$e8                ;if vertical position not below the
        bcc ExPRp               ;bottom of the screen, we're done, branch to leave
        lda R0 
        and #%10111111          ;mask out d6 of low byte of name table address
        sta R0 
ExPRp:  rts                     ;leave!

InitPlatformFall:
      tya                        ;move offset of other platform from Y to X
      tax
      jsr GetEnemyOffscreenBits  ;get offscreen bits
      lda #$06
      jsr SetupFloateyNumber     ;award 1000 points to player
      lda Player_Rel_XPos
      sta FloateyNum_X_Pos,x     ;put floatey number coordinates where player is
      lda Player_Y_Position
      sta FloateyNum_Y_Pos,x
      lda #$01                   ;set moving direction as flag for
      sta Enemy_MovingDir,x      ;falling platforms

StopPlatforms:
      jsr InitVStf             ;initialize vertical speed and low byte
      sta Enemy_Y_Speed,y      ;for both platforms and leave
      sta Enemy_Y_MoveForce,y
      rts

PlatformFall:
      tya                         ;save offset for other platform to stack
      pha
      jsr MoveFallingPlatform     ;make current platform fall
      pla
      tax                         ;pull offset from stack and save to X
      jsr MoveFallingPlatform     ;make other platform fall
      ldx ObjectOffset
      lda PlatformCollisionFlag,x ;if player not standing on either platform,
      bmi ExPF                    ;skip this part
      tax                         ;transfer collision flag offset as offset to X
      jsr PositionPlayerOnVPlat   ;and position player appropriately
ExPF: ldx ObjectOffset            ;get enemy object buffer offset and leave
      rts



;--------------------------------

YMovingPlatform:
        lda Enemy_Y_Speed,x          ;if platform moving up or down, skip ahead to
        ora Enemy_Y_MoveForce,x      ;check on other position
        bne ChkYCenterPos
        sta Enemy_YMoveForceFractional,x        ;initialize dummy variable
        lda Enemy_Y_Position,x
        cmp YPlatformTopYPos,x       ;if current vertical position => top position, branch
        bcs ChkYCenterPos            ;ahead of all this
        lda FrameCounter
        and #%00000111               ;check for every eighth frame
        bne SkipIY
        inc Enemy_Y_Position,x       ;increase vertical position every eighth frame
SkipIY: jmp ChkYPCollision           ;skip ahead to last part

ChkYCenterPos:
        lda Enemy_Y_Position,x       ;if current vertical position < central position, branch
        cmp YPlatformCenterYPos,x    ;to slow ascent/move downwards
        bcc YMDown
        jsr MovePlatformUp           ;otherwise start slowing descent/moving upwards
        jmp ChkYPCollision
YMDown: jsr MovePlatformDown         ;start slowing ascent/moving downwards

ChkYPCollision:
       lda PlatformCollisionFlag,x  ;if collision flag not set here, branch
       bmi ExYPl                    ;to leave
       jmp PositionPlayerOnVPlat    ;otherwise position player appropriately
ExYPl: rts ; TODO check this RTS can be removed                          ;leave

;--------------------------------
;$00 - used as adder to position player hotizontally

XMovingPlatform:
      lda #$0e                     ;load preset maximum value for secondary counter
      jsr XMoveCntr_Platform       ;do a sub to increment counters for movement
      jsr MoveWithXMCntrs          ;do a sub to move platform accordingly, and return value
      lda PlatformCollisionFlag,x  ;if no collision with player,
      bmi ExXMP                    ;branch ahead to leave

PositionPlayerOnHPlat:
         lda Player_X_Position
         clc                       ;add saved value from second subroutine to
         adc R0                    ;current player's position to position
         sta Player_X_Position     ;player accordingly in horizontal position
         lda Player_PageLoc        ;get player's page location
         ldy R0                    ;check to see if saved value here is positive or negative
         bmi PPHSubt               ;if negative, branch to subtract
         adc #$00                  ;otherwise add carry to page location
         jmp SetPVar               ;jump to skip subtraction
PPHSubt: sbc #$00                  ;subtract borrow from page location
SetPVar: sta Player_PageLoc        ;save result to player's page location
         sty Platform_X_Scroll     ;put saved value from second sub here to be used later
         jmp PositionPlayerOnVPlat ;position player vertically and appropriately
ExXMP:   rts ; TODO check this RTS can be removed                       ;and we are done here

;--------------------------------

DropPlatform:
       lda PlatformCollisionFlag,x  ;if no collision between platform and player
       bmi ExDPl                    ;occurred, just leave without moving anything
       jsr MoveDropPlatform         ;otherwise do a sub to move platform down very quickly
       jmp PositionPlayerOnVPlat    ;do a sub to position player appropriately
ExDPl: rts ; TODO check this RTS can be removed                          ;leave

;--------------------------------
;$00 - residual value from sub

RightPlatform:
       jsr MoveEnemyHorizontally     ;move platform with current horizontal speed, if any
       sta R0                        ;store saved value here (residual code)
       lda PlatformCollisionFlag,x   ;check collision flag, if no collision between player
       bmi ExRPl                     ;and platform, branch ahead, leave speed unaltered
       lda #$10
       sta Enemy_X_Speed,x           ;otherwise set new speed (gets moving if motionless)
       jmp PositionPlayerOnHPlat     ;use saved value from earlier sub to position player
ExRPl: rts ; TODO check this RTS can be removed                           ;then leave

;--------------------------------

MoveLargeLiftPlat:
      jsr MoveLiftPlatforms  ;execute common to all large and small lift platforms
      jmp ChkYPCollision     ;branch to position player correctly

MoveSmallPlatform:
      jsr MoveLiftPlatforms      ;execute common to all large and small lift platforms
      jmp ChkSmallPlatCollision  ;branch to position player correctly

MoveLiftPlatforms:
      lda TimerControl         ;if master timer control set, skip all of this
      bne ExLiftP              ;and branch to leave
      lda Enemy_YMoveForceFractional,x
      clc                      ;add contents of movement amount to whatever's here
      adc Enemy_Y_MoveForce,x
      sta Enemy_YMoveForceFractional,x
      lda Enemy_Y_Position,x   ;add whatever vertical speed is set to current
      adc Enemy_Y_Speed,x      ;vertical position plus carry to move up or down
      sta Enemy_Y_Position,x   ;and then leave
ExLiftP:
      rts

ChkSmallPlatCollision:
         lda PlatformCollisionFlag,x ;get bounding box counter saved in collision flag
         beq ExLiftP                 ;if none found, leave player position alone
         jmp PositionPlayerOnS_Plat  ;use to position player correctly



;-------------------------------------------------------------------------------------

PlayerPosSPlatData:
      .byte $80, $00

PositionPlayerOnS_Plat:
      tay                        ;use bounding box counter saved in collision flag
      lda Enemy_Y_Position,x     ;for offset
      clc                        ;add positioning data using offset to the vertical
      adc PlayerPosSPlatData-1,y ;coordinate
      .byte $2c                    ;BIT instruction opcode

PositionPlayerOnVPlat:
         lda Enemy_Y_Position,x    ;get vertical coordinate
         ldy GameEngineSubroutine
         cpy #$0b                  ;if certain routine being executed on this frame,
         beq ExPlPos               ;skip all of this
         ldy Enemy_Y_HighPos,x
         cpy #$01                  ;if vertical high byte offscreen, skip this
         bne ExPlPos
         sec                       ;subtract 32 pixels from vertical coordinate
         sbc #$20                  ;for the player object's height
         sta Player_Y_Position     ;save as player's new vertical coordinate
         tya
         sbc #$00                  ;subtract borrow and store as player's
         sta Player_Y_HighPos      ;new vertical high byte
         lda #$00
         sta Player_Y_Speed        ;initialize vertical speed and low byte of force
         sta Player_Y_MoveForce    ;and then leave
ExPlPos: rts


;--------------------------------

InitGoomba:
  jsr InitNormalEnemy  ;set appropriate horizontal speed
  jmp SmallBBox        ;set $09 as bounding box control, set other values

;--------------------------------

InitRedKoopa:
  jsr InitNormalEnemy   ;load appropriate horizontal speed
  lda #$01              ;set enemy state for red koopa troopa $03
  sta Enemy_State,x
  rts

;--------------------------------

ProcMoveRedPTroopa:
  lda Enemy_Y_Speed,x
  ora Enemy_Y_MoveForce,x     ;check for any vertical force or speed
  bne MoveRedPTUpOrDown       ;branch if any found
  sta Enemy_YMoveForceFractional,x       ;initialize something here
  lda Enemy_Y_Position,x      ;check current vs. original vertical coordinate
  cmp RedPTroopaOrigXPos,x
  bcs MoveRedPTUpOrDown       ;if current => original, skip ahead to more code
      lda FrameCounter            ;get frame counter
      and #%00000111              ;mask out all but 3 LSB
      bne NoIncPT                 ;if any bits set, branch to leave
        inc Enemy_Y_Position,x      ;otherwise increment red paratroopa's vertical position
NoIncPT:
    rts                         ;leave

MoveRedPTUpOrDown:
  lda Enemy_Y_Position,x      ;check current vs. central vertical coordinate
  cmp RedPTroopaCenterYPos,x
  bcc MovPTDwn                ;if current < central, jump to move downwards
    jmp MoveRedPTroopaUp        ;otherwise jump to move upwards
MovPTDwn:
  jmp MoveRedPTroopaDown      ;move downwards


;--------------------------------

MoveRedPTroopaDown:
      ldy #$00            ;set Y to move downwards
      jmp MoveRedPTroopa  ;skip to movement routine

MoveRedPTroopaUp:
      ldy #$01            ;set Y to move upwards

MoveRedPTroopa:
      inx                 ;increment X for enemy offset
      lda #$03
      sta R0              ;set downward movement amount here
      lda #$06
      sta R1              ;set upward movement amount here
      lda #$02
      sta R2              ;set maximum speed here
      tya                 ;set movement direction in A, and
      jmp RedPTroopaGrav  ;jump to move this thing

;--------------------------------

InitPodoboo:
      lda #$02                  ;set enemy position to below
      sta Enemy_Y_HighPos,x     ;the bottom of the screen
      sta Enemy_Y_Position,x
      lsr
      sta EnemyIntervalTimer,x  ;set timer for enemy
      lsr
      sta Enemy_State,x         ;initialize enemy state, then jump to use
      jmp SmallBBox             ;$09 as bounding box size and set other things

;-------------------------------------------------------------------------------------

MovePodoboo:
      lda EnemyIntervalTimer,x   ;check enemy timer
      bne PdbM                   ;branch to move enemy if not expired
      jsr InitPodoboo            ;otherwise set up podoboo again
      lda PseudoRandomBitReg+1,x ;get part of LSFR
      ora #%10000000             ;set d7
      sta Enemy_Y_MoveForce,x    ;store as movement force
      and #%00001111             ;mask out high nybble
      ora #$06                   ;set for at least six intervals
      sta EnemyIntervalTimer,x   ;store as new enemy timer
      lda #$f9
      sta Enemy_Y_Speed,x        ;set vertical speed to move podoboo upwards
PdbM: jmp MoveJ_EnemyVertically  ;branch to impose gravity on podoboo



;-------------------------------------------------------------------------------------

PowerUpObjHandler:
         stx ObjectOffset
         lda Enemy_State,x          ;check power-up object's state
         beq ExitPUp                ;if not set, branch to leave
         asl                        ;shift to check if d7 was set in object state
         bcc GrowThePowerUp         ;if not set, branch ahead to skip this part
         lda TimerControl           ;if master timer control set,
         bne RunPUSubs              ;branch ahead to enemy object routines
         lda PowerUpType,x          ;check power-up type
         beq ShroomM                ;if normal mushroom, branch ahead to move it
         cmp #$03
         beq ShroomM                ;if 1-up mushroom, branch ahead to move it
         cmp #$02
         bne RunPUSubs              ;if not star, branch elsewhere to skip movement
         jsr MoveJumpingEnemy       ;otherwise impose gravity on star power-up and make it jump
         jsr EnemyJump              ;note that green paratroopa shares the same code here 
         jmp RunPUSubs              ;then jump to other power-up subroutines
ShroomM: jsr MoveNormalEnemy        ;do sub to make mushrooms move
         jsr EnemyToBGCollisionDet  ;deal with collisions
         jmp RunPUSubs              ;run the other subroutines

GrowThePowerUp:
           lda FrameCounter           ;get frame counter
           and #$03                   ;mask out all but 2 LSB
           bne ChkPUSte               ;if any bits set here, branch
           dec Enemy_Y_Position,x     ;otherwise decrement vertical coordinate slowly
           lda Enemy_State,x          ;load power-up object state
           inc Enemy_State,x          ;increment state for next frame (to make power-up rise)
           cmp #$11                   ;if power-up object state not yet past 16th pixel,
           bcc ChkPUSte               ;branch ahead to last part here
           lda #$10
           sta Enemy_X_Speed,x        ;otherwise set horizontal speed
           lda #%10000000
           sta Enemy_State,x          ;and then set d7 in power-up object's state
           asl                        ;shift once to init A
           sta Enemy_SprAttrib,x      ;initialize background priority bit set here
           rol                        ;rotate A to set right moving direction
           sta Enemy_MovingDir,x      ;set moving direction
ChkPUSte:  lda Enemy_State,x          ;check power-up object's state
           cmp #$06                   ;for if power-up has risen enough
           bcc ExitPUp                ;if not, don't even bother running these routines
RunPUSubs: jsr RelativeEnemyPosition  ;get coordinates relative to screen
           jsr GetEnemyOffscreenBits  ;get offscreen bits
           jsr GetEnemyBoundBox       ;get bounding box coordinates
           jsr DrawPowerUp            ;draw the power-up object
           jsr PlayerEnemyCollision   ;check for collision with player
           jmp OffscreenBoundsCheck   ;check to see if it went offscreen
ExitPUp:   rts ; TODO check this RTS can be removed                        ;and we're done



;-------------------------------------------------------------------------------------

Setup_Vine:
        lda #VineObject          ;load identifier for vine object
        sta Enemy_ID,x           ;store in buffer
        lda #$01
        sta Enemy_Flag,x         ;set flag for enemy object buffer
        lda Block_PageLoc,y
        sta Enemy_PageLoc,x      ;copy page location from previous object
        lda Block_X_Position,y
        sta Enemy_X_Position,x   ;copy horizontal coordinate from previous object
        lda Block_Y_Position,y
        sta Enemy_Y_Position,x   ;copy vertical coordinate from previous object
        ldy Vine_FlagOffset       ;load vine flag/offset to next available vine slot
        bne NextVO               ;if set at all, don't bother to store vertical
        sta Vine_Start_Y_Position ;otherwise store vertical coordinate here
NextVO: txa                      ;store object offset to next available vine slot
        sta Vine_ObjOffset,y      ;using vine flag as offset
        inc Vine_FlagOffset       ;increment vine flag offset
        lda #Sfx_GrowVine
        sta Square2SoundQueue    ;load vine grow sound
        rts

;-------------------------------------------------------------------------------------
;$06-$07 - used as address to block buffer data
;$02 - used as vertical high nybble of block buffer offset

VineHeightData:
      .byte $30, $60

VineObjectHandler:
           cpx #$05                  ;check enemy offset for special use slot
           bne ExitVH                ;if not in last slot, branch to leave
           ldy Vine_FlagOffset
           dey                       ;decrement vine flag in Y, use as offset
           lda Vine_Height
           cmp VineHeightData,y      ;if vine has reached certain height,
           beq RunVSubs              ;branch ahead to skip this part
           lda FrameCounter          ;get frame counter
           lsr                       ;shift d1 into carry
           lsr
           bcc RunVSubs              ;if d1 not set (2 frames every 4) skip this part
           lda Enemy_Y_Position+5
           sbc #$01                  ;subtract vertical position of vine
           sta Enemy_Y_Position+5    ;one pixel every frame it's time
           inc Vine_Height            ;increment vine height
RunVSubs:  lda Vine_Height            ;if vine still very small,
           cmp #$08                  ;branch to leave
           bcc ExitVH
           jsr RelativeEnemyPosition ;get relative coordinates of vine,
           jsr GetEnemyOffscreenBits ;and any offscreen bits
           ldy #$00                  ;initialize offset used in draw vine sub
VDrawLoop: jsr DrawVine              ;draw vine
           iny                       ;increment offset
           cpy Vine_FlagOffset        ;if offset in Y and offset here
           bne VDrawLoop             ;do not yet match, loop back to draw more vine
           lda Enemy_OffscreenBits
           and #%00001100            ;mask offscreen bits
           beq WrCMTile              ;if none of the saved offscreen bits set, skip ahead
           dey                       ;otherwise decrement Y to get proper offset again
KillVine:  ldx Vine_ObjOffset,y       ;get enemy object offset for this vine object
           jsr EraseEnemyObject      ;kill this vine object
           dey                       ;decrement Y
           bpl KillVine              ;if any vine objects left, loop back to kill it
           sta Vine_FlagOffset        ;initialize vine flag/offset
           sta Vine_Height            ;initialize vine height
WrCMTile:  lda Vine_Height            ;check vine height
           cmp #$20                  ;if vine small (less than 32 pixels tall)
           bcc ExitVH                ;then branch ahead to leave
           ldx #$06                  ;set offset in X to last enemy slot
           lda #$01                  ;set A to obtain horizontal in $04, but we don't care
           ldy #$1b                  ;set Y to offset to get block at ($04, $10) of coordinates
           jsr BlockBufferCollision  ;do a sub to get block buffer address set, return contents
           ldy R2 
           cpy #$d0                  ;if vertical high nybble offset beyond extent of
           bcs ExitVH                ;current block buffer, branch to leave, do not write
           lda (R6), y               ;otherwise check contents of block buffer at 
           bne ExitVH                ;current offset, if not empty, branch to leave
           lda #$26
           sta (R6), y               ;otherwise, write climbing metatile to block buffer
ExitVH:    ldx ObjectOffset          ;get enemy object offset and leave
           rts

;-------------------------------------------------------------------------------------

WarpZoneObject:
  lda ScrollLock         ;check for scroll lock flag
  beq @ExGTimer           ;branch if not set to leave
  lda Player_Y_Position  ;check to see if player's vertical coordinate has
  and Player_Y_HighPos   ;same bits set as in vertical high byte (why?)
  bne @ExGTimer           ;if so, branch to leave
    sta ScrollLock         ;otherwise nullify scroll lock flag
    inc WarpZoneControl    ;increment warp zone flag to make warp pipes for warp zone
    jmp EraseEnemyObject   ;kill this object
; added rts here since this relied on a common rts
@ExGTimer:
  rts
  
.segment "MORE_OBJECT"
  
;-------------------------------------------------------------------------------------
  
JumpspringHandlerBanked:
           jsr GetEnemyOffscreenBits   ;get offscreen information
           lda TimerControl            ;check master timer control
           bne DrawJSpr                ;branch to last section if set
           lda JumpspringAnimCtrl      ;check jumpspring frame control
           beq DrawJSpr                ;branch to last section if not set
           tay
           dey                         ;subtract one from frame control,
           tya                         ;the only way a poor nmos 6502 can
           and #%00000010              ;mask out all but d1, original value still in Y
           bne DownJSpr                ;if set, branch to move player up
           inc Player_Y_Position
           inc Player_Y_Position       ;move player's vertical position down two pixels
           jmp PosJSpr                 ;skip to next part
DownJSpr:  dec Player_Y_Position       ;move player's vertical position up two pixels
           dec Player_Y_Position
PosJSpr:   lda Jumpspring_FixedYPos,x  ;get permanent vertical position
           clc
           adc Jumpspring_Y_PosData,y  ;add value using frame control as offset
           sta Enemy_Y_Position,x      ;store as new vertical position
           cpy #$01                    ;check frame control offset (second frame is $00)
           bcc BounceJS                ;if offset not yet at third frame ($01), skip to next part
           lda A_B_Buttons
           and #A_Button               ;check saved controller bits for A button press
           beq BounceJS                ;skip to next part if A not pressed
           and PreviousA_B_Buttons     ;check for A button pressed in previous frame
           bne BounceJS                ;skip to next part if so
           lda #$f4
           sta JumpspringForce         ;otherwise write new jumpspring force here
BounceJS:  cpy #$03                    ;check frame control offset again
           bne DrawJSpr                ;skip to last part if not yet at fifth frame ($03)
           lda JumpspringForce
           sta Player_Y_Speed          ;store jumpspring force as player's new vertical speed
           lda #$00
           sta JumpspringAnimCtrl      ;initialize jumpspring frame control
DrawJSpr:  
            ; jsr RelativeEnemyPosition   ;get jumpspring's relative coordinates
      ;      jsr EnemyGfxHandler         ;draw jumpspring
           jsr DrawJumpSpring
           jsr OffscreenBoundsCheck    ;check to see if we need to kill it
           lda JumpspringAnimCtrl      ;if frame control at zero, don't bother
           beq ExJSpring               ;trying to animate it, just leave
           lda JumpspringTimer
           bne ExJSpring               ;if jumpspring timer not expired yet, leave
           lda #$04
           sta JumpspringTimer         ;otherwise initialize jumpspring timer
           inc JumpspringAnimCtrl      ;increment frame control to animate jumpspring
ExJSpring: rts                         ;leave  