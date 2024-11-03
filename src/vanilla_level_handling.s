
.segment "LEVEL"

.proc GetAreaDataAddrs
  lda AreaPointer          ;use 2 MSB for Y
  jsr GetAreaType
  tay
  lda AreaPointer          ;mask out all but 5 LSB
  and #%00011111
  sta AreaAddrsLOffset     ;save as low offset
  lda EnemyAddrHOffsets,y  ;load base value with 2 altered MSB,
  clc                      ;then add base value to 5 LSB, result
  adc AreaAddrsLOffset     ;becomes offset for level data
  tay
  lda EnemyDataAddrLow,y   ;use offset to load pointer
  sta EnemyDataLow
  lda EnemyDataAddrHigh,y
  sta EnemyDataHigh
  ldy AreaType             ;use area type as offset
  lda AreaDataHOffsets,y   ;do the same thing but with different base value
  clc
  adc AreaAddrsLOffset        
  tay
  lda AreaDataAddrLow,y    ;use this offset to load another pointer
  sta AreaDataLow
  lda AreaDataAddrHigh,y
  sta AreaDataHigh
  ldy #$00                 ;load first byte of header
  lda (AreaData),y     
  pha                      ;save it to the stack for now
  and #%00000111           ;save 3 LSB for foreground scenery or bg color control
  cmp #$04
  bcc StoreFore
  sta BackgroundColorCtrl  ;if 4 or greater, save value here as bg color control
  lda #$00
StoreFore:
  sta ForegroundScenery    ;if less, save value here as foreground scenery
  pla                      ;pull byte from stack and push it back
  pha
  and #%00111000           ;save player entrance control bits
  lsr                      ;shift bits over to LSBs
  lsr
  lsr
  sta PlayerEntranceCtrl       ;save value here as player entrance control
  pla                      ;pull byte again but do not push it back
  and #%11000000           ;save 2 MSB for game timer setting
  clc
  rol                      ;rotate bits over to LSBs
  rol
  rol
  sta GameTimerSetting     ;save value here as game timer setting
  iny
  lda (AreaData),y         ;load second byte of header
  pha                      ;save to stack
  and #%00001111           ;mask out all but lower nybble
  sta TerrainControl
  pla                      ;pull and push byte to copy it to A
  pha
  and #%00110000           ;save 2 MSB for background scenery type
  lsr
  lsr                      ;shift bits to LSBs
  lsr
  lsr
  sta BackgroundScenery    ;save as background scenery
  pla           
  and #%11000000
  clc
  rol                      ;rotate bits over to LSBs
  rol
  rol
  cmp #%00000011           ;if set to 3, store here
  bne StoreStyle           ;and nullify other value
  sta CloudTypeOverride    ;otherwise store value in other place
  lda #$00
StoreStyle:
  sta AreaStyle
  lda AreaDataLow          ;increment area data address by 2 bytes
  clc
  adc #$02
  sta AreaDataLow
  lda AreaDataHigh
  adc #$00
  sta AreaDataHigh
  rts
.endproc

;-------------------------------------------------------------------------------------
;$00 - used as counter, store for low nybble for background, ceiling byte for terrain
;$01 - used to store floor byte for terrain
;$07 - used to store terrain metatile
;$06-$07 - used to store block buffer address

BSceneDataOffsets:
  .byte $00, $30, $60

BackSceneryData:
  .byte $93, $00, $00, $11, $12, $12, $13, $00 ;clouds
  .byte $00, $51, $52, $53, $00, $00, $00, $00
  .byte $00, $00, $01, $02, $02, $03, $00, $00
  .byte $00, $00, $00, $00, $91, $92, $93, $00
  .byte $00, $00, $00, $51, $52, $53, $41, $42
  .byte $43, $00, $00, $00, $00, $00, $91, $92

  .byte $97, $87, $88, $89, $99, $00, $00, $00 ;mountains and bushes
  .byte $11, $12, $13, $a4, $a5, $a5, $a5, $a6
  .byte $97, $98, $99, $01, $02, $03, $00, $a4
  .byte $a5, $a6, $00, $11, $12, $12, $12, $13
  .byte $00, $00, $00, $00, $01, $02, $02, $03
  .byte $00, $a4, $a5, $a5, $a6, $00, $00, $00

  .byte $11, $12, $12, $13, $00, $00, $00, $00 ;trees and fences
  .byte $00, $00, $00, $9c, $00, $8b, $aa, $aa
  .byte $aa, $aa, $11, $12, $13, $8b, $00, $9c
  .byte $9c, $00, $00, $01, $02, $03, $11, $12
  .byte $12, $13, $00, $00, $00, $00, $aa, $aa
  .byte $9c, $aa, $00, $8b, $00, $01, $02, $03

BackSceneryMetatiles:
  .byte MT_CLOUD_LEFT, MT_CLOUD_BOTTOM_LEFT, $00 ;cloud left
  .byte MT_CLOUD_MIDDLE, MT_CLOUD_BOTTOM_MIDDLE, $00 ;cloud middle
  .byte MT_CLOUD_RIGHT, MT_CLOUD_BOTTOM_RIGHT, $00 ;cloud right
  .byte MT_BUSH_LEFT, $00, $00 ;bush left
  .byte MT_BUSH_MIDDLE, $00, $00 ;bush middle
  .byte MT_BUSH_RIGHT, $00, $00 ;bush right
  .byte $00, MT_MOUNTAIN_LEFT, MT_MOUNTAIN_LEFT_BOTTOM_MIDDLE_CENTER ;mountain left
  .byte MT_MOUNTAIN_MIDDLE_TOP, MT_MOUNTAIN_LEFT_BOTTOM_MIDDLE_CENTER, MT_MOUNTAIN_MIDDLE_BOTTOM ;mountain middle
  .byte $00, MT_MOUNTAIN_RIGHT, MT_MOUNTAIN_RIGHT_BOTTOM ;mountain right
  .byte MT_FENCE, $00, $00 ;fence
  .byte MT_TALL_TREE_TOP_AND_TOP_HALF, MT_TALL_TREE_TOP_AND_BOTTOM_HALF, MT_TREE_TRUNK ;tall tree
  .byte MT_SHORT_TREE_TOP, MT_TREE_TRUNK, MT_TREE_TRUNK ;short tree

FSceneDataOffsets:
  .byte $00, $0d, $1a

ForeSceneryData:
;in water
  .byte MT_WATER_OR_LAVA_TOP
  .byte MT_WATER_OR_LAVA
  .byte MT_WATER_OR_LAVA
  .byte MT_WATER_OR_LAVA
  .byte MT_WATER_OR_LAVA
  .byte MT_WATER_OR_LAVA
  .byte MT_WATER_OR_LAVA   
  .byte MT_WATER_OR_LAVA
  .byte MT_WATER_OR_LAVA
  .byte MT_WATER_OR_LAVA
  .byte MT_WATER_OR_LAVA
  .byte MT_SOLID_BLOCK_WATER_LEVEL_GREEN_ROCK
  .byte MT_SOLID_BLOCK_WATER_LEVEL_GREEN_ROCK

;wall
  .byte $00
  .byte $00
  .byte $00
  .byte $00
  .byte $00
  .byte MT_CASTLE_TOP
  .byte MT_CASTLE_BRICK_WALL   
  .byte MT_CASTLE_BRICK_WALL
  .byte MT_CASTLE_BRICK_WALL
  .byte MT_CASTLE_BRICK_WALL
  .byte MT_CASTLE_BRICK_WALL
  .byte $00
  .byte $00

;over water
  .byte $00
  .byte $00
  .byte $00
  .byte $00
  .byte $00
  .byte $00
  .byte $00   
  .byte $00
  .byte $00
  .byte $00
  .byte $00
  .byte MT_WATER_OR_LAVA_TOP
  .byte MT_WATER_OR_LAVA

TerrainMetatiles:
  .byte MT_SOLID_BLOCK_WATER_LEVEL_GREEN_ROCK
  .byte MT_CRACKED_ROCK_TERRAIN
  .byte MT_BREAKABLE_BRICK
  .byte MT_SOLID_BLOCK_WHITE_WALL

TerrainRenderBits:
  .byte %00000000, %00000000 ;no ceiling or floor
  .byte %00000000, %00011000 ;no ceiling, floor 2
  .byte %00000001, %00011000 ;ceiling 1, floor 2
  .byte %00000111, %00011000 ;ceiling 3, floor 2
  .byte %00001111, %00011000 ;ceiling 4, floor 2
  .byte %11111111, %00011000 ;ceiling 8, floor 2
  .byte %00000001, %00011111 ;ceiling 1, floor 5
  .byte %00000111, %00011111 ;ceiling 3, floor 5
  .byte %00001111, %00011111 ;ceiling 4, floor 5
  .byte %10000001, %00011111 ;ceiling 1, floor 6
  .byte %00000001, %00000000 ;ceiling 1, no floor
  .byte %10001111, %00011111 ;ceiling 4, floor 6
  .byte %11110001, %00011111 ;ceiling 1, floor 9
  .byte %11111001, %00011000 ;ceiling 1, middle 5, floor 2
  .byte %11110001, %00011000 ;ceiling 1, middle 4, floor 2
  .byte %11111111, %00011111 ;completely solid top to bottom

.proc AreaParserCore
  lda BackloadingFlag       ;check to see if we are starting right of start
  beq RenderSceneryTerrain  ;if not, go ahead and render background, foreground and terrain
    jsr ProcessAreaData       ;otherwise skip ahead and load level data
RenderSceneryTerrain:
  ldx #$0c
  lda #$00
ClrMTBuf:
  sta MetatileBuffer,x       ;clear out metatile buffer
  dex
  bpl ClrMTBuf
    ldy BackgroundScenery      ;do we need to render the background scenery?
    beq RendFore               ;if not, skip to check the foreground
      lda CurrentPageLoc         ;otherwise check for every third page
ThirdP:
        cmp #$03
        bmi RendBack               ;if less than three we're there
          sec
          sbc #$03                   ;if 3 or more, subtract 3 and 
        bpl ThirdP                 ;do an unconditional branch
RendBack:
      asl                        ;move results to higher nybble
      asl
      asl
      asl
      adc BSceneDataOffsets-1,y  ;add to it offset loaded from here
      adc CurrentColumnPos       ;add to the result our current column position
      tax
      lda BackSceneryData,x      ;load data from sum of offsets
      beq RendFore               ;if zero, no scenery for that part
      pha
        and #$0f                   ;save to stack and clear high nybble
        sec
        sbc #$01                   ;subtract one (because low nybble is $01-$0c)
        sta R0                     ;save low nybble
        asl                        ;multiply by three (shift to left and add result to old one)
        adc R0                     ;note that since d7 was nulled, the carry flag is always clear
        tax                        ;save as offset for background scenery metatile data
      pla                        ;get high nybble from stack, move low
      lsr
      lsr
      lsr
      lsr
      tay                        ;use as second offset (used to determine height)
      lda #$03                   ;use previously saved memory location for counter
      sta R0 
SceLoop1:
        lda BackSceneryMetatiles,x ;load metatile data from offset of (lsb - 1) * 3
        sta MetatileBuffer,y       ;store into buffer from offset of (msb / 16)
        inx
        iny
        cpy #$0b                   ;if at this location, leave loop
        beq RendFore
        dec R0                     ;decrement until counter expires, barring exception
        bne SceLoop1
RendFore:
      ldx ForegroundScenery      ;check for foreground data needed or not
      beq RendTerr               ;if not, skip this part
        ldy FSceneDataOffsets-1,x  ;load offset from location offset by header value, then
        ldx #$00                   ;reinit X
SceLoop2:
        lda ForeSceneryData,y      ;load data until counter expires
        beq NoFore                 ;do not store if zero found
        sta MetatileBuffer,x
NoFore:
        iny
        inx
        cpx #$0d                   ;store up to end of metatile buffer
        bne SceLoop2
RendTerr:
      ldy AreaType               ;check world type for water level
      bne TerMTile               ;if not water level, skip this part
        lda WorldNumber            ;check world number, if not world number eight
        cmp #World8                ;then skip this part
        bne TerMTile
          lda #MT_SOLID_BLOCK_WHITE_WALL ;if set as water level and world number eight,
          jmp StoreMT                ;use castle wall metatile as terrain type
TerMTile:
      lda TerrainMetatiles,y     ;otherwise get appropriate metatile for area type
      ldy CloudTypeOverride      ;check for cloud type override
      beq StoreMT                ;if not set, keep value otherwise
        lda #MT_CLOUD_LEVEL_TERRAIN ;use cloud block terrain
StoreMT:
      sta R7                     ;store value here
      ldx #$00                   ;initialize X, use as metatile buffer offset
      lda TerrainControl         ;use yet another value from the header
      asl                        ;multiply by 2 and use as yet another offset
      tay
TerrLoop:
      lda TerrainRenderBits,y    ;get one of the terrain rendering bit data
      sta R0 
      iny                        ;increment Y and use as offset next time around
      sty R1 
      lda CloudTypeOverride      ;skip if value here is zero
      beq NoCloud2
        cpx #$00                   ;otherwise, check if we're doing the ceiling byte
        beq NoCloud2
          lda R0                     ;if not, mask out all but d3
          and #%00001000
          sta R0 
NoCloud2:
      ldy #$00                   ;start at beginning of bitmasks
TerrBChk:
      lda Bitmasks,y             ;load bitmask, then perform AND on contents of first byte
      bit R0 
      beq NextTBit               ;if not set, skip this part (do not write terrain to buffer)
        lda R7 
        sta MetatileBuffer,x       ;load terrain type metatile number and store into buffer here
NextTBit:
      inx                        ;continue until end of buffer
      cpx #$0d
      beq RendBBuf               ;if we're at the end, break out of this loop
        lda AreaType               ;check world type for underground area
        cmp #$02
        bne EndUChk                ;if not underground, skip this part
          cpx #$0b
          bne EndUChk                ;if we're at the bottom of the screen, override
            lda #MT_CRACKED_ROCK_TERRAIN  ;old terrain type with ground level terrain type
            sta R7 
EndUChk:
    iny                        ;increment bitmasks offset in Y
    cpy #$08
    bne TerrBChk               ;if not all bits checked, loop back    
      ldy R1 
      bne TerrLoop               ;unconditional branch, use Y to load next byte
RendBBuf:
    jsr ProcessAreaData        ;do the area data loading routine now
    lda BlockBufferColumnPos
    jsr GetBlockBufferAddr     ;get block buffer address from where we're at
    ldx #$00
    ldy #$00                   ;init index regs and start at beginning of smaller buffer
ChkMTLow:
    sty R0 
    lda MetatileBuffer,x       ;load stored metatile number
    tay
    lda Metatile_Attributes,y
    lsr                        ;move bg attribute bit into carry
    tya
    bcs StrBlock               ;if equal or greater, branch
      lda #$00                   ;if less, init value before storing
StrBlock:
    ldy R0                     ;get offset for block buffer
    sta (R6),y                ;store value into block buffer
    tya
    clc                        ;add 16 (move down one row) to offset
    adc #$10
    tay
    inx                        ;increment column value
    cpx #$0d
    bcc ChkMTLow               ;continue until we pass last row, then leave
  rts

.endproc

;-------------------------------------------------------------------------------------
;$00 - used to store area object identifier
;$07 - used as adder to find proper area object code

ProcessAreaData:
            ldx #$02                 ;start at the end of area object buffer
ProcADLoop: stx ObjectOffset
            lda #$00                 ;reset flag
            sta BehindAreaParserFlag
            ldy AreaDataOffset       ;get offset of area data pointer
            lda (AreaData),y         ;get first byte of area object
            cmp #$fd                 ;if end-of-area, skip all this crap
            beq RdyDecode
            lda AreaObjectLength,x   ;check area object buffer flag
            bpl RdyDecode            ;if buffer not negative, branch, otherwise
            iny
            lda (AreaData),y         ;get second byte of area object
            asl                      ;check for page select bit (d7), branch if not set
            bcc Chk1Row13
            lda AreaObjectPageSel    ;check page select
            bne Chk1Row13
            inc AreaObjectPageSel    ;if not already set, set it now
            inc AreaObjectPageLoc    ;and increment page location
Chk1Row13:  dey
            lda (AreaData),y         ;reread first byte of level object
            and #$0f                 ;mask out high nybble
            cmp #$0d                 ;row 13?
            bne Chk1Row14
            iny                      ;if so, reread second byte of level object
            lda (AreaData),y
            dey                      ;decrement to get ready to read first byte
            and #%01000000           ;check for d6 set (if not, object is page control)
            bne CheckRear
            lda AreaObjectPageSel    ;if page select is set, do not reread
            bne CheckRear
            iny                      ;if d6 not set, reread second byte
            lda (AreaData),y
            and #%00011111           ;mask out all but 5 LSB and store in page control
            sta AreaObjectPageLoc
            inc AreaObjectPageSel    ;increment page select
            jmp NextAObj
Chk1Row14:  cmp #$0e                 ;row 14?
            bne CheckRear
            lda BackloadingFlag      ;check flag for saved page number and branch if set
            bne RdyDecode            ;to render the object (otherwise bg might not look right)
CheckRear:  lda AreaObjectPageLoc    ;check to see if current page of level object is
            cmp CurrentPageLoc       ;behind current page of renderer
            bcc SetBehind            ;if so branch
RdyDecode:  jsr DecodeAreaData       ;do sub and do not turn on flag
            jmp ChkLength
SetBehind:  inc BehindAreaParserFlag ;turn on flag if object is behind renderer
NextAObj:   jsr IncAreaObjOffset     ;increment buffer offset and move on
ChkLength:  ldx ObjectOffset         ;get buffer offset
            lda AreaObjectLength,x   ;check object length for anything stored here
            bmi ProcLoopb            ;if not, branch to handle loopback
            dec AreaObjectLength,x   ;otherwise decrement length or get rid of it
ProcLoopb:  dex                      ;decrement buffer offset
            bpl ProcADLoop           ;and loopback unless exceeded buffer
            lda BehindAreaParserFlag ;check for flag set if objects were behind renderer
            bne ProcessAreaData      ;branch if true to load more level data, otherwise
            lda BackloadingFlag      ;check for flag set if starting right of page $00
            bne ProcessAreaData      ;branch if true to load more level data, otherwise leave
EndAParse:  rts

IncAreaObjOffset:
      inc AreaDataOffset    ;increment offset of level pointer
      inc AreaDataOffset
      lda #$00              ;reset page select
      sta AreaObjectPageSel
      rts

DecodeAreaData:
          lda AreaObjectLength,x     ;check current buffer flag
          bmi Chk1stB
          ldy AreaObjOffsetBuffer,x  ;if not, get offset from buffer
Chk1stB:  ldx #$10                   ;load offset of 16 for special row 15
          lda (AreaData),y           ;get first byte of level object again
          cmp #$fd
          beq EndAParse              ;if end of level, leave this routine
          and #$0f                   ;otherwise, mask out low nybble
          cmp #$0f                   ;row 15?
          beq ChkRow14               ;if so, keep the offset of 16
          ldx #$08                   ;otherwise load offset of 8 for special row 12
          cmp #$0c                   ;row 12?
          beq ChkRow14               ;if so, keep the offset value of 8
          ldx #$00                   ;otherwise nullify value by default
ChkRow14: stx R7                     ;store whatever value we just loaded here
          ldx ObjectOffset           ;get object offset again
          cmp #$0e                   ;row 14?
          bne ChkRow13
          lda #$00                   ;if so, load offset with $00
          sta R7 
          lda #$2e                   ;and load A with another value
          bne NormObj                ;unconditional branch
ChkRow13: cmp #$0d                   ;row 13?
          bne ChkSRows
          lda #$22                   ;if so, load offset with 34
          sta R7 
          iny                        ;get next byte
          lda (AreaData),y
          and #%01000000             ;mask out all but d6 (page control obj bit)
          beq LeavePar               ;if d6 clear, branch to leave (we handled this earlier)
          lda (AreaData),y           ;otherwise, get byte again
          and #%01111111             ;mask out d7
          cmp #$4b                   ;check for loop command in low nybble
          bne Mask2MSB               ;(plus d6 set for object other than page control)
          inc LoopCommand            ;if loop command, set loop command flag
Mask2MSB: and #%00111111             ;mask out d7 and d6
          jmp NormObj                ;and jump
ChkSRows: cmp #$0c                   ;row 12-15?
          bcs SpecObj
          iny                        ;if not, get second byte of level object
          lda (AreaData),y
          and #%01110000             ;mask out all but d6-d4
          bne LrgObj                 ;if any bits set, branch to handle large object
          lda #$16
          sta R7                     ;otherwise set offset of 24 for small object
          lda (AreaData),y           ;reload second byte of level object
          and #%00001111             ;mask out higher nybble and jump
          jmp NormObj
LrgObj:   sta R0                     ;store value here (branch for large objects)
          cmp #$70                   ;check for vertical pipe object
          bne NotWPipe
          lda (AreaData),y           ;if not, reload second byte
          and #%00001000             ;mask out all but d3 (usage control bit)
          beq NotWPipe               ;if d3 clear, branch to get original value
          lda #$00                   ;otherwise, nullify value for warp pipe
          sta R0 
NotWPipe: lda R0                     ;get value and jump ahead
          jmp MoveAOId
SpecObj:  iny                        ;branch here for rows 12-15
          lda (AreaData),y
          and #%01110000             ;get next byte and mask out all but d6-d4
MoveAOId: lsr                        ;move d6-d4 to lower nybble
          lsr
          lsr
          lsr
NormObj:  sta R0                     ;store value here (branch for small objects and rows 13 and 14)
          lda AreaObjectLength,x     ;is there something stored here already?
          bpl RunAObj                ;if so, branch to do its particular sub
          lda AreaObjectPageLoc      ;otherwise check to see if the object we've loaded is on the
          cmp CurrentPageLoc         ;same page as the renderer, and if so, branch
          beq InitRear
          ldy AreaDataOffset         ;if not, get old offset of level pointer
          lda (AreaData),y           ;and reload first byte
          and #%00001111
          cmp #$0e                   ;row 14?
          bne LeavePar
          lda BackloadingFlag        ;if so, check backloading flag
          bne StrAObj                ;if set, branch to render object, else leave
LeavePar: rts
InitRear: lda BackloadingFlag        ;check backloading flag to see if it's been initialized
          beq BackColC               ;branch to column-wise check
          lda #$00                   ;if not, initialize both backloading and 
          sta BackloadingFlag        ;behind-renderer flags and leave
          sta BehindAreaParserFlag
          sta ObjectOffset
LoopCmdE: rts
BackColC: ldy AreaDataOffset         ;get first byte again
          lda (AreaData),y
          and #%11110000             ;mask out low nybble and move high to low
          lsr
          lsr
          lsr
          lsr
          cmp CurrentColumnPos       ;is this where we're at?
          bne LeavePar               ;if not, branch to leave
StrAObj:  lda AreaDataOffset         ;if so, load area obj offset and store in buffer
          sta AreaObjOffsetBuffer,x
          jsr IncAreaObjOffset       ;do sub to increment to next object data
RunAObj:  lda R0                     ;get stored value and add offset to it
          clc                        ;then use the jump engine with current contents of A
          adc R7 
          jsr JumpEngine

;large objects (rows $00-$0b or 00-11, d6-d4 set)
      .word VerticalPipe         ;used by warp pipes
      .word AreaStyleObject
      .word RowOfBricks
      .word RowOfSolidBlocks
      .word RowOfCoins
      .word ColumnOfBricks
      .word ColumnOfSolidBlocks
      .word VerticalPipe         ;used by decoration pipes

;objects for special row $0c or 12
      .word Hole_Empty
      .word PulleyRopeObject
      .word Bridge_High
      .word Bridge_Middle
      .word Bridge_Low
      .word Hole_Water
      .word QuestionBlockRow_High
      .word QuestionBlockRow_Low

;objects for special row $0f or 15
      .word EndlessRope
      .word BalancePlatRope
      .word CastleObject
      .word StaircaseObject
      .word ExitPipe
      .word FlagpoleObject

;small objects (rows $00-$0b or 00-11, d6-d4 all clear)
      .word QuestionBlock     ;power-up
      .word QuestionBlock     ;coin
      .word QuestionBlock     ;hidden, coin
      .word Hidden1UpBlock    ;hidden, 1-up
      .word BrickWithItem     ;brick, power-up
      .word BrickWithItem     ;brick, vine
      .word BrickWithItem     ;brick, star
      .word BrickWithCoins    ;brick, coins
      .word BrickWithItem     ;brick, 1-up
      .word WaterPipe
      .word EmptyBlock
      .word Jumpspring

;objects for special row $0d or 13 (d6 set)
      .word IntroPipe
      .word FlagpoleObject
      .word AxeObj
      .word ChainObj
      .word CastleBridgeObj
      .word ScrollLockObject_Warp
      .word ScrollLockObject
      .word ScrollLockObject
      .word AreaFrenzy            ;flying cheep-cheeps 
      .word AreaFrenzy            ;bullet bills or swimming cheep-cheeps
      .word AreaFrenzy            ;stop frenzy
      .word LoopCmdE

;object for special row $0e or 14
      .word AlterAreaAttributes

;-------------------------------------------------------------------------------------
;(these apply to all area object subroutines in this section unless otherwise stated)
;$00 - used to store offset used to find object code
;$07 - starts with adder from area parser, used to store row offset

AlterAreaAttributes:
         ldy AreaObjOffsetBuffer,x ;load offset for level object data saved in buffer
         iny                       ;load second byte
         lda (AreaData),y
         pha                       ;save in stack for now
         and #%01000000
         bne Alter2                ;branch if d6 is set
         pla
         pha                       ;pull and push offset to copy to A
         and #%00001111            ;mask out high nybble and store as
         sta TerrainControl        ;new terrain height type bits
         pla
         and #%00110000            ;pull and mask out all but d5 and d4
         lsr                       ;move bits to lower nybble and store
         lsr                       ;as new background scenery bits
         lsr
         lsr
         sta BackgroundScenery     ;then leave
         rts
Alter2:  pla
         and #%00000111            ;mask out all but 3 LSB
         cmp #$04                  ;if four or greater, set color control bits
         bcc SetFore               ;and nullify foreground scenery bits
         sta BackgroundColorCtrl
         lda #$00
SetFore: sta ForegroundScenery     ;otherwise set new foreground scenery bits
         rts


;--------------------------------
ScrollLockObject_Warp:
         ldx #$04            ;load value of 4 for game text routine as default
         lda WorldNumber     ;warp zone (4-3-2), then check world number
         beq WarpNum
         inx                 ;if world number > 1, increment for next warp zone (5)
         ldy AreaType        ;check area type
         dey
         bne WarpNum         ;if ground area type, increment for last warp zone
         inx                 ;(8-7-6) and move on
WarpNum: txa
         sta WarpZoneControl ;store number here to be used by warp zone routine
         farcall WriteGameText   ;print text and warp zone numbers
         lda #PiranhaPlant
         jsr KillEnemies     ;load identifier for piranha plants and do sub

