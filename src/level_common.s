; Level code used by both level formats.

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
  inc BlockBufferColumnPos ;increment column offset where we're at
  lda BlockBufferColumnPos
  and #%00011111           ;mask out all but 5 LSB (0-1f)
  sta BlockBufferColumnPos ;and save
  rts

;-------------------------------------------------------------------------------------

.if ::USE_SMB2J_FEATURES
BlowPlayerAround:
        lda WindFlag            ;if wind is turned off, just exit
        beq ExBlow
        lda AreaType            ;don't blow the player around unless
        cmp #$01                ;the area is ground type
        bne ExBlow
        ldy #$01
        lda FrameCounter        ;branch to set d0 if on an odd frame
        asl
        bcs BThr                ;otherwise wind will only blow
        ldy #$03                ;one out of every four frames
BThr:   sty R0
        lda FrameCounter        ;throttle wind blowing by using the frame counter
        and R0                 ;to mask out certain frames
        bne ExBlow
        lda Player_X_Position   ;move player slightly to the right
        clc                     ;to simulate the wind moving the player
        adc #$01
        sta Player_X_Position
        lda Player_PageLoc
        adc #$00
        sta Player_PageLoc
        inc Player_X_Scroll     ;add one to movement speed for scroll
ExBlow: rts

;note the position data values are overwritten in RAM
LeavesYPosData:
        .byte $30, $70, $b8, $50, $98, $30
        .byte $70, $b8, $50, $98, $30, $70

LeavesXPosData:
        .byte $30, $30, $30, $60, $60, $a0
        .byte $a0, $a0, $d0, $d0, $d0, $60

LeavesTile:
        .byte $7b, $7b, $7b, $7b, $7a, $7a
        .byte $7b, $7b, $7b, $7a, $7b, $7a

SimulateWind:
          lda WindFlag             ;if no wind, branch to leave
          beq ExSimW
          lda #Sfx_Wind            ;play wind sfx
          sta NoiseSoundQueue
          jsr ModifyLeavesPos      ;modify X and Y position data of leaves
          ldx #$00                 ;use mostly unused sprite data offset
          AllocSpr 12
DrawLeaf: lda LeavesYPos,x
          sta Sprite_Y_Position,y  ;set up sprite data in OAM memory
          lda LeavesTile,x
          sta Sprite_Tilenumber,y
          lda #$41
          sta Sprite_Attributes,y
          lda LeavesXPos,x
          sta Sprite_X_Position,y
          iny
          iny
          iny
          iny
          inx                      ;if still on first six leaves, continue
          cpx #$0c                 ;continue until done putting all leaves on the screen
          bne DrawLeaf
ExSimW:   rts

LeavesPosAdder:
   .byte $57, $57, $56, $56, $58, $58, $56, $56, $57, $58, $57, $58
   .byte $59, $59, $58, $58, $5a, $5a, $58, $58, $59, $5a, $59, $5a

ModifyLeavesPos:
         ldx #$0b
MLPLoop: lda LeavesXPos,x      ;add each adder to each X position twice
         clc                   ;and to each Y position once
         adc LeavesPosAdder,x
         adc LeavesPosAdder,x
         sta LeavesXPos,x
         lda LeavesYPos,x
         clc
         adc LeavesPosAdder,x
         sta LeavesYPos,x
         dex
         bpl MLPLoop
         rts

WindOn:
     lda #$01         ;branch to turn the wind on
     bne WOn
WindOff:
     lda #$00         ;turn the wind off
WOn: sta WindFlag
     rts

InitWindLeaves:
  ldx #LeavesYPosData-1
@loop:
    lda LeavesYPosData,x
    sta LeavesYPos,x
    lda LeavesXPosData,x
    sta LeavesXPos,x
    dex
    bpl @loop
  rts

.endif ; ::USE_SMB2J_FEATURES

;--------------------------------

.segment "LOWCODE"

;--------------------------------

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
.if MULTIPLE_POWERUPS_ON_SCREEN
      jsr GetEmptySlot
      bcs AllSlotsFull        ;exit if all slots are full
.else
      ldx #$05
.endif
      sta PowerUpType,x
      jmp SetupPowerUp
AllSlotsFull:
      rts

VineBlock:
      ldx #$05                ;load last slot for enemy object buffer
      ldy SprDataOffset_Ctrl  ;get control bit
      farcall Setup_Vine, jmp ;set up vine object

;--------------------------------

BrickQBlockMetatiles:
      .byte $c1, $c0, $5f, $60 ;used by question blocks

      ;these two sets are functionally identical, but look different
      .byte $55, $56, $57, $58, $59 ;used by ground level types
      .byte $5a, $5b, $5c, $5d, $5e ;used by other level types

BlockBumpedChk:
             ldy #$0d                    ;start at end of metatile data
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
       cmp #$c2                ;is it a coin? (not underwater)
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
ExitStpPowerUp:
           rts

;-------------------------------------------------------------------------------------

.proc SetupPowerUp
  ldy SprDataOffset_Ctrl    ;get control bit
  lda #PowerUpObject        ;load power-up identifier into
  sta Enemy_ID,x            ;special use slot of enemy object buffer
  lda Block_PageLoc,y       ;store page location of block object
  sta Enemy_PageLoc,x       ;as page location of power-up object
  lda Block_X_Position,y    ;store horizontal coordinate of block object
  sta Enemy_X_Position,x    ;as horizontal coordinate of power-up object
  lda #$01
  sta Enemy_Y_HighPos,x     ;set vertical high byte of power-up object
  lda Block_Y_Position,y    ;get vertical coordinate of block object
  sec
  sbc #$08                  ;subtract 8 pixels
  sta Enemy_Y_Position,x    ;and use as vertical coordinate of power-up object
  FALLTHROUGH PwrUpJmp
.endproc
.proc PwrUpJmp
  lda #$01                  ;this is a residual jump point in enemy object jump table
  sta Enemy_State,x         ;set power-up object's state
  sta Enemy_Flag,x          ;set buffer flag
  lda #$03
  sta Enemy_BoundBoxCtrl,x  ;set bounding box size control for power-up object
  lda PowerUpType,x
  cmp #$02                  ;check currently loaded power-up type
  bcs PutBehind             ;if star or 1-up, branch ahead
  lda PlayerStatus          ;otherwise check player's current status
  cmp #$02
  bcc StrType               ;if player not fiery, use status as power-up type
  lsr                       ;otherwise shift right to force fire flower type
StrType:
  sta PowerUpType,x         ;store type here
PutBehind:
  lda #%00100000
  sta Enemy_SprAttrib,x     ;set background priority bit
  lda #Sfx_GrowPowerUp
  sta Square2SoundQueue     ;load power-up reveal sound and leave
  lda #0
  sta EnemyMetasprite,x
  rts
.endproc

.if MULTIPLE_POWERUPS_ON_SCREEN
.proc GetEmptySlot
  pha
  ldx #$05
@loop:
  lda Enemy_Flag,x
  beq @found
  dex
  bpl @loop
  pla
  sec       ; if every slot is full, then do not spawn
  rts
@found:
  pla
  clc       ; if found, then return x and carry clear
  rts
.endproc
.endif
