
.segment "OBJECT"

;-------------------------------------------------------------------------------------
;$00 - offset to vine Y coordinate adder
;$02 - offset to sprite data

.proc DrawVine
  sty R0                     ;save offset here
  lda Enemy_Rel_YPos         ;get relative vertical coordinate
  clc
  adc VineYPosAdder,y        ;add value using offset in Y to get value
  ldx Vine_ObjOffset,y        ;get offset to vine
  ReserveSpr 6
  sty R2                    ;store sprite data offset here
  ; jsr SixSpriteStacker       ;stack six sprites on top of each other vertically
  ; inlined 
  
.repeat 6, I
  sta Sprite_Data + (I*4),y ;store X or Y coordinate into OAM data
.if I <> 5
  clc
  adc #$08           ;add eight pixels
.endif
.endrepeat

  lda Enemy_Rel_XPos         ;get relative horizontal coordinate
  sta Sprite_X_Position,y    ;store in first, third and fifth sprites
  sta Sprite_X_Position+8,y
  sta Sprite_X_Position+16,y
  clc
  adc #$06                   ;add six pixels to second, fourth and sixth sprites
  sta Sprite_X_Position+4,y  ;to give characteristic staggered vine shape to
  sta Sprite_X_Position+12,y ;our vertical stack of sprites
  sta Sprite_X_Position+20,y
  lda #%00100001             ;set bg priority and palette attribute bits
  sta Sprite_Attributes,y    ;set in first, third and fifth sprites
  sta Sprite_Attributes+8,y
  sta Sprite_Attributes+16,y
  ora #%01000000             ;additionally, set horizontal flip bit
  sta Sprite_Attributes+4,y  ;for second, fourth and sixth sprites
  sta Sprite_Attributes+12,y
  sta Sprite_Attributes+20,y
  ldx #$05                   ;set tiles for six sprites
VineTL:
  lda #VINE_TILE_2           ;set tile number for sprite
  sta Sprite_Tilenumber,y
  iny                        ;move offset to next sprite data
  iny
  iny
  iny
  dex                        ;move onto next sprite
  bpl VineTL                 ;loop until all sprites are done
UpdateOAMPosition
  ldy R2                     ;get original offset
  lda R0                     ;get offset to vine adding data
  bne :+                ;if offset not zero, skip this part
    lda #VINE_TILE_1
    sta Sprite_Tilenumber,y    ;set other tile number for top of vine
  :
  ldx #$00                   ;start with the first sprite again
ChkFTop:
    lda Vine_Start_Y_Position   ;get original starting vertical coordinate
    sec
    sbc Sprite_Y_Position,y    ;subtract top-most sprite's Y coordinate
    cmp #$64                   ;if two coordinates are less than 100/$64 pixels
    bcc :+                ;apart, skip this to leave sprite alone
      lda #$f8
      sta Sprite_Y_Position,y    ;otherwise move sprite offscreen
  :
    iny                        ;move offset to next OAM data
    iny
    iny
    iny
    inx                        ;move onto next sprite
    cpx #$06                   ;do this until all sprites are checked
    bne ChkFTop
  ldy R0                     ;return offset set earlier
  rts

VineYPosAdder:
  .byte $00, $30

.endproc

.proc SprObjectOffscrChk
  ldx ObjectOffset          ;get enemy buffer offset
  lda Enemy_OffscreenBits   ;check offscreen information
  asl
  bcc Exit
    lda Enemy_ID,x
    cmp #Podoboo              ;check enemy identifier for podoboo
    beq Exit                  ;skip this part if found, we do not want to erase podoboo!
      lda Enemy_Y_HighPos,x     ;check high byte of vertical position
      cmp #$02                  ;if not yet past the bottom of the screen, branch
      bne Exit
        jmp EraseEnemyObject      ;what it says
Exit:
  rts
.endproc

.proc DrawHammer
  lda #0
  sta Misc_SprAttrib,x
  lda #1
  sta Enemy_MovingDir + (Misc_SprAttrib - Enemy_SprAttrib),x
  ldy #METASPRITE_HAMMER_FRAME_1
  lda TimerControl
  bne ForceHPose
    lda Misc_State,x            ;otherwise get hammer's state
    and #%01111111              ;mask out d7
    cmp #$01                    ;check to see if set to 1 yet
    beq GetHPose                ;if so, branch
ForceHPose:
    lda #0
    beq RenderH                 ;do unconditional branch to rendering part
