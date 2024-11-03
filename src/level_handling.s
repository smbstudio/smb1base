.segment "LEVEL"

AreaParserTaskLoop:
    jsr AreaParserTaskHandler ;render column set of current area
    lda AreaParserTaskNum     ;check number of tasks
    bne AreaParserTaskLoop              ;if tasks still not all done, do another one
SkipATRender:
  rts

AreaParserTaskHandler:
  ldy AreaParserTaskNum     ;check number of tasks here
  bne DoAPTasks             ;if already set, go ahead
    ldy #$08
    sty AreaParserTaskNum     ;otherwise, set eight by default
DoAPTasks:
  dey
  tya
  jsr AreaParserTasks
  dec AreaParserTaskNum     ;if all tasks not complete do not
  bne SkipATRender          ;render attribute table yet
    farcall RenderAttributeTables, jmp

AreaParserTasks:
  jsr JumpEngine
  .word IncrementColumnPos
  .word FarCallRenderAreaGraphics
  .word FarCallRenderAreaGraphics
  .word AreaParserCore
  .word IncrementColumnPos
  .word FarCallRenderAreaGraphics
  .word FarCallRenderAreaGraphics
  .word AreaParserCore

.proc FarCallRenderAreaGraphics
  farcall RenderAreaGraphics, jmp
.endproc

;-------------------------------------------------------------------------------------

IncrementColumnPos:
  inc CurrentColumnPos     ;increment column where we're at
  lda CurrentColumnPos
  and #%00001111           ;mask out higher nybble
  bne NoColWrap
   sta CurrentColumnPos     ;if no bits left set, wrap back to zero (0-f)
   inc CurrentPageLoc       ;and increment page number where we're at
NoColWrap:
  rts

;--------------------------------------------
; Enemy loading code

;--------------------------------

;loop command data
LoopCmdWorldNumber:
      .byte $03, $03, $06, $06, $06, $06, $06, $06, $07, $07, $07

LoopCmdPageNumber:
      .byte $05, $09, $04, $05, $06, $08, $09, $0a, $06, $0b, $10

LoopCmdYPosition:
      .byte $40, $b0, $b0, $80, $40, $40, $80, $40, $f0, $f0, $f0

ExecGameLoopback:
      lda Player_PageLoc        ;send player back four pages
      sec
      sbc #$04
      sta Player_PageLoc
      lda CurrentPageLoc        ;send current page back four pages
      sec
      sbc #$04
      sta CurrentPageLoc
      lda ScreenLeft_PageLoc    ;subtract four from page location
      sec                       ;of screen's left border
      sbc #$04
      sta ScreenLeft_PageLoc
      lda ScreenRight_PageLoc   ;do the same for the page location
      sec                       ;of screen's right border
      sbc #$04
      sta ScreenRight_PageLoc
      lda AreaObjectPageLoc     ;subtract four from page control
      sec                       ;for area objects
      sbc #$04
      sta AreaObjectPageLoc
      lda #$00                  ;initialize page select for both
      sta EnemyObjectPageSel    ;area and enemy objects
      sta AreaObjectPageSel
      sta EnemyDataOffset       ;initialize enemy object data offset
      sta EnemyObjectPageLoc    ;and enemy object page control
      lda AreaDataOfsLoopback,y ;adjust area object offset based on
      sta AreaDataOffset        ;which loop command we encountered
      rts

;-------------------------------------------------------------------------------------

AreaDataOfsLoopback:
      .byte $12, $36, $0e, $0e, $0e, $32, $32, $32, $0a, $26, $40

ProcLoopCommand:
          lda LoopCommand           ;check if loop command was found
          beq ChkEnemyFrenzy
          lda CurrentColumnPos      ;check to see if we're still on the first page
          bne ChkEnemyFrenzy        ;if not, do not loop yet
          ldy #$0b                  ;start at the end of each set of loop data
