
.segment "RENDER"

clabel InitScreen
clabel SetupIntermediate
clabel WriteTopStatusLine
clabel WriteBottomStatusLine
clabel DisplayTimeUp
clabel ResetSpritesAndScreenTimer
clabel DisplayIntermediate
clabel AreaParserTaskControl
clabel GetAreaPalette
clabel GetBackgroundColor
clabel GetAlternatePalette1
clabel DrawTitleScreen
clabel ClearBuffersDrawIcon
clabel WriteTopScore

;-------------------------------------------------------------------------------------

.proc ScreenRoutines

  lda ScreenRoutineTask        ;run one of the following subroutines
  jsr JumpEngine

  .word InitScreen
  .word SetupIntermediate
  .word WriteTopStatusLine
  .word WriteBottomStatusLine
  .word DisplayTimeUp
  .word ResetSpritesAndScreenTimer
  .word DisplayIntermediate
  .word ResetSpritesAndScreenTimer
  .word AreaParserTaskControl
  .word GetAreaPalette
  .word GetBackgroundColor
  .word GetAlternatePalette1
  .word DrawTitleScreen
  .word ClearBuffersDrawIcon
  .word WriteTopScore
.endproc


;-------------------------------------------------------------------------------------
InitScreen:
  lda Mirror_PPUMASK
  and #%00011000
  beq :+
    rts
  :
  farcall MoveAllSpritesOffscreen ;initialize all sprites including sprite #0
  jsr InitializeNameTables    ;and erase both name and attribute tables
  lda OperMode
  beq NextSubtask             ;if mode still 0, do not load
  ldx #UndergroundPaletteDataOffset ;into buffer pointer
  jmp SetVRAMAddr_A
  ; implicit rts

GetAreaPalette:
  ldy AreaType             ;select appropriate palette to load
  ldx AreaPalette,y        ;based on area type
SetVRAMAddr_A:
  VramSelectSourceX        ;store offset into buffer control
NextSubtask:
  jmp IncSubtask           ;move onto next task
AreaPalette:
  .byte WaterPaletteDataOffset, GroundPaletteDataOffset
  .byte UndergroundPaletteDataOffset, CastlePaletteDataOffset


;-------------------------------------------------------------------------------------
InitializeNameTables:

  lda PPUSTATUS            ;reset flip-flop
  lda Mirror_PPUCTRL       ;load mirror of ppu reg $2000
  ora #%00001000            ;set sprites for first 4k and background for second 4k
  and #%11101000            ;make sure to keep sprites and bg switched
  sta PPUCTRL         ;write contents of A to PPU register 1
  sta Mirror_PPUCTRL       ;and its mirror
  lda #$24                  ;set vram address to start of name table 1
  jsr WriteNTAddr
  lda #$20                  ;and then set it to name table 0
WriteNTAddr:
  sta PPUADDR
  lda #$00
  sta PPUADDR
  ldx #$04                  ;clear name table with blank tile #24
  ldy #$c0
  lda #$24
InitNTLoop:
  sta PPUDATA              ;count out exactly 768 tiles
  dey
  bne InitNTLoop
  dex
  bne InitNTLoop
  ldy #64                   ;now to clear the attribute table (with zero this time)
  txa
  VramQueueReset           ;init vram buffer 1
InitATLoop:
  sta PPUDATA
  dey
  bne InitATLoop
  sta HorizontalScroll      ;reset scroll variables
  sta VerticalScroll
  jmp InitScroll  ;initialize scroll registers to zero

;-------------------------------------------------------------------------------------

WriteTopStatusLine:
  lda #$00          ;select main status bar
  jsr WriteGameText ;output it
  jmp IncSubtask    ;onto the next task
  ;implicit rts

;-------------------------------------------------------------------------------------

SetupIntermediate:
  lda BackgroundColorCtrl  ;save current background color control
  pha                      ;and player status to stack
    lda PlayerStatus
    pha
      lda #$00                 ;set background color to black
      sta PlayerStatus         ;and player status to not fiery
      lda #$02                 ;this is the ONLY time background color control
      sta BackgroundColorCtrl  ;is set to less than 4
      jsr GetPlayerColors
    pla                      ;we only execute this routine for
    sta PlayerStatus         ;the intermediate lives display
  pla                      ;and once we're done, we return bg
  sta BackgroundColorCtrl  ;color ctrl and player status from stack
  jmp IncSubtask           ;then move onto the next task

;-------------------------------------------------------------------------------------
WriteBottomStatusLine:

  jsr GetSBNybbles        ;write player's score and coin tally to screen
  ldx VramQueueIndex
  lda #$00                ;new terminator first
  sta VramQueue+7,x
  lda #<(HUD_SCORE_ADDR+$13) ;write address for world-area number on screen
  sta VramQueue+1,x
  VramStoreEntry 3, VramQueue+2, x
  ldy WorldNumber         ;first the world number
  iny
  tya
  sta VramQueue+4,x
  lda #$28                ;next the dash
  sta VramQueue+5,x
  ldy LevelNumber         ;next the level number
  iny                     ;increment for proper number display
  tya
  sta VramQueue+6,x
  lda #>HUD_SCORE_ADDR    ;publish
  sta VramQueue,x
  txa                     ;move the buffer offset up by 7 bytes
  clc
  adc #$07
  sta VramQueueIndex
  jmp IncSubtask

;-------------------------------------------------------------------------------------

ResetSpritesAndScreenTimer:
  lda ScreenTimer             ;check if screen timer has expired
  bne NoReset                 ;if not, branch to leave
  farcall MoveAllSpritesOffscreen ;otherwise reset sprites now

ResetScreenTimer:
  lda #$07                    ;reset timer again
  sta ScreenTimer
  inc ScreenRoutineTask       ;move onto next task
NoReset:
  rts

;-------------------------------------------------------------------------------------

.proc DrawPlayer_Intermediate
;   ldx #$05                       ;store data into zero page memory
; PIntLoop:
;     lda IntermediatePlayerData,x   ;load data to display player as he always
;     sta R2 ,x                      ;appears on world/lives display
;     dex
;     bpl PIntLoop                   ;do this until all data is loaded
;   ldx #$b8                       ;load offset for small standing
;   ldy #$04                       ;load sprite data offset
;   jsr              ;draw player accordingly
;   lda Sprite_Attributes+36       ;get empty sprite attributes
;   ora #%01000000                 ;set horizontal flip bit for bottom-right sprite
;   sta Sprite_Attributes+32       ;store and leave
  lda #METASPRITE_SMALL_MARIO_STANDING
  sta ObjectMetasprite
  lda #CHR_SMALLMARIO
  sta PlayerChrBank
  inc ReloadCHRBank
  lda IntermediatePlayerData+0
  sta SprObject_Y_Position
  lda IntermediatePlayerData+1
  sta PlayerFacingDir
  lda IntermediatePlayerData+2
  sta SprObject_SprAttrib
  lda IntermediatePlayerData+3
  sta SprObject_X_Position
  lda ScreenLeft_PageLoc
  sta SprObject_PageLoc
  lda #1
  sta SprObject_Y_HighPos
  rts
IntermediatePlayerData:
  .byte $58, $01, $00, $60 ; , $ff, $04

.endproc


.proc DisplayIntermediate
  lda OperMode                 ;check primary mode of operation
  beq NoInter                  ;if in title screen mode, skip this
  cmp #MODE_GAMEOVER           ;are we in game over mode?
  beq GameOverInter            ;if so, proceed to display game over screen
  lda AltEntranceControl       ;otherwise check for mode of alternate entry
  bne NoInter                  ;and branch if found
  ldy AreaType                 ;check if we are on castle level
  cpy #$03                     ;and if so, branch (possibly residual)
  beq PlayerInter
  lda DisableIntermediate      ;if this flag is set, skip intermediate lives display
  bne NoInter                  ;and jump to specific task, otherwise
PlayerInter:
  jsr DrawPlayer_Intermediate  ;put player in appropriate place for
  lda #0
  ldy #0
  ldx ObjectMetasprite
  farcall DrawMetasprite
  lda #$01                     ;lives display, then output lives display to buffer
OutputInter:
  jsr WriteGameText
  jsr ResetScreenTimer
  lda #$00
  sta DisableScreenFlag        ;reenable screen output
  rts
GameOverInter:
  lda #$12                     ;set screen timer
  sta ScreenTimer
  lda #$03                     ;output game over screen to buffer
  jsr WriteGameText
  jmp IncModeTask_B
NoInter:
  lda #$08                     ;set for specific task and leave
  sta ScreenRoutineTask
  rts
.endproc

;-------------------------------------------------------------------------------------

DisplayTimeUp:
  lda GameTimerExpiredFlag  ;if game timer not expired, increment task
  beq NoTimeUp              ;control 2 tasks forward, otherwise, stay here
  lda #$00
  sta GameTimerExpiredFlag  ;reset timer expiration flag
  lda #$02                  ;output time-up screen to buffer
  jmp DisplayIntermediate::OutputInter
NoTimeUp:
  inc ScreenRoutineTask     ;increment control task 2 tasks forward
  jmp IncSubtask

;-------------------------------------------------------------------------------------

.proc AreaParserTaskControl
  inc DisableScreenFlag     ;turn off screen
  lda #$00                  ;the set is too big for the column region, and the queue
  sta VramBuffer            ;is empty here, so build it from the start of the buffer
  sta VramColumnIndex
  sta VramColumnStart
  farcall AreaParserTaskLoop
  dec ColumnSets            ;do we need to render more column sets?
  bpl OutputCol
    inc ScreenRoutineTask     ;if not, move on to the next task
OutputCol:
  VramSelectSource VramSrcColumn ;output rendered column set on next NMI
  rts
.endproc

;-------------------------------------------------------------------------------------
;$00 - used as temp counter in GetPlayerColors
GetBackgroundColor:
  ldy BackgroundColorCtrl   ;check background color control
  beq NoBGColor             ;if not set, increment task and fetch palette
  lda BGColorCtrl_Addr-4,y  ;put appropriate palette into vram
  VramSelectSourceA         ;note that if set to 5-7, $0301 will not be read
NoBGColor:
  inc ScreenRoutineTask     ;increment to next subtask and plod on through    
  ;fallthrough

GetPlayerColors:
  ldx VramQueueIndex       ;get current buffer offset
  lda #$00
  sta VramQueue+8,x        ;new terminator first
  ldy #$00
  lda CurrentPlayer        ;check which player is on the screen
  beq ChkFiery
  ldy #$04                 ;load offset for luigi
ChkFiery:
  lda PlayerStatus         ;check player status
  cmp #$02
  bne StartClrGet          ;if fiery, load alternate offset for fiery player
  ldy #$08
StartClrGet:
  lda #$03                 ;do four colors
  sta R0 
ClrGetLoop:
  lda PlayerColors,y       ;fetch player colors and store them
  sta VramQueue+4,x        ;in the buffer
  iny
  inx
  dec R0 
  bpl ClrGetLoop
  txa                      ;back to the original offset
  sec
  sbc #$04
  tax
  ldy BackgroundColorCtrl  ;if this value is four or greater, it will be set
  bne SetBGColor           ;therefore use it as offset to background color
  ldy AreaType             ;otherwise use area type bits from area offset as offset
SetBGColor:
  lda BackgroundColors,y   ;to background color instead
  sta VramQueue+4,x
  lda #$10                 ;set for sprite palette address
  sta VramQueue+1,x
  VramStoreEntry 4, VramQueue+2, x
  lda #$3f                 ;publish
  sta VramQueue,x
  txa                      ;move the buffer pointer ahead 8 bytes
  clc                      ;in case we want to write anything else later
  adc #$08
SetVRAMOffset:
  sta VramQueueIndex       ;store as new vram buffer offset
  rts

BGColorCtrl_Addr:
      .byte VramSrcQueue, DaySnowPaletteDataOffset
      .byte NightSnowPaletteDataOffset, CastlePaletteDataOffset

BackgroundColors:
      .byte $22, $22, $0f, $0f ;used by area type if bg color ctrl not set
      .byte $0f, $22, $0f, $0f ;used by background color control if set

PlayerColors:
      .byte $22, $16, $27, $18 ;mario's colors
      .byte $22, $30, $27, $19 ;luigi's colors
      .byte $22, $37, $27, $16 ;fiery (used by both)


;-------------------------------------------------------------------------------------

GetAlternatePalette1:
  lda AreaStyle            ;check for mushroom level style
  cmp #$01
  bne NoAltPal
  lda #MushroomPaletteDataOffset ;if found, load appropriate palette

SetVRAMAddr_B:
  VramSelectSourceA
NoAltPal:
  jmp IncSubtask           ;now onto the next task

;-------------------------------------------------------------------------------------

;$00 - vram buffer address table low
;$01 - vram buffer address table high

DrawTitleScreen:
  lda OperMode                 ;are we in title screen mode?
  bne IncModeTask_B            ;if not, exit
  lda #TitleScreenDataOffset   ;set buffer transfer control to $0300,
  jmp SetVRAMAddr_B            ;increment task and exit

;-------------------------------------------------------------------------------------

WriteTopScore:
  lda #$fa           ;run display routine to display top score on title
  jsr UpdateNumber
IncModeTask_B:
  inc OperMode_Task  ;move onto next mode
  rts
;-------------------------------------------------------------------------------------

ClearBuffersDrawIcon:
  lda OperMode               ;check game mode
  bne IncModeTask_B          ;if not title screen mode, leave
; Vanilla cleared 512 bytes from the old VRAM buffer, which also reset these variables
ICON_CLEAR_SIZE = HammerEnemyOffset + 2 - BowserBodyControls
  ldx #$00                   ;A is 0 here
TScrClear:
  sta BowserBodyControls,x
  sta BowserBodyControls+ICON_CLEAR_SIZE-$100,x
  dex
  bne TScrClear
  jsr VramReset
  jsr DrawMushroomIcon       ;draw player select icon
IncSubtask:
  inc ScreenRoutineTask      ;move onto next task
  rts

;-------------------------------------------------------------------------------------

cproc DrawMushroomIcon
  lda #$00                ;empty the list while it is replaced
  sta VramQueue
  ldy #$07
IconDataRead:
  lda MushroomIconData,y  ;note that the default position is set for a
  sta VramQueue,y         ;1-player game
  dey
  bne IconDataRead
  lda NumberOfPlayers     ;check number of players
  beq ExitIcon            ;if set to 1-player game, we're done
  lda #$24                ;otherwise, load blank tile in 1-player position
  sta VramQueue+4
  lda #$2a                ;then load shroom icon tile in 2-player position
  sta VramQueue+6
ExitIcon:
  lda MushroomIconData    ;publish
  sta VramQueue
  lda #$07
  sta VramQueueIndex
  rts
MushroomIconData:
  VramBuf $a1c9, 3     ;d15 set: vertical
  .byte $2a, $24, $24, $00
.endproc


;-------------------------------------------------------------------------------------
cproc WriteGameText
  pha                      ;save text number to stack
    asl
    tay                      ;multiply by 2 and use as offset
    cpy #$04                 ;if set to do top status bar or world/lives display,
    bcc LdGameText           ;branch to use current offset as-is
    cpy #$08                 ;if set to do time-up or game over,
    bcc Chk2Players          ;branch to check players
    ldy #$08                 ;otherwise warp zone, therefore set offset
Chk2Players:
    lda NumberOfPlayers      ;check for number of players
    bne LdGameText           ;if there are two, use current offset to also print name
    iny                      ;otherwise increment offset by one to not print name
LdGameText:
    ldx GameTextOffsets,y    ;get offset to message we want to print
    lda GameTextEnds,y
    sta M0
    lda #$00                 ;empty the list while it is replaced
    sta VramQueue
    lda GameText,x           ;hold back the first byte
    pha
      inx
      ldy #$01
GameTextLoop:
        lda GameText,x         ;load message data
        sta VramQueue,y        ;write data to buffer
        inx                    ;and increment increment
        iny
        cpx M0
        bne GameTextLoop
      lda #$00                 ;put null terminator at end
      sta VramQueue,y
      sty M1                   ;length of the message
    pla
    sta M0
  pla                      ;pull original text number from stack
  jsr PatchGameText
  lda M0                   ;publish
  sta VramQueue
  lda M1                   ;later queue writes go after the message
  sta VramQueueIndex
  rts

PatchGameText:
  tax
  cmp #$04                 ;are we printing warp zone?
  bcs PrintWarpZoneNumbers
  dex                      ;are we printing the world/lives display?
  bne CheckPlayerName      ;if not, branch to check player's name
  lda NumberofLives        ;otherwise, check number of lives
  clc                      ;and increment by one for display
  adc #$01
  cmp #10                  ;more than 9 lives?
  bcc PutLives
  sbc #10                  ;if so, subtract 10 and put a crown tile
  ldy #$9f                 ;next to the difference...strange things happen if
  sty VramQueue+LivesCrownPos          ;the number of lives exceeds 19
PutLives:
  sta VramQueue+LivesCountPos
  ldy WorldNumber          ;write world and level numbers (incremented for display)
  iny                      ;to the buffer in the spaces surrounding the dash
  sty VramQueue+LivesWorldPos
  ldy LevelNumber
  iny
  sty VramQueue+LivesWorldPos+2        ;we're done here
  rts
CheckPlayerName:
  lda NumberOfPlayers    ;check number of players
  beq ExitChkName        ;if only 1 player, leave
  lda CurrentPlayer      ;load current player
  dex                    ;check to see if current message number is for time up
  bne ChkLuigi
  ldy OperMode           ;check for game over mode
  cpy #MODE_GAMEOVER
  beq ChkLuigi
  eor #%00000001         ;if not, must be time up, invert d0 to do other player
ChkLuigi:
  lsr
  bcc ExitChkName        ;if mario is current player, do not change the name
    ldy #$04
    cpx #$fe               ;the top status bar has the name at another position
    beq TopNameLoop
NameLoop:
      lda LuigiName,y        ;otherwise, replace "MARIO" with "LUIGI"
      sta VramQueue+TimeUpNamePos,y
      dey
      bpl NameLoop           ;do this until each letter is replaced
ExitChkName:
  rts
TopNameLoop:
  lda LuigiName,y
  sta VramQueue+TopNamePos,y
  dey
  bpl TopNameLoop
  rts

PrintWarpZoneNumbers:
  sbc #$04               ;subtract 4 and then shift to the left
  asl                    ;twice to get proper warp zone number
  asl                    ;offset
  tax
  ldy #$00
WarpNumLoop:
    lda WarpZoneNumbers,x  ;print warp zone numbers into the
    sta VramQueue+WarpNumberPos,y ;placeholders from earlier
    inx
    tya                    ;put a number in the data byte of each pipe packet
    clc
    adc #WarpNumberStride
    tay
    cpy #WarpNumberStride * 3
    bcc WarpNumLoop
  rts


endcproc

GameText:
TopStatusBarLine:
; jroweboy: moved the attribute writes first which fixes a glitchy transition between levels.
; if the last byte written in nmi is in the attribute tables, it affects the scroll for the
; next frame, so this works around it by making sure attributes aren't last.
  VramFill $23c0, 64, $aa ; attribute table data, clears name table 0 to palette 2
  VramFill $27f8, 8, $aa  ; lower half of the status bar
  VramBuf $27fa, 1        ; attribute table data, used for coin icon in status bar
  .byte $ae
  VramBuf HUD_LABEL_ADDR+$03, 5
TopStatusName:
  .byte "MARIO"
  VramBuf HUD_LABEL_ADDR+$12, 11
  .byte "WORLD  TIME"
  VramBuf HUD_SCORE_ADDR+$08, 5
  .byte "0  ", $2e, $29      ; score trailing digit and coin display

WorldLivesDisplay:
  VramBuf $23d4, 1        ; attribute table data for crown if more than 9 lives
  .byte $ba
  VramBuf $214d, 7        ; cross with spaces used on
LivesData:
  .byte $24, $24, $29, $24, $24, $24, $24 ; lives display
  VramBuf $20cb, 9
LivesWorldData:
  .byte "WORLD  - "
  VramFill $218c, 7, $24  ; possibly used to clear time up

TwoPlayerTimeUp:
; jroweboy since we reordered the attribute writes to fix a glitchy transition
; we need to pad out the time up and game over messages with a blank first packet
  VramBuf $214d, 5
  .byte "     "
  VramBuf $214d, 5
TimeUpName:
  .byte "MARIO"
OnePlayerTimeUp:
  VramBuf $218c, 7
  .byte "TIME UP"

TwoPlayerGameOver:
  VramBuf $214d, 5
  .byte "     "
  VramBuf $214d, 5
GameOverName:
  .byte "MARIO"
OnePlayerGameOver:
  VramBuf $218b, 9
  .byte "GAME OVER"

WarpZoneWelcome:
  VramBuf $2504, 21
  .byte "WELCOME TO WARP ZONE!"
  VramBuf $25a5, 1        ; placeholder for left pipe
WarpPipeLeft:
  .byte $24
  VramBuf $25ad, 1        ; placeholder for middle pipe
WarpPipeMiddle:
  .byte $24
  VramBuf $25b5, 1        ; placeholder for right pipe
  .byte $24
  VramFill $27d1, 6, $aa  ; attribute data
  VramFill $27d9, 5, $aa
WarpZoneWelcomeEnd:

; Offsets into the buffer of the data that gets patched after a message is copied
TopNamePos       = TopStatusName - TopStatusBarLine
TimeUpNamePos    = TimeUpName - TwoPlayerTimeUp
LivesCrownPos    = LivesData + 4 - WorldLivesDisplay
LivesCountPos    = LivesData + 5 - WorldLivesDisplay
LivesWorldPos    = LivesWorldData + 6 - WorldLivesDisplay
WarpNumberPos    = WarpPipeLeft - WarpZoneWelcome
WarpNumberStride = WarpPipeMiddle - WarpPipeLeft
.assert GameOverName - TwoPlayerGameOver = TimeUpNamePos, error, "Time up and game over names must line up"
.assert WarpZoneWelcomeEnd - GameText <= $ff, error, "GameText offsets must fit in a byte"

LuigiName:
  .byte "LUIGI"

WarpZoneNumbers:
  .byte "432", $00         ; warp zone numbers, note spaces on middle
  .byte " 5 ", $00         ; zone, partly responsible for
  .byte "876", $00         ; the minus world

GameTextOffsets:
  .byte TopStatusBarLine-GameText, TopStatusBarLine-GameText
  .byte WorldLivesDisplay-GameText, WorldLivesDisplay-GameText
  .byte TwoPlayerTimeUp-GameText, OnePlayerTimeUp-GameText
  .byte TwoPlayerGameOver-GameText, OnePlayerGameOver-GameText
  .byte WarpZoneWelcome-GameText, WarpZoneWelcome-GameText

GameTextEnds:
  .byte WorldLivesDisplay-GameText, WorldLivesDisplay-GameText
  .byte TwoPlayerTimeUp-GameText, TwoPlayerTimeUp-GameText
  .byte TwoPlayerGameOver-GameText, TwoPlayerGameOver-GameText
  .byte WarpZoneWelcome-GameText, WarpZoneWelcome-GameText
  .byte WarpZoneWelcomeEnd-GameText, WarpZoneWelcomeEnd-GameText


.proc SetupPipeTransitionOverlay
  rts
;   sta InPipeTransition
;   beq ClearTransition
;   cmp #1
;   beq IsDownPipe
;   cmp #2
;   beq IsRightPipe
;   ; fallthrough
; RisingEntrance:
;   lda #$90 + 32
;   sta PipeYPosition
;   jmp IsDownPipe
; ClearTransition:
;   ; reset the color for the palette back to the original
;   lda #$27
;   jmp SetPaletteColor
;   ; rts
; IsRightPipe:
;   lda Player_X_Position   ;get player's horizontal coordinate
;   clc
;   adc #$08 + 16                ;add eight pixels
;   and #$f0                ;mask out low nybble to give 16-pixel correspondence
;   sta PipeXPosition
;   lda Player_Y_Position
;   sta PipeYPosition
;   jmp ChangeColorToBackground
; IsDownPipe:
;   lda RelativePlayerPosition
;   sta PipeXPosition
;   ; fallthrough
; ChangeColorToBackground:
;   ldy BackgroundColorCtrl
;   bne :+
;     ldy AreaType
; :
;   lda BackgroundColors,y   ;to background color instead
;   ; jmp SetPaletteColor
;   ; fallthrough
; SetPaletteColor:
;   ldx VramQueueIndex
;   sta VramQueue+3,x
;   lda #$3f
;   sta VramQueue+0,x
;   lda #$1b
;   sta VramQueue+1,x
;   lda #1
;   sta VramQueue+2,x
;   lda #0
;   sta VramQueue+4,x
;   lda VramQueueIndex
;   clc 
;   adc #4
;   sta VramQueueIndex
;   rts
.endproc


;-------------------------------------------------------------------------------------
GiveOneCoin:
  lda #$01               ;set digit modifier to add 1 coin
  sta DigitModifier+PlayerCoinLastIndex    ;to the current player's coin tally
  ldx CurrentPlayer      ;get current player on the screen
  ldy CoinTallyOffsets,x ;get offset for player's coin tally
  ldx #PlayerCoinLastIndex
  jsr DigitsMathRoutine  ;update the coin tally
  inc CoinTally          ;increment onscreen player's coin amount
  lda CoinTally
  cmp #100               ;does player have 100 coins yet?
  bne CoinPoints         ;if not, skip all of this
  lda #$00
  sta CoinTally          ;otherwise, reinitialize coin amount
  inc NumberofLives      ;give the player an extra life
  lda #Sfx_ExtraLife
  sta Square2SoundQueue  ;play 1-up sound

CoinPoints:
  lda #$02               ;set digit modifier to award
  sta DigitModifier+PlayerScoreLastIndex-1    ;200 points to the player

AddToScore:
  ldx CurrentPlayer      ;get current player
  ldy ScoreOffsets,x     ;get offset for player's score
  ldx #PlayerScoreLastIndex
  jsr DigitsMathRoutine  ;update the score internally with value in digit modifier

GetSBNybbles:
  ldy CurrentPlayer      ;get current player
  lda StatusBarNybbles,y ;get nybbles based on player, use to update score and coins

UpdateNumber:
  jsr PrintStatusBarNumbers ;print status bar numbers based on nybbles, whatever they be
  ldy VramQueueIndex
  ldx ObjectOffset          ;get enemy object buffer offset
  rts
      
CoinTallyOffsets:
  .byte (Player1CoinDisplay + PlayerCoinLastIndex - DisplayDigits)
  .byte (Player2CoinDisplay + PlayerCoinLastIndex - DisplayDigits)

ScoreOffsets:
  .byte (Player1ScoreDisplay + PlayerScoreLastIndex - DisplayDigits)
  .byte (Player2ScoreDisplay + PlayerScoreLastIndex - DisplayDigits)

StatusBarNybbles:
  .byte $02, $13


;-------------------------------------------------------------------------------------
.proc UpdateTopScore
  ldx #5                 ;start with mario's score
  jsr TopScoreCheck
  ldx #5 + 6             ;now do luigi's score
TopScoreCheck:
  ldy #5                 ;start with the lowest digit
  sec           
GetScoreDiff:
  lda PlayerScoreDisplay,x ;subtract each player digit from each high score digit
  sbc TopScoreDisplay,y    ;from lowest to highest, if any top score digit exceeds
  dex                      ;any player digit, borrow will be set until a subsequent
  dey                      ;subtraction clears it (player digit is higher than top)
  bpl GetScoreDiff      
  bcc NoTopSc              ;check to see if borrow is still set, if so, no new high score
  inx                      ;increment X and Y once to the start of the score
  iny
CopyScore:
  lda PlayerScoreDisplay,x ;store player's score digits into high score memory area
  sta TopScoreDisplay,y
  inx
  iny
  cpy #$06                 ;do this until we have stored them all
  bcc CopyScore
NoTopSc:
  rts
.endproc

;-------------------------------------------------------------------------------------
;$00 - temp store for offset control bit
;$01 - temp vram buffer offset
;$02 - temp store for vertical high nybble in block buffer routine
;$03 - temp adder for high byte of name table address
;$04, $05 - name table address low/high
;$06, $07 - block buffer address low/high

.proc RemoveCoin_Axe
  ldy VramColumnIndex      ;append to the column list
  lda #$03                 ;load offset for default blank metatile
  ldx AreaType             ;check area type
  bne :+                   ;if not water type, use offset
    lda #$04                 ;otherwise load offset for blank metatile used in water
:
  jsr PutBlockMetatile     ;do a sub to write blank metatile to vram buffer
  tya
  clc
  adc #BLOCK_PACKETS_SIZE
  sta VramColumnIndex
  VramSelectSource VramSrcColumn ;upload the column list and leave
  rts
.endproc

; Two packets of two tiles
BLOCK_PACKETS_SIZE = 12

DestroyBlockMetatile:
  lda #$00       ;force blank metatile if branched/jumped to this point
WriteBlockMetatile:
  ldy #$03                ;load offset for blank metatile
  cmp #$00                ;check contents of A for blank metatile
  beq UseBOffset          ;branch if found (unconditional if branched from 8a6b)
  ldy #$00                ;load offset for brick metatile w/ line
  cmp #$58
  beq UseBOffset          ;use offset if metatile is brick with coins (w/ line)
  cmp #$51
  beq UseBOffset          ;use offset if metatile is breakable brick w/ line
  iny                     ;increment offset for brick metatile w/o line
  cmp #$5d
  beq UseBOffset          ;use offset if metatile is brick with coins (w/o line)
  cmp #$52
  beq UseBOffset          ;use offset if metatile is breakable brick w/o line
  iny                     ;if any other metatile, increment offset for empty block
UseBOffset:
  tya                     ;put Y in A
  ldy VramQueueIndex      ;get vram buffer offset
  jsr PutBlockMetatile    ;get appropriate block data and write to vram buffer
MoveVOffset:
  tya                     ;add both packets to the vram buffer offset
  clc
  adc #BLOCK_PACKETS_SIZE
  jmp SetVRAMOffset       ;branch to store as new vram buffer offset
PutBlockMetatile:
  stx R0                ;store control bit from SprDataOffset_Ctrl
  sty R1                ;store vram buffer offset for next byte
  asl
  asl                   ;multiply A by four and use as X
  tax
  ldy #$20              ;load high byte for name table 0
  lda R6                ;get low byte of block buffer pointer
  cmp #$d0              ;check to see if we're on odd-page block buffer
  bcc SaveHAdder        ;if not, use current high byte
  ldy #$24              ;otherwise load high byte for name table 1
SaveHAdder:
  sty R3                ;save high byte here
  and #$0f              ;mask out high nybble of block buffer pointer
  asl                   ;multiply by 2 to get appropriate name table low byte
  sta R4                ;and then store it here
  lda #$00
  sta R5                ;initialize temp high byte
  lda R2                ;get vertical high nybble offset used in block buffer routine
  asl
  rol R5                ;shift and rotate d7 onto d0 and d6 into carry
  asl
  rol R5                ;shift and rotate d6 onto d0 and d5 into carry
  adc R4                ;add low byte of name table and carry to vertical high nybble
  sta R4                ;and store here
  lda R5                ;get whatever was in d7 and d6 of vertical high nybble
  adc #$00              ;add carry
  clc
  adc R3                ;then add high byte of name table
  sta R5                ;store here
  ldy R1                ;get vram buffer offset to be used
  ;fallthrough
RemBridge:
  lda #$00
  sta VramQueue+BLOCK_PACKETS_SIZE,y ;new terminator first
  lda BlockGfxData,x    ;write top left and top right
  sta VramQueue+4,y     ;tile numbers into first spot
  lda BlockGfxData+1,x
  sta VramQueue+5,y
  lda BlockGfxData+2,x  ;write bottom left and bottom
  sta VramQueue+10,y    ;right tiles numbers into
  lda BlockGfxData+3,x  ;second spot
  sta VramQueue+11,y
  lda R4 
  sta VramQueue+1,y     ;write low byte of name table
  clc                   ;into first slot as read
  adc #$20              ;add 32 bytes to value
  sta VramQueue+7,y     ;write low byte of name table
  lda #<VramBufEntry(2) ;put entry words in
  sta VramQueue+2,y     ;both slots
  sta VramQueue+8,y
  lda #>VramBufEntry(2)
  sta VramQueue+3,y
  sta VramQueue+9,y
  lda R5                ;write high byte of name table address to both slots,
  sta VramQueue+6,y     ;the first one last to publish
  sta VramQueue,y
  ldx R0                ;get offset control bit here
  rts                   ;and leave

BlockGfxData:
  .byte $47, $47, $48, $48
  .byte $48, $48, $48, $48
  .byte $AE, $AF, $BE, $BF
  .byte $24, $24, $24, $24
  .byte $26, $26, $26, $26


;-------------------------------------------------------------------------------------
;$00 - temp vram buffer offset
;$01 - temp metatile buffer offset
;$02 - temp metatile graphics table offset
;$03 - used to store attribute bits
;$04 - used to determine attribute table row
;$05 - used to determine attribute table column
;$06 - metatile graphics table address low
;$07 - metatile graphics table address high

RenderAreaGraphics:
  lda CurrentColumnPos         ;store LSB of where we're at
  and #$01
  sta R5
  ldy VramColumnIndex          ;store vram buffer offset
  sty R0
COLUMN_TILES = 26
COLUMN_PACKET_SIZE = 4 + COLUMN_TILES
  lda #$00                     ;new terminator first
  sta VramBuffer+COLUMN_PACKET_SIZE,y
  lda CurrentNTAddr_Low        ;get current name table address we're supposed to render
  sta VramBuffer+1,y
  VramStoreEntry COLUMN_TILES, VramBuffer+2, y
  lda #$00                     ;init attribute row
  sta R4
  tax
DrawMTLoop: 
  stx R1                       ;store init value of 0 or incremented offset for buffer

  ldy MetatileBuffer,x         ;get metatile number in y
  ldx R0
  lda AreaParserTaskNum        ;get current task number for level processing and check bit 0
  lsr                          ;if the carry is clear, then we are rendering the second row of mtiles, so use the right versions
  bcc @RightSideOfMtile
    ; Rendering the left side of the metatile, so load and store the two tiles for this column
    lda MTileTopLeft,y
    sta VramBuffer+4,x
    lda MTileBotLeft,y
    sta VramBuffer+5,x
    jmp @UpdateAttributes
@RightSideOfMtile:
    ; Render the right side tiles and then fallthrough to get the attributes and update them
    lda MTileTopRight,y
    sta VramBuffer+4,x
    lda MTileBotRight,y
    sta VramBuffer+5,x
    ; fallthrough
@UpdateAttributes:
  lda MTileAttribute,y
  and #%11000000
  sta R3                       ;store attribute table bits here
  ldy R4                       ;get current attribute row
  lda R5                       ;get LSB of current column where we're at, and
  bne RightCheck               ;branch if set (clear = left attrib, set = right)
    lda R1                       ;get current row we're rendering
    lsr                          ;branch if LSB set (clear = top left, set = bottom left)
    bcs LLeft
      rol R3                       ;rotate attribute bits 3 to the left
      rol R3                       ;thus in d1-d0, for upper left square
      rol R3 
      jmp SetAttrib
RightCheck:
  lda R1                       ;get LSB of current row we're rendering
  lsr                          ;branch if set (clear = top right, set = bottom right)
  bcs NextMTRow
    lsr R3                       ;shift attribute bits 4 to the right
    lsr R3                       ;thus in d3-d2, for upper right square
    lsr R3 
    lsr R3 
    jmp SetAttrib
LLeft:
    lsr R3                       ;shift attribute bits 2 to the right
    lsr R3                       ;thus in d5-d4 for lower left square
NextMTRow:
    inc R4                       ;move onto next attribute row  
SetAttrib:
  lda AttributeBuffer,y        ;get previously saved bits from before
  ora R3                       ;if any, and put new bits, if any, onto
  sta AttributeBuffer,y        ;the old, and store
  inc R0                       ;increment vram buffer offset by 2
  inc R0 
  ldx R1                       ;get current gfx buffer row, and check for
  inx                          ;the bottom of the screen
  cpx #$0d
  bcc DrawMTLoop               ;if not there yet, loop back
            lda R0                       ;get current vram buffer offset, increment by 4
            clc                          ;(for name table address and entry word)
            adc #$04
            tay
            sty VramColumnIndex          ;store new buffer offset
            lda CurrentNTAddr_High       ;d7 set to increment by 32 (in columns)
            ora #$80
            sta VramBuffer-COLUMN_PACKET_SIZE,y ;publish
            inc CurrentNTAddr_Low        ;increment name table address low
            lda CurrentNTAddr_Low        ;check current low byte
            and #%00011111               ;if no wraparound, just skip this part
            bne ExitDrawM
            lda #$00                     ;if wraparound occurs, go back to
            sta CurrentNTAddr_Low        ;the top of the playfield
            lda CurrentNTAddr_High       ;and then invert d2 of the name table address high
            eor #%00000100               ;to move onto the next appropriate name table
            sta CurrentNTAddr_High
ExitDrawM:  jmp SetVRAMCtrl              ;jump to set buffer to $0341 and leave

;-------------------------------------------------------------------------------------
;$00 - temp attribute table address high (big endian order this time!)
;$01 - temp attribute table address low

RenderAttributeTables:
             lda CurrentNTAddr_Low    ;get low byte of next name table address
             and #%00011111           ;to be written to, mask out all but 5 LSB,
             sec                      ;subtract four 
             sbc #$04
             and #%00011111           ;mask out bits again and store
             sta R1 
             lda CurrentNTAddr_High   ;get high byte and branch if borrow not set
             bcs SetATHigh
             eor #%00000100           ;otherwise invert d2
SetATHigh:   and #%00000100           ;mask out all other bits
             ora #$23                 ;add $2300 to the high byte and store
             sta R0 
             lda R1                   ;get low byte - 4, divide by 4, add offset for
             lsr                      ;attribute table and store
             lsr
             adc #$c0 - 8             ;one row early, as the loop adds a row before
             sta R1                   ;each write
ATTRIB_PACKET_SIZE = 5
ATTRIB_SET_SIZE = 7 * ATTRIB_PACKET_SIZE
.assert ATTRIB_SET_SIZE < VRAM_BUFFER_SIZE - VRAM_COLUMN_BASE, error, "Attribute packets overflow the column region"
.assert COLUMN_PACKET_SIZE < VRAM_BUFFER_SIZE - VRAM_COLUMN_BASE, error, "Column packet overflows the column region"
             ldx #$00
             ldy VramColumnIndex      ;get buffer offset
             txa
             sta VramBuffer+ATTRIB_SET_SIZE,y ;new terminator first
AttribLoop:  cpx #$00                 ;the first high byte publishes the whole set,
             beq SkipHigh             ;so it is written last
             lda R0 
             sta VramBuffer,y         ;store high byte of attribute table address
SkipHigh:    lda R1 
             clc                      ;get low byte, add 8 because we want to start
             adc #$08                 ;and store
             sta VramBuffer+1,y
             sta R1                   ;also store in temp again
             VramStoreEntry 1, VramBuffer+2, y
             lda AttributeBuffer,x    ;fetch current attribute table byte and store
             sta VramBuffer+4,y       ;in the buffer
             lda #$00
             sta AttributeBuffer,x    ;clear current byte in attribute buffer
             tya                      ;increment buffer offset to the next packet
             clc
             adc #ATTRIB_PACKET_SIZE
             tay
             inx                      ;increment attribute offset and check to see
             cpx #$07                 ;if we're at the end yet
             bcc AttribLoop
             sty VramColumnIndex      ;store offset in case we want to do any more
             lda R0 
             sta VramBuffer-ATTRIB_SET_SIZE,y ;publish
SetVRAMCtrl: VramSelectSource VramSrcColumn ;upload the column list and leave
             rts

;-------------------------------------------------------------------------------------
;METATILE GRAPHICS TABLE
MTILE_CURRENT_INDEX .set $00
.macro MTileDefine tl, bl, tr, br, attr
.ident(.sprintf("MTILE_TL_%d", MTILE_CURRENT_INDEX)) = tl
.ident(.sprintf("MTILE_BL_%d", MTILE_CURRENT_INDEX)) = bl
.ident(.sprintf("MTILE_TR_%d", MTILE_CURRENT_INDEX)) = tr
.ident(.sprintf("MTILE_BR_%d", MTILE_CURRENT_INDEX)) = br
.ident(.sprintf("MTILE_AT_%d", MTILE_CURRENT_INDEX)) = attr
MTILE_CURRENT_INDEX .set MTILE_CURRENT_INDEX + 1
.endmacro

MTILE_SOLID     = 1 << 0 ; Blocks that are collidable at all
MTILE_CLIMB     = 1 << 1 ; Climbable blocks
MTILE_BUMP      = 1 << 2 ; Solid blocks that also make a bump noise when hitting them with your head
; MTILE_DAMAGE    = 1 << 3 ; unimplemented
; MTILE_KILL      = 1 << 4 ; unimplemented
; MTILE_SWIM      = 1 << 5 ; unimplemented
MTILE_PALETTE_0 = 0 << 6
MTILE_PALETTE_1 = 1 << 6
MTILE_PALETTE_2 = 2 << 6
MTILE_PALETTE_3 = 3 << 6
; TODO: consider making a second batch of table entries for extended attributes
; TODO: update the level format to condense the table (remove the palette from bit 6/7 and renumber the metatiles?)
; could maybe pull this off by changing all of the metatiles in level_vanilla.s without touching the level format (so it should still be possible to use existing level editors)

MTILE_CURRENT_INDEX .set $00
  MTileDefine $24, $24, $24, $24, MTILE_PALETTE_0 ;blank
  MTileDefine $27, $27, $27, $27, MTILE_PALETTE_0 ;black metatile
  MTileDefine $24, $24, $24, $30, MTILE_PALETTE_0 ;bush left
  MTileDefine $31, $25, $32, $25, MTILE_PALETTE_0 ;bush middle
  MTileDefine $24, $33, $24, $24, MTILE_PALETTE_0 ;bush right
  MTileDefine $24, $34, $34, $26, MTILE_PALETTE_0 ;mountain left
  MTileDefine $26, $26, $38, $26, MTILE_PALETTE_0 ;mountain left bottom/middle center
  MTileDefine $24, $35, $24, $36, MTILE_PALETTE_0 ;mountain middle top
  MTileDefine $37, $26, $24, $37, MTILE_PALETTE_0 ;mountain right
  MTileDefine $38, $26, $26, $26, MTILE_PALETTE_0 ;mountain right bottom
  MTileDefine $26, $26, $26, $26, MTILE_PALETTE_0 ;mountain middle bottom
  MTileDefine $24, $44, $24, $44, MTILE_PALETTE_0 ;bridge guardrail
  MTileDefine $24, $CF, $CF, $24, MTILE_PALETTE_0 ;chain
  MTileDefine $3E, $4E, $3F, $4F, MTILE_PALETTE_0 ;tall tree top, top half
  MTileDefine $3E, $4C, $3F, $4D, MTILE_PALETTE_0 ;short tree top
  MTileDefine $4E, $4C, $4F, $4D, MTILE_PALETTE_0 ;tall tree top, bottom half
  MTileDefine $50, $60, $51, $61, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;warp pipe end left, points up
  MTileDefine $52, $62, $53, $63, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;warp pipe end right, points up
  MTileDefine $50, $60, $51, $61, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;decoration pipe end left, points up
  MTileDefine $52, $62, $53, $63, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;decoration pipe end right, points up
  MTileDefine $70, $70, $71, $71, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;pipe shaft left
  MTileDefine $26, $26, $72, $72, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;pipe shaft right
  MTileDefine $59, $69, $5A, $6A, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;tree ledge left edge
  MTileDefine $5A, $6C, $5A, $6C, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;tree ledge middle
  MTileDefine $5A, $6A, $5B, $6B, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;tree ledge right edge
  MTileDefine $A0, $B0, $A1, $B1, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;mushroom left edge
  MTileDefine $A2, $B2, $A3, $B3, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;mushroom middle
  MTileDefine $A4, $B4, $A5, $B5, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;mushroom right edge
  MTileDefine $54, $64, $55, $65, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;sideways pipe end top
  MTileDefine $56, $66, $56, $66, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;sideways pipe shaft top
  MTileDefine $57, $67, $71, $71, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;sideways pipe joint top
  MTileDefine $74, $84, $75, $85, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;sideways pipe end bottom
  MTileDefine $26, $76, $26, $76, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;sideways pipe shaft bottom
  MTileDefine $58, $68, $71, $71, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;sideways pipe joint bottom
  MTileDefine $8C, $9C, $8D, $9D, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;seaplant
  MTileDefine $24, $24, $24, $24, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP ;blank, used on bricks or blocks that are hit
  MTileDefine $24, $5F, $24, $6F, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP | MTILE_CLIMB  ;flagpole ball
  MTileDefine $7D, $7D, $7E, $7E, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP | MTILE_CLIMB  ;flagpole shaft
  MTileDefine $24, $24, $24, $24, MTILE_PALETTE_0 | MTILE_SOLID | MTILE_BUMP | MTILE_CLIMB  ;blank, used in conjunction with vines