GetHPose:
    lda FrameCounter            ;get frame counter
    lsr                         ;move d3-d2 to d1-d0
    lsr
    and #%00000011              ;mask out all but d1-d0 (changes every four frames)
RenderH:
  sta R2
  ; if bit 0 is set, then use the horizontal hammer sprite
  lsr
  bcc CheckForVerticalFlip
    ldy #METASPRITE_HAMMER_FRAME_2
CheckForVerticalFlip:
  lsr
  bcc WriteMetasprite
    ; if bit 1 is also set, then apply vertical flip too
    ; but if only bit 2 is set, apply the horizontal flag
    lda R2
    lsr
    bcs :+
      lda Misc_SprAttrib,x
      ora #OAM_FLIP_H
      sta Misc_SprAttrib,x
    :
    lda Misc_SprAttrib,x
    ora #OAM_FLIP_V
    sta Misc_SprAttrib,x

    ; and use the sprite that faces the other way
    lda #2
    sta Enemy_MovingDir + (Misc_State - Enemy_State),x
WriteMetasprite:
  tya
  sta MiscMetasprite,x
  rts
.endproc

;-------------------------------------------------------------------------------------

DrawLargePlatform:
  ldy AreaType
  cpy #$03                    ;check for castle-type level
  beq ShrinkPlatform
    ldy SecondaryHardMode       ;check for secondary hard mode flag set
    bne ShrinkPlatform          ;branch if its hardmode
      ldy #METASPRITE_PLATFORM_GIRDER_LARGE
      ldx CloudTypeOverride
      beq ProcessTiles      ;if cloud level override flag not set, use
        ldy #METASPRITE_PLATFORM_CLOUD_LARGE
        bne ProcessTiles
ShrinkPlatform:
  ldy #METASPRITE_PLATFORM_GIRDER_SMALL
  ldx CloudTypeOverride
  beq ProcessTiles      ;if cloud level override flag not set, use
    ldy #METASPRITE_PLATFORM_CLOUD_SMALL
ProcessTiles:
  ldx ObjectOffset            ;get enemy object buffer offset
  ; Alternate frames for the girder for sprite shuffling
  lda FrameCounter
  and #1
  sta R2
  tya
  clc
  adc R2
  sta EnemyMetasprite,x
  rts

;-------------------------------------------------------------------------------------

.proc JCoinGfxHandler
  lda Misc_State,x            ;get state of misc object
  cmp #$02                    ;if 2 or greater, 
  bcs DrawFloateyNumber_Coin  ;branch to draw floatey number
    lda FrameCounter            ;get frame counter
    lsr                         ;divide by 2 to alter every other frame
    and #%00000011              ;mask out d2-d1
    tay                         ;use as graphical offset
    lda JumpingCoinTiles,y      ;load tile number
    sta MiscMetasprite,x
    rts                         ;leave

DrawFloateyNumber_Coin:
  lda #0
  sta Misc_SprAttrib,x
  lda FrameCounter          ;get frame counter
  lsr                       ;divide by 2
  bcs @NotRsNum             ;branch if d0 not set to raise number every other frame
    dec Misc_Y_Position,x     ;otherwise, decrement vertical coordinate
@NotRsNum:
  lda #METASPRITE_NUMBER_200
  sta MiscMetasprite,x
  ; Force the number metasprite to always face the correct direction
  lda #1
  sta Enemy_MovingDir+12,x
  rts

JumpingCoinTiles:
  .byte METASPRITE_COIN_FRAME_1, METASPRITE_COIN_FRAME_2
  .byte METASPRITE_COIN_FRAME_3, METASPRITE_COIN_FRAME_4

.endproc
;-------------------------------------------------------------------------------------
;$00-$01 - used to hold tiles for drawing the power-up, $00 also used to hold power-up type
;$02 - used to hold bottom row Y position
;$03 - used to hold flip control (not used here)
;$04 - used to hold sprite attributes
;$05 - used to hold X position
;$07 - counter

.proc DrawPowerUp
  ldx ObjectOffset
  ldy PowerUpType,x            ;get power-up type
  beq SkipPaletteCycle       ; Don't cycle the palettes for mushroom and 1-up
  cpy #3
  beq SkipPaletteCycle
    lda FrameCounter           ;get frame counter
    lsr                        ;divide by 2 to change colors every two frames
    and #%00000011             ;mask out all but d1 and d0 (previously d2 and d1)
    sta R2
    lda Enemy_SprAttrib,x      ;add background priority bit if any set
    and #%11100000
    ora R2
    sta Enemy_SprAttrib,x
SkipPaletteCycle:
  lda PowerUpGfxTable,y
  sta EnemyMetasprite,x
Exit:
  jmp SprObjectOffscrChk

PowerUpGfxTable:
  .byte METASPRITE_POWERUP_MUSHROOM
  .byte METASPRITE_POWERUP_FIREFLOWER
  .byte METASPRITE_POWERUP_STAR
  .byte METASPRITE_POWERUP_1UP
.endproc

.proc EnemyGraphicsEngine
  jsr RunEngine
  jmp SprObjectOffscrChk

RunEngine:
  lda Enemy_ID,x
  jsr JumpEngine
  ;only objects $00-$14 use this table
  .word ProcessGreenKoopa
  .word ProcessDemotedKoopa
  .word ProcessBuzzyBeetle
  .word ProcessRedKoopa
  .word Noop
  .word ProcessHammerBro
  .word ProcessGoomba
  .word ProcessBlooper
  .word ProcessBulletBill
  .word Noop
  .word ProcessSwimmingCheepCheep
  .word ProcessSwimmingCheepCheep
  .word ProcessPodoboo
  .word ProcessPiranhaPlant
  .word ProcessJumpingParatrooper
  .word ProcessRedFlyingParatrooper
  .word ProcessGreenFlyingParatrooper
  .word ProcessLakitu
  .word ProcessSpiny
  .word Noop
  .word ProcessFlyingCheepCheep
.endproc

Noop:
  ; debug me! this shouldn't be hit!
  brk
  nop
  rts

.proc ProcessPiranhaPlant
  lda #%00100000              ;set background priority bit in sprite
  sta Enemy_SprAttrib,x       ;attributes to give illusion of being inside pipe
  lda TimerControl
  bne Exit                    ; Just use the previous metasprite and leave if we aren't moving
    lda PiranhaPlant_Y_Speed,x
    bmi DrawPiranha           ;if piranha plant moving upwards, branch
      lda EnemyFrameTimer,x
      bne Exit                ;if timer for movement expired, branch
DrawPiranha:
  ldy #METASPRITE_PIRANHA_MOUTH_OPEN
    lda FrameCounter
    and #%00001000        ;check for every eighth frame
    bne DrawSprite
      ldy #METASPRITE_PIRANHA_MOUTH_CLOSED
DrawSprite:
  tya
  sta EnemyMetasprite,x
Exit:
  rts
.endproc

.proc ProcessGoomba
  lda Enemy_State,x
  ldy #METASPRITE_GOOMBA_WALKING_1
  cmp #$02              ;check for defeated state
  bcc GmbaAnim          ;if not defeated, go ahead and animate
    ; check if the death is from being bumped. if its bumped then d5 is set
    cmp #4        ;check for enemy stomped
    bne :+
      ; goomba was squished so use that metasprite instead
      ldy #METASPRITE_GOOMBA_DEAD
      ; the sprite in CHR is upside down intentionally so let the flip happen anyway
    :
    lda Enemy_SprAttrib,x
    ora #%10000000
    sta Enemy_SprAttrib,x
    bne Exit
GmbaAnim:
  and #%00100000        ;check for d5 set in enemy object state
  ora TimerControl      ;or timer disable flag set
  bne Exit              ;if either condition true, do not animate goomba
    lda FrameCounter
    and #%00001000        ;check for every eighth frame
    bne Exit
      ldy #METASPRITE_GOOMBA_WALKING_2
Exit:
  tya
  sta EnemyMetasprite,x
  rts
.endproc

ProcessDemotedKoopa:
.proc ProcessRedKoopa
  lda Enemy_SprAttrib,x
  ora #OAM_PALLETE_2
  sta Enemy_SprAttrib,x
  bne ProcessKoopa  ; unconditional
.endproc
.proc ProcessGreenKoopa
  ; default animation cycle for the koopa
  lda Enemy_SprAttrib,x
  ora #OAM_PALLETE_1
  sta Enemy_SprAttrib,x
  ; fallthrough
.endproc
.proc ProcessKoopa
  ; Reinitialize the flip flag, we'll set it later if we need to flip
  lda #0
  sta EnemyVerticalFlip,x
  ldy #METASPRITE_KOOPA_WALKING_1
  lda Enemy_State,x
  cmp #$02
  bcc CheckRightSideUpShell
    ; Koopa is upside down, and so we don't apply the flip bits here.
    ldy #METASPRITE_KOOPA_SHELL
    ; fallthrough intentional. The original code does this too
CheckRightSideUpShell:
  and #%00001111
  cmp #$04 ; enemy stomped
  bne NormalKoopaAnimation
    ; if the shell is right side up 
    ldy #METASPRITE_KOOPA_SHELL
    ; Shell is upside down in OAM, so flip the koopa right side up
    ; and then check for animation
    ; We do need an offset, so turn on VFlip and set the offset 
    ; Add 2 px down offset
    lda #MetaspriteOffset{2} | MSPR_VERTICAL_FLIP
    sta EnemyVerticalFlip,x
NormalKoopaAnimation:
  lda Enemy_State,x
  ; check for the animation bits
  ; for d7 or d5, or check for timers stopped
  and #%10100000
  ora TimerControl
  bne WriteMetasprite
    ; Check if the timer is in the last 5 frame rules
    lda EnemyIntervalTimer,x
    cmp #$05
    bcs WriteMetasprite
      ; and run the animation every 8 frames
      lda FrameCounter
      and #%00001000
      bne WriteMetasprite
        ; This uses the next sequential metasprite ID for all the shell animations
        iny
WriteMetasprite:
  tya
  sta EnemyMetasprite,x
  rts
.endproc

ProcessRedFlyingParatrooper:
  lda Enemy_SprAttrib,x
  ora #OAM_PALLETE_2
  sta Enemy_SprAttrib,x
  bne ProcessJumpingParatrooperInner  ; unconditional

ProcessGreenFlyingParatrooper:
  ;fallthrough

ProcessJumpingParatrooper:
  lda Enemy_SprAttrib,x
  ora #OAM_PALLETE_1
  sta Enemy_SprAttrib,x
ProcessJumpingParatrooperInner:
  ldy #METASPRITE_KOOPA_FLYING_1
  lda Enemy_State,x
  ; check for the animation bits
  ; for d7 or d5, or check for timers stopped
  and #%10100000
  ora TimerControl
  bne @WriteMetasprite
    ; and run the animation every 8 frames
    lda FrameCounter
    and #%00001000
    bne @WriteMetasprite
      ; This uses the next sequential metasprite ID for all the shell animations
      iny
@WriteMetasprite:
  tya
  sta EnemyMetasprite,x
  rts

.proc ProcessBulletBill
  lda #BULLET_PALETTE
  ldy EnemyFrameTimer,x       ;get timer for enemy object
  beq :+                   ;if expired, do not set priority bit
    ora #%00100000              ;otherwise do so
: 
  sta Enemy_SprAttrib,x                      ;set new sprite attributes
  lda #METASPRITE_BULLET_BILL
  sta EnemyMetasprite,x
  jmp SprObjectOffscrChk
.endproc

.proc ProcessPodoboo
  lda #METASPRITE_PODOBOO_UP
  sta EnemyMetasprite,x
  ; The only real decision we have to make is
  ; if it died or its going down, flip it upside down
  ldy #0
  lda Enemy_State,x
  and #%00100000
  beq :+
    ; if dead
    ldy #OAM_FLIP_V
  :
  lda Enemy_Y_Speed,x
  bmi :+
    ; if going down
    ldy #OAM_FLIP_V
  :
  tya
  sta Enemy_SprAttrib,x
  rts
.endproc


.proc ProcessBuzzyBeetle
  ; Reinitialize the flip flag, we'll set it later if we need to flip
  lda #0
  sta EnemyVerticalFlip,x
  ldy #METASPRITE_BUZZY_BEETLE_WALKING_1
  lda Enemy_State,x
  cmp #$02
  bcc CheckRightSideUpShell
    ldy #METASPRITE_BUZZY_BEETLE_SHELL
    ; fallthrough intentional. The original code does this too
CheckRightSideUpShell:
  and #%00001111
  cmp #$02 ; enemy stomped in air
  beq WriteMetasprite
  cmp #$03 ; enemy stomped upside down
  beq WriteMetasprite
  cmp #$04 ; enemy stomped
  bne NormalBuzzyAnimation
    ; if the shell is right side up 
    ldy #METASPRITE_BUZZY_BEETLE_SHELL
    ; Shell is upside down in OAM, so flip the buzzy right side up
    ; and then check for animation
    ; Add 2 px down offset
    lda #MetaspriteOffset{2} | MSPR_VERTICAL_FLIP
    sta EnemyVerticalFlip,x
    bne WriteMetasprite ; unconditional. we don't animate upside down buzzy
NormalBuzzyAnimation:
  lda Enemy_State,x
  ; check for the animation bits
  ; for d7 or d5, or check for timers stopped
  and #%10100000
  ora TimerControl      ;or timer disable flag set
  bne WriteMetasprite   ;if either condition true, do not animate goomba
    lda FrameCounter
    and #%00001000        ;check for every eighth frame
    bne WriteMetasprite
      iny
WriteMetasprite:
  tya
  sta EnemyMetasprite,x
  rts
.endproc

ProcessSwimmingCheepCheep:
  lda #$01
  .byte $2c
  ; fallthrough
.proc ProcessFlyingCheepCheep
  lda #$02
  sta Enemy_SprAttrib,x
  ldy #METASPRITE_CHEEP_CHEEP_SWIM_1
  lda Enemy_State,x
  ; check for the animation bits
  and #%10100000
  ora TimerControl      ;or timer disable flag set
  bne CheckDefeated   ;if either condition true, do not animate goomba
    lda FrameCounter
    and #%00001000        ;check for every eighth frame
    bne CheckDefeated
      iny
CheckDefeated:
  ; d5 is set when the enemy is dead
  lda Enemy_State,x
  and #%00100000        ;for d5 set
  beq WriteMetasprite
    lda #MSPR_VERTICAL_FLIP
    sta EnemyVerticalFlip,x
WriteMetasprite:
  tya
  sta EnemyMetasprite,x
  rts
.endproc

.proc ProcessBlooper
  ldy #METASPRITE_BLOOPER_SWIM_1
  lda EnemyIntervalTimer,x
  ; Greater than 5 means defeated
  cmp #$05
  bcs CheckDefeated
    ; if the timer is set to 1, don't animate
    cmp #1
    beq CheckDefeated
      ; Check if the timers are running
      lda Enemy_State,x        ;check saved enemy state
      and #%10100000      ;for d7 or d5, or check for timers stopped
      ora TimerControl
      bne CheckDefeated   ;if either condition true, branch
        ldy #METASPRITE_BLOOPER_SWIM_2
CheckDefeated:
  ; d5 is set when the enemy is dead
  lda Enemy_State,x
  and #%00100000        ;for d5 set
  beq WriteMetasprite
    lda #MSPR_VERTICAL_FLIP
    sta EnemyVerticalFlip,x
WriteMetasprite:
  tya
  sta EnemyMetasprite,x
  rts
.endproc

.proc ProcessHammerBro
  ldy #METASPRITE_HAMMER_BRO_WALK_1

  lda Enemy_State,x
  beq CheckToAnimateEnemy  ;branch if not in normal enemy state
  and #%00001000
  beq CheckDefeatedState   ;if d3 not set, branch further away
    ldy #METASPRITE_HAMMER_BRO_THROW_1
    ; bne CheckToAnimateEnemy  ;unconditional branch
CheckToAnimateEnemy:
  lda FrameCounter
  and #$08
  bne CheckDefeatedState
      lda Local_ed                 ;check saved enemy state
      and #%10100000          ;for d7 or d5, or check for timers stopped
      ora TimerControl
      bne CheckDefeatedState  ;if either condition true, branch
        iny ; use the next frame of whatever action is selected
CheckDefeatedState:
  lda Enemy_State,x
  and #%00100000        ;for d5 set
  beq WriteMetasprite   ;branch if not set
    lda #MSPR_VERTICAL_FLIP
    sta EnemyVerticalFlip,x
WriteMetasprite:
  tya
  sta EnemyMetasprite,x
  rts
.endproc

.proc ProcessLakitu
  ldy #METASPRITE_LAKITU_NORMAL
  lda Enemy_State,x
  and #%00100000            ;check for d5 set in enemy state
  bne NoLakituOrFrenzy      ;branch if set
    lda FrenzyEnemyTimer
    cmp #$10
    bcs NoLakituOrFrenzy
      ; load second animation frame for lakitu
      ldy #METASPRITE_LAKITU_THROWING
NoLakituOrFrenzy:
CheckDefeatedState:
  lda Enemy_State,x     ;check saved enemy state
  and #%00100000        ;for d5 set
  beq WriteMetasprite   ;branch if not set
    lda #MSPR_VERTICAL_FLIP
    sta EnemyVerticalFlip,x
WriteMetasprite:
  tya
  sta EnemyMetasprite,x
  rts
.endproc

.proc ProcessSpiny
  lda Enemy_State,x
  cmp #$05 ; Egg state
  bne NotEgg
    ; Manually set the egg to look to the left (vanilla does right?)
    lda #1
    sta Enemy_MovingDir,x
    ldy #METASPRITE_SPINY_EGG_1
    bne CheckToAnimateEnemy
NotEgg:
  ldy #METASPRITE_SPINY_WALK_1
CheckToAnimateEnemy:
  lda FrameCounter
  and #$08
  bne CheckDefeatedState
      lda Local_ed                 ;check saved enemy state
      and #%10100000          ;for d7 or d5, or check for timers stopped
      ora TimerControl
      bne CheckDefeatedState  ;if either condition true, branch
        iny ; use the next frame of whatever action is selected

CheckDefeatedState:
  lda Enemy_State,x     ;check saved enemy state
  and #%00100000        ;for d5 set
  beq WriteMetasprite   ;branch if not set
    lda #MSPR_VERTICAL_FLIP
    sta EnemyVerticalFlip,x
WriteMetasprite:
  tya
  sta EnemyMetasprite,x
  rts
.endproc

; GreenKoopa            = $00
; BuzzyBeetle           = $02
; RedKoopa              = $03
; HammerBro             = $05
; Goomba                = $06
; Bloober               = $07
; BulletBill_FrenzyVar  = $08
; GreyCheepCheep        = $0a
; RedCheepCheep         = $0b
; Podoboo               = $0c
; PiranhaPlant          = $0d
; GreenParatroopaJump   = $0e
; RedParatroopa         = $0f
; GreenParatroopaFly    = $10
; Lakitu                = $11
; Spiny                 = $12
; FlyCheepCheepFrenzy   = $14
; FlyingCheepCheep      = $14  .word MoveFlyingCheepCheep

;-------------------------------------------------------------------------------------

.proc DrawBlock
  ldx ObjectOffset              ;get block object offset
  ldy #METASPRITE_MISC_BRICK_GROUND
  lda #3
  sta Block_SprAttrib,x
  lda AreaType
  cmp #1                        ;check for ground level type area
  beq CheckReplacement          ;if found, branch to next part
    ldy #METASPRITE_MISC_BRICK_OTHER
CheckReplacement:
  lda Block_Metatile,x          ;check replacement metatile
  cmp #$c4                      ;if not used block metatile, then
  bne Exit                 ;branch ahead to use current graphics
    ldy #METASPRITE_MISC_BLOCK
    lda AreaType
    cmp #1
    beq Exit
      lda #1
      sta Block_SprAttrib,x
Exit:
  tya
  sta BlockMetasprite,x
  rts
.endproc

;-------------------------------------------------------------------------------------
;$00 - used to hold palette bits for attribute byte or relative X position

.proc DrawBrickChunks
  lda #$02                    ;set palette bits here
  sta R0 
;  lda #$75                   ;set tile number for ball (something residual, likely)
  ldy GameEngineSubroutine
  cpy #$05                    ;if end-of-level routine running,
  beq :+                      ;use palette and tile number assigned
    lda #$03                   ;otherwise set different palette bits
    sta R0 
    ;  lda #$84                   ;and set tile number for brick chunks
    lda #BRICK_CHUNK_TILE
:
  ; lazy way to keep the sprite tile here.
  pha
AllocSpr 4
  pla
  iny                        ;increment to start with tile bytes in OAM
  jsr DumpFourSpr            ;do sub to dump tile number into all four sprites
  lda FrameCounter           ;get frame counter
  asl
  asl
  asl                        ;move low nybble to high
  asl
  and #$c0                   ;get what was originally d3-d2 of low nybble
  ora R0                     ;add palette bits
  iny                        ;increment offset for attribute bytes
  jsr DumpFourSpr            ;do sub to dump attribute data into all four sprites
  dey
  dey                        ;decrement offset to Y coordinate
  lda Block_Rel_YPos         ;get first block object's relative vertical coordinate
  jsr DumpTwoSpr             ;do sub to dump current Y coordinate into two sprites
  lda Block_Rel_XPos         ;get first block object's relative horizontal coordinate
  sta Sprite_X_Position,y    ;save into X coordinate of first sprite
  lda Block_Orig_XPos,x      ;get original horizontal coordinate
  sec
  sbc ScreenLeft_X_Pos       ;subtract coordinate of left side from original coordinate
  sta R0                     ;store result as relative horizontal coordinate of original
  sec
  sbc Block_Rel_XPos         ;get difference of relative positions of original - current
  adc R0                     ;add original relative position to result
  adc #$06                   ;plus 6 pixels to position second brick chunk correctly
  sta Sprite_X_Position+4,y  ;save into X coordinate of second sprite
  lda Block_Rel_YPos+1       ;get second block object's relative vertical coordinate
  sta Sprite_Y_Position+8,y
  sta Sprite_Y_Position+12,y ;dump into Y coordinates of third and fourth sprites
  lda Block_Rel_XPos+1       ;get second block object's relative horizontal coordinate
  sta Sprite_X_Position+8,y  ;save into X coordinate of third sprite
  lda R0                     ;use original relative horizontal position
  sec
  sbc Block_Rel_XPos+1       ;get difference of relative positions of original - current
  adc R0                     ;add original relative position to result
  adc #$06                   ;plus 6 pixels to position fourth brick chunk correctly
  sta Sprite_X_Position+12,y ;save into X coordinate of fourth sprite
  lda Block_OffscreenBits    ;get offscreen bits for block object
  ; jsr ChkLeftCo              ;do sub to move left half of sprites offscreen if necessary
  and #%00001000                ;check to see if d3 in offscreen bits are set
  beq :+                    ;if not set, branch, otherwise move sprites offscreen
    lda #$f8                   ;move offscreen two OAMs
    sta Sprite_Y_Position,y    ;on the left side (or two rows of enemy on either side
    sta Sprite_Y_Position+8,y  ;if branched here from enemy graphics handler)
:
  lda Block_OffscreenBits    ;get offscreen bits again
  asl                        ;shift d7 into carry
  bcc :+                ;if d7 not set, branch to last part
    lda #$f8
    jsr DumpTwoSpr             ;otherwise move top sprites offscreen
:
  lda R0                     ;if relative position on left side of screen,
  bpl Exit                 ;go ahead and leave
  lda Sprite_X_Position,y    ;otherwise compare left-side X coordinate
  cmp Sprite_X_Position+4,y  ;to right-side X coordinate
  bcc Exit                 ;branch to leave if less
    lda #$f8                   ;otherwise move right half of sprites offscreen
    sta Sprite_Y_Position+4,y
    sta Sprite_Y_Position+12,y
Exit:
  rts                        ;leave
.endproc
;-------------------------------------------------------------------------------------

.proc DrawFireball
  lda FrameCounter         ;get frame counter
  lsr                      ;divide by four
  lsr
  pha                      ;save result to stack
    ;and #$01                 ;mask out all but last bit
    ; eor #FIREBALL_TILE1                 ;set either tile $64 or $65 as fireball tile
    ; sta Sprite_Tilenumber,y  ;thus tile changes every four frames
    lsr
    lda #METASPRITE_FIREBALL_FRAME_1
    bcc :+
      lda #METASPRITE_FIREBALL_FRAME_2
    :
    sta FireballMetasprite,x
  pla                      ;get from stack
  lsr                      ;divide by four again
  lsr
  lda #$02                 ;load value $02 to set palette in attrib byte
  bcc FireA                ;if last bit shifted out was not set, skip this
  ora #%11000000           ;otherwise flip both ways every eight frames
FireA:
  sta Fireball_SprAttrib,x  ;store attribute byte and leave
  rts
.endproc

.proc DrawSingleFireball
  lda FrameCounter         ;get frame counter
  lsr                      ;divide by four
  lsr
  pha                      ;save result to stack
    ;and #$01                 ;mask out all but last bit
    ; eor #FIREBALL_TILE1                 ;set either tile $64 or $65 as fireball tile
    ; sta Sprite_Tilenumber,y  ;thus tile changes every four frames
    lsr
    lda #FIREBALL_TILE1
    bcc :+
      lda #FIREBALL_TILE2
    :
    sta Sprite_Tilenumber,y
  pla                      ;get from stack
  lsr                      ;divide by four again
  lsr
  lda #$02                 ;load value $02 to set palette in attrib byte
  bcc FireA                ;if last bit shifted out was not set, skip this
  ora #%11000000           ;otherwise flip both ways every eight frames
FireA:
  sta Sprite_Attributes,y  ;store attribute byte and leave
  rts
.endproc

;-------------------------------------------------------------------------------------

DrawSmallPlatform:
      ;  ldy Enemy_SprDataOffset,x   ;get OAM data offset
    AllocSpr 6
       lda #PLATFORM_GIRDER        ;load tile number for small platforms
       iny                         ;increment offset for tile numbers
       jsr DumpSixSpr              ;dump tile number into all six sprites
       iny                         ;increment offset for attributes
       lda #$02                    ;load palette controls
       jsr DumpSixSpr              ;dump attributes into all six sprites
       dey                         ;decrement for original offset
       dey
       lda Enemy_Rel_XPos          ;get relative horizontal coordinate
       sta Sprite_X_Position,y
       sta Sprite_X_Position+12,y  ;dump as X coordinate into first and fourth sprites
       clc
       adc #$08                    ;add eight pixels
       sta Sprite_X_Position+4,y   ;dump into second and fifth sprites
       sta Sprite_X_Position+16,y
       clc
       adc #$08                    ;add eight more pixels
       sta Sprite_X_Position+8,y   ;dump into third and sixth sprites
       sta Sprite_X_Position+20,y
       lda Enemy_Y_Position,x      ;get vertical coordinate
       tax
       pha                         ;save to stack
       cpx #$20                    ;if vertical coordinate below status bar,
       bcs TopSP                   ;do not mess with it
       lda #$f8                    ;otherwise move first three sprites offscreen
TopSP: jsr DumpThreeSpr            ;dump vertical coordinate into Y coordinates
       pla                         ;pull from stack
       clc
       adc #$80                    ;add 128 pixels
       tax
       cpx #$20                    ;if below status bar (taking wrap into account)
       bcs BotSP                   ;then do not change altered coordinate
       lda #$f8                    ;otherwise move last three sprites offscreen
BotSP: sta Sprite_Y_Position+12,y  ;dump vertical coordinate + 128 pixels
       sta Sprite_Y_Position+16,y  ;into Y coordinates
       sta Sprite_Y_Position+20,y
       lda Enemy_OffscreenBits     ;get offscreen bits
       pha                         ;save to stack
       and #%00001000              ;check d3
       beq SOfs
       lda #$f8                    ;if d3 was set, move first and
       sta Sprite_Y_Position,y     ;fourth sprites offscreen
       sta Sprite_Y_Position+12,y
SOfs:  pla                         ;move out and back into stack
       pha
       and #%00000100              ;check d2
       beq SOfs2
       lda #$f8                    ;if d2 was set, move second and
       sta Sprite_Y_Position+4,y   ;fifth sprites offscreen
       sta Sprite_Y_Position+16,y
SOfs2: pla                         ;get from stack
       and #%00000010              ;check d1
       beq ExSPl
       lda #$f8                    ;if d1 was set, move third and
       sta Sprite_Y_Position+8,y   ;sixth sprites offscreen
       sta Sprite_Y_Position+20,y
ExSPl: ldx ObjectOffset            ;get enemy object offset and leave
       rts

;-------------------------------------------------------------------------------------
;$00-$01 - used to hold tile numbers ($01 addressed in draw floatey number part)
;$02 - used to hold Y coordinate for floatey number
;$03 - residual byte used for flip (but value set here affects nothing)
;$04 - attribute byte for floatey number
;$05 - used as X coordinate for floatey number


.proc FlagpoleGfxHandler
  lda #METASPRITE_MISC_FLAGPOLE_FLAG
  sta EnemyMetasprite,x

  lda FlagpoleCollisionYPos
  beq Exit
    ; there is no need to un-hardcode the floatey number as Mario can only interact 
    ; with one flagpole
    lda MiscMetasprite+5
    bne AlreadyInitializedScore
      ; Initialize the score position

      ldy FlagpoleScore
      lda FlagpoleScoreNumTiles,y
      sta MiscMetasprite+5
      lda #1
      sta Misc_Y_HighPos+5
      lda Enemy_X_Position,x
      clc
      adc #20 ; add 20px to align with vanilla
      sta Misc_X_Position+5
      lda Enemy_PageLoc,x
      adc #00
      sta Misc_PageLoc+5

  AlreadyInitializedScore:

    lda FlagpoleFNum_Y_Pos
    sta Misc_Y_Position+5
Exit:
  rts

FlagpoleScoreNumTiles:
  .byte METASPRITE_NUMBER_5000
  .byte METASPRITE_NUMBER_2000
  .byte METASPRITE_NUMBER_800
  .byte METASPRITE_NUMBER_400
  .byte METASPRITE_NUMBER_100
.endproc

;-------------------------------------------------------------------------------------

MoveSixSpritesOffscreen:
  lda #$f8                  ;set offscreen coordinate if jumping here

DumpSixSpr:
  sta Sprite_Data+20,y      ;dump A contents
  sta Sprite_Data+16,y      ;into third row sprites

DumpFourSpr:
  sta Sprite_Data+12,y      ;into second row sprites

DumpThreeSpr:
  sta Sprite_Data+8,y

DumpTwoSpr:
  sta Sprite_Data+4,y       ;and into first row sprites
  sta Sprite_Data,y

ExitDumpSpr:
  rts