ScrollLockObject:
      lda ScrollLock      ;invert scroll lock to turn it on
      eor #%00000001
      sta ScrollLock
      rts


;--------------------------------

FrenzyIDData:
      .byte FlyCheepCheepFrenzy, BBill_CCheep_Frenzy, Stop_Frenzy

AreaFrenzy:  ldx R0                ;use area object identifier bit as offset
             lda FrenzyIDData-8,x  ;note that it starts at 8, thus weird address here
             ldy #$05
FreCompLoop: dey                   ;check regular slots of enemy object buffer
             bmi ExitAFrenzy       ;if all slots checked and enemy object not found, branch to store
             cmp Enemy_ID,y    ;check for enemy object in buffer versus frenzy object
             bne FreCompLoop
             lda #$00              ;if enemy object already present, nullify queue and leave
ExitAFrenzy: sta EnemyFrenzyQueue  ;store enemy into frenzy queue
             rts



;--------------------------------

ChkLrgObjLength:
        jsr GetLrgObjAttrib     ;get row location and size (length if branched to from here)

ChkLrgObjFixedLength:
        lda AreaObjectLength,x  ;check for set length counter
        clc                     ;clear carry flag for not just starting
        bpl LenSet              ;if counter not set, load it, otherwise leave alone
        tya                     ;save length into length counter
        sta AreaObjectLength,x
        sec                     ;set carry flag if just starting
LenSet: rts


GetLrgObjAttrib:
      ldy AreaObjOffsetBuffer,x ;get offset saved from area obj decoding routine
      lda (AreaData),y          ;get first byte of level object
      and #%00001111
      sta R7                    ;save row location
      iny
      lda (AreaData),y          ;get next byte, save lower nybble (length or height)
      and #%00001111            ;as Y, then leave
      tay
      rts

;--------------------------------

GetAreaObjXPosition:
      lda CurrentColumnPos    ;multiply current offset where we're at by 16
      asl                     ;to obtain horizontal pixel coordinate
      asl
      asl
      asl
      rts

;--------------------------------

GetAreaObjYPosition:
      lda R7   ;multiply value by 16
      asl
      asl      ;this will give us the proper vertical pixel coordinate
      asl
      asl
      clc
      adc #32  ;add 32 pixels for the status bar
      rts

;-------------------------------------------------------------------------------------
;GAME LEVELS DATA

;bonus area data offsets, included here for comparison purposes
;underground bonus area  - c2
;cloud area 1 (day)      - 2b
;cloud area 2 (night)    - 34
;water area (5-2/6-2)    - 00
;water area (8-4)        - 02
;warp zone area (4-2)    - 2f

EnemyAddrHOffsets:
      .byte $1f, $06, $1c, $00

.define EnemyDataAddr \
      E_CastleArea1, E_CastleArea2, E_CastleArea3, E_CastleArea4, E_CastleArea5, E_CastleArea6, \
      E_GroundArea1, E_GroundArea2, E_GroundArea3, E_GroundArea4, E_GroundArea5, E_GroundArea6, \
      E_GroundArea7, E_GroundArea8, E_GroundArea9, E_GroundArea10, E_GroundArea11, E_GroundArea12, \
      E_GroundArea13, E_GroundArea14, E_GroundArea15, E_GroundArea16, E_GroundArea17, E_GroundArea18, \
      E_GroundArea19, E_GroundArea20, E_GroundArea21, E_GroundArea22, E_UndergroundArea1, \
      E_UndergroundArea2, E_UndergroundArea3, E_WaterArea1, E_WaterArea2, E_WaterArea3

EnemyDataAddrLow: .lobytes EnemyDataAddr
EnemyDataAddrHigh: .hibytes EnemyDataAddr

AreaDataHOffsets:
      .byte $00, $03, $19, $1c

.define AreaDataAddr \
      L_WaterArea1, L_WaterArea2, L_WaterArea3, L_GroundArea1, L_GroundArea2, L_GroundArea3, \
      L_GroundArea4, L_GroundArea5, L_GroundArea6, L_GroundArea7, L_GroundArea8, L_GroundArea9, \
      L_GroundArea10, L_GroundArea11, L_GroundArea12, L_GroundArea13, L_GroundArea14, L_GroundArea15, \
      L_GroundArea16, L_GroundArea17, L_GroundArea18, L_GroundArea19, L_GroundArea20, L_GroundArea21, \
      L_GroundArea22, L_UndergroundArea1, L_UndergroundArea2, L_UndergroundArea3, L_CastleArea1, \
      L_CastleArea2, L_CastleArea3, L_CastleArea4, L_CastleArea5, L_CastleArea6

AreaDataAddrLow: .lobytes AreaDataAddr
AreaDataAddrHigh: .hibytes AreaDataAddr


;ENEMY OBJECT DATA

;level 1-4/6-4
E_CastleArea1:
      .byte $76, $dd, $bb, $4c, $ea, $1d, $1b, $cc, $56, $5d
      .byte $16, $9d, $c6, $1d, $36, $9d, $c9, $1d, $04, $db
      .byte $49, $1d, $84, $1b, $c9, $5d, $88, $95, $0f, $08
      .byte $30, $4c, $78, $2d, $a6, $28, $90, $b5
      .byte $ff

;level 4-4
E_CastleArea2:
      .byte $0f, $03, $56, $1b, $c9, $1b, $0f, $07, $36, $1b
      .byte $aa, $1b, $48, $95, $0f, $0a, $2a, $1b, $5b, $0c
      .byte $78, $2d, $90, $b5
      .byte $ff

;level 2-4/5-4
E_CastleArea3:
      .byte $0b, $8c, $4b, $4c, $77, $5f, $eb, $0c, $bd, $db
      .byte $19, $9d, $75, $1d, $7d, $5b, $d9, $1d, $3d, $dd
      .byte $99, $1d, $26, $9d, $5a, $2b, $8a, $2c, $ca, $1b
      .byte $20, $95, $7b, $5c, $db, $4c, $1b, $cc, $3b, $cc
      .byte $78, $2d, $a6, $28, $90, $b5
      .byte $ff

;level 3-4
E_CastleArea4:
      .byte $0b, $8c, $3b, $1d, $8b, $1d, $ab, $0c, $db, $1d
      .byte $0f, $03, $65, $1d, $6b, $1b, $05, $9d, $0b, $1b
      .byte $05, $9b, $0b, $1d, $8b, $0c, $1b, $8c, $70, $15
      .byte $7b, $0c, $db, $0c, $0f, $08, $78, $2d, $a6, $28
      .byte $90, $b5
      .byte $ff

;level 7-4
E_CastleArea5:
      .byte $27, $a9, $4b, $0c, $68, $29, $0f, $06, $77, $1b
      .byte $0f, $0b, $60, $15, $4b, $8c, $78, $2d, $90, $b5
      .byte $ff

;level 8-4
E_CastleArea6:
      .byte $0f, $03, $8e, $65, $e1, $bb, $38, $6d, $a8, $3e, $e5, $e7
      .byte $0f, $08, $0b, $02, $2b, $02, $5e, $65, $e1, $bb, $0e
      .byte $db, $0e, $bb, $8e, $db, $0e, $fe, $65, $ec, $0f, $0d
      .byte $4e, $65, $e1, $0f, $0e, $4e, $02, $e0, $0f, $10, $fe, $e5, $e1
      .byte $1b, $85, $7b, $0c, $5b, $95, $78, $2d, $90, $b5
      .byte $ff

;level 3-3
E_GroundArea1:
      .byte $a5, $86, $e4, $28, $18, $a8, $45, $83, $69, $03
      .byte $c6, $29, $9b, $83, $16, $a4, $88, $24, $e9, $28
      .byte $05, $a8, $7b, $28, $24, $8f, $c8, $03, $e8, $03
      .byte $46, $a8, $85, $24, $c8, $24
      .byte $ff

;level 8-3
E_GroundArea2:
      .byte $eb, $8e, $0f, $03, $fb, $05, $17, $85, $db, $8e
      .byte $0f, $07, $57, $05, $7b, $05, $9b, $80, $2b, $85
      .byte $fb, $05, $0f, $0b, $1b, $05, $9b, $05
      .byte $ff

;level 4-1
E_GroundArea3:
      .byte $2e, $c2, $66, $e2, $11, $0f, $07, $02, $11, $0f, $0c
      .byte $12, $11
      .byte $ff

;level 6-2
E_GroundArea4:
      .byte $0e, $c2, $a8, $ab, $00, $bb, $8e, $6b, $82, $de, $00, $a0
      .byte $33, $86, $43, $06, $3e, $b4, $a0, $cb, $02, $0f, $07
      .byte $7e, $42, $a6, $83, $02, $0f, $0a, $3b, $02, $cb, $37
      .byte $0f, $0c, $e3, $0e
      .byte $ff

;level 3-1
E_GroundArea5:
      .byte $9b, $8e, $ca, $0e, $ee, $42, $44, $5b, $86, $80, $b8
      .byte $1b, $80, $50, $ba, $10, $b7, $5b, $00, $17, $85
      .byte $4b, $05, $fe, $34, $40, $b7, $86, $c6, $06, $5b, $80
      .byte $83, $00, $d0, $38, $5b, $8e, $8a, $0e, $a6, $00
      .byte $bb, $0e, $c5, $80, $f3, $00
      .byte $ff

;level 1-1
E_GroundArea6:
      .byte $1e, $c2, $00, $6b, $06, $8b, $86, $63, $b7, $0f, $05
      .byte $03, $06, $23, $06, $4b, $b7, $bb, $00, $5b, $b7
      .byte $fb, $37, $3b, $b7, $0f, $0b, $1b, $37
      .byte $ff

;level 1-3/5-3
E_GroundArea7:
      .byte $2b, $d7, $e3, $03, $c2, $86, $e2, $06, $76, $a5
      .byte $a3, $8f, $03, $86, $2b, $57, $68, $28, $e9, $28
      .byte $e5, $83, $24, $8f, $36, $a8, $5b, $03
      .byte $ff

;level 2-3/7-3
E_GroundArea8:
      .byte $0f, $02, $78, $40, $48, $ce, $f8, $c3, $f8, $c3
      .byte $0f, $07, $7b, $43, $c6, $d0, $0f, $8a, $c8, $50
      .byte $ff

;level 2-1
E_GroundArea9:
      .byte $85, $86, $0b, $80, $1b, $00, $db, $37, $77, $80
      .byte $eb, $37, $fe, $2b, $20, $2b, $80, $7b, $38, $ab, $b8
      .byte $77, $86, $fe, $42, $20, $49, $86, $8b, $06, $9b, $80
      .byte $7b, $8e, $5b, $b7, $9b, $0e, $bb, $0e, $9b, $80
;pipe intro area
E_GroundArea10:
      .byte $ff

;level 5-1
E_GroundArea11:
      .byte $0b, $80, $60, $38, $10, $b8, $c0, $3b, $db, $8e
      .byte $40, $b8, $f0, $38, $7b, $8e, $a0, $b8, $c0, $b8
      .byte $fb, $00, $a0, $b8, $30, $bb, $ee, $42, $88, $0f, $0b
      .byte $2b, $0e, $67, $0e
      .byte $ff

;cloud level used in levels 2-1 and 5-2
E_GroundArea12:
      .byte $0a, $aa, $0e, $28, $2a, $0e, $31, $88
      .byte $ff

;level 4-3
E_GroundArea13:
      .byte $c7, $83, $d7, $03, $42, $8f, $7a, $03, $05, $a4
      .byte $78, $24, $a6, $25, $e4, $25, $4b, $83, $e3, $03
      .byte $05, $a4, $89, $24, $b5, $24, $09, $a4, $65, $24
      .byte $c9, $24, $0f, $08, $85, $25
      .byte $ff

;level 6-3
E_GroundArea14:
      .byte $cd, $a5, $b5, $a8, $07, $a8, $76, $28, $cc, $25
      .byte $65, $a4, $a9, $24, $e5, $24, $19, $a4, $0f, $07
      .byte $95, $28, $e6, $24, $19, $a4, $d7, $29, $16, $a9
      .byte $58, $29, $97, $29
      .byte $ff

;level 6-1
E_GroundArea15:
      .byte $0f, $02, $02, $11, $0f, $07, $02, $11
      .byte $ff

;warp zone area used in level 4-2
E_GroundArea16:
      .byte $ff

;level 8-1
E_GroundArea17:
      .byte $2b, $82, $ab, $38, $de, $42, $e2, $1b, $b8, $eb
      .byte $3b, $db, $80, $8b, $b8, $1b, $82, $fb, $b8, $7b
      .byte $80, $fb, $3c, $5b, $bc, $7b, $b8, $1b, $8e, $cb
      .byte $0e, $1b, $8e, $0f, $0d, $2b, $3b, $bb, $b8, $eb, $82
      .byte $4b, $b8, $bb, $38, $3b, $b7, $bb, $02, $0f, $13
      .byte $1b, $00, $cb, $80, $6b, $bc
      .byte $ff

;level 5-2
E_GroundArea18:
      .byte $7b, $80, $ae, $00, $80, $8b, $8e, $e8, $05, $f9, $86 
      .byte $17, $86, $16, $85, $4e, $2b, $80, $ab, $8e, $87, $85
      .byte $c3, $05, $8b, $82, $9b, $02, $ab, $02, $bb, $86
      .byte $cb, $06, $d3, $03, $3b, $8e, $6b, $0e, $a7, $8e
      .byte $ff

;level 8-2
E_GroundArea19:
      .byte $29, $8e, $52, $11, $83, $0e, $0f, $03, $9b, $0e
      .byte $2b, $8e, $5b, $0e, $cb, $8e, $fb, $0e, $fb, $82
      .byte $9b, $82, $bb, $02, $fe, $42, $e8, $bb, $8e, $0f, $0a
      .byte $ab, $0e, $cb, $0e, $f9, $0e, $88, $86, $a6, $06
      .byte $db, $02, $b6, $8e
      .byte $ff

;level 7-1
E_GroundArea20:
      .byte $ab, $ce, $de, $42, $c0, $cb, $ce, $5b, $8e, $1b, $ce
      .byte $4b, $85, $67, $45, $0f, $07, $2b, $00, $7b, $85
      .byte $97, $05, $0f, $0a, $92, $02
      .byte $ff

;cloud level used in levels 3-1 and 6-2
E_GroundArea21:
      .byte $0a, $aa, $0e, $24, $4a, $1e, $23, $aa
      .byte $ff

;level 3-2
E_GroundArea22:
      .byte $1b, $80, $bb, $38, $4b, $bc, $eb, $3b, $0f, $04
      .byte $2b, $00, $ab, $38, $eb, $00, $cb, $8e, $fb, $80
      .byte $ab, $b8, $6b, $80, $fb, $3c, $9b, $bb, $5b, $bc
      .byte $fb, $00, $6b, $b8, $fb, $38
      .byte $ff

;level 1-2
E_UndergroundArea1:
      .byte $0b, $86, $1a, $06, $db, $06, $de, $c2, $02, $f0, $3b
      .byte $bb, $80, $eb, $06, $0b, $86, $93, $06, $f0, $39
      .byte $0f, $06, $60, $b8, $1b, $86, $a0, $b9, $b7, $27
      .byte $bd, $27, $2b, $83, $a1, $26, $a9, $26, $ee, $25, $0b
      .byte $27, $b4
      .byte $ff

;level 4-2
E_UndergroundArea2:
      .byte $0f, $02, $1e, $2f, $60, $e0, $3a, $a5, $a7, $db, $80
      .byte $3b, $82, $8b, $02, $fe, $42, $68, $70, $bb, $25, $a7
      .byte $2c, $27, $b2, $26, $b9, $26, $9b, $80, $a8, $82
      .byte $b5, $27, $bc, $27, $b0, $bb, $3b, $82, $87, $34
      .byte $ee, $25, $6b
      .byte $ff

;underground bonus rooms area used in many levels
E_UndergroundArea3:
      .byte $1e, $a5, $0a, $2e, $28, $27, $2e, $33, $c7, $0f, $03, $1e, $40, $07
      .byte $2e, $30, $e7, $0f, $05, $1e, $24, $44, $0f, $07, $1e, $22, $6a
      .byte $2e, $23, $ab, $0f, $09, $1e, $41, $68, $1e, $2a, $8a, $2e, $23, $a2
      .byte $2e, $32, $ea
      .byte $ff

;water area used in levels 5-2 and 6-2
E_WaterArea1:
      .byte $3b, $87, $66, $27, $cc, $27, $ee, $31, $87, $ee, $23, $a7
      .byte $3b, $87, $db, $07
      .byte $ff

;level 2-2/7-2
E_WaterArea2:
      .byte $0f, $01, $2e, $25, $2b, $2e, $25, $4b, $4e, $25, $cb, $6b, $07
      .byte $97, $47, $e9, $87, $47, $c7, $7a, $07, $d6, $c7
      .byte $78, $07, $38, $87, $ab, $47, $e3, $07, $9b, $87
      .byte $0f, $09, $68, $47, $db, $c7, $3b, $c7
      .byte $ff

;water area used in level 8-4
E_WaterArea3:
      .byte $47, $9b, $cb, $07, $fa, $1d, $86, $9b, $3a, $87
      .byte $56, $07, $88, $1b, $07, $9d, $2e, $65, $f0
      .byte $ff

;AREA OBJECT DATA

;level 1-4/6-4
L_CastleArea1:
      .byte $9b, $07
      .byte $05, $32, $06, $33, $07, $34, $ce, $03, $dc, $51
      .byte $ee, $07, $73, $e0, $74, $0a, $7e, $06, $9e, $0a
      .byte $ce, $06, $e4, $00, $e8, $0a, $fe, $0a, $2e, $89
      .byte $4e, $0b, $54, $0a, $14, $8a, $c4, $0a, $34, $8a
      .byte $7e, $06, $c7, $0a, $01, $e0, $02, $0a, $47, $0a
      .byte $81, $60, $82, $0a, $c7, $0a, $0e, $87, $7e, $02
      .byte $a7, $02, $b3, $02, $d7, $02, $e3, $02, $07, $82
      .byte $13, $02, $3e, $06, $7e, $02, $ae, $07, $fe, $0a
      .byte $0d, $c4, $cd, $43, $ce, $09, $de, $0b, $dd, $42
      .byte $fe, $02, $5d, $c7
      .byte $fd

;level 4-4
L_CastleArea2:
      .byte $5b, $07
      .byte $05, $32, $06, $33, $07, $34, $5e, $0a, $68, $64
      .byte $98, $64, $a8, $64, $ce, $06, $fe, $02, $0d, $01
      .byte $1e, $0e, $7e, $02, $94, $63, $b4, $63, $d4, $63
      .byte $f4, $63, $14, $e3, $2e, $0e, $5e, $02, $64, $35
      .byte $88, $72, $be, $0e, $0d, $04, $ae, $02, $ce, $08
      .byte $cd, $4b, $fe, $02, $0d, $05, $68, $31, $7e, $0a
      .byte $96, $31, $a9, $63, $a8, $33, $d5, $30, $ee, $02
      .byte $e6, $62, $f4, $61, $04, $b1, $08, $3f, $44, $33
      .byte $94, $63, $a4, $31, $e4, $31, $04, $bf, $08, $3f
      .byte $04, $bf, $08, $3f, $cd, $4b, $03, $e4, $0e, $03
      .byte $2e, $01, $7e, $06, $be, $02, $de, $06, $fe, $0a
      .byte $0d, $c4, $cd, $43, $ce, $09, $de, $0b, $dd, $42
      .byte $fe, $02, $5d, $c7
      .byte $fd

;level 2-4/5-4
L_CastleArea3:
      .byte $9b, $07
      .byte $05, $32, $06, $33, $07, $34, $fe, $00, $27, $b1
      .byte $65, $32, $75, $0a, $71, $00, $b7, $31, $08, $e4
      .byte $18, $64, $1e, $04, $57, $3b, $bb, $0a, $17, $8a
      .byte $27, $3a, $73, $0a, $7b, $0a, $d7, $0a, $e7, $3a
      .byte $3b, $8a, $97, $0a, $fe, $08, $24, $8a, $2e, $00
      .byte $3e, $40, $38, $64, $6f, $00, $9f, $00, $be, $43
      .byte $c8, $0a, $c9, $63, $ce, $07, $fe, $07, $2e, $81
      .byte $66, $42, $6a, $42, $79, $0a, $be, $00, $c8, $64
      .byte $f8, $64, $08, $e4, $2e, $07, $7e, $03, $9e, $07
      .byte $be, $03, $de, $07, $fe, $0a, $03, $a5, $0d, $44
      .byte $cd, $43, $ce, $09, $dd, $42, $de, $0b, $fe, $02
      .byte $5d, $c7
      .byte $fd

;level 3-4
L_CastleArea4:
      .byte $9b, $07
      .byte $05, $32, $06, $33, $07, $34, $fe, $06, $0c, $81
      .byte $39, $0a, $5c, $01, $89, $0a, $ac, $01, $d9, $0a
      .byte $fc, $01, $2e, $83, $a7, $01, $b7, $00, $c7, $01
      .byte $de, $0a, $fe, $02, $4e, $83, $5a, $32, $63, $0a
      .byte $69, $0a, $7e, $02, $ee, $03, $fa, $32, $03, $8a
      .byte $09, $0a, $1e, $02, $ee, $03, $fa, $32, $03, $8a
      .byte $09, $0a, $14, $42, $1e, $02, $7e, $0a, $9e, $07
      .byte $fe, $0a, $2e, $86, $5e, $0a, $8e, $06, $be, $0a
      .byte $ee, $07, $3e, $83, $5e, $07, $fe, $0a, $0d, $c4
      .byte $41, $52, $51, $52, $cd, $43, $ce, $09, $de, $0b
      .byte $dd, $42, $fe, $02, $5d, $c7
      .byte $fd

;level 7-4
L_CastleArea5:
      .byte $5b, $07
      .byte $05, $32, $06, $33, $07, $34, $fe, $0a, $ae, $86
      .byte $be, $07, $fe, $02, $0d, $02, $27, $32, $46, $61
      .byte $55, $62, $5e, $0e, $1e, $82, $68, $3c, $74, $3a
      .byte $7d, $4b, $5e, $8e, $7d, $4b, $7e, $82, $84, $62
      .byte $94, $61, $a4, $31, $bd, $4b, $ce, $06, $fe, $02
      .byte $0d, $06, $34, $31, $3e, $0a, $64, $32, $75, $0a
      .byte $7b, $61, $a4, $33, $ae, $02, $de, $0e, $3e, $82
      .byte $64, $32, $78, $32, $b4, $36, $c8, $36, $dd, $4b
      .byte $44, $b2, $58, $32, $94, $63, $a4, $3e, $ba, $30
      .byte $c9, $61, $ce, $06, $dd, $4b, $ce, $86, $dd, $4b
      .byte $fe, $02, $2e, $86, $5e, $02, $7e, $06, $fe, $02
      .byte $1e, $86, $3e, $02, $5e, $06, $7e, $02, $9e, $06
      .byte $fe, $0a, $0d, $c4, $cd, $43, $ce, $09, $de, $0b
      .byte $dd, $42, $fe, $02, $5d, $c7
      .byte $fd

;level 8-4
L_CastleArea6:
      .byte $5b, $06
      .byte $05, $32, $06, $33, $07, $34, $5e, $0a, $ae, $02
      .byte $0d, $01, $39, $73, $0d, $03, $39, $7b, $4d, $4b
      .byte $de, $06, $1e, $8a, $ae, $06, $c4, $33, $16, $fe
      .byte $a5, $77, $fe, $02, $fe, $82, $0d, $07, $39, $73
      .byte $a8, $74, $ed, $4b, $49, $fb, $e8, $74, $fe, $0a
      .byte $2e, $82, $67, $02, $84, $7a, $87, $31, $0d, $0b
      .byte $fe, $02, $0d, $0c, $39, $73, $5e, $06, $c6, $76
      .byte $45, $ff, $be, $0a, $dd, $48, $fe, $06, $3d, $cb
      .byte $46, $7e, $ad, $4a, $fe, $82, $39, $f3, $a9, $7b
      .byte $4e, $8a, $9e, $07, $fe, $0a, $0d, $c4, $cd, $43
      .byte $ce, $09, $de, $0b, $dd, $42, $fe, $02, $5d, $c7
      .byte $fd

;level 3-3
L_GroundArea1:
      .byte $94, $11
      .byte $0f, $26, $fe, $10, $28, $94, $65, $15, $eb, $12
      .byte $fa, $41, $4a, $96, $54, $40, $a4, $42, $b7, $13
      .byte $e9, $19, $f5, $15, $11, $80, $47, $42, $71, $13
      .byte $80, $41, $15, $92, $1b, $1f, $24, $40, $55, $12
      .byte $64, $40, $95, $12, $a4, $40, $d2, $12, $e1, $40
      .byte $13, $c0, $2c, $17, $2f, $12, $49, $13, $83, $40
      .byte $9f, $14, $a3, $40, $17, $92, $83, $13, $92, $41
      .byte $b9, $14, $c5, $12, $c8, $40, $d4, $40, $4b, $92
      .byte $78, $1b, $9c, $94, $9f, $11, $df, $14, $fe, $11
      .byte $7d, $c1, $9e, $42, $cf, $20
      .byte $fd

;level 8-3
L_GroundArea2:
      .byte $90, $b1
      .byte $0f, $26, $29, $91, $7e, $42, $fe, $40, $28, $92
      .byte $4e, $42, $2e, $c0, $57, $73, $c3, $25, $c7, $27
      .byte $23, $84, $33, $20, $5c, $01, $77, $63, $88, $62
      .byte $99, $61, $aa, $60, $bc, $01, $ee, $42, $4e, $c0
      .byte $69, $11, $7e, $42, $de, $40, $f8, $62, $0e, $c2
      .byte $ae, $40, $d7, $63, $e7, $63, $33, $a7, $37, $27
      .byte $43, $04, $cc, $01, $e7, $73, $0c, $81, $3e, $42
      .byte $0d, $0a, $5e, $40, $88, $72, $be, $42, $e7, $87
      .byte $fe, $40, $39, $e1, $4e, $00, $69, $60, $87, $60
      .byte $a5, $60, $c3, $31, $fe, $31, $6d, $c1, $be, $42
      .byte $ef, $20
      .byte $fd

;level 4-1
L_GroundArea3:
      .byte $52, $21
      .byte $0f, $20, $6e, $40, $58, $f2, $93, $01, $97, $00
      .byte $0c, $81, $97, $40, $a6, $41, $c7, $40, $0d, $04
      .byte $03, $01, $07, $01, $23, $01, $27, $01, $ec, $03
      .byte $ac, $f3, $c3, $03, $78, $e2, $94, $43, $47, $f3
      .byte $74, $43, $47, $fb, $74, $43, $2c, $f1, $4c, $63
      .byte $47, $00, $57, $21, $5c, $01, $7c, $72, $39, $f1
      .byte $ec, $02, $4c, $81, $d8, $62, $ec, $01, $0d, $0d
      .byte $0f, $38, $c7, $07, $ed, $4a, $1d, $c1, $5f, $26
      .byte $fd

;level 6-2
L_GroundArea4:
      .byte $54, $21
      .byte $0f, $26, $a7, $22, $37, $fb, $73, $20, $83, $07
      .byte $87, $02, $93, $20, $c7, $73, $04, $f1, $06, $31
      .byte $39, $71, $59, $71, $e7, $73, $37, $a0, $47, $04
      .byte $86, $7c, $e5, $71, $e7, $31, $33, $a4, $39, $71
      .byte $a9, $71, $d3, $23, $08, $f2, $13, $05, $27, $02
      .byte $49, $71, $75, $75, $e8, $72, $67, $f3, $99, $71
      .byte $e7, $20, $f4, $72, $f7, $31, $17, $a0, $33, $20
      .byte $39, $71, $73, $28, $bc, $05, $39, $f1, $79, $71
      .byte $a6, $21, $c3, $06, $d3, $20, $dc, $00, $fc, $00
      .byte $07, $a2, $13, $21, $5f, $32, $8c, $00, $98, $7a
      .byte $c7, $63, $d9, $61, $03, $a2, $07, $22, $74, $72
      .byte $77, $31, $e7, $73, $39, $f1, $58, $72, $77, $73
      .byte $d8, $72, $7f, $b1, $97, $73, $b6, $64, $c5, $65
      .byte $d4, $66, $e3, $67, $f3, $67, $8d, $c1, $cf, $26
      .byte $fd

;level 3-1
L_GroundArea5:
      .byte $52, $31
      .byte $0f, $20, $6e, $66, $07, $81, $36, $01, $66, $00
      .byte $a7, $22, $08, $f2, $67, $7b, $dc, $02, $98, $f2
      .byte $d7, $20, $39, $f1, $9f, $33, $dc, $27, $dc, $57
      .byte $23, $83, $57, $63, $6c, $51, $87, $63, $99, $61
      .byte $a3, $06, $b3, $21, $77, $f3, $f3, $21, $f7, $2a
      .byte $13, $81, $23, $22, $53, $00, $63, $22, $e9, $0b
      .byte $0c, $83, $13, $21, $16, $22, $33, $05, $8f, $35
      .byte $ec, $01, $63, $a0, $67, $20, $73, $01, $77, $01
      .byte $83, $20, $87, $20, $b3, $20, $b7, $20, $c3, $01
      .byte $c7, $00, $d3, $20, $d7, $20, $67, $a0, $77, $07
      .byte $87, $22, $e8, $62, $f5, $65, $1c, $82, $7f, $38
      .byte $8d, $c1, $cf, $26
      .byte $fd

;level 1-1
L_GroundArea6:
      .byte $50, $21
      .byte $07, $81, $47, $24, $57, $00, $63, $01, $77, $01
      .byte $c9, $71, $68, $f2, $e7, $73, $97, $fb, $06, $83
      .byte $5c, $01, $d7, $22, $e7, $00, $03, $a7, $6c, $02
      .byte $b3, $22, $e3, $01, $e7, $07, $47, $a0, $57, $06
      .byte $a7, $01, $d3, $00, $d7, $01, $07, $81, $67, $20
      .byte $93, $22, $03, $a3, $1c, $61, $17, $21, $6f, $33
      .byte $c7, $63, $d8, $62, $e9, $61, $fa, $60, $4f, $b3
      .byte $87, $63, $9c, $01, $b7, $63, $c8, $62, $d9, $61
      .byte $ea, $60, $39, $f1, $87, $21, $a7, $01, $b7, $20
      .byte $39, $f1, $5f, $38, $6d, $c1, $af, $26
      .byte $fd

;level 1-3/5-3
L_GroundArea7:
      .byte $90, $11
      .byte $0f, $26, $fe, $10, $2a, $93, $87, $17, $a3, $14
      .byte $b2, $42, $0a, $92, $19, $40, $36, $14, $50, $41
      .byte $82, $16, $2b, $93, $24, $41, $bb, $14, $b8, $00
      .byte $c2, $43, $c3, $13, $1b, $94, $67, $12, $c4, $15
      .byte $53, $c1, $d2, $41, $12, $c1, $29, $13, $85, $17
      .byte $1b, $92, $1a, $42, $47, $13, $83, $41, $a7, $13
      .byte $0e, $91, $a7, $63, $b7, $63, $c5, $65, $d5, $65
      .byte $dd, $4a, $e3, $67, $f3, $67, $8d, $c1, $ae, $42
      .byte $df, $20
      .byte $fd

;level 2-3/7-3
L_GroundArea8:
      .byte $90, $11
      .byte $0f, $26, $6e, $10, $8b, $17, $af, $32, $d8, $62
      .byte $e8, $62, $fc, $3f, $ad, $c8, $f8, $64, $0c, $be
      .byte $43, $43, $f8, $64, $0c, $bf, $73, $40, $84, $40
      .byte $93, $40, $a4, $40, $b3, $40, $f8, $64, $48, $e4
      .byte $5c, $39, $83, $40, $92, $41, $b3, $40, $f8, $64
      .byte $48, $e4, $5c, $39, $f8, $64, $13, $c2, $37, $65
      .byte $4c, $24, $63, $00, $97, $65, $c3, $42, $0b, $97
      .byte $ac, $32, $f8, $64, $0c, $be, $53, $45, $9d, $48
      .byte $f8, $64, $2a, $e2, $3c, $47, $56, $43, $ba, $62
      .byte $f8, $64, $0c, $b7, $88, $64, $bc, $31, $d4, $45
      .byte $fc, $31, $3c, $b1, $78, $64, $8c, $38, $0b, $9c
      .byte $1a, $33, $18, $61, $28, $61, $39, $60, $5d, $4a
      .byte $ee, $11, $0f, $b8, $1d, $c1, $3e, $42, $6f, $20
      .byte $fd

;level 2-1
L_GroundArea9:
      .byte $52, $31
      .byte $0f, $20, $6e, $40, $f7, $20, $07, $84, $17, $20
      .byte $4f, $34, $c3, $03, $c7, $02, $d3, $22, $27, $e3
      .byte $39, $61, $e7, $73, $5c, $e4, $57, $00, $6c, $73
      .byte $47, $a0, $53, $06, $63, $22, $a7, $73, $fc, $73
      .byte $13, $a1, $33, $05, $43, $21, $5c, $72, $c3, $23
      .byte $cc, $03, $77, $fb, $ac, $02, $39, $f1, $a7, $73
      .byte $d3, $04, $e8, $72, $e3, $22, $26, $f4, $bc, $02
      .byte $8c, $81, $a8, $62, $17, $87, $43, $24, $a7, $01
      .byte $c3, $04, $08, $f2, $97, $21, $a3, $02, $c9, $0b
      .byte $e1, $69, $f1, $69, $8d, $c1, $cf, $26
      .byte $fd

;pipe intro area
L_GroundArea10:
      .byte $38, $11
      .byte $0f, $26, $ad, $40, $3d, $c7
      .byte $fd

;level 5-1
L_GroundArea11:
      .byte $95, $b1
      .byte $0f, $26, $0d, $02, $c8, $72, $1c, $81, $38, $72
      .byte $0d, $05, $97, $34, $98, $62, $a3, $20, $b3, $06
      .byte $c3, $20, $cc, $03, $f9, $91, $2c, $81, $48, $62
      .byte $0d, $09, $37, $63, $47, $03, $57, $21, $8c, $02
      .byte $c5, $79, $c7, $31, $f9, $11, $39, $f1, $a9, $11
      .byte $6f, $b4, $d3, $65, $e3, $65, $7d, $c1, $bf, $26
      .byte $fd

;cloud level used in levels 2-1 and 5-2
L_GroundArea12:
      .byte $00, $c1
      .byte $4c, $00, $f4, $4f, $0d, $02, $02, $42, $43, $4f
      .byte $52, $c2, $de, $00, $5a, $c2, $4d, $c7
      .byte $fd

;level 4-3
L_GroundArea13:
      .byte $90, $51
      .byte $0f, $26, $ee, $10, $0b, $94, $33, $14, $42, $42
      .byte $77, $16, $86, $44, $02, $92, $4a, $16, $69, $42
      .byte $73, $14, $b0, $00, $c7, $12, $05, $c0, $1c, $17
      .byte $1f, $11, $36, $12, $8f, $14, $91, $40, $1b, $94
      .byte $35, $12, $34, $42, $60, $42, $61, $12, $87, $12
      .byte $96, $40, $a3, $14, $1c, $98, $1f, $11, $47, $12
      .byte $9f, $15, $cc, $15, $cf, $11, $05, $c0, $1f, $15
      .byte $39, $12, $7c, $16, $7f, $11, $82, $40, $98, $12
      .byte $df, $15, $16, $c4, $17, $14, $54, $12, $9b, $16
      .byte $28, $94, $ce, $01, $3d, $c1, $5e, $42, $8f, $20
      .byte $fd

;level 6-3
L_GroundArea14:
      .byte $97, $11
      .byte $0f, $26, $fe, $10, $2b, $92, $57, $12, $8b, $12
      .byte $c0, $41, $f7, $13, $5b, $92, $69, $0b, $bb, $12
      .byte $b2, $46, $19, $93, $71, $00, $17, $94, $7c, $14
      .byte $7f, $11, $93, $41, $bf, $15, $fc, $13, $ff, $11
      .byte $2f, $95, $50, $42, $51, $12, $58, $14, $a6, $12
      .byte $db, $12, $1b, $93, $46, $43, $7b, $12, $8d, $49
      .byte $b7, $14, $1b, $94, $49, $0b, $bb, $12, $fc, $13
      .byte $ff, $12, $03, $c1, $2f, $15, $43, $12, $4b, $13
      .byte $77, $13, $9d, $4a, $15, $c1, $a1, $41, $c3, $12
      .byte $fe, $01, $7d, $c1, $9e, $42, $cf, $20
      .byte $fd

;level 6-1
L_GroundArea15:
      .byte $52, $21
      .byte $0f, $20, $6e, $44, $0c, $f1, $4c, $01, $aa, $35
      .byte $d9, $34, $ee, $20, $08, $b3, $37, $32, $43, $04
      .byte $4e, $21, $53, $20, $7c, $01, $97, $21, $b7, $07
      .byte $9c, $81, $e7, $42, $5f, $b3, $97, $63, $ac, $02
      .byte $c5, $41, $49, $e0, $58, $61, $76, $64, $85, $65
      .byte $94, $66, $a4, $22, $a6, $03, $c8, $22, $dc, $02
      .byte $68, $f2, $96, $42, $13, $82, $17, $02, $af, $34
      .byte $f6, $21, $fc, $06, $26, $80, $2a, $24, $36, $01
      .byte $8c, $00, $ff, $35, $4e, $a0, $55, $21, $77, $20
      .byte $87, $07, $89, $22, $ae, $21, $4c, $82, $9f, $34
      .byte $ec, $01, $03, $e7, $13, $67, $8d, $4a, $ad, $41
      .byte $0f, $a6
      .byte $fd

;warp zone area used in level 4-2
L_GroundArea16:
      .byte $10, $51
      .byte $4c, $00, $c7, $12, $c6, $42, $03, $92, $02, $42
      .byte $29, $12, $63, $12, $62, $42, $69, $14, $a5, $12
      .byte $a4, $42, $e2, $14, $e1, $44, $f8, $16, $37, $c1
      .byte $8f, $38, $02, $bb, $28, $7a, $68, $7a, $a8, $7a
      .byte $e0, $6a, $f0, $6a, $6d, $c5
      .byte $fd

;level 8-1
L_GroundArea17:
      .byte $92, $31
      .byte $0f, $20, $6e, $40, $0d, $02, $37, $73, $ec, $00
      .byte $0c, $80, $3c, $00, $6c, $00, $9c, $00, $06, $c0
      .byte $c7, $73, $06, $83, $28, $72, $96, $40, $e7, $73
      .byte $26, $c0, $87, $7b, $d2, $41, $39, $f1, $c8, $f2
      .byte $97, $e3, $a3, $23, $e7, $02, $e3, $07, $f3, $22
      .byte $37, $e3, $9c, $00, $bc, $00, $ec, $00, $0c, $80
      .byte $3c, $00, $86, $21, $a6, $06, $b6, $24, $5c, $80
      .byte $7c, $00, $9c, $00, $29, $e1, $dc, $05, $f6, $41
      .byte $dc, $80, $e8, $72, $0c, $81, $27, $73, $4c, $01
      .byte $66, $74, $0d, $11, $3f, $35, $b6, $41, $2c, $82
      .byte $36, $40, $7c, $02, $86, $40, $f9, $61, $39, $e1
      .byte $ac, $04, $c6, $41, $0c, $83, $16, $41, $88, $f2
      .byte $39, $f1, $7c, $00, $89, $61, $9c, $00, $a7, $63
      .byte $bc, $00, $c5, $65, $dc, $00, $e3, $67, $f3, $67
      .byte $8d, $c1, $cf, $26
      .byte $fd

;level 5-2
L_GroundArea18:
      .byte $55, $b1
      .byte $0f, $26, $cf, $33, $07, $b2, $15, $11, $52, $42
      .byte $99, $0b, $ac, $02, $d3, $24, $d6, $42, $d7, $25
      .byte $23, $84, $cf, $33, $07, $e3, $19, $61, $78, $7a
      .byte $ef, $33, $2c, $81, $46, $64, $55, $65, $65, $65
      .byte $ec, $74, $47, $82, $53, $05, $63, $21, $62, $41
      .byte $96, $22, $9a, $41, $cc, $03, $b9, $91, $39, $f1
      .byte $63, $26, $67, $27, $d3, $06, $fc, $01, $18, $e2
      .byte $d9, $07, $e9, $04, $0c, $86, $37, $22, $93, $24
      .byte $87, $84, $ac, $02, $c2, $41, $c3, $23, $d9, $71
      .byte $fc, $01, $7f, $b1, $9c, $00, $a7, $63, $b6, $64
      .byte $cc, $00, $d4, $66, $e3, $67, $f3, $67, $8d, $c1
      .byte $cf, $26
      .byte $fd

;level 8-2
L_GroundArea19:
      .byte $50, $b1
      .byte $0f, $26, $fc, $00, $1f, $b3, $5c, $00, $65, $65
      .byte $74, $66, $83, $67, $93, $67, $dc, $73, $4c, $80
      .byte $b3, $20, $c9, $0b, $c3, $08, $d3, $2f, $dc, $00
      .byte $2c, $80, $4c, $00, $8c, $00, $d3, $2e, $ed, $4a
      .byte $fc, $00, $d7, $a1, $ec, $01, $4c, $80, $59, $11
      .byte $d8, $11, $da, $10, $37, $a0, $47, $04, $99, $11
      .byte $e7, $21, $3a, $90, $67, $20, $76, $10, $77, $60
      .byte $87, $07, $d8, $12, $39, $f1, $ac, $00, $e9, $71
      .byte $0c, $80, $2c, $00, $4c, $05, $c7, $7b, $39, $f1
      .byte $ec, $00, $f9, $11, $0c, $82, $6f, $34, $f8, $11
      .byte $fa, $10, $7f, $b2, $ac, $00, $b6, $64, $cc, $01
      .byte $e3, $67, $f3, $67, $8d, $c1, $cf, $26
      .byte $fd

;level 7-1
L_GroundArea20:
      .byte $52, $b1
      .byte $0f, $20, $6e, $45, $39, $91, $b3, $04, $c3, $21
      .byte $c8, $11, $ca, $10, $49, $91, $7c, $73, $e8, $12
      .byte $88, $91, $8a, $10, $e7, $21, $05, $91, $07, $30
      .byte $17, $07, $27, $20, $49, $11, $9c, $01, $c8, $72
      .byte $23, $a6, $27, $26, $d3, $03, $d8, $7a, $89, $91
      .byte $d8, $72, $39, $f1, $a9, $11, $09, $f1, $63, $24
      .byte $67, $24, $d8, $62, $28, $91, $2a, $10, $56, $21
      .byte $70, $04, $79, $0b, $8c, $00, $94, $21, $9f, $35
      .byte $2f, $b8, $3d, $c1, $7f, $26
      .byte $fd

;cloud level used in levels 3-1 and 6-2
L_GroundArea21:
      .byte $06, $c1
      .byte $4c, $00, $f4, $4f, $0d, $02, $06, $20, $24, $4f
      .byte $35, $a0, $36, $20, $53, $46, $d5, $20, $d6, $20
      .byte $34, $a1, $73, $49, $74, $20, $94, $20, $b4, $20
      .byte $d4, $20, $f4, $20, $2e, $80, $59, $42, $4d, $c7
      .byte $fd

;level 3-2
L_GroundArea22:
      .byte $96, $31
      .byte $0f, $26, $0d, $03, $1a, $60, $77, $42, $c4, $00
      .byte $c8, $62, $b9, $e1, $d3, $06, $d7, $07, $f9, $61
      .byte $0c, $81, $4e, $b1, $8e, $b1, $bc, $01, $e4, $50
      .byte $e9, $61, $0c, $81, $0d, $0a, $84, $43, $98, $72
      .byte $0d, $0c, $0f, $38, $1d, $c1, $5f, $26
      .byte $fd

;level 1-2
L_UndergroundArea1:
      .byte $48, $0f
      .byte $0e, $01, $5e, $02, $a7, $00, $bc, $73, $1a, $e0
      .byte $39, $61, $58, $62, $77, $63, $97, $63, $b8, $62
      .byte $d6, $07, $f8, $62, $19, $e1, $75, $52, $86, $40
      .byte $87, $50, $95, $52, $93, $43, $a5, $21, $c5, $52
      .byte $d6, $40, $d7, $20, $e5, $06, $e6, $51, $3e, $8d
      .byte $5e, $03, $67, $52, $77, $52, $7e, $02, $9e, $03
      .byte $a6, $43, $a7, $23, $de, $05, $fe, $02, $1e, $83
      .byte $33, $54, $46, $40, $47, $21, $56, $04, $5e, $02
      .byte $83, $54, $93, $52, $96, $07, $97, $50, $be, $03
      .byte $c7, $23, $fe, $02, $0c, $82, $43, $45, $45, $24
      .byte $46, $24, $90, $08, $95, $51, $78, $fa, $d7, $73
      .byte $39, $f1, $8c, $01, $a8, $52, $b8, $52, $cc, $01
      .byte $5f, $b3, $97, $63, $9e, $00, $0e, $81, $16, $24
      .byte $66, $04, $8e, $00, $fe, $01, $08, $d2, $0e, $06
      .byte $6f, $47, $9e, $0f, $0e, $82, $2d, $47, $28, $7a
      .byte $68, $7a, $a8, $7a, $ae, $01, $de, $0f, $6d, $c5
      .byte $fd

;level 4-2
L_UndergroundArea2:
      .byte $48, $0f
      .byte $0e, $01, $5e, $02, $bc, $01, $fc, $01, $2c, $82
      .byte $41, $52, $4e, $04, $67, $25, $68, $24, $69, $24
      .byte $ba, $42, $c7, $04, $de, $0b, $b2, $87, $fe, $02
      .byte $2c, $e1, $2c, $71, $67, $01, $77, $00, $87, $01
      .byte $8e, $00, $ee, $01, $f6, $02, $03, $85, $05, $02
      .byte $13, $21, $16, $02, $27, $02, $2e, $02, $88, $72
      .byte $c7, $20, $d7, $07, $e4, $76, $07, $a0, $17, $06
      .byte $48, $7a, $76, $20, $98, $72, $79, $e1, $88, $62
      .byte $9c, $01, $b7, $73, $dc, $01, $f8, $62, $fe, $01
      .byte $08, $e2, $0e, $00, $6e, $02, $73, $20, $77, $23
      .byte $83, $04, $93, $20, $ae, $00, $fe, $0a, $0e, $82
      .byte $39, $71, $a8, $72, $e7, $73, $0c, $81, $8f, $32
      .byte $ae, $00, $fe, $04, $04, $d1, $17, $04, $26, $49
      .byte $27, $29, $df, $33, $fe, $02, $44, $f6, $7c, $01
      .byte $8e, $06, $bf, $47, $ee, $0f, $4d, $c7, $0e, $82
      .byte $68, $7a, $ae, $01, $de, $0f, $6d, $c5
      .byte $fd

;underground bonus rooms area used in many levels
L_UndergroundArea3:
      .byte $48, $01
      .byte $0e, $01, $00, $5a, $3e, $06, $45, $46, $47, $46
      .byte $53, $44, $ae, $01, $df, $4a, $4d, $c7, $0e, $81
      .byte $00, $5a, $2e, $04, $37, $28, $3a, $48, $46, $47
      .byte $c7, $07, $ce, $0f, $df, $4a, $4d, $c7, $0e, $81
      .byte $00, $5a, $33, $53, $43, $51, $46, $40, $47, $50
      .byte $53, $04, $55, $40, $56, $50, $62, $43, $64, $40
      .byte $65, $50, $71, $41, $73, $51, $83, $51, $94, $40
      .byte $95, $50, $a3, $50, $a5, $40, $a6, $50, $b3, $51
      .byte $b6, $40, $b7, $50, $c3, $53, $df, $4a, $4d, $c7
      .byte $0e, $81, $00, $5a, $2e, $02, $36, $47, $37, $52
      .byte $3a, $49, $47, $25, $a7, $52, $d7, $04, $df, $4a
      .byte $4d, $c7, $0e, $81, $00, $5a, $3e, $02, $44, $51
      .byte $53, $44, $54, $44, $55, $24, $a1, $54, $ae, $01
      .byte $b4, $21, $df, $4a, $e5, $07, $4d, $c7
      .byte $fd

;water area used in levels 5-2 and 6-2
L_WaterArea1:
      .byte $41, $01
      .byte $b4, $34, $c8, $52, $f2, $51, $47, $d3, $6c, $03
      .byte $65, $49, $9e, $07, $be, $01, $cc, $03, $fe, $07
      .byte $0d, $c9, $1e, $01, $6c, $01, $62, $35, $63, $53
      .byte $8a, $41, $ac, $01, $b3, $53, $e9, $51, $26, $c3
      .byte $27, $33, $63, $43, $64, $33, $ba, $60, $c9, $61
      .byte $ce, $0b, $e5, $09, $ee, $0f, $7d, $ca, $7d, $47
      .byte $fd

;level 2-2/7-2
L_WaterArea2:
      .byte $41, $01
      .byte $b8, $52, $ea, $41, $27, $b2, $b3, $42, $16, $d4
      .byte $4a, $42, $a5, $51, $a7, $31, $27, $d3, $08, $e2
      .byte $16, $64, $2c, $04, $38, $42, $76, $64, $88, $62
      .byte $de, $07, $fe, $01, $0d, $c9, $23, $32, $31, $51
      .byte $98, $52, $0d, $c9, $59, $42, $63, $53, $67, $31
      .byte $14, $c2, $36, $31, $87, $53, $17, $e3, $29, $61
      .byte $30, $62, $3c, $08, $42, $37, $59, $40, $6a, $42
      .byte $99, $40, $c9, $61, $d7, $63, $39, $d1, $58, $52
      .byte $c3, $67, $d3, $31, $dc, $06, $f7, $42, $fa, $42
      .byte $23, $b1, $43, $67, $c3, $34, $c7, $34, $d1, $51
      .byte $43, $b3, $47, $33, $9a, $30, $a9, $61, $b8, $62
      .byte $be, $0b, $d5, $09, $de, $0f, $0d, $ca, $7d, $47
      .byte $fd

;water area used in level 8-4
L_WaterArea3:
      .byte $49, $0f
      .byte $1e, $01, $39, $73, $5e, $07, $ae, $0b, $1e, $82
      .byte $6e, $88, $9e, $02, $0d, $04, $2e, $0b, $45, $09
      .byte $4e, $0f, $ed, $47
      .byte $fd

;-------------------------------------------------------------------------------------
; Individual metatile data

;--------------------------------
;$06 - used by MushroomLedge to store length

AreaStyleObject:
      lda AreaStyle        ;load level object style and jump to the right sub
      jsr JumpEngine 
      .word TreeLedge        ;also used for cloud type levels
      .word MushroomLedge
      .word BulletBillCannon

TreeLedge:
          jsr GetLrgObjAttrib     ;get row and length of green ledge
          lda AreaObjectLength,x  ;check length counter for expiration
          beq EndTreeL   
          bpl MidTreeL
          tya
          sta AreaObjectLength,x  ;store lower nybble into buffer flag as length of ledge
          lda CurrentPageLoc
          ora CurrentColumnPos    ;are we at the start of the level?
          beq MidTreeL
          lda #MT_TREE_LEDGE_LEFT_EDGE ;render start of tree ledge
          jmp NoUnder
MidTreeL: ldx R7 
          lda #MT_TREE_LEDGE_MIDDLE ;render middle of tree ledge
          sta MetatileBuffer,x    ;note that this is also used if ledge position is
          lda #MT_GREEN_LEDGE_STUMP ;at the start of level for continuous effect
          jmp AllUnder            ;now render the part underneath
EndTreeL: lda #MT_TREE_LEDGE_RIGHT_EDGE ;render end of tree ledge
          jmp NoUnder

MushroomLedge:
          jsr ChkLrgObjLength        ;get shroom dimensions
          sty R6                     ;store length here for now
          bcc EndMushL
          lda AreaObjectLength,x     ;divide length by 2 and store elsewhere
          lsr
          sta MushroomLedgeHalfLen,x
          lda #MT_MUSHROOM_LEFT_EDGE      ;render start of mushroom
          jmp NoUnder
EndMushL: lda #MT_MUSHROOM_RIGHT_EDGE     ;if at the end, render end of mushroom
          ldy AreaObjectLength,x
          beq NoUnder
          lda MushroomLedgeHalfLen,x ;get divided length and store where length
          sta R6                     ;was stored originally
          ldx R7 
          lda #MT_MUSHROOM_MIDDLE
          sta MetatileBuffer,x       ;render middle of mushroom
          cpy R6                     ;are we smack dab in the center?
          bne CannonExit              ;if not, branch to leave
          inx
          lda #MT_MUSHROOM_STUMP_TOP
          sta MetatileBuffer,x       ;render stem top of mushroom underneath the middle
          lda #MT_MUSHROOM_STUMP_BOTTOM
AllUnder: inx
          ldy #$0f                   ;set $0f to render all way down
          jmp RenderUnderPart        ;now render the stem of mushroom
NoUnder:  ldx R7                     ;load row of ledge
          ldy #$00                   ;set 0 for no bottom on this part
          jmp RenderUnderPart

;--------------------------------

BulletBillCannon:
             jsr GetLrgObjAttrib      ;get row and length of bullet bill cannon
             ldx R7                   ;start at first row
             lda #MT_BULLET_BILL_CANNON_BARREL ;render bullet bill cannon
             sta MetatileBuffer,x
             inx
             dey                      ;done yet?
             bmi SetupCannon
             lda #MT_BULLET_BILL_CANNON_TOP     ;if not, render middle part
             sta MetatileBuffer,x
             inx
             dey                      ;done yet?
             bmi SetupCannon
             lda #MT_BULLET_BILL_CANNON_BOTTOM     ;if not, render bottom until length expires
             jsr RenderUnderPart
SetupCannon: ldx Cannon_Offset        ;get offset for data used by cannons and whirlpools
             jsr GetAreaObjYPosition  ;get proper vertical coordinate for cannon
             sta Cannon_Y_Position,x  ;and store it here
             lda CurrentPageLoc
             sta Cannon_PageLoc,x     ;store page number for cannon here
             jsr GetAreaObjXPosition  ;get proper horizontal coordinate for cannon
             sta Cannon_X_Position,x  ;and store it here
             inx
             cpx #$06                 ;increment and check offset
             bcc StrCOffset           ;if not yet reached sixth cannon, branch to save offset
             ldx #$00                 ;otherwise initialize it
StrCOffset:  stx Cannon_Offset        ;save new offset and leave
CannonExit:
             rts

;--------------------------------

SolidBlockMetatiles:
;water
      .byte MT_SOLID_BLOCK_WATER_LEVEL_GREEN_ROCK
;ground
      .byte MT_SOLID_BLOCK_3D_BLOCK
;underground
      .byte MT_SOLID_BLOCK_3D_BLOCK
;castle
      .byte MT_SOLID_BLOCK_WHITE_WALL

BrickMetatiles:
;water
      .byte MT_SEAPLANT
;ground
      .byte MT_BREAKABLE_BRICK_WITH_LINE
;underground
      .byte MT_BREAKABLE_BRICK
;castle
      .byte MT_BREAKABLE_BRICK

BrickMetatileForRow = * - BrickMetatiles
      .byte MT_CLOUD_LEVEL_TERRAIN

RowOfBricks:
            ldy AreaType           ;load area type obtained from area offset pointer
            lda CloudTypeOverride  ;check for cloud type override
            beq DrawBricks
            ldy #BrickMetatileForRow ;if cloud type, override area type
DrawBricks: lda BrickMetatiles,y   ;get appropriate metatile
            jmp GetRow             ;and go render it

RowOfSolidBlocks:
         ldy AreaType               ;load area type obtained from area offset pointer
         lda SolidBlockMetatiles,y  ;get metatile
GetRow:  pha                        ;store metatile here
         jsr ChkLrgObjLength        ;get row number, load length
DrawRow: ldx R7 
         ldy #$00                   ;set vertical height of 1
         pla
         jmp RenderUnderPart        ;render object

ColumnOfBricks:
      ldy AreaType          ;load area type obtained from area offset
      lda BrickMetatiles,y  ;get metatile (no cloud override as for row)
      jmp GetRow2

ColumnOfSolidBlocks:
         ldy AreaType               ;load area type obtained from area offset
         lda SolidBlockMetatiles,y  ;get metatile
GetRow2: pha                        ;save metatile to stack for now
         jsr GetLrgObjAttrib        ;get length and row
         pla                        ;restore metatile
         ldx R7                     ;get starting row
         jmp RenderUnderPart        ;now render the column

;--------------------------------
;$07 - used to save ID of brick object

Hidden1UpBlock:
      lda Hidden1UpFlag  ;if flag not set, do not render object
      beq ExitDecBlock
      lda #$00           ;if set, init for the next one
      sta Hidden1UpFlag
      jmp BrickWithItem  ;jump to code shared with unbreakable bricks

QuestionBlock:
      jsr GetAreaObjectID ;get value from level decoder routine
      jmp DrawQBlk        ;go to render it

BrickWithCoins:
      lda #$00                 ;initialize multi-coin timer flag
      sta BrickCoinTimerFlag

BrickWithItem:
          jsr GetAreaObjectID         ;save area object ID
          sty R7               
          lda #$00                    ;load default adder for bricks with lines
          ldy AreaType                ;check level type for ground level
          dey
          beq BWithL                  ;if ground type, do not start with 5
          lda #NumOfUniqBricks        ;otherwise use adder for bricks without lines
BWithL:   clc                         ;add object ID to adder
          adc R7 
          tay                         ;use as offset for metatile
DrawQBlk: lda BrickQBlockMetatiles,y  ;get appropriate metatile for brick (question block
          pha                         ;if branched to here from question block routine)
          jsr GetLrgObjAttrib         ;get row from location byte
          jmp DrawRow                 ;now render the object

GetAreaObjectID:
  ldy R0 
ExitDecBlock:
  rts

Bridge_High:
      lda #$06  ;start on the seventh row from top of screen
      .byte $2c   ;BIT instruction opcode

Bridge_Middle:
      lda #$07  ;start on the eighth row
      .byte $2c   ;BIT instruction opcode

Bridge_Low:
      lda #$09             ;start on the tenth row
      pha                  ;save whatever row to the stack for now
      jsr ChkLrgObjLength  ;get low nybble and save as length
      pla
      tax                  ;render bridge railing
      lda #MT_BRIDGE_GUARDRAIL
      sta MetatileBuffer,x
      inx
      ldy #$00             ;now render the bridge itself
      lda #MT_BRIDGE
      jmp RenderUnderPart

;--------------------------------
;$06 - used to store upper limit of rows for CastleObject

;these metatiles are in horizontally reversed order (top to bottom, right to left)
CastleMetatiles:
.byte MT_BLANK,                 MT_CASTLE_TOP,            MT_CASTLE_TOP,            MT_CASTLE_TOP,            MT_BLANK                  ; www
.byte MT_BLANK,                 MT_CASTLE_WINDOW_RIGHT,   MT_CASTLE_BRICK_WALL,     MT_CASTLE_WINDOW_LEFT,    MT_BLANK                  ; [#]
.byte MT_CASTLE_TOP,            MT_CASTLE_TOP_WITH_BRICK, MT_CASTLE_TOP_WITH_BRICK, MT_CASTLE_TOP_WITH_BRICK, MT_CASTLE_TOP             ;wWWWw
.byte MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_TOP,          MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL      ;##^##
.byte MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_BOTTOM,       MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL      ;##U##
.byte MT_CASTLE_TOP_WITH_BRICK, MT_CASTLE_TOP_WITH_BRICK, MT_CASTLE_TOP_WITH_BRICK, MT_CASTLE_TOP_WITH_BRICK, MT_CASTLE_TOP_WITH_BRICK  ;WWWWW
.byte MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_TOP,          MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_TOP,          MT_CASTLE_BRICK_WALL      ;#^#^#
.byte MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_BOTTOM,       MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_BOTTOM,       MT_CASTLE_BRICK_WALL      ;#U#U#
.byte MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL,     MT_CASTLE_BRICK_WALL      ;#####
.byte MT_ENTRANCE_TOP,          MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_TOP,          MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_TOP           ;^#^#^
.byte MT_ENTRANCE_BOTTOM,       MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_BOTTOM,       MT_CASTLE_BRICK_WALL,     MT_ENTRANCE_BOTTOM        ;U#U#U

;mtile that is placed at the door (so that mario stops moving after clearing the level)
ReplacedCastleMTile = MT_BREAKABLE_BRICK

CastleObject:
            jsr GetLrgObjAttrib      ;save lower nybble as starting row
            sty R7                   ;if starting row is above $0a, game will crash!!!
            ldy #$04
            jsr ChkLrgObjFixedLength ;load length of castle if not already loaded
            txa                  
            pha                      ;save obj buffer offset to stack
            ldy AreaObjectLength,x   ;use current length as offset for castle data
            ldx R7                   ;begin at starting row
            lda #$0b
            sta R6                   ;load upper limit of number of rows to print
CRendLoop:  lda CastleMetatiles,y    ;load current byte using offset
            sta MetatileBuffer,x
            inx                      ;store in buffer and increment buffer offset
            lda R6 
            beq ChkCFloor            ;have we reached upper limit yet?
            iny                      ;if not, increment column-wise
            iny                      ;to byte in next row
            iny
            iny
            iny
            dec R6                   ;move closer to upper limit
ChkCFloor:  cpx #$0b                 ;have we reached the row just before floor?
            bne CRendLoop            ;if not, go back and do another row
            pla
            tax                      ;get obj buffer offset from before
            lda CurrentPageLoc
            beq ExitCastle           ;if we're at page 0, we do not need to do anything else
            lda AreaObjectLength,x   ;check length
            cmp #$01                 ;if length almost about to expire, put brick at floor
            beq PlayerStop
            ldy R7                   ;check starting row for tall castle ($00)
            bne NotTall
            cmp #$03                 ;if found, then check to see if we're at the second column
            beq PlayerStop
NotTall:    cmp #$02                 ;if not tall castle, check to see if we're at the third column
            bne ExitCastle           ;if we aren't and the castle is tall, don't create flag yet
            jsr GetAreaObjXPosition  ;otherwise, obtain and save horizontal pixel coordinate
            pha
            jsr FindEmptyEnemySlot   ;find an empty place on the enemy object buffer
            pla
            sta Enemy_X_Position,x   ;then write horizontal coordinate for star flag
            lda CurrentPageLoc
            sta Enemy_PageLoc,x      ;set page location for star flag
            lda #$01
            sta Enemy_Y_HighPos,x    ;set vertical high byte
            sta Enemy_Flag,x         ;set flag for buffer
            lda #$90
            sta Enemy_Y_Position,x   ;set vertical coordinate
            lda #StarFlagObject      ;set star flag value in buffer itself
            sta Enemy_ID,x
            rts
PlayerStop: ldy #ReplacedCastleMTile ;put brick at floor to stop player at end of level
            sty MetatileBuffer+10    ;this is only done if we're on the second column
ExitCastle: rts

;--------------------------------

C_ObjectRow:
      .byte $06, $07, $08

C_ObjectMetatile:
      .byte MT_AXE, MT_CHAIN, MT_BOWSERS_BRIDGE

CastleBridgeObj:
      ldy #$0c                  ;load length of 13 columns
      jsr ChkLrgObjFixedLength
      jmp ChainObj

AxeObj:
      lda #$08                  ;load bowser's palette into sprite portion of palette
      sta VRAM_Buffer_AddrCtrl

ChainObj:
      ldy R0                    ;get value loaded earlier from decoder
      ldx C_ObjectRow-2,y       ;get appropriate row and metatile for object
      lda C_ObjectMetatile-2,y
      jmp ColObj

EmptyBlock:
        jsr GetLrgObjAttrib  ;get row location
        ldx R7 
        lda #MT_EMPTY_BLOCK
ColObj: ldy #$00             ;column length of 1
        jmp RenderUnderPart

;--------------------------------

CoinMetatileData:
;water
      .byte MT_UNDERWATER_COIN
;ground
      .byte MT_COIN
;underground
      .byte MT_COIN
;castle
      .byte MT_COIN

RowOfCoins:
      ldy AreaType            ;get area type
      lda CoinMetatileData,y  ;load appropriate coin metatile
      jmp GetRow

;--------------------------------

FlagpoleObject:
  lda #MT_FLAGPOLE_BALL                 ;render flagpole ball on top
  sta MetatileBuffer
  ldx #$01                 ;now render the flagpole shaft
  ldy #$08
  lda #MT_FLAGPOLE_SHAFT
  jsr RenderUnderPart
  lda #MT_SOLID_BLOCK_3D_BLOCK      ;render solid block at the bottom
  sta MetatileBuffer+10
  jsr GetAreaObjXPosition
  sec                      ;get pixel coordinate of where the flagpole is,
  sbc #$08                 ;subtract eight pixels and use as horizontal
  sta Enemy_X_Position+5   ;coordinate for the flag
  lda CurrentPageLoc
  sbc #$00                 ;subtract borrow from page location and use as
  sta Enemy_PageLoc+5      ;page location for the flag
  lda #$30
  sta Enemy_Y_Position+5   ;set vertical coordinate for flag
  lda #1
  sta Enemy_Y_HighPos+5
  lda #$b0 + 8 ; jroweboy offset the flag score by 8 px to account for 8x16 difference
  sta FlagpoleFNum_Y_Pos   ;set initial vertical coordinate for flagpole's floatey number
  lda #FlagpoleFlagObject
  sta Enemy_ID+5           ;set flag identifier, note that identifier and coordinates
  inc Enemy_Flag+5         ;use last space in enemy object buffer
  rts

;--------------------------------

Hole_Water:
      jsr ChkLrgObjLength   ;get low nybble and save as length
      lda #MT_WATER_OR_LAVA_TOP              ;render waves
      sta MetatileBuffer+10
      ldx #$0b
      ldy #$01              ;now render the water underneath
      lda #MT_WATER_OR_LAVA
      jmp RenderUnderPart

;--------------------------------

HoleMetatiles:
;water
      .byte MT_WATER_OR_LAVA
;ground
      .byte MT_BLANK
;underground
      .byte MT_BLANK
;castle
      .byte MT_BLANK

Hole_Empty:
            jsr ChkLrgObjLength          ;get lower nybble and save as length
            bcc NoWhirlP                 ;skip this part if length already loaded
            lda AreaType                 ;check for water type level
            bne NoWhirlP                 ;if not water type, skip this part
            ldx Whirlpool_Offset         ;get offset for data used by cannons and whirlpools
            jsr GetAreaObjXPosition      ;get proper vertical coordinate of where we're at
            sec
            sbc #$10                     ;subtract 16 pixels
            sta Whirlpool_LeftExtent,x   ;store as left extent of whirlpool
            lda CurrentPageLoc           ;get page location of where we're at
            sbc #$00                     ;subtract borrow
            sta Whirlpool_PageLoc,x      ;save as page location of whirlpool
            iny
            iny                          ;increment length by 2
            tya
            asl                          ;multiply by 16 to get size of whirlpool
            asl                          ;note that whirlpool will always be
            asl                          ;two blocks bigger than actual size of hole
            asl                          ;and extend one block beyond each edge
            sta Whirlpool_Length,x       ;save size of whirlpool here
            inx
            cpx #$05                     ;increment and check offset
            bcc StrWOffset               ;if not yet reached fifth whirlpool, branch to save offset
            ldx #$00                     ;otherwise initialize it
StrWOffset: stx Whirlpool_Offset         ;save new offset here
NoWhirlP:   ldx AreaType                 ;get appropriate metatile, then
            lda HoleMetatiles,x          ;render the hole proper
            ldx #$08
            ldy #$0f                     ;start at ninth row and go to bottom, run RenderUnderPart

;--------------------------------

RenderUnderPart:
             sty AreaObjectHeight  ;store vertical length to render
             ldy MetatileBuffer,x  ;check current spot to see if there's something
             beq DrawThisRow       ;we need to keep, if nothing, go ahead
             cpy #MT_TREE_LEDGE_MIDDLE
             beq WaitOneRow        ;if middle part (tree ledge), wait until next row
             cpy #MT_MUSHROOM_MIDDLE
             beq WaitOneRow        ;if middle part (mushroom ledge), wait until next row
             cpy #MT_QUESTION_BLOCK_COIN
             beq DrawThisRow       ;if question block w/ coin, overwrite
             
             ;TODO: this needs to be optimized in the future
             ;(originally the code checked for palette 3 metatiles here)
             cpy #MT_QUESTION_BLOCK_POWER_UP
             beq WaitOneRow
             cpy #MT_COIN
             beq WaitOneRow
             cpy #MT_UNDERWATER_COIN
             beq WaitOneRow
             cpy #MT_EMPTY_BLOCK
             beq WaitOneRow
             cpy #MT_AXE
             beq WaitOneRow

             cpy #MT_CRACKED_ROCK_TERRAIN
             bne DrawThisRow       ;if cracked rock terrain, overwrite
             cmp #MT_MUSHROOM_STUMP_BOTTOM
             beq WaitOneRow        ;if stem bottom of mushroom, wait until next row
DrawThisRow: sta MetatileBuffer,x  ;render contents of A from routine that called this
WaitOneRow:  inx
             cpx #$0d              ;stop rendering if we're at the bottom of the screen
             bcs ExitUPartR
             ldy AreaObjectHeight  ;decrement, and stop rendering if there is no more length
             dey
             bpl RenderUnderPart
ExitUPartR:  rts


;--------------------------------

Jumpspring:
      jsr GetLrgObjAttrib
      jsr FindEmptyEnemySlot      ;find empty space in enemy object buffer
      jsr GetAreaObjXPosition     ;get horizontal coordinate for jumpspring
      sta Enemy_X_Position,x      ;and store
      lda CurrentPageLoc          ;store page location of jumpspring
      sta Enemy_PageLoc,x
      jsr GetAreaObjYPosition     ;get vertical coordinate for jumpspring
      sta Enemy_Y_Position,x      ;and store
      sta Jumpspring_FixedYPos,x  ;store as permanent coordinate here
      lda #JumpspringObject
      sta Enemy_ID,x              ;write jumpspring object to enemy object buffer
      ldy #$01
      sty Enemy_Y_HighPos,x       ;store vertical high byte
      inc Enemy_Flag,x            ;set flag for enemy object buffer
      ldx R7 
      lda #MT_BLANK_USED_FOR_JUMPSPRING   ;draw metatiles in two rows where jumpspring is
      sta MetatileBuffer,x
      lda #MT_HALF_BRICK_USED_FOR_JUMPSPRING
      sta MetatileBuffer+1,x
      rts

;--------------------------------

WaterPipe:
      jsr GetLrgObjAttrib     ;get row and lower nybble
      ; ldy AreaObjectLength,x  ;get length (residual code, water pipe is 1 col thick)
      ldx R7                  ;get row
      lda #MT_WATER_PIPE_TOP
      sta MetatileBuffer,x    ;draw something here and below it
      lda #MT_WATER_PIPE_BOTTOM
      sta MetatileBuffer+1,x
      rts

;--------------------------------
;$05 - used to store length of vertical shaft in RenderSidewaysPipe
;$06 - used to store leftover horizontal length in RenderSidewaysPipe
; and vertical length in VerticalPipe and GetPipeHeight

IntroPipe:
               ldy #$03                 ;check if length set, if not set, set it
               jsr ChkLrgObjFixedLength
               ldy #$0a                 ;set fixed value and render the sideways part
               jsr RenderSidewaysPipe
               bcs NoBlankP             ;if carry flag set, not time to draw vertical pipe part
               ldx #$06                 ;blank everything above the vertical pipe part
VPipeSectLoop: lda #MT_BLANK            ;all the way to the top of the screen
               sta MetatileBuffer,x     ;because otherwise it will look like exit pipe
               dex
               bpl VPipeSectLoop
               lda VerticalPipeData,y   ;draw the end of the vertical pipe part
               sta MetatileBuffer+7
NoBlankP:      rts

SidePipeShaftData:
      .byte MT_PIPE_SHAFT_RIGHT, MT_PIPE_SHAFT_LEFT  ;used to control whether or not vertical pipe shaft
      .byte MT_BLANK, MT_BLANK  ;is drawn, and if so, controls the metatile number
SidePipeTopPart:
      .byte MT_PIPE_SHAFT_RIGHT, MT_SIDEWAYS_PIPE_JOINT_TOP  ;top part of sideways part of pipe
      .byte MT_SIDEWAYS_PIPE_SHAFT_TOP, MT_SIDEWAYS_PIPE_END_TOP
SidePipeBottomPart: 
      .byte MT_PIPE_SHAFT_RIGHT, MT_SIDEWAYS_PIPE_JOINT_BOTTOM  ;bottom part of sideways part of pipe
      .byte MT_SIDEWAYS_PIPE_SHAFT_BOTTOM, MT_SIDEWAYS_PIPE_END_BOTTOM

ExitPipe:
      ldy #$03                 ;check if length set, if not set, set it
      jsr ChkLrgObjFixedLength
      jsr GetLrgObjAttrib      ;get vertical length, then plow on through RenderSidewaysPipe

RenderSidewaysPipe:
              dey                       ;decrement twice to make room for shaft at bottom
              dey                       ;and store here for now as vertical length
              sty R5 
              ldy AreaObjectLength,x    ;get length left over and store here
              sty R6 
              ldx R5                    ;get vertical length plus one, use as buffer offset
              inx
              lda SidePipeShaftData,y   ;check for value $00 based on horizontal offset
              cmp #MT_BLANK
              beq DrawSidePart          ;if found, do not draw the vertical pipe shaft
              ldx #$00
              ldy R5                    ;init buffer offset and get vertical length
              jsr RenderUnderPart       ;and render vertical shaft using tile number in A
              clc                       ;clear carry flag to be used by IntroPipe
DrawSidePart: ldy R6                    ;render side pipe part at the bottom
              lda SidePipeTopPart,y
              sta MetatileBuffer,x      ;note that the pipe parts are stored
              lda SidePipeBottomPart,y  ;backwards horizontally
              sta MetatileBuffer+1,x
              rts

VerticalPipeData:
      .byte MT_WARP_PIPE_END_RIGHT_AND_POINTS_UP, MT_WARP_PIPE_END_LEFT_AND_POINTS_UP ;used by pipes that lead somewhere
      .byte MT_PIPE_SHAFT_RIGHT, MT_PIPE_SHAFT_LEFT
      .byte MT_DECORATION_PIPE_END_RIGHT_AND_POINTS_UP, MT_DECORATION_PIPE_END_LEFT_AND_POINTS_UP ;used by decoration pipes
      .byte MT_PIPE_SHAFT_RIGHT, MT_PIPE_SHAFT_LEFT

VerticalPipe:
          jsr GetPipeHeight
          lda R0                   ;check to see if value was nullified earlier
          beq WarpPipe             ;(if d3, the usage control bit of second byte, was set)
          iny
          iny
          iny
          iny                      ;add four if usage control bit was not set
WarpPipe: tya                      ;save value in stack
          pha
          lda AreaNumber
          ora WorldNumber          ;if at world 1-1, do not add piranha plant ever
          beq DrawPipe
          ldy AreaObjectLength,x   ;if on second column of pipe, branch
          beq DrawPipe             ;(because we only need to do this once)
          jsr FindEmptyEnemySlot   ;check for an empty moving data buffer space
          bcs DrawPipe             ;if not found, too many enemies, thus skip
          jsr GetAreaObjXPosition  ;get horizontal pixel coordinate
          clc
          adc #$08                 ;add eight to put the piranha plant in the center
          sta Enemy_X_Position,x   ;store as enemy's horizontal coordinate
          lda CurrentPageLoc       ;add carry to current page number
          adc #$00
          sta Enemy_PageLoc,x      ;store as enemy's page coordinate
          lda #$01
          sta Enemy_Y_HighPos,x
          sta Enemy_Flag,x         ;activate enemy flag
          jsr GetAreaObjYPosition  ;get piranha plant's vertical coordinate and store here
          sta Enemy_Y_Position,x
          lda #PiranhaPlant        ;write piranha plant's value into buffer
          sta Enemy_ID,x
          farcall InitPiranhaPlant
DrawPipe: pla                      ;get value saved earlier and use as Y
          tay
          ldx R7                   ;get buffer offset
          lda VerticalPipeData,y   ;draw the appropriate pipe with the Y we loaded earlier
          sta MetatileBuffer,x     ;render the top of the pipe
          inx
          lda VerticalPipeData+2,y ;render the rest of the pipe
          ldy R6                   ;subtract one from length and render the part underneath
          dey
          jmp RenderUnderPart
      
GetPipeHeight:
      ldy #$01       ;check for length loaded, if not, load
      jsr ChkLrgObjFixedLength ;pipe length of 2 (horizontal)
      jsr GetLrgObjAttrib
      tya            ;get saved lower nybble as height
      and #$07       ;save only the three lower bits as
      sta R6         ;vertical length, then load Y with
      ldy AreaObjectLength,x    ;length left over
      rts

FindEmptyEnemySlot:
              ldx #$00          ;start at first enemy slot
EmptyChkLoop: clc               ;clear carry flag by default
              lda Enemy_Flag,x  ;check enemy buffer for nonzero
              beq ExitEmptyChk  ;if zero, leave
              inx
              cpx #$05          ;if nonzero, check next value
              bne EmptyChkLoop
ExitEmptyChk: rts               ;if all values nonzero, carry flag is set

;--------------------------------

;tiles used by pulleys and rope object
PulleyRopeMetatiles:
      .byte MT_LEFT_PULLEY, MT_HORIZONTAL_ROPE, MT_RIGHT_PULLEY

PulleyRopeObject:
           jsr ChkLrgObjLength       ;get length of pulley/rope object
           ldy #$00                  ;initialize metatile offset
           bcs RenderPul             ;if starting, render left pulley
           iny
           lda AreaObjectLength,x    ;if not at the end, render rope
           bne RenderPul
           iny                       ;otherwise render right pulley
RenderPul: lda PulleyRopeMetatiles,y
           sta MetatileBuffer        ;render at the top of the screen
MushLExit: rts                       ;and leave


;--------------------------------

QuestionBlockRow_High:
      lda #$03    ;start on the fourth row
      .byte $2c     ;BIT instruction opcode

QuestionBlockRow_Low:
      lda #$07             ;start on the eighth row
      pha                  ;save whatever row to the stack for now
      jsr ChkLrgObjLength  ;get low nybble and save as length
      pla
      tax                  ;render question boxes with coins
      lda #MT_QUESTION_BLOCK_COIN
      sta MetatileBuffer,x
      rts

;--------------------------------

EndlessRope:
      ldx #$00       ;render rope from the top to the bottom of screen
      ldy #$0f
      jmp DrawRope

BalancePlatRope:
          txa                 ;save object buffer offset for now
          pha
          ldx #$01            ;blank out all from second row to the bottom
          ldy #$0f            ;with blank used for balance platform rope
          lda #MT_BLANK_USED_FOR_BALANCE_ROPE
          jsr RenderUnderPart
          pla                 ;get back object buffer offset
          tax
          jsr GetLrgObjAttrib ;get vertical length from lower nybble
          ldx #$01
DrawRope: lda #MT_VERTICAL_ROPE     ;render the actual rope
          jmp RenderUnderPart


;--------------------------------

StaircaseHeightData:
      .byte $07, $07, $06, $05, $04, $03, $02, $01, $00

StaircaseRowData:
      .byte $03, $03, $04, $05, $06, $07, $08, $09, $0a

StaircaseObject:
           jsr ChkLrgObjLength       ;check and load length
           bcc NextStair             ;if length already loaded, skip init part
           lda #$09                  ;start past the end for the bottom
           sta StaircaseControl      ;of the staircase
NextStair: dec StaircaseControl      ;move onto next step (or first if starting)
           ldy StaircaseControl
           ldx StaircaseRowData,y    ;get starting row and height to render
           lda StaircaseHeightData,y
           tay
           lda #MT_SOLID_BLOCK_3D_BLOCK                  ;now render solid block staircase
           jmp RenderUnderPart