MTILE_CURRENT_INDEX .set $40
  MTileDefine $7D, $7D, $7E, $7E, MTILE_PALETTE_1 ;vertical rope
  MTileDefine $5C, $24, $5C, $24, MTILE_PALETTE_1 ;horizontal rope
  MTileDefine $24, $7D, $5D, $6D, MTILE_PALETTE_1 ;left pulley
  MTileDefine $5E, $6E, $24, $7E, MTILE_PALETTE_1 ;right pulley
  MTileDefine $24, $24, $24, $24, MTILE_PALETTE_1 ;blank used for balance rope
  MTileDefine $77, $48, $78, $48, MTILE_PALETTE_1 ;castle top
  MTileDefine $48, $48, $27, $27, MTILE_PALETTE_1 ;castle window left
  MTileDefine $48, $48, $48, $48, MTILE_PALETTE_1 ;castle brick wall
  MTileDefine $27, $27, $48, $48, MTILE_PALETTE_1 ;castle window right
  MTileDefine $79, $48, $7A, $48, MTILE_PALETTE_1 ;castle top w/ brick
  MTileDefine $7B, $27, $7C, $27, MTILE_PALETTE_1 ;entrance top
  MTileDefine $27, $27, $27, $27, MTILE_PALETTE_1 ;entrance bottom
  MTileDefine $73, $73, $73, $73, MTILE_PALETTE_1 ;green ledge stump
  MTileDefine $3A, $4A, $3B, $4B, MTILE_PALETTE_1 ;fence
  MTileDefine $3C, $3C, $3D, $3D, MTILE_PALETTE_1 ;tree trunk
  MTileDefine $A6, $4E, $A7, $4F, MTILE_PALETTE_1 ;mushroom stump top
  MTileDefine $4E, $4E, $4F, $4F, MTILE_PALETTE_1 ;mushroom stump bottom
  MTileDefine $47, $48, $47, $48, MTILE_PALETTE_1 | MTILE_SOLID ;breakable brick w/ line 
  MTileDefine $48, $48, $48, $48, MTILE_PALETTE_1 | MTILE_SOLID ;breakable brick 
  MTileDefine $47, $48, $47, $48, MTILE_PALETTE_1 | MTILE_SOLID ;breakable brick (not used)
  MTileDefine $82, $92, $83, $93, MTILE_PALETTE_1 | MTILE_SOLID ;cracked rock terrain
  MTileDefine $47, $48, $47, $48, MTILE_PALETTE_1 | MTILE_SOLID ;brick with line (power-up)
  MTileDefine $47, $48, $47, $48, MTILE_PALETTE_1 | MTILE_SOLID ;brick with line (vine)
  MTileDefine $47, $48, $47, $48, MTILE_PALETTE_1 | MTILE_SOLID ;brick with line (star)
  MTileDefine $47, $48, $47, $48, MTILE_PALETTE_1 | MTILE_SOLID ;brick with line (coins)
  MTileDefine $47, $48, $47, $48, MTILE_PALETTE_1 | MTILE_SOLID ;brick with line (1-up)
  MTileDefine $48, $48, $48, $48, MTILE_PALETTE_1 | MTILE_SOLID ;brick (power-up)
  MTileDefine $48, $48, $48, $48, MTILE_PALETTE_1 | MTILE_SOLID ;brick (vine)
  MTileDefine $48, $48, $48, $48, MTILE_PALETTE_1 | MTILE_SOLID ;brick (star)
  MTileDefine $48, $48, $48, $48, MTILE_PALETTE_1 | MTILE_SOLID ;brick (coins)
  MTileDefine $48, $48, $48, $48, MTILE_PALETTE_1 | MTILE_SOLID ;brick (1-up)
  MTileDefine $24, $24, $24, $24, MTILE_PALETTE_1 | MTILE_SOLID ;hidden block (1 coin)
  MTileDefine $24, $24, $24, $24, MTILE_PALETTE_1 | MTILE_SOLID ;hidden block (1-up)
  MTileDefine $80, $90, $81, $91, MTILE_PALETTE_1 | MTILE_SOLID | MTILE_BUMP ;solid block (3-d block)
  MTileDefine $B6, $B7, $B6, $B7, MTILE_PALETTE_1 | MTILE_SOLID | MTILE_BUMP ;solid block (white wall)
  MTileDefine $45, $24, $45, $24, MTILE_PALETTE_1 | MTILE_SOLID | MTILE_BUMP ;bridge
  MTileDefine $86, $96, $87, $97, MTILE_PALETTE_1 | MTILE_SOLID | MTILE_BUMP ;bullet bill cannon barrel
  MTileDefine $88, $98, $89, $99, MTILE_PALETTE_1 | MTILE_SOLID | MTILE_BUMP ;bullet bill cannon top
  MTileDefine $94, $94, $95, $95, MTILE_PALETTE_1 | MTILE_SOLID | MTILE_BUMP ;bullet bill cannon bottom
  MTileDefine $24, $24, $24, $24, MTILE_PALETTE_1 | MTILE_SOLID | MTILE_BUMP ;blank used for jumpspring
  MTileDefine $24, $48, $24, $48, MTILE_PALETTE_1 | MTILE_SOLID | MTILE_BUMP ;half brick used for jumpspring
  MTileDefine $8A, $9A, $8B, $9B, MTILE_PALETTE_1 | MTILE_SOLID | MTILE_BUMP ;solid block (water level, green rock)
  MTileDefine $24, $48, $24, $48, MTILE_PALETTE_1 | MTILE_SOLID | MTILE_BUMP ;half brick (???)
  MTileDefine $54, $64, $55, $65, MTILE_PALETTE_1 | MTILE_SOLID | MTILE_BUMP ;water pipe top
  MTileDefine $74, $84, $75, $85, MTILE_PALETTE_1 | MTILE_SOLID | MTILE_BUMP ;water pipe bottom
  MTileDefine $24, $5F, $24, $6F, MTILE_PALETTE_1 | MTILE_SOLID | MTILE_BUMP | MTILE_CLIMB ;flag ball (residual object)

MTILE_CURRENT_INDEX .set $80
  MTileDefine $24, $24, $24, $30, MTILE_PALETTE_2 ;cloud left
  MTileDefine $31, $25, $32, $25, MTILE_PALETTE_2 ;cloud middle
  MTileDefine $24, $33, $24, $24, MTILE_PALETTE_2 ;cloud right
  MTileDefine $24, $24, $40, $24, MTILE_PALETTE_2 ;cloud bottom left
  MTileDefine $41, $24, $42, $24, MTILE_PALETTE_2 ;cloud bottom middle
  MTileDefine $43, $24, $24, $24, MTILE_PALETTE_2 ;cloud bottom right
  MTileDefine $46, $26, $46, $26, MTILE_PALETTE_2 ;water/lava top
  MTileDefine $26, $26, $26, $26, MTILE_PALETTE_2 ;water/lava
  MTileDefine $8E, $9E, $8F, $9F, MTILE_PALETTE_2 | MTILE_SOLID | MTILE_BUMP ;cloud level terrain
  MTileDefine $39, $49, $39, $49, MTILE_PALETTE_2 | MTILE_SOLID | MTILE_BUMP ;bowser's bridge

MTILE_CURRENT_INDEX .set $c0
  MTileDefine $A8, $B8, $A9, $B9, MTILE_PALETTE_3 | MTILE_SOLID ;question block (coin)
  MTileDefine $A8, $B8, $A9, $B9, MTILE_PALETTE_3 | MTILE_SOLID ;question block (power-up)
  MTileDefine $AA, $BA, $AB, $BB, MTILE_PALETTE_3 | MTILE_SOLID ;coin
  MTileDefine $AC, $BC, $AD, $BD, MTILE_PALETTE_3 | MTILE_SOLID ;underwater coin
  MTileDefine $AE, $BE, $AF, $BF, MTILE_PALETTE_3 | MTILE_SOLID | MTILE_BUMP ;empty block
  MTileDefine $CB, $CD, $CC, $CE, MTILE_PALETTE_3 | MTILE_SOLID | MTILE_BUMP ;axe


; Create the actual metatile tables.
; TODO page align them to save a cycle someday lul
MTileTopLeft:
.repeat 256, I
.if .defined(.ident(.sprintf("MTILE_TL_%d", I)))
  .byte .ident(.sprintf("MTILE_TL_%d", I))
.else
  .byte $00
.endif
.endrepeat

MTileBotLeft:
.repeat 256, I
.if .defined(.ident(.sprintf("MTILE_BL_%d", I)))
  .byte .ident(.sprintf("MTILE_BL_%d", I))
.else
  .byte $00
.endif
.endrepeat

MTileTopRight:
.repeat 256, I
.if .defined(.ident(.sprintf("MTILE_TR_%d", I)))
  .byte .ident(.sprintf("MTILE_TR_%d", I))
.else
  .byte $00
.endif
.endrepeat

MTileBotRight:
.repeat 256, I
.if .defined(.ident(.sprintf("MTILE_BR_%d", I)))
  .byte .ident(.sprintf("MTILE_BR_%d", I))
.else
  .byte $00
.endif
.endrepeat

; THIS TABLE IS IN FIXED MEMORY since its loaded for both level loading and collision code
.segment "FIXED"
MTileAttribute:
.repeat 256, I
.if .defined(.ident(.sprintf("MTILE_AT_%d", I)))
  .byte .ident(.sprintf("MTILE_AT_%d", I))
.else
  .byte $00
.endif
.endrepeat