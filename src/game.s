
.segment "CODE"

.proc IdleLoop
  lda NmiDisable
  beq IdleLoop
; Detect if the last frame lagged and skip immediately to the next frame if we did so we don't
; slow down if we lag.
GoToNextFrameImmediately:
  lda NmiSkipped
  pha
    jsr GameLoop
  pla
  cmp NmiSkipped
  beq IdleLoop
  ; We lagged this frame, so skip sprites next frame for faster processing
  lda #1
  sta ShouldSkipDrawSprites
  jmp GoToNextFrameImmediately
.endproc

.proc GameLoop
  jsr PauseRoutine          ;handle pause

  ldx #$00
  ldy #$07
  lda PseudoRandomBitReg    ;get first memory location of LSFR bytes
  and #%00000010            ;mask out all but d1
  sta R0                    ;save here
  lda PseudoRandomBitReg+1  ;get second memory location
  and #%00000010            ;mask out all but d1
  eor R0                    ;perform exclusive-OR on d1 from first and second bytes
  clc                       ;if neither or both are set, carry will be clear
  beq RotPRandomBit
  sec                       ;if one or the other is set, carry will be set
RotPRandomBit:
    ror PseudoRandomBitReg,x  ;rotate carry into d7, and rotate last bit into carry
    inx                       ;increment to next byte
    dey                       ;decrement for loop
    bne RotPRandomBit

  ; BankPRGA #.bank(UpdateTopScore)
  farcall UpdateTopScore
  lda GamePauseStatus       ;if in pause mode, do not perform operation mode stuff
  lsr
  bcs PauseSkip

    ; Move the timers ahead by a frame as well
    lda TimerControl          ;if master timer control not set, decrement
    beq DecTimers             ;all frame and interval timers
      dec TimerControl
    bne NoDecTimers
    DecTimers:
      ldx #FRAME_TIMER_COUNT    ;load end offset for end of frame timers
      dec IntervalTimerControl  ;decrement interval timer control,
      bpl DecTimersLoop         ;if not expired, only frame timers will decrement
      lda #$14
      sta IntervalTimerControl  ;if control for interval timers expired,
      ldx #ALL_TIMER_COUNT      ;interval timers will decrement along with frame timers
    DecTimersLoop:
        lda Timers,x              ;check current timer
        beq SkipExpTimer          ;if current timer expired, branch to skip,
          dec Timers,x              ;otherwise decrement the current timer
      SkipExpTimer:
        dex                       ;move onto next timer
        bpl DecTimersLoop         ;do this until all timers are dealt with
NoDecTimers:
    inc FrameCounter          ;increment frame counter

.if ::DEBUG_DISPLAY_VISUAL_FRAMETIME
    lda Mirror_PPUMASK
    ora #%00100000
    sta PPUMASK
.endif
    ; otherwise do one of many, many possible subroutines
    jsr OperModeExecutionTree
.if ::DEBUG_DISPLAY_VISUAL_FRAMETIME
    lda Mirror_PPUMASK
    and #%11011111
    sta PPUMASK
.endif

PauseSkip:
  lda #0
  sta NmiDisable
  rts
.endproc

;-------------------------------------------------------------------------------------
.proc PauseRoutine
               lda OperMode           ;are we in victory mode?
               cmp #MODE_VICTORY  ;if so, go ahead
               beq ChkPauseTimer
               cmp #MODE_GAMEPLAY     ;are we in game mode?
               bne ExitPause          ;if not, leave
               lda OperMode_Task      ;if we are in game mode, are we running game engine?
               cmp #$03
               bne ExitPause          ;if not, leave
ChkPauseTimer: lda GamePauseTimer     ;check if pause timer is still counting down
               beq ChkStart
               dec GamePauseTimer     ;if so, decrement and leave
               rts
ChkStart:      lda SavedJoypad1Bits   ;check to see if start is pressed
               and #Start_Button      ;on controller 1
               beq ClrPauseTimer
               lda GamePauseStatus    ;check to see if timer flag is set
               and #%10000000         ;and if so, do not reset timer
               bne ExitPause
               lda #$2b               ;set pause timer
               sta GamePauseTimer
               lda GamePauseStatus
               tay
               iny                    ;set pause sfx queue for next pause mode
               sty PauseSoundQueue
               eor #%00000001         ;invert d0 and set d7
               ora #%10000000
               bne SetPause           ;unconditional branch
ClrPauseTimer: lda GamePauseStatus    ;clear timer flag if timer is at zero and start button
               and #%01111111         ;is not pressed
SetPause:      sta GamePauseStatus
ExitPause:     rts
.endproc

;-------------------------------------------------------------------------------------
clabel GameCoreRoutine
GameCoreRoutine:
  ldx CurrentPlayer          ;get which player is on the screen
  lda SavedJoypadBits,x      ;use appropriate player's controller bits
  sta SavedJoypadBits        ;as the master controller bits
  
  farcall GameRoutines           ;execute one of many possible subs

  ; lda #0
  ; sta PlayerOAMOffset
  lda #4 * 4 ; save enough room to draw the player first later
  sta CurrentOAMOffset

  lda OperMode_Task          ;check major task of operating mode
  cmp #$03                   ;if we are supposed to be here,
  bcs GameEngine             ;branch to the game engine itself
    rts
GameEngine:
  far OBJECT
    jsr ProcFireball_Bubble    ;process fireballs and air bubbles
    ldx #$00
ProcELoop:
      stx ObjectOffset           ;put incremented offset in X as enemy object offset
      jsr EnemiesAndLoopsCore    ;process enemy objects
      jsr FloateyNumbersCore     ;process floatey numbers
      inx
      cpx #$06                   ;do these two subroutines until the whole buffer is done
    bne ProcELoop
    jsr GetPlayerOffscreenBits ;get offscreen bits for player object
    jsr RelativePlayerPosition ;get relative coordinates for player object
    farcall PlayerGfxHandler       ;draw the player
    jsr BlockObjMT_Updater     ;replace block objects with metatiles if necessary
    ldx #$01
    stx ObjectOffset           ;set offset for second
    jsr BlockObjectsCore       ;process second block object
    dex
    stx ObjectOffset           ;set offset for first
    jsr BlockObjectsCore       ;process first block object
    jsr MiscObjectsCore        ;process misc objects (hammer, jumping coins)
    jsr ProcessCannons         ;process bullet bill cannons
    jsr ProcessWhirlpools      ;process whirlpools
    jsr FlagpoleRoutine        ;process the flagpole
    jsr RunGameTimer           ;count down the game timer
  endfar

  lda ShouldSkipDrawSprites
  beq NoLagSoDraw
  lda FramesSinceLastSpriteDraw
  cmp #13 ; Force a draw every 13 frames (~5fps) so its not too broken at extreme lag
  bcc SkipDrawingCauseLagged
NoLagSoDraw:
    farcall DrawAllMetasprites
    lda #0
    sta FramesSinceLastSpriteDraw
    beq DoneDrawing
SkipDrawingCauseLagged:
    inc FramesSinceLastSpriteDraw
DoneDrawing:
  lda #0
  sta ShouldSkipDrawSprites

  jsr ColorRotation          ;cycle one of the background colors

  lda Player_Y_HighPos
  cmp #$02                   ;if player is below the screen, don't bother with the music
  bpl NoChgMus
    lda StarInvincibleTimer    ;if star mario invincibility timer at zero,
    beq ClrPlrPal              ;skip this part
      cmp #$04
      bne NoChgMus               ;if not yet at a certain point, continue
        lda IntervalTimerControl   ;if interval timer not yet expired,
        bne NoChgMus               ;branch ahead, don't bother with the music
          jsr GetAreaMusic       ;to re-attain appropriate level music
NoChgMus:
  ldy StarInvincibleTimer    ;get invincibility timer
  lda FrameCounter           ;get frame counter
  cpy #$08                   ;if timer still above certain point,
  bcs CycleTwo               ;branch to cycle player's palette quickly
    lsr                      ;otherwise, divide by 8 to cycle every eighth frame
    lsr
CycleTwo:
  lsr                        ;if branched here, divide by 2 to cycle every other frame
  sta R0 
  farcall CyclePlayerPalettePreload     ;do sub to cycle the palette (note: shares fire flower code)
  jmp SaveAB                 ;then skip this sub to finish up the game engine
ClrPlrPal:
  farcall ResetPalStar           ;do sub to clear player's palette bits in attributes
SaveAB:
  lda A_B_Buttons            ;save current A and B button
  sta PreviousA_B_Buttons    ;into temp variable to be used on next frame
  lda #$00
  sta Left_Right_Buttons     ;nullify left and right buttons temp variable
UpdScrollVar:
  lda VRAM_Buffer_AddrCtrl
  cmp #$06                   ;if vram address controller set to 6 (one of two $0341s)
  beq ExitEng                ;then branch to leave
    lda AreaParserTaskNum      ;otherwise check number of tasks
    bne RunParser
      lda ScrollThirtyTwo        ;get horizontal scroll in 0-31 or $00-$20 range
      cmp #$20                   ;check to see if exceeded $21
      bmi ExitEng                ;branch to leave if not
        lda ScrollThirtyTwo
        sbc #$20                   ;otherwise subtract $20 to set appropriately
        sta ScrollThirtyTwo        ;and store
        lda #$00                   ;reset vram buffer offset used in conjunction with
        sta VRAM_Buffer2_Offset    ;level graphics buffer at $0341-$035f
  RunParser:
        farcall AreaParserTaskHandler, jmp  ;update the name table with more level graphics
ExitEng:

.if DEBUG_ADD_EXTRA_LAG
  ; lda SavedJoypadBits
  ; and #Select_Button
  ; bne :+
    lda #<DEBUG_ADD_EXTRA_LAG
    ldx #>DEBUG_ADD_EXTRA_LAG
    jsr delay_256x_a_30_clocks_b
  ; :
.endif

.if ENABLE_C_CODE
  .import _after_frame_callback
  jmp _after_frame_callback
.else
  rts                        ;and after all that, we're finally done!
.endif


;-------------------------------------------------------------------------------------
;$02 - used to store offset to block buffer
;$06-$07 - used to store block buffer address
BlockObjMT_Updater:
  ldx #$01                  ;set offset to start with second block object
UpdateLoop:
    stx ObjectOffset          ;set offset here
    lda VRAM_Buffer1          ;if vram buffer already being used here,
    bne NextBUpd              ;branch to move onto next block object
    lda Block_RepFlag,x       ;if flag for block object already clear,
    beq NextBUpd              ;branch to move onto next block object
      lda Block_BBuf_Low,x      ;get low byte of block buffer
      sta R6                    ;store into block buffer address
      lda #>Block_Buffer_1
      sta R7                    ;set high byte of block buffer address
      lda Block_Orig_YPos,x     ;get original vertical coordinate of block object
      sta R2                    ;store here and use as offset to block buffer
      tay
      lda Block_Metatile,x      ;get metatile to be written
      sta (R6),y                ;write it to the block buffer
      farcall WriteBlockMetatile  ;do sub to replace metatile where block object is
      lda #$00
      sta Block_RepFlag,x       ;clear block object flag
NextBUpd:
    dex                       ;decrement block object offset
    bpl UpdateLoop            ;do this until both block objects are dealt with
  rts                       ;then leave

;-------------------------------------------------------------------------------------

; Because the metasprite is rendered after, we need to keep the block around for one
; extra frame in order to clear the metasprite on the same frame it would in vanilla
EliminateBlock:
  lda #0
  sta BlockMetasprite,x
  sta Block_State,x
  rts

BlockObjectsCore:
        lda Block_State,x           ;get state of block object
        bmi EliminateBlock
        beq UpdSte                  ;if not set, branch to leave
        and #$0f                    ;mask out high nybble
        pha                         ;push to stack
        tay                         ;put in Y for now
        txa
        clc
        adc #Block_Y_Speed - SprObject_Y_Speed  ;add 9 bytes to offset (note two block objects are created
        tax                         ;when using brick chunks, but only one offset for both)
        dey                         ;decrement Y to check for solid block state
        beq BouncingBlockHandler    ;branch if found, otherwise continue for brick chunks
        jsr ImposeGravityBlock      ;do sub to impose gravity on one block object object
        jsr MoveObjectHorizontally  ;do another sub to move horizontally
        ; txa
        ; clc                         ;move onto next block object
        ; adc #$02
        ; tax
        inx
        inx
        jsr ImposeGravityBlock      ;do sub to impose gravity on other block object
        jsr MoveObjectHorizontally  ;do another sub to move horizontally
        ldx ObjectOffset            ;get block object offset used for both
        jsr RelativeBlockPosition   ;get relative coordinates
        jsr GetBlockOffscreenBits   ;get offscreen information
        jsr DrawBrickChunks         ;draw the brick chunks
        pla                         ;get lower nybble of saved state
        ldy Block_Y_HighPos,x       ;check vertical high byte of block object
        beq UpdSte                  ;if above the screen, branch to kill it
        pha                         ;otherwise save state back into stack
        lda #$f0
        cmp Block_Y_Position+2,x    ;check to see if bottom block object went
        bcs ChkTop                  ;to the bottom of the screen, and branch if not
        sta Block_Y_Position+2,x    ;otherwise set offscreen coordinate
ChkTop: lda Block_Y_Position,x      ;get top block object's vertical coordinate
        cmp #$f0                    ;see if it went to the bottom of the screen
        pla                         ;pull block object state from stack
        bcc UpdSte                  ;if not, branch to save state
        bcs KillBlock               ;otherwise do unconditional branch to kill it

BouncingBlockHandler:
           jsr ImposeGravityBlock     ;do sub to impose gravity on block object
           ldx ObjectOffset           ;get block object offset
           jsr RelativeBlockPosition  ;get relative coordinates
           jsr GetBlockOffscreenBits  ;get offscreen information
           jsr DrawBlock              ;draw the block
           lda Block_Y_Position,x     ;get vertical coordinate
           and #$0f                   ;mask out high nybble
           cmp #$05                   ;check to see if low nybble wrapped around
           pla                        ;pull state from stack
           bcs UpdSte                 ;if still above amount, not time to kill block yet, thus branch
           lda #$01
           sta Block_RepFlag,x        ;otherwise set flag to replace metatile
KillBlock: lda #$80                   ;if branched here, nullify object state
           bne UpdSte
KeepBlock: lda #1
UpdSte:    sta Block_State,x          ;store contents of A in block object state
           rts

;-------------------------------------------------------------------------------------

RunGameTimer:
  lda OperMode               ;get primary mode of operation
  beq ExGTimer               ;branch to leave if in title screen mode
  lda GameEngineSubroutine
  cmp #$08                   ;if routine number less than eight running,
  bcc ExGTimer               ;branch to leave
  cmp #$0b                   ;if running death routine,
  beq ExGTimer               ;branch to leave
  lda Player_Y_HighPos
  cmp #$02                   ;if player below the screen,
  bcs ExGTimer               ;branch to leave regardless of level type
  lda GameTimerCtrlTimer     ;if game timer control not yet expired,
  bne ExGTimer               ;branch to leave
  lda GameTimerDisplay
  ora GameTimerDisplay+1     ;otherwise check game timer digits
  ora GameTimerDisplay+2
  beq TimeUpOn               ;if game timer digits at 000, branch to time-up code
  ldy GameTimerDisplay       ;otherwise check first digit
  dey                        ;if first digit not on 1,
  bne ResGTCtrl              ;branch to reset game timer control
  lda GameTimerDisplay+1     ;otherwise check second and third digits
  ora GameTimerDisplay+2
  bne ResGTCtrl              ;if timer not at 100, branch to reset game timer control
  lda #TimeRunningOutMusic
  sta EventMusicQueue        ;otherwise load time running out music
ResGTCtrl:
  lda #$18                   ;reset game timer control
  sta GameTimerCtrlTimer
  ldy #(GameTimerDisplay + 2 - DisplayDigits) ;set offset for last digit
  lda #-1                    ;set value to decrement game timer digit
  sta DigitModifier + GameTimerLastIndex
  ldx #GameTimerLastIndex
  jsr DigitsMathRoutine      ;do sub to decrement game timer slowly
  lda #$a4                   ;set status nybbles to update game timer display
  jmp PrintStatusBarNumbers  ;do sub to update the display
TimeUpOn:
  sta PlayerStatus           ;init player status (note A will always be zero here)
  jsr ForceInjury            ;do sub to kill the player (note player is small here)
  inc GameTimerExpiredFlag   ;set game timer expiration flag
ExGTimer:
  rts                        ;leave

;-------------------------------------------------------------------------------------
;$00 - used in WhirlpoolActivate to store whirlpool length / 2, page location of center of whirlpool
;and also to store movement force exerted on player
;$01 - used in ProcessWhirlpools to store page location of right extent of whirlpool
;and in WhirlpoolActivate to store center of whirlpool
;$02 - used in ProcessWhirlpools to store right extent of whirlpool and in
;WhirlpoolActivate to store maximum vertical speed

ProcessWhirlpools:
        lda AreaType                ;check for water type level
        bne ExitWh                  ;branch to leave if not found
        sta Whirlpool_Flag          ;otherwise initialize whirlpool flag
        lda TimerControl            ;if master timer control set,
        bne ExitWh                  ;branch to leave
        ldy #$04                    ;otherwise start with last whirlpool data
WhLoop: lda Whirlpool_LeftExtent,y  ;get left extent of whirlpool
        clc
        adc Whirlpool_Length,y      ;add length of whirlpool
        sta R2                      ;store result as right extent here
        lda Whirlpool_PageLoc,y     ;get page location
        beq NextWh                  ;if none or page 0, branch to get next data
        adc #$00                    ;add carry
        sta R1                      ;store result as page location of right extent here
        lda Player_X_Position       ;get player's horizontal position
        sec
        sbc Whirlpool_LeftExtent,y  ;subtract left extent
        lda Player_PageLoc          ;get player's page location
        sbc Whirlpool_PageLoc,y     ;subtract borrow
        bmi NextWh                  ;if player too far left, branch to get next data
        lda R2                      ;otherwise get right extent
        sec
        sbc Player_X_Position       ;subtract player's horizontal coordinate
        lda R1                      ;get right extent's page location
        sbc Player_PageLoc          ;subtract borrow
        bpl WhirlpoolActivate       ;if player within right extent, branch to whirlpool code
NextWh: dey                         ;move onto next whirlpool data
        bpl WhLoop                  ;do this until all whirlpools are checked
ExitWh: rts                         ;leave

WhirlpoolActivate:
        lda Whirlpool_Length,y      ;get length of whirlpool
        lsr                         ;divide by 2
        sta R0                      ;save here
        lda Whirlpool_LeftExtent,y  ;get left extent of whirlpool
        clc
        adc R0                      ;add length divided by 2
        sta R1                      ;save as center of whirlpool
        lda Whirlpool_PageLoc,y     ;get page location
        adc #$00                    ;add carry
        sta R0                      ;save as page location of whirlpool center
        lda FrameCounter            ;get frame counter
        lsr                         ;shift d0 into carry (to run on every other frame)
        bcc WhPull                  ;if d0 not set, branch to last part of code
        lda R1                      ;get center
        sec
        sbc Player_X_Position       ;subtract player's horizontal coordinate
        lda R0                      ;get page location of center
        sbc Player_PageLoc          ;subtract borrow
        bpl LeftWh                  ;if player to the left of center, branch
        lda Player_X_Position       ;otherwise slowly pull player left, towards the center
        sec
        sbc #$01                    ;subtract one pixel
        sta Player_X_Position       ;set player's new horizontal coordinate
        lda Player_PageLoc
        sbc #$00                    ;subtract borrow
        jmp SetPWh                  ;jump to set player's new page location
LeftWh: lda Player_CollisionBits    ;get player's collision bits
        lsr                         ;shift d0 into carry
        bcc WhPull                  ;if d0 not set, branch
        lda Player_X_Position       ;otherwise slowly pull player right, towards the center
        clc
        adc #$01                    ;add one pixel
        sta Player_X_Position       ;set player's new horizontal coordinate
        lda Player_PageLoc
        adc #$00                    ;add carry
SetPWh: sta Player_PageLoc          ;set player's new page location
WhPull: lda #$10
        sta R0                      ;set vertical movement force
        lda #$01
        sta Whirlpool_Flag          ;set whirlpool flag to be used later
        sta R2                      ;also set maximum vertical speed
        lsr
        tax                         ;set X for player offset
        jmp ImposeGravity           ;jump to put whirlpool effect on player vertically, do not return

;-------------------------------------------------------------------------------------

FlagpoleScoreMods:
  .byte $05, $02, $08, $04, $01

FlagpoleScoreDigits:
  .byte $03, $03, $04, $04, $04

FlagpoleRoutine:
           ldx #$05                  ;set enemy object offset
           stx ObjectOffset          ;to special use slot
           lda Enemy_ID,x
           cmp #FlagpoleFlagObject   ;if flagpole flag not found,
           bne ExitFlagP             ;branch to leave
           lda GameEngineSubroutine
           cmp #$04                  ;if flagpole slide routine not running,
           bne SkipScore             ;branch to near the end of code
           lda Player_State
           cmp #$03                  ;if player state not climbing,
           bne SkipScore             ;branch to near the end of code
           lda Enemy_Y_Position,x    ;check flagpole flag's vertical coordinate
           cmp #$aa                  ;if flagpole flag down to a certain point,
           bcs GiveFPScr             ;branch to end the level
           lda Player_Y_Position     ;check player's vertical coordinate
           cmp #$a2                  ;if player down to a certain point,
           bcs GiveFPScr             ;branch to end the level
           lda Enemy_YMoveForceFractional,x
           adc #$ff                  ;add movement amount to dummy variable
           sta Enemy_YMoveForceFractional,x     ;save dummy variable
           lda Enemy_Y_Position,x    ;get flag's vertical coordinate
           adc #$01                  ;add 1 plus carry to move flag, and
           sta Enemy_Y_Position,x    ;store vertical coordinate
           lda FlagpoleFNum_YMFDummy
           sec                       ;subtract movement amount from dummy variable
           sbc #$ff
           sta FlagpoleFNum_YMFDummy ;save dummy variable
           lda FlagpoleFNum_Y_Pos
           sbc #$01                  ;subtract one plus borrow to move floatey number,
           sta FlagpoleFNum_Y_Pos    ;and store vertical coordinate here
SkipScore: jmp FPGfx                 ;jump to skip ahead and draw flag and floatey number
GiveFPScr: ldy FlagpoleScore         ;get score offset from earlier (when player touched flagpole)
           lda FlagpoleScoreMods,y   ;get amount to award player points
           ldx FlagpoleScoreDigits,y ;get digit with which to award points
           sta DigitModifier,x       ;store in digit modifier
           farcall AddToScore        ;do sub to award player points depending on height of collision
           lda #$05
           sta GameEngineSubroutine  ;set to run end-of-level subroutine on next frame
FPGfx:     ;jsr GetEnemyOffscreenBits ;get offscreen information
           ;jsr RelativeEnemyPosition ;get relative coordinates
           jmp FlagpoleGfxHandler    ;draw flagpole flag and floatey number
ExitFlagP: rts ; TODO check this RTS can be removed

;-------------------------------------------------------------------------------------

;$00 - used as temporary counter in ColorRotation

ColorRotatePalette:
       .byte $27, $27, $27, $17, $07, $17

BlankPalette:
       .byte $3f, $0c, $04, $ff, $ff, $ff, $ff, $00

;used based on area type
Palette3Data:
       .byte $0f, $07, $12, $0f 
       .byte $0f, $07, $17, $0f
       .byte $0f, $07, $17, $1c
       .byte $0f, $07, $17, $00

ColorRotation:
              lda FrameCounter         ;get frame counter
              and #$07                 ;mask out all but three LSB
              bne ExitColorRot         ;branch if not set to zero to do this every eighth frame
              ldx VRAM_Buffer1_Offset  ;check vram buffer offset
              cpx #$31
              bcs ExitColorRot         ;if offset over 48 bytes, branch to leave
              tay                      ;otherwise use frame counter's 3 LSB as offset here
GetBlankPal:  lda BlankPalette,y       ;get blank palette for palette 3
              sta VRAM_Buffer1,x       ;store it in the vram buffer
              inx                      ;increment offsets
              iny
              cpy #$08
              bcc GetBlankPal          ;do this until all bytes are copied
              ldx VRAM_Buffer1_Offset  ;get current vram buffer offset
              lda #$03
              sta R0                   ;set counter here
              lda AreaType             ;get area type
              asl                      ;multiply by 4 to get proper offset
              asl
              tay                      ;save as offset here
GetAreaPal:   lda Palette3Data,y       ;fetch palette to be written based on area type
              sta VRAM_Buffer1+3,x     ;store it to overwrite blank palette in vram buffer
              iny
              inx
              dec R0                   ;decrement counter
              bpl GetAreaPal           ;do this until the palette is all copied
              ldx VRAM_Buffer1_Offset  ;get current vram buffer offset
              ldy ColorRotateOffset    ;get color cycling offset
              lda ColorRotatePalette,y
              sta VRAM_Buffer1+4,x     ;get and store current color in second slot of palette
              lda VRAM_Buffer1_Offset
              clc                      ;add seven bytes to vram buffer offset
              adc #$07
              sta VRAM_Buffer1_Offset
              inc ColorRotateOffset    ;increment color cycling offset
              lda ColorRotateOffset
              cmp #$06                 ;check to see if it's still in range
              bcc ExitColorRot         ;if so, branch to leave
              lda #$00
              sta ColorRotateOffset    ;otherwise, init to keep it in range
ExitColorRot: rts                      ;leave


;-------------------------------------------------------------------------------------

;indirect jump routine called when
;$0770 is set to 1
.proc GameMode

  lda OperMode_Task
  jsr JumpEngine

  .word InitializeArea
  .word FarCallScreenRoutines
  .word SecondaryGameSetup
  .word GameCoreRoutine
.endproc

.proc FarCallScreenRoutines
  farcall ScreenRoutines, jmp
.endproc

;-------------------------------------------------------------------------------------
PrimaryGameSetup:
  lda #$01
  sta FetchNewGameTimerFlag   ;set flag to load game timer from header
  sta PlayerSize              ;set player's size to small
  lda #$02
  sta NumberofLives           ;give each player three lives
  sta OffScr_NumberofLives
SecondaryGameSetup:
  lda #$00
  sta DisableScreenFlag     ;enable screen output
  tay
ClearVRLoop: sta VRAM_Buffer1-1,y      ;clear buffer at $0300-$03ff
  iny
  bne ClearVRLoop
  sta GameTimerExpiredFlag  ;clear game timer exp flag
  sta DisableIntermediate   ;clear skip lives display flag
  sta BackloadingFlag       ;clear value here
  lda #$ff
  sta BalPlatformAlignment  ;initialize balance platform assignment flag
  lda ScreenLeft_PageLoc    ;get left side page location
  lsr Mirror_PPUCTRL       ;shift LSB of ppu register #1 mirror out
  and #$01                  ;mask out all but LSB of page location
  ror                       ;rotate LSB of page location into carry then onto mirror
  rol Mirror_PPUCTRL       ;this is to set the proper PPU name table
  jsr GetAreaMusic          ;load proper music into queue
  inc Sprite0HitDetectFlag  ;set sprite #0 check flag
  inc OperMode_Task         ;increment to next task
  rts

;-------------------------------------------------------------------------------------
.proc OperModeExecutionTree
  lda OperMode     ;this is the heart of the entire program,
  jsr JumpEngine   ;most of what goes on starts here

  .word TitleScreenMode
  .word GameMode
  .word VictoryMode
  .word GameOverMode
.endproc

;-------------------------------------------------------------------------------------

.if USE_CUSTOM_TITLESCREEN
.proc TitleScreenMode
  lda OperMode_Task
  jsr JumpEngine

  .word InitializeGame
  .word FarCallTitleScreenSetup
  .word PrimaryGameSetup
  .word FarCallGameMenu

.import _title_screen_setup
FarCallTitleScreenSetup:
  farcall _title_screen_setup, jmp
  ; jmp _title_screen_setup

.import _title_screen_menu
FarCallGameMenu:
  farcall _title_screen_menu, jmp
  ; jmp _title_screen_menu

.endproc
.else
.proc TitleScreenMode
  lda OperMode_Task
  jsr JumpEngine

  .word InitializeGame
  .word FarCallScreenRoutines
  .word PrimaryGameSetup
  .word GameMenuRoutine
.endproc
.endif

InitializeGame:
  ldy #<WorldSelectNumber  ;clear all memory as in initialization procedure,
  jsr InitializeMemory     ;but this time, clear only as far as $076f
  jsr AudioClear
  lda #$18              ;set demo timer
  sta DemoTimer
  jsr LoadAreaPointer

InitializeArea:

  ldy #<SecondaryMsgCounter                 ;clear all memory again, only as far as $074b
  jsr InitializeMemory     ;this is only necessary in game mode
  ldx #FRAME_TIMER_COUNT
  lda #$00
ClrTimersLoop:
    sta Timers,x             ;clear out memory between
    dex                      ;$0780 and $07a1
    bpl ClrTimersLoop
  lda HalfwayPage
  ldy AltEntranceControl   ;if AltEntranceControl not set, use halfway page, if any found
  beq StartPage
    lda EntrancePage         ;otherwise use saved entry page number here
StartPage:
  sta ScreenLeft_PageLoc   ;set as value here
  sta CurrentPageLoc       ;also set as current page
  sta BackloadingFlag      ;set flag here if halfway page or saved entry page number found
  jsr GetScreenPosition    ;get pixel coordinates for screen borders
  ldy #$20                 ;if on odd numbered page, use $2480 as start of rendering
  and #%00000001           ;otherwise use $2080, this address used later as name table
  beq SetInitNTHigh        ;address for rendering of game area
    ldy #$24
SetInitNTHigh:
  sty CurrentNTAddr_High   ;store name table address
  ldy #$80
  sty CurrentNTAddr_Low
  asl                      ;store LSB of page number in high nybble
  asl                      ;of block buffer column position
  asl
  asl
  sta BlockBufferColumnPos
  dec AreaObjectLength     ;set area object lengths for all empty
  dec AreaObjectLength+1
  dec AreaObjectLength+2
  lda #$0b                 ;set value for renderer to update 12 column sets
  sta ColumnSets           ;12 column sets = 24 metatile columns = 1 1/2 screens
.if USE_TILED_LEVELS
  jsr LoadLevel
.else
  farcall GetAreaDataAddrs     ;get enemy and level addresses and load header
.endif
  lda PrimaryHardMode      ;check to see if primary hard mode has been activated
  bne SetSecHard           ;if so, activate the secondary no matter where we're at
    lda WorldNumber          ;otherwise check world number
    cmp #World5              ;if less than 5, do not activate secondary
    bcc CheckHalfway
      bne SetSecHard           ;if not equal to, then world > 5, thus activate
        lda LevelNumber          ;otherwise, world 5, so check level number
        cmp #Level3              ;if 1 or 2, do not set secondary hard mode flag
        bcc CheckHalfway
  SetSecHard:
          inc SecondaryHardMode    ;set secondary hard mode flag for areas 5-3 and beyond
  CheckHalfway:
    lda HalfwayPage
    beq DoneInitArea
      lda #$02                 ;if halfway page set, overwrite start position from header
      sta PlayerEntranceCtrl
DoneInitArea:
  lda #Silence             ;silence music
  sta AreaMusicQueue
  lda #$01                 ;disable screen output
  sta DisableScreenFlag
  inc OperMode_Task        ;increment one of the modes
  rts


;-------------------------------------------------------------------------------------
.proc GameOverMode
  lda OperMode_Task
  jsr JumpEngine
  
  .word SetupGameOver
  .word FarCallScreenRoutines
  .word RunGameOver
.endproc

;-------------------------------------------------------------------------------------

.proc SetupGameOver
  lda #$00                  ;reset screen routine task control for title screen, game,
  sta ScreenRoutineTask     ;and game over modes
  sta Sprite0HitDetectFlag  ;disable sprite 0 check
  lda #GameOverMusic
  sta EventMusicQueue       ;put game over music in secondary queue
  inc DisableScreenFlag     ;disable screen output
  inc OperMode_Task         ;set secondary mode to 1
  rts
.endproc


;-------------------------------------------------------------------------------------

.proc RunGameOver

  lda #$00              ;reenable screen
  sta DisableScreenFlag
  lda SavedJoypad1Bits  ;check controller for start pressed
  and #Start_Button
  bne TerminateGame
  lda ScreenTimer       ;if not pressed, wait for
  bne GameIsOn          ;screen timer to expire
TerminateGame:
  lda #Silence          ;silence music
  sta EventMusicQueue
  jsr TransposePlayers  ;check if other player can keep
  bcc ContinueGame      ;going, and do so if possible
  lda WorldNumber       ;otherwise put world number of current
  sta ContinueWorld     ;player into secret continue function variable
  lda #$00
  sta OperMode_Task     ;reset all modes to title screen and
  sta ScreenTimer       ;leave
  sta OperMode
  rts

ContinueGame:
  jsr LoadAreaPointer       ;update level pointer with
  lda #$01                  ;actual world and area numbers, then
  sta PlayerSize            ;reset player's size, status, and
  inc FetchNewGameTimerFlag ;set game timer flag to reload
  lda #$00                  ;game timer from header
  sta TimerControl          ;also set flag for timers to count again
  sta PlayerStatus
  sta GameEngineSubroutine  ;reset task for game core
  sta OperMode_Task         ;set modes and leave
  lda #$01                  ;if in game over mode, switch back to
  sta OperMode              ;game mode, because game is still on
GameIsOn:
  rts
.endproc


;-------------------------------------------------------------------------------------

.proc GameMenuRoutine

  ldy #$00
  lda SavedJoypad1Bits        ;check to see if either player pressed
  ora SavedJoypad2Bits        ;only the start button (either joypad)
  cmp #Start_Button
  beq StartGame
  cmp #A_Button+Start_Button  ;check to see if A + start was pressed
  bne ChkSelect               ;if not, branch to check select button
StartGame:
  jmp ChkContinue             ;if either start or A + start, execute here
ChkSelect:
  cmp #Select_Button          ;check to see if the select button was pressed
  beq SelectBLogic            ;if so, branch reset demo timer
  ldx DemoTimer               ;otherwise check demo timer
  bne ChkWorldSel             ;if demo timer not expired, branch to check world selection
  sta SelectTimer             ;set controller bits here if running demo
  jsr DemoEngine              ;run through the demo actions
  bcs ResetTitle              ;if carry flag set, demo over, thus branch
  jmp RunDemo                 ;otherwise, run game engine for demo
ChkWorldSel:
  ldx WorldSelectEnableFlag   ;check to see if world selection has been enabled
  beq NullJoypad
  cmp #B_Button               ;if so, check to see if the B button was pressed
  bne NullJoypad
  iny                         ;if so, increment Y and execute same code as select
SelectBLogic:
  lda DemoTimer               ;if select or B pressed, check demo timer one last time
  beq ResetTitle              ;if demo timer expired, branch to reset title screen mode
  lda #$18                    ;otherwise reset demo timer
  sta DemoTimer
  lda SelectTimer             ;check select/B button timer
  bne NullJoypad              ;if not expired, branch
  lda #$10                    ;otherwise reset select button timer
  sta SelectTimer
  cpy #$01                    ;was the B button pressed earlier?  if so, branch
  beq IncWorldSel             ;note this will not be run if world selection is disabled
  lda NumberOfPlayers         ;if no, must have been the select button, therefore
  eor #%00000001              ;change number of players and draw icon accordingly
  sta NumberOfPlayers
  farcall DrawMushroomIcon
  jmp NullJoypad
IncWorldSel:
  ldx WorldSelectNumber       ;increment world select number
  inx
  txa
  and #%00000111              ;mask out higher bits
  sta WorldSelectNumber       ;store as current world select number
  jsr GoContinue
UpdateShroom:
  lda WSelectBufferTemplate,x ;write template for world select in vram buffer
  sta VRAM_Buffer1-1,x        ;do this until all bytes are written
  inx
  cpx #$06
  bmi UpdateShroom
  ldy WorldNumber             ;get world number from variable and increment for
  iny                         ;proper display, and put in blank byte before
  sty VRAM_Buffer1+3          ;null terminator
NullJoypad:
  lda #$00                    ;clear joypad bits for player 1
  sta SavedJoypad1Bits
RunDemo:
  jsr GameCoreRoutine         ;run game engine
  lda GameEngineSubroutine    ;check to see if we're running lose life routine
  cmp #$06
  bne ExitMenu                ;if not, do not do all the resetting below
ResetTitle:
  lda #$00                    ;reset game modes, disable
  sta OperMode                ;sprite 0 check and disable
  sta OperMode_Task           ;screen output
  sta Sprite0HitDetectFlag
  inc DisableScreenFlag
  rts
ChkContinue:
  ldy DemoTimer               ;if timer for demo has expired, reset modes
  beq ResetTitle
  asl                         ;check to see if A button was also pushed
  bcc StartWorld1             ;if not, don't load continue function's world number
  lda ContinueWorld           ;load previously saved world number for secret
  jsr GoContinue              ;continue function when pressing A + start
StartWorld1:
  jsr LoadAreaPointer
  inc Hidden1UpFlag           ;set 1-up box flag for both players
  inc OffScr_Hidden1UpFlag
  inc FetchNewGameTimerFlag   ;set fetch new game timer flag
  inc OperMode                ;set next game mode
  lda WorldSelectEnableFlag   ;if world select flag is on, then primary
  sta PrimaryHardMode         ;hard mode must be on as well
  lda #$00
  sta OperMode_Task           ;set game mode here, and clear demo timer
  sta DemoTimer
  ldx #6 + 6 + 2 + 2 - 1      ; for each of the scores
  lda #$00
InitScores:
  sta ScoreAndCoinDisplay,x   ;clear player scores and coin displays
  dex
  bpl InitScores
ExitMenu:
  rts
GoContinue:
  sta WorldNumber             ;start both players at the first area
  sta OffScr_WorldNumber      ;of the previously saved world number
  ldx #$00                    ;note that on power-up using this function
  stx AreaNumber              ;will make no difference
  stx OffScr_AreaNumber   
  rts
.endproc
clabel WSelectBufferTemplate
WSelectBufferTemplate:
      .byte $04, $20, $73, $01, $00, $00



;-------------------------------------------------------------------------------------

cproc DemoEngine
  ldx DemoAction         ;load current demo action
  lda DemoActionTimer    ;load current action timer
  bne DoAction           ;if timer still counting down, skip
  inx
  inc DemoAction         ;if expired, increment action, X, and
  sec                    ;set carry by default for demo over
  lda DemoTimingData-1,x ;get next timer
  sta DemoActionTimer    ;store as current timer
  beq DemoOver           ;if timer already at zero, skip
DoAction:
  lda DemoActionData-1,x ;get and perform action (current or next)
  sta SavedJoypad1Bits
  dec DemoActionTimer    ;decrement action timer
  clc                    ;clear carry if demo still going
DemoOver:
  rts

DemoActionData:
      .byte $01, $80, $02, $81, $41, $80, $01
      .byte $42, $c2, $02, $80, $41, $c1, $41, $c1
      .byte $01, $c1, $01, $02, $80, $00

DemoTimingData:
      .byte $9b, $10, $18, $05, $2c, $20, $24
      .byte $15, $5a, $10, $20, $28, $30, $20, $10
      .byte $80, $20, $30, $30, $01, $ff, $00
.endproc


;-------------------------------------------------------------------------------------

.proc VictoryMode

  ; lda #0
  ; sta PlayerOAMOffset
  lda #4 * 4 ; save enough room to draw the player first later
  sta CurrentOAMOffset
  
  jsr VictoryModeSubroutines  ;run victory mode subroutines
  lda OperMode_Task           ;get current task of victory mode
  beq AutoPlayer              ;if on bridge collapse, skip enemy processing
  ldx #$00
  stx ObjectOffset            ;otherwise reset enemy object offset 
  ; TODO Consolidate farcall 
  farcall EnemiesAndLoopsCore     ;and run enemy code
AutoPlayer:
  jsr RelativePlayerPosition  ;get player's relative coordinates
  farcall PlayerGfxHandler    ;draw the player, then leave
  
  farcall DrawAllMetasprites, jmp

.endproc

.proc VictoryModeSubroutines
  lda OperMode_Task
  jsr JumpEngine

  .word BridgeCollapseJmp
  .word SetupVictoryMode
  .word PlayerVictoryWalk
  .word PrintVictoryMessages
  .word PlayerEndWorld
.endproc

.proc BridgeCollapseJmp
  farcall BridgeCollapse, jmp
.endproc

;-------------------------------------------------------------------------------------

.proc SetupVictoryMode
  ldx ScreenRight_PageLoc  ;get page location of right side of screen
  inx                      ;increment to next page
  stx DestinationPageLoc   ;store here
  lda #EndOfCastleMusic
  sta EventMusicQueue      ;play win castle music
  inc OperMode_Task
  rts
.endproc

;-------------------------------------------------------------------------------------
; TODO jroweboy move this to player.s maybe
.proc PlayerVictoryWalk
  ldy #$00                ;set value here to not walk player by default
  sty VictoryWalkControl
  lda Player_PageLoc      ;get player's page location
  cmp DestinationPageLoc  ;compare with destination page location
  bne PerformWalk         ;if page locations don't match, branch
  lda Player_X_Position   ;otherwise get player's horizontal position
  cmp #$60                ;compare with preset horizontal position
  bcs DontWalk            ;if still on other page, branch ahead
PerformWalk:
  inc VictoryWalkControl  ;otherwise increment value and Y
  iny                     ;note Y will be used to walk the player
DontWalk:
  tya                     ;put contents of Y in A and
  sta SavedJoypadBits
  farcall PlayerCtrlRoutine   ;use A to move player to the right or not
  lda ScreenLeft_PageLoc  ;check page location of left side of screen
  cmp DestinationPageLoc  ;against set value here
  beq ExitVWalk           ;branch if equal to change modes if necessary
  lda ScrollFractional
  clc                     ;do fixed point math on fractional part of scroll
  adc #$80        
  sta ScrollFractional    ;save fractional movement amount
  lda #$01                ;set 1 pixel per frame
  adc #$00                ;add carry from previous addition
  tay                     ;use as scroll amount
  farcall ScrollScreen        ;do sub to scroll the screen
  jsr UpdScrollVar        ;do another sub to update screen and scroll variables
  inc VictoryWalkControl  ;increment value to stay in this routine
ExitVWalk:
  lda VictoryWalkControl  ;load value set here
  ; jroweboy: Change from vanilla: just inc and rts here instead
  ; beq IncModeTask_A       ;if zero, branch to change modes
  ; rts                     ;otherwise leave
  bne DontIncModeTask
    inc OperMode_Task
DontIncModeTask:
  rts
.endproc

;-------------------------------------------------------------------------------------

.proc PrintVictoryMessages
  lda SecondaryMsgCounter   ;load secondary message counter
  bne IncMsgCounter         ;if set, branch to increment message counters
  lda PrimaryMsgCounter     ;otherwise load primary message counter
  beq ThankPlayer           ;if set to zero, branch to print first message
  ldy WorldNumber           ;check world number
  cpy #World8
  bne MRetainerMsg          ;if not at world 8, skip to next part
  cmp #$03                  ;check primary message counter again
  bcc IncMsgCounter         ;if not at 3 yet (world 8 only), branch to increment
  sbc #$01                  ;otherwise subtract one
  jmp ThankPlayer           ;and skip to next part
MRetainerMsg:
  cmp #$02                  ;check primary message counter
  bcc IncMsgCounter         ;if not at 2 yet (world 1-7 only), branch
ThankPlayer:
  tay                       ;put primary message counter into Y
  bne SecondPartMsg         ;if counter nonzero, skip this part, do not print first message
  lda CurrentPlayer         ;otherwise get player currently on the screen
  beq EvalForMusic          ;if mario, branch
  iny                       ;otherwise increment Y once for luigi and
  bne EvalForMusic          ;do an unconditional branch to the same place
SecondPartMsg:
  iny                       ;increment Y to do world 8's message
  lda WorldNumber
  cmp #World8               ;check world number
  beq EvalForMusic          ;if at world 8, branch to next part
  dey                       ;otherwise decrement Y for world 1-7's message
  cpy #$04                  ;if counter at 4 (world 1-7 only)
  bcs SetEndTimer           ;branch to set victory end timer
  cpy #$03                  ;if counter at 3 (world 1-7 only)
  bcs IncMsgCounter         ;branch to keep counting
EvalForMusic:
  cpy #$03                  ;if counter not yet at 3 (world 8 only), branch
  bne PrintMsg              ;to print message only (note world 1-7 will only
  lda #VictoryMusic         ;reach this code if counter = 0, and will always branch)
  sta EventMusicQueue       ;otherwise load victory music first (world 8 only)
PrintMsg:
  tya                       ;put primary message counter in A
  clc                       ;add $0c or 12 to counter thus giving an appropriate value,
  adc #$0c                  ;($0c-$0d = first), ($0e = world 1-7's), ($0f-$12 = world 8's)
  sta VRAM_Buffer_AddrCtrl  ;write message counter to vram address controller
IncMsgCounter:
  lda SecondaryMsgCounter
  clc
  adc #$04                      ;add four to secondary message counter
  sta SecondaryMsgCounter
  lda PrimaryMsgCounter
  adc #$00                      ;add carry to primary message counter
  sta PrimaryMsgCounter
  cmp #$07                      ;check primary counter one more time
SetEndTimer:
  bcc ExitMsgs                  ;if not reached value yet, branch to leave
  lda #$06
  sta WorldEndTimer             ;otherwise set world end timer
IncModeTask_A:
  inc OperMode_Task             ;move onto next task in mode
ExitMsgs:
  rts                           ;leave
.endproc

;-------------------------------------------------------------------------------------

.proc PlayerEndWorld

  lda WorldEndTimer          ;check to see if world end timer expired
  bne EndExitOne             ;branch to leave if not
  ldy WorldNumber            ;check world number
  cpy #World8                ;if on world 8, player is done with game, 
  bcs EndChkBButton          ;thus branch to read controller
  lda #$00
  sta AreaNumber             ;otherwise initialize area number used as offset
  sta LevelNumber            ;and level number control to start at area 1
  sta OperMode_Task          ;initialize secondary mode of operation
  ; jroweboy added:
  ; disable the screen since loading a new area pointer will change CHR banks
  inc DisableScreenFlag
  inc WorldNumber            ;increment world number to move onto the next world
  jsr LoadAreaPointer        ;get area address offset for the next area
  inc FetchNewGameTimerFlag  ;set flag to load game timer from header
  lda #MODE_GAMEPLAY
  sta OperMode               ;set mode of operation to game mode
EndExitOne:
  rts                        ;and leave
EndChkBButton:
  lda SavedJoypad1Bits
  ora SavedJoypad2Bits       ;check to see if B button was pressed on
  and #B_Button              ;either controller
  beq EndExitTwo             ;branch to leave if not
  lda #$01                   ;otherwise set world selection flag
  sta WorldSelectEnableFlag
  lda #$ff                   ;remove onscreen player's lives
  sta NumberofLives
  jsr RunGameOver::TerminateGame          ;do sub to continue other player or end game
EndExitTwo:
  rts                        ;leave
.endproc

.proc FloateyNumbersCore
  lda FloateyNum_Control,x     ;load control for floatey number
  beq EndFloateyNumber         ;if zero, branch to leave
    cmp #$0b                     ;if less than $0b, branch
    bcc ChkNumTimer
      lda #$0b                     ;otherwise set to $0b, thus keeping
      sta FloateyNum_Control,x     ;it in range
ChkNumTimer:
    tay                          ;use as Y
    lda FloateyNum_Timer,x       ;check value here
    bne DecNumTimer              ;if nonzero, branch ahead
      sta FloateyNum_Control,x     ;initialize floatey number control and leave
EndFloateyNumber:
  rts
DecNumTimer:
  dec FloateyNum_Timer,x       ;decrement value here
  cmp #$2b                     ;if not reached a certain point, branch  
  bne Exit
    cpy #$0b                     ;check offset for $0b
    bne LoadNumTiles             ;branch ahead if not found
      inc NumberofLives            ;give player one extra life (1-up)
      lda #Sfx_ExtraLife
      sta Square2SoundQueue        ;and play the 1-up sound
  LoadNumTiles:
    ldx ScoreUpdateDigit-1,y        ;load point value here
    lda ScoreUpdateAmount-1,y     ;load again and this time
    sta DigitModifier,x          ;store as amount to add to the digit
    farcall AddToScore, jmp      ;update the score accordingly
Exit:
  rts

;high nybble is digit number, low nybble is number to
;add to the digit of the player's score
ScoreUpdateData:
ScoreUpdateAmount:
  .byte $01, $02, $04, $05, $08
  .byte $01, $02, $04, $05, $08, $00
ScoreUpdateDigit:
  .byte $04, $04, $04, $04, $04
  .byte $03, $03, $03, $03, $03, $00

.endproc

;-------------------------------------------------------------------------------------
.proc DigitsMathRoutine
  lda OperMode              ;check mode of operation
  cmp #MODE_TITLESCREEN
  beq EraseDMods            ;if in title screen mode, branch to lock score
; ldx #$05
AddModLoop:
  lda DigitModifier,x       ;load digit amount to increment
  clc
  adc DisplayDigits,y       ;add to current digit
  bmi BorrowOne             ;if result is a negative number, branch to subtract
  cmp #10
  bcs CarryOne              ;if digit greater than $09, branch to add
StoreNewD:
  sta DisplayDigits,y       ;store as new score or game timer digit
  dey                       ;move onto next digits in score or game timer
  dex                       ;and digit amounts to increment
  bpl AddModLoop            ;loop back if we're not done yet
EraseDMods:
  lda #$00                  ;store zero here
  ldx #$06                  ;start with the last digit
EraseMLoop:
  sta DigitModifier-1,x     ;initialize the digit amounts to increment
  dex
  bpl EraseMLoop            ;do this until they're all reset, then leave
  rts
BorrowOne:
  dec DigitModifier-1,x     ;decrement the previous digit, then put $09 in
  lda #$09                  ;the game timer digit we're currently on to "borrow
  bne StoreNewD             ;the one", then do an unconditional branch back
CarryOne:
  sec                       ;subtract ten from our digit to make it a
  sbc #10                   ;proper BCD number, then increment the digit
  inc DigitModifier-1,x     ;preceding current digit to "carry the one" properly
  jmp StoreNewD             ;go back to just after we branched here
.endproc

.proc PrintStatusBarNumbers
  sta R0             ;store player-specific offset
  jsr OutputNumbers  ;use first nybble to print the coin display
  lda R0             ;move high nybble to low
  lsr                ;and print to score display
  lsr
  lsr
  lsr
OutputNumbers:
  clc                      ;add 1 to low nybble
  adc #$01
  and #%00001111           ;mask out high nybble
  cmp #$06
  bcs ExitOutputN
  pha                      ;save incremented value to stack for now and
    asl                      ;shift to left and use as offset
    tay
    ldx VRAM_Buffer1_Offset  ;get current buffer pointer
    lda #$20                 ;put at top of screen by default
    cpy #$00                 ;are we writing top score on title screen?
    bne SetupNums
    lda #$22                 ;if so, put further down on the screen
SetupNums:
    sta VRAM_Buffer1,x
    lda StatusBarData,y      ;write low vram address and length of thing
    sta VRAM_Buffer1+1,x     ;we're printing to the buffer
    lda StatusBarData+1,y
    sta VRAM_Buffer1+2,x
    sta R3                   ;save length byte in counter
    stx R2                   ;and buffer pointer elsewhere for now
  pla                      ;pull original incremented value from stack
  tax
  lda StatusBarOffset,x    ;load offset to value we want to write
  sec
  sbc StatusBarData+1,y    ;subtract from length byte we read before
  tay                      ;use value as offset to display digits
  ldx R2 
DigitPLoop:
  lda DisplayDigits,y      ;write digits to the buffer
  sta VRAM_Buffer1+3,x    
  inx
  iny
  dec R3                   ;do this until all the digits are written
  bne DigitPLoop
  lda #$00                 ;put null terminator at end
  sta VRAM_Buffer1+3,x
  inx                      ;increment buffer pointer by 3
  inx
  inx
  stx VRAM_Buffer1_Offset  ;store it in case we want to use it again
ExitOutputN:
  rts
  

;-------------------------------------------------------------------------------------
;$00 - used to store status bar nybbles
;$02 - used as temp vram offset
;$03 - used to store length of status bar number

;status bar name table offset and length data
StatusBarData:
  .byte $f0, $06 ; top score display on title screen
  .byte $62, $06 ; player score
  .byte $62, $06
  .byte $6d, $02 ; coin tally
  .byte $6d, $02
  .byte $7a, $03 ; game timer

StatusBarOffset:
  .byte TopScoreDisplay + TopScoreLastIndex - DisplayDigits + 1
  .byte Player1ScoreDisplay + PlayerScoreLastIndex - DisplayDigits + 1
  .byte Player2ScoreDisplay + PlayerScoreLastIndex - DisplayDigits + 1
  .byte Player1CoinDisplay + PlayerCoinLastIndex - DisplayDigits + 1
  .byte Player2CoinDisplay + PlayerCoinLastIndex - DisplayDigits + 1
  .byte GameTimerDisplay + GameTimerLastIndex - DisplayDigits + 1
.endproc