FindLoop: dey
          bmi ChkEnemyFrenzy        ;if all data is checked and not match, do not loop
          lda WorldNumber           ;check to see if one of the world numbers
          cmp LoopCmdWorldNumber,y  ;matches our current world number
          bne FindLoop
          lda CurrentPageLoc        ;check to see if one of the page numbers
          cmp LoopCmdPageNumber,y   ;matches the page we're currently on
          bne FindLoop
          lda Player_Y_Position     ;check to see if the player is at the correct position
          cmp LoopCmdYPosition,y    ;if not, branch to check for world 7
          bne WrongChk
          lda Player_State          ;check to see if the player is
          cmp #$00                  ;on solid ground (i.e. not jumping or falling)
          bne WrongChk              ;if not, player fails to pass loop, and loopback
          lda WorldNumber           ;are we in world 7? (check performed on correct
          cmp #World7               ;vertical position and on solid ground)
          bne InitMLp               ;if not, initialize flags used there, otherwise
          inc MultiLoopCorrectCntr  ;increment counter for correct progression
IncMLoop: inc MultiLoopPassCntr     ;increment master multi-part counter
          lda MultiLoopPassCntr     ;have we done all three parts?
          cmp #$03
          bne InitLCmd              ;if not, skip this part
          lda MultiLoopCorrectCntr  ;if so, have we done them all correctly?
          cmp #$03
          beq InitMLp               ;if so, branch past unnecessary check here
          bne DoLpBack              ;unconditional branch if previous branch fails
WrongChk: lda WorldNumber           ;are we in world 7? (check performed on
          cmp #World7               ;incorrect vertical position or not on solid ground)
          beq IncMLoop
DoLpBack: jsr ExecGameLoopback      ;if player is not in right place, loop back
          farcall KillAllEnemies
InitMLp:  lda #$00                  ;initialize counters used for multi-part loop commands
          sta MultiLoopPassCntr
          sta MultiLoopCorrectCntr
InitLCmd: lda #$00                  ;initialize loop command flag
          sta LoopCommand
          ; fallthrough
;--------------------------------

ChkEnemyFrenzy:
  lda EnemyFrenzyQueue  ;check for enemy object in frenzy queue
  beq ProcessEnemyData  ;if not, skip this part
  sta Enemy_ID,x        ;store as enemy object identifier here
  lda #$01
  sta Enemy_Flag,x      ;activate enemy object flag
  lda #$00
  sta Enemy_State,x     ;initialize state and frenzy queue
  sta EnemyFrenzyQueue
  jmp InitEnemyObject   ;and then jump to deal with this enemy

;--------------------------------
;$06 - used to hold page location of extended right boundary
;$07 - used to hold high nybble of position of extended right boundary

ProcessEnemyData:
        ldy EnemyDataOffset      ;get offset of enemy object data
        lda (EnemyData),y        ;load first byte
        cmp #$ff                 ;check for EOD terminator
        bne CheckEndofBuffer
        jmp CheckFrenzyBuffer    ;if found, jump to check frenzy buffer, otherwise

CheckEndofBuffer:
        and #%00001111           ;check for special row $0e
        cmp #$0e
        beq CheckRightBounds     ;if found, branch, otherwise
        cpx #$05                 ;check for end of buffer
        bcc CheckRightBounds     ;if not at end of buffer, branch
        iny
        lda (EnemyData),y        ;check for specific value here
        and #%00111111           ;not sure what this was intended for, exactly
        cmp #$2e                 ;this part is quite possibly residual code
        beq CheckRightBounds     ;but it has the effect of keeping enemies out of
        rts                      ;the sixth slot

CheckRightBounds:
        lda ScreenRight_X_Pos    ;add 48 to pixel coordinate of right boundary
        clc
        adc #$30
        and #%11110000           ;store high nybble
        sta R7 
        lda ScreenRight_PageLoc  ;add carry to page location of right boundary
        adc #$00
        sta R6                   ;store page location + carry
        ldy EnemyDataOffset
        iny
        lda (EnemyData),y        ;if MSB of enemy object is clear, branch to check for row $0f
        asl
        bcc CheckPageCtrlRow
        lda EnemyObjectPageSel   ;if page select already set, do not set again
        bne CheckPageCtrlRow
        inc EnemyObjectPageSel   ;otherwise, if MSB is set, set page select 
        inc EnemyObjectPageLoc   ;and increment page control

CheckPageCtrlRow:
  dey
  lda (EnemyData),y        ;reread first byte
  and #$0f
  cmp #$0f                 ;check for special row $0f
  bne PositionEnemyObj     ;if not found, branch to position enemy object
  lda EnemyObjectPageSel   ;if page select set,
  bne PositionEnemyObj     ;branch without reading second byte
  iny
  lda (EnemyData),y        ;otherwise, get second byte, mask out 2 MSB
  and #%00111111
  sta EnemyObjectPageLoc   ;store as page control for enemy object data
  inc EnemyDataOffset      ;increment enemy object data offset 2 bytes
  inc EnemyDataOffset
  inc EnemyObjectPageSel   ;set page select for enemy object data and 
  jmp ProcLoopCommand      ;jump back to process loop commands again

PositionEnemyObj:
  lda EnemyObjectPageLoc   ;store page control as page location
  sta Enemy_PageLoc,x      ;for enemy object
  lda (EnemyData),y        ;get first byte of enemy object
  and #%11110000
  sta Enemy_X_Position,x   ;store column position
  cmp ScreenRight_X_Pos    ;check column position against right boundary
  lda Enemy_PageLoc,x      ;without subtracting, then subtract borrow
  sbc ScreenRight_PageLoc  ;from page location
  bcs CheckRightExtBounds  ;if enemy object beyond or at boundary, branch
  lda (EnemyData),y
  and #%00001111           ;check for special row $0e
  cmp #$0e                 ;if found, jump elsewhere
  beq ParseRow0e
  jmp CheckThreeBytes      ;if not found, unconditional jump

CheckRightExtBounds:
  lda R7                   ;check right boundary + 48 against
  cmp Enemy_X_Position,x   ;column position without subtracting,
  lda R6                   ;then subtract borrow from page control temp
  sbc Enemy_PageLoc,x      ;plus carry
  bcc CheckFrenzyBuffer    ;if enemy object beyond extended boundary, branch
  lda #$01                 ;store value in vertical high byte
  sta Enemy_Y_HighPos,x
  lda (EnemyData),y        ;get first byte again
  asl                      ;multiply by four to get the vertical
  asl                      ;coordinate
  asl
  asl
  sta Enemy_Y_Position,x
  cmp #$e0                 ;do one last check for special row $0e
  beq ParseRow0e           ;(necessary if branched to $c1cb)
  iny
  lda (EnemyData),y        ;get second byte of object
  and #%01000000           ;check to see if hard mode bit is set
  beq CheckForEnemyGroup   ;if not, branch to check for group enemy objects
  lda SecondaryHardMode    ;if set, check to see if secondary hard mode flag
  beq Inc2B                ;is on, and if not, branch to skip this object completely

CheckForEnemyGroup:
  lda (EnemyData),y      ;get second byte and mask out 2 MSB
  and #%00111111
  cmp #$37               ;check for value below $37
  bcc BuzzyBeetleMutate
  cmp #$3f               ;if $37 or greater, check for value
  bcc DoGroup            ;below $3f, branch if below $3f

BuzzyBeetleMutate:
  cmp #Goomba          ;if below $37, check for goomba
  bne StrID            ;value ($3f or more always fails)
  ldy PrimaryHardMode  ;check if primary hard mode flag is set
  beq StrID            ;and if so, change goomba to buzzy beetle
    lda #BuzzyBeetle
StrID:
  sta Enemy_ID,x       ;store enemy object number into buffer
  lda #$01
  sta Enemy_Flag,x     ;set flag for enemy in buffer
  jsr InitEnemyObject
  lda Enemy_Flag,x     ;check to see if flag is set
  bne Inc2B            ;if not, leave, otherwise branch
ExitStrID:
  rts

CheckFrenzyBuffer:
  lda EnemyFrenzyBuffer    ;if enemy object stored in frenzy buffer
  bne StrFre               ;then branch ahead to store in enemy object buffer
  lda Vine_FlagOffset       ;otherwise check vine flag offset
  cmp #$01
  bne ExitStrID               ;if other value <> 1, leave
  lda #VineObject          ;otherwise put vine in enemy identifier
StrFre:
  sta Enemy_ID,x           ;store contents of frenzy buffer into enemy identifier value

InitEnemyObject:
  lda #$00                 ;initialize enemy state
  sta Enemy_State,x
  farcall CheckpointEnemyID, jmp    ;jump ahead to run jump engine and subroutines

DoGroup:
  jmp HandleGroupEnemies   ;handle enemy group objects

ParseRow0e:
  iny                      ;increment Y to load third byte of object
  iny
  lda (EnemyData),y
  lsr                      ;move 3 MSB to the bottom, effectively
  lsr                      ;making %xxx00000 into %00000xxx
  lsr
  lsr
  lsr
  cmp WorldNumber          ;is it the same world number as we're on?
  bne NotUse               ;if not, do not use (this allows multiple uses
  dey                      ;of the same area, like the underground bonus areas)
  lda (EnemyData),y        ;otherwise, get second byte and use as offset
  sta AreaPointer          ;to addresses for level and enemy object data
  iny
  lda (EnemyData),y        ;get third byte again, and this time mask out
  and #%00011111           ;the 3 MSB from before, save as page number to be
  sta EntrancePage         ;used upon entry to area, if area is entered
NotUse:
  jmp Inc3B

CheckThreeBytes:
  ldy EnemyDataOffset      ;load current offset for enemy object data
  lda (EnemyData),y        ;get first byte
  and #%00001111           ;check for special row $0e
  cmp #$0e
  bne Inc2B
Inc3B:
  inc EnemyDataOffset      ;if row = $0e, increment three bytes
Inc2B:
  inc EnemyDataOffset      ;otherwise increment two bytes
  inc EnemyDataOffset
  lda #$00                 ;init page select for enemy objects
  sta EnemyObjectPageSel
  ldx ObjectOffset         ;reload current offset in enemy buffers
  rts                      ;and leave


;--------------------------------
;$00 - used to store Y position of group enemies
;$01 - used to store enemy ID
;$02 - used to store page location of right side of screen
;$03 - used to store X position of right side of screen

HandleGroupEnemies:
        ldy #$00                  ;load value for green koopa troopa
        sec
        sbc #$37                  ;subtract $37 from second byte read
        pha                       ;save result in stack for now
        cmp #$04                  ;was byte in $3b-$3e range?
        bcs SnglID                ;if so, branch
        pha                       ;save another copy to stack
        ldy #Goomba               ;load value for goomba enemy
        lda PrimaryHardMode       ;if primary hard mode flag not set,
        beq PullID                ;branch, otherwise change to value
        ldy #BuzzyBeetle          ;for buzzy beetle
PullID: pla                       ;get second copy from stack
SnglID: sty R1                    ;save enemy id here
        ldy #$b0                  ;load default y coordinate
        and #$02                  ;check to see if d1 was set
        beq SetYGp                ;if so, move y coordinate up,
        ldy #$70                  ;otherwise branch and use default
SetYGp: sty R0                    ;save y coordinate here
        lda ScreenRight_PageLoc   ;get page number of right edge of screen
        sta R2                    ;save here
        lda ScreenRight_X_Pos     ;get pixel coordinate of right edge
        sta R3                    ;save here
        ldy #$02                  ;load two enemies by default
        pla                       ;get first copy from stack
        lsr                       ;check to see if d0 was set
        bcc CntGrp                ;if not, use default value
        iny                       ;otherwise increment to three enemies
; CntGrp: sty NumberofGroupEnemies  ;save number of enemies here
CntGrp:
        sty NumberofGroupEnemies  ;save number of enemies here
GrLoop: ldx #$ff                  ;start at beginning of enemy buffers
GSltLp: inx                       ;increment and branch if past
        cpx #$05                  ;end of buffers
        bcs NextED
        lda Enemy_Flag,x          ;check to see if enemy is already
        bne GSltLp                ;stored in buffer, and branch if so
        lda R1 
        sta Enemy_ID,x            ;store enemy object identifier
        lda R2 
        sta Enemy_PageLoc,x       ;store page location for enemy object
        lda R3 
        sta Enemy_X_Position,x    ;store x coordinate for enemy object
        clc
        adc #$18                  ;add 24 pixels for next enemy
        sta R3 
        lda R2                    ;add carry to page location for
        adc #$00                  ;next enemy
        sta R2 
        lda R0                    ;store y coordinate for enemy object
        sta Enemy_Y_Position,x
        lda #$01                  ;activate flag for buffer, and
        sta Enemy_Y_HighPos,x     ;put enemy within the screen vertically
        sta Enemy_Flag,x
        farcall CheckpointEnemyID     ;process each enemy object separately
        dec NumberofGroupEnemies  ;do this until we run out of enemy objects
      ;   dec R7
        bne GrLoop
NextED: jmp Inc2B                 ;jump to increment data offset and leave

;---------------------------------------------------------------------------------
.pushseg
.segment "LOWCODE"
InitBlock_XY_Pos:
      lda Player_X_Position   ;get player's horizontal coordinate
      clc
      adc #$08                ;add eight pixels
      and #$f0                ;mask out low nybble to give 16-pixel correspondence
      sta Block_X_Position,x  ;save as horizontal coordinate for block object
      lda Player_PageLoc
      adc #$00                ;add carry to page location of player
      sta Block_PageLoc,x     ;save as page location of block object
      sta Block_PageLoc2,x    ;save elsewhere to be used later
      lda Player_Y_HighPos
      sta Block_Y_HighPos,x   ;save vertical high byte of player into
ExitBlockChk:
      rts                     ;vertical high byte of block object and leave

;--------------------------------

BumpBlock:
           jsr CheckTopOfBlock     ;check to see if there's a coin directly above this block
           lda #Sfx_Bump
           sta Square1SoundQueue   ;play bump sound
           lda #$00
           sta Block_X_Speed,x     ;initialize horizontal speed for block object
           sta Block_Y_MoveForce,x ;init fractional movement force
           sta Player_Y_Speed      ;init player's vertical speed
           lda #$fe
           sta Block_Y_Speed,x     ;set vertical speed for block object
           lda R5                  ;get original metatile from stack
           jsr BlockBumpedChk      ;do a sub to check which block player bumped head on
           bcc ExitBlockChk        ;if no match was found, branch to leave
           tya                     ;move block number to A
           cmp #$09                ;if block number was within 0-8 range,
           bcc BlockCode           ;branch to use current number
           sbc #$05                ;otherwise subtract 5 for second set to get proper number
BlockCode: jsr JumpEngine          ;run appropriate subroutine depending on block number

      .word MushFlowerBlock
      .word CoinBlock
      .word CoinBlock
      .word ExtraLifeMushBlock
      .word MushFlowerBlock
      .word VineBlock
      .word StarBlock
      .word CoinBlock
      .word ExtraLifeMushBlock

;--------------------------------

MushFlowerBlock:
      lda #$00       ;load mushroom/fire flower into power-up type
      .byte $2c        ;BIT instruction opcode

StarBlock:
      lda #$02       ;load star into power-up type
      .byte $2c        ;BIT instruction opcode

ExtraLifeMushBlock:
      lda #$03         ;load 1-up mushroom into power-up type
      sta PowerUpType          ;store correct power-up type
      jmp SetupPowerUp

VineBlock:
      ldx #$05                ;load last slot for enemy object buffer
      ldy SprDataOffset_Ctrl  ;get control bit
      farcall Setup_Vine, jmp ;set up vine object

;--------------------------------

BrickQBlockMetatiles:
;used by question blocks
      .byte MT_QUESTION_BLOCK_POWER_UP
      .byte MT_QUESTION_BLOCK_COIN
      .byte MT_HIDDEN_BLOCK_1_COIN
      .byte MT_HIDDEN_BLOCK_1_UP

UniqBricks:
;used by ground level types
      .byte MT_BRICK_WITH_LINE_POWER_UP
      .byte MT_BRICK_WITH_LINE_VINE
      .byte MT_BRICK_WITH_LINE_STAR
      .byte MT_BRICK_WITH_LINE_COINS
      .byte MT_BRICK_WITH_LINE_1_UP
      
NumOfUniqBricks = * - UniqBricks
;used by other level types
      .byte MT_BRICK_POWER_UP
      .byte MT_BRICK_VINE
      .byte MT_BRICK_STAR
      .byte MT_BRICK_COINS
      .byte MT_BRICK_1_UP

SizeOfBrickQBlockMetatiles = * - BrickQBlockMetatiles

BlockBumpedChk:
             ldy #SizeOfBrickQBlockMetatiles-1 ;start at end of metatile data
BumpChkLoop: cmp BrickQBlockMetatiles,y  ;check to see if current metatile matches
             beq MatchBump               ;metatile found in block buffer, branch if so
             dey                         ;otherwise move onto next metatile
             bpl BumpChkLoop             ;do this until all metatiles are checked
             clc                         ;if none match, return with carry clear
MatchBump:   rts                         ;note carry is set if found match

;--------------------------------

BrickShatter:
      jsr CheckTopOfBlock    ;check to see if there's a coin directly above this block
      lda #Sfx_BrickShatter
      sta Block_RepFlag,x    ;set flag for block object to immediately replace metatile
      sta NoiseSoundQueue    ;load brick shatter sound
      jsr SpawnBrickChunks   ;create brick chunk objects
      lda #$fe
      sta Player_Y_Speed     ;set vertical speed for player
      lda #$05
      sta DigitModifier+PlayerScoreLastIndex    ;set digit modifier to give player 50 points
      farcall AddToScore     ;do sub to update the score
      ldx SprDataOffset_Ctrl ;load control bit and leave
      rts

;--------------------------------

CheckTopOfBlock:
       ldx SprDataOffset_Ctrl  ;load control bit
       ldy R2                  ;get vertical high nybble offset used in block buffer
       beq TopEx               ;branch to leave if set to zero, because we're at the top
       tya                     ;otherwise set to A
       sec
       sbc #$10                ;subtract $10 to move up one row in the block buffer
       sta R2                  ;store as new vertical high nybble offset
       tay 
       lda (R6),y             ;get contents of block buffer in same column, one row up
       cmp #MT_COIN                ;is it a coin? (not underwater)
       bne TopEx               ;if not, branch to leave
       lda #$00
       sta (R6),y             ;otherwise put blank metatile where coin was
       farcall RemoveCoin_Axe      ;write blank metatile to vram buffer
       ldx SprDataOffset_Ctrl  ;get control bit
       jmp SetupJumpCoin       ;create jumping coin object and update coin variables
TopEx: rts ; TODO check this RTS can be removed                     ;leave!

;--------------------------------

SpawnBrickChunks:
      lda Block_X_Position,x     ;set horizontal coordinate of block object
      sta Block_Orig_XPos,x      ;as original horizontal coordinate here
      lda #$f0
      sta Block_X_Speed,x        ;set horizontal speed for brick chunk objects
      sta Block_X_Speed+2,x
      lda #$fa
      sta Block_Y_Speed,x        ;set vertical speed for one
      lda #$fc
      sta Block_Y_Speed+2,x      ;set lower vertical speed for the other
      lda #$00
      sta Block_Y_MoveForce,x    ;init fractional movement force for both
      sta Block_Y_MoveForce+2,x
      lda Block_PageLoc,x
      sta Block_PageLoc+2,x      ;copy page location
      lda Block_X_Position,x
      sta Block_X_Position+2,x   ;copy horizontal coordinate
      lda Block_Y_Position,x
      clc                        ;add 8 pixels to vertical coordinate
      adc #$08                   ;and save as vertical coordinate for one of them
      sta Block_Y_Position+2,x
      ; lda #$fa
      ; sta Block_Y_Speed,x        ;set vertical speed...again??? (redundant)
      rts


;-------------------------------------------------------------------------------------
;$02 - used to store vertical high nybble offset from block buffer routine
;$06 - used to store low byte of block buffer address

CoinBlock:
      jsr FindEmptyMiscSlot   ;set offset for empty or last misc object buffer slot
      lda Block_PageLoc,x     ;get page location of block object
      sta Misc_PageLoc,y      ;store as page location of misc object
      lda Block_X_Position,x  ;get horizontal coordinate of block object
      ora #$05                ;add 5 pixels
      sta Misc_X_Position,y   ;store as horizontal coordinate of misc object
      lda Block_Y_Position,x  ;get vertical coordinate of block object
      sbc #$10                ;subtract 16 pixels
      sta Misc_Y_Position,y   ;store as vertical coordinate of misc object
      jmp JCoinC              ;jump to rest of code as applies to this misc object

SetupJumpCoin:
        jsr FindEmptyMiscSlot  ;set offset for empty or last misc object buffer slot
        lda Block_PageLoc2,x   ;get page location saved earlier
        sta Misc_PageLoc,y     ;and save as page location for misc object
        lda R6                 ;get low byte of block buffer offset
        asl
        asl                    ;multiply by 16 to use lower nybble
        asl
        asl
        ora #$05               ;add five pixels
        sta Misc_X_Position,y  ;save as horizontal coordinate for misc object
        lda R2                 ;get vertical high nybble offset from earlier
        adc #$20               ;add 32 pixels for the status bar
        sta Misc_Y_Position,y  ;store as vertical coordinate
JCoinC: lda #$fb
        sta Misc_Y_Speed,y     ;set vertical speed
        lda #$01
        sta Misc_Y_HighPos,y   ;set vertical high byte
        sta Misc_State,y       ;set state for misc object
        sta Square2SoundQueue  ;load coin grab sound
        stx ObjectOffset       ;store current control bit as misc object offset 
        farcall GiveOneCoin        ;update coin tally on the screen and coin amount variable
        inc CoinTallyFor1Ups   ;increment coin tally used to activate 1-up block flag
        rts

FindEmptyMiscSlot:
           ldy #$08                ;start at end of misc objects buffer
FMiscLoop: lda Misc_State,y        ;get misc object state
           beq UseMiscS            ;branch if none found to use current offset
           dey                     ;decrement offset
           cpy #$05                ;do this for three slots
           bne FMiscLoop           ;do this until all slots are checked
           ldy #$08                ;if no empty slots found, use last slot
UseMiscS:  sty JumpCoinMiscOffset  ;store offset of misc object buffer here (residual)
           rts

.proc SetupPowerUp
  lda #PowerUpObject        ;load power-up identifier into
  sta Enemy_ID+5            ;special use slot of enemy object buffer
  lda Block_PageLoc,x       ;store page location of block object
  sta Enemy_PageLoc+5       ;as page location of power-up object
  lda Block_X_Position,x    ;store horizontal coordinate of block object
  sta Enemy_X_Position+5    ;as horizontal coordinate of power-up object
  lda #$01
  sta Enemy_Y_HighPos+5     ;set vertical high byte of power-up object
  lda Block_Y_Position,x    ;get vertical coordinate of block object
  sec
  sbc #$08                  ;subtract 8 pixels
  sta Enemy_Y_Position+5    ;and use as vertical coordinate of power-up object
  ; fallthrough
.endproc
.proc PwrUpJmp
  lda #$01                  ;this is a residual jump point in enemy object jump table
  sta Enemy_State+5         ;set power-up object's state
  sta Enemy_Flag+5          ;set buffer flag
  lda #$03
  sta Enemy_BoundBoxCtrl+5  ;set bounding box size control for power-up object
  lda PowerUpType
  cmp #$02                  ;check currently loaded power-up type
  bcs PutBehind             ;if star or 1-up, branch ahead
  lda PlayerStatus          ;otherwise check player's current status
  cmp #$02
  bcc StrType               ;if player not fiery, use status as power-up type
  lsr                       ;otherwise shift right to force fire flower type
StrType:
  sta PowerUpType           ;store type here
PutBehind:
  lda #%00100000
  sta Enemy_SprAttrib+5     ;set background priority bit
  lda #Sfx_GrowPowerUp
  sta Square2SoundQueue     ;load power-up reveal sound and leave
  lda #0
  sta EnemyMetasprite+5
  rts
.endproc
.popseg