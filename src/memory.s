
; Quick macros to reserve a value and export it for usage in C
.macro RESERVE name, size
  .export .ident(.sprintf("_%s", .string(name))) = .ident(.string(name)) 
  .ident(.string(name)): .res size
.endmacro
.macro RESERVE_ZP name, size
  .exportzp .ident(.sprintf("_%s", .string(name))) = .ident(.string(name)) 
  .ident(.string(name)): .res size
.endmacro

.pushseg

.zeropage

; Temporary values used by the vanilla code
RESERVE_ZP R0, 1
RESERVE_ZP R1, 1
RESERVE_ZP R2, 1
RESERVE_ZP R3, 1
RESERVE_ZP R4, 1
RESERVE_ZP R5, 1
RESERVE_ZP R6, 1
RESERVE_ZP R7, 1

; Temporary values used in NMI in vanilla
RESERVE_ZP NmiR0, 1
RESERVE_ZP NmiR1, 1

; New temporaries that can be reused wherever
RESERVE_ZP M0, 1
RESERVE_ZP M1, 1

RESERVE_ZP ObjectOffset, 1
RESERVE_ZP FrameCounter, 1

RESERVE_ZP SavedJoypad1Bits, 1
RESERVE_ZP SavedJoypad2Bits, 1
SavedJoypadBits := SavedJoypad1Bits


RESERVE_ZP GameEngineSubroutine, 1
RESERVE_ZP Enemy_Flag, 7
RESERVE_ZP Enemy_ID, 7

RESERVE_ZP Player_State, 1
RESERVE_ZP Enemy_State, 6
RESERVE_ZP Fireball_State, 2
RESERVE_ZP Block_State, 4
RESERVE_ZP Misc_State, 9

RESERVE_ZP PowerUpType, 1
RESERVE_ZP FireballBouncingFlag, 2
RESERVE_ZP HammerBroJumpTimer, 9
RESERVE_ZP Player_MovingDir, 1

RESERVE_ZP Player_X_Speed, 1
SprObject_X_Speed := Player_X_Speed
RESERVE_ZP Enemy_X_Speed, 6
LakituMoveSpeed := Enemy_X_Speed
PiranhaPlant_Y_Speed := Enemy_X_Speed
ExplosionGfxCounter := Enemy_X_Speed
Jumpspring_FixedYPos := Enemy_X_Speed
RedPTroopaCenterYPos := Enemy_X_Speed
BlooperMoveSpeed := Enemy_X_Speed
XMoveSecondaryCounter := Enemy_X_Speed
CheepCheepMoveMFlag := Enemy_X_Speed
FirebarSpinState_Low := Enemy_X_Speed
YPlatformCenterYPos := Enemy_X_Speed
RESERVE_ZP Fireball_X_Speed, 2
RESERVE_ZP Block_X_Speed, 4
RESERVE_ZP Misc_X_Speed, 9

RESERVE_ZP Player_PageLoc, 1
SprObject_PageLoc := Player_PageLoc

RESERVE_ZP Enemy_PageLoc, 6
RESERVE_ZP Fireball_PageLoc, 2
RESERVE_ZP Block_PageLoc, 4
RESERVE_ZP Misc_PageLoc, 9
RESERVE_ZP Bubble_PageLoc, 3

RESERVE_ZP Player_X_Position, 1
SprObject_X_Position := Player_X_Position

RESERVE_ZP Enemy_X_Position, 6
RESERVE_ZP Fireball_X_Position, 2
RESERVE_ZP Block_X_Position, 4
RESERVE_ZP Misc_X_Position, 9
RESERVE_ZP Bubble_X_Position, 3

RESERVE_ZP Player_Y_Speed, 1
SprObject_Y_Speed := Player_Y_Speed

RESERVE_ZP Enemy_Y_Speed, 6
FirebarSpinState_High := Enemy_Y_Speed
XMovePrimaryCounter := Enemy_Y_Speed
BlooperMoveCounter := Enemy_Y_Speed
LakituMoveDirection := Enemy_Y_Speed
ExplosionTimerCounter := Enemy_Y_Speed
PiranhaPlant_MoveFlag := Enemy_Y_Speed

RESERVE_ZP Fireball_Y_Speed, 2
RESERVE_ZP Block_Y_Speed, 4
RESERVE_ZP Misc_Y_Speed, 9

RESERVE_ZP Player_Y_HighPos, 1
SprObject_Y_HighPos := Player_Y_HighPos

RESERVE_ZP Enemy_Y_HighPos, 6
RESERVE_ZP Fireball_Y_HighPos, 2
RESERVE_ZP Block_Y_HighPos, 4
RESERVE_ZP Misc_Y_HighPos, 9
RESERVE_ZP Bubble_Y_HighPos, 3

RESERVE_ZP Player_Y_Position, 1
SprObject_Y_Position := Player_Y_Position

RESERVE_ZP Enemy_Y_Position, 6
RESERVE_ZP Fireball_Y_Position, 2
RESERVE_ZP Block_Y_Position, 4
RESERVE_ZP Misc_Y_Position, 9
RESERVE_ZP Bubble_Y_Position, 3

RESERVE_ZP AreaData, 2
AreaDataLow := AreaData
AreaDataHigh := AreaData+1

RESERVE_ZP EnemyData, 2
EnemyDataLow := EnemyData
EnemyDataHigh := EnemyData + 1


RESERVE_ZP SpriteLocalTemp, 4
Local_eb := SpriteLocalTemp + 0
Local_ec := SpriteLocalTemp + 1
Local_ed := SpriteLocalTemp + 2
; RESERVEZP Local_ee ; unused
Local_ef := SpriteLocalTemp + 3

RESERVE_ZP MusicData, 2
MusicDataLow := MusicData
MusicDataHigh := MusicData+1

; .segment "STACK"

.segment "SHORTRAM"

RESERVE PauseSoundQueue, 1
RESERVE AreaMusicQueue, 1
RESERVE EventMusicQueue, 1
RESERVE NoiseSoundQueue, 1
RESERVE Square2SoundQueue, 1
RESERVE Square1SoundQueue, 1

RESERVE FlagpoleFNum_Y_Pos, 1
RESERVE FlagpoleFNum_YMFDummy, 1
RESERVE FlagpoleScore, 1

RESERVE FloateyNum_Control, 7
RESERVE FloateyNum_X_Pos, 7
RESERVE FloateyNum_Y_Pos, 7

RESERVE ShellChainCounter, 7
RESERVE FloateyNum_Timer, 8
RESERVE DigitModifier, 6


StackClear = DigitModifier+6

; DON'T CLEAR PAST HERE

RESERVE IrqNewScroll, 1
RESERVE IrqPPUCTRL, 1

RESERVE NmiDisable, 1
RESERVE NmiSkipped, 1
RESERVE ShouldSkipDrawSprites, 1
RESERVE FramesSinceLastSpriteDraw, 1

RESERVE IrqNextScanline, 1
RESERVE CurrentA, 1
RESERVE NextBank, 1
RESERVE SwitchToMainIRQ, 1
RESERVE IrqPointerJmp, 3
IrqPointer := IrqPointerJmp + 1

.if ENABLE_C_CODE
RESERVE CStack, $20
.endif

; segment "BSS"
.segment "OAM"

RESERVE Sprite_Y_Position, 1
RESERVE Sprite_Tilenumber, 1
RESERVE Sprite_Attributes, 1
RESERVE Sprite_X_Position, 1
Sprite_Data := Sprite_Y_Position
.export _Sprite_Data = Sprite_Data

.segment "BSS"

RESERVE Block_Buffer_1, 208
RESERVE Block_Buffer_2, 208
RESERVE BlockBufferColumnPos, 1
RESERVE MetatileBuffer, 13
RESERVE BackgroundBuffer, 13
RESERVE BackgroundBufferAddr, 2

RESERVE VRAM_Buffer1_Offset, 1
RESERVE VRAM_Buffer1, 84
RESERVE VRAM_Buffer2_Offset, 1
RESERVE VRAM_Buffer2, 34
VRAM_Buffer1_PtrOffset = 0
VRAM_Buffer2_PtrOffset = VRAM_Buffer2_Offset - VRAM_Buffer1_Offset

RESERVE BowserBodyControls, 1
RESERVE BowserFeetCounter, 1
RESERVE BowserMovementSpeed, 1
RESERVE BowserOrigXPos, 1
RESERVE BowserFlameTimerCtrl, 1
RESERVE BowserFront_Offset, 1
RESERVE BridgeCollapseOffset, 1
RESERVE BowserGfxFlag, 1

;BSS temporary values (non NMI)
RESERVE B0, 1
RESERVE B1, 1

RESERVE FirebarSpinSpeed, 16

; moved to abs ram

RESERVE PlayerFacingDir, 1
RESERVE Enemy_MovingDir, 25

; moved to abs ram
RESERVE A_B_Buttons, 1
RESERVE Up_Down_Buttons, 1
RESERVE Left_Right_Buttons, 1
RESERVE PreviousA_B_Buttons, 1

RESERVE Vine_FlagOffset, 1
RESERVE Vine_Height, 1
RESERVE Vine_ObjOffset, 3
RESERVE Vine_Start_Y_Position, 3

RESERVE BalPlatformAlignment, 1
RESERVE Platform_X_Scroll, 1

RESERVE PlatformCollisionFlag, 11
HammerThrowingTimer := PlatformCollisionFlag

RESERVE Player_Rel_XPos, 1
SprObject_Rel_XPos := Player_Rel_XPos
RESERVE Enemy_Rel_XPos, 1
RESERVE Fireball_Rel_XPos, 1
RESERVE Bubble_Rel_XPos, 1
RESERVE Block_Rel_XPos, 2
RESERVE Misc_Rel_XPos, 5

RESERVE Player_Rel_YPos, 1
SprObject_Rel_YPos := Player_Rel_YPos
RESERVE Enemy_Rel_YPos, 1
RESERVE Fireball_Rel_YPos, 1
RESERVE Bubble_Rel_YPos, 1
RESERVE Block_Rel_YPos, 2
RESERVE Misc_Rel_YPos, 5

RESERVE Player_SprAttrib, 1
SprObject_SprAttrib := Player_SprAttrib
RESERVE Enemy_SprAttrib, 6
RESERVE Fireball_SprAttrib, 2
RESERVE Block_SprAttrib, 4
RESERVE Misc_SprAttrib, 9
RESERVE Bubble_SprAttrib, 3

RESERVE Player_OffscreenBits, 1
SprObject_OffscrBits := Player_OffscreenBits
RESERVE Enemy_OffscreenBits, 1
RESERVE FBall_OffscreenBits, 1
RESERVE Bubble_OffscreenBits, 1
RESERVE Block_OffscreenBits, 2
RESERVE Misc_OffscreenBits, 2
RESERVE EnemyOffscrBitsMasked, 12
RESERVE Block_Orig_YPos, 2
RESERVE Block_BBuf_Low, 2
RESERVE Block_BBuf_High, 2
RESERVE Block_Metatile, 2
RESERVE Block_PageLoc2, 2
RESERVE Block_RepFlag, 2
RESERVE SprDataOffset_Ctrl, 2
RESERVE Block_Orig_XPos, 8
RESERVE AttributeBuffer, 7

RESERVE SprObject_X_MoveForce, 1
RESERVE Enemy_X_MoveForce, 21
YPlatformTopYPos := Enemy_X_MoveForce
RedPTroopaOrigXPos := Enemy_X_MoveForce


RESERVE Player_YMoveForceFractional, 1
SprObject_YMoveForceFractional := Player_YMoveForceFractional

RESERVE Enemy_YMoveForceFractional, 21
BowserFlamePRandomOfs := Enemy_YMoveForceFractional
PiranhaPlantUpYPos := Enemy_YMoveForceFractional

RESERVE Bubble_YMoveForceFractional, 7

RESERVE Player_Y_MoveForce, 1
SprObject_Y_MoveForce := Player_Y_MoveForce

RESERVE Enemy_Y_MoveForce, 8
CheepCheepOrigYPos := Enemy_Y_MoveForce
PiranhaPlantDownYPos := Enemy_Y_MoveForce

RESERVE Block_Y_MoveForce, 20
RESERVE MaximumLeftSpeed, 1
RESERVE MaximumRightSpeed, 1

RESERVE Whirlpool_Offset, 1
Cannon_Offset := Whirlpool_Offset

RESERVE Whirlpool_PageLoc, 6
Cannon_PageLoc := Whirlpool_PageLoc

RESERVE Whirlpool_LeftExtent, 6
Cannon_X_Position := Whirlpool_LeftExtent

RESERVE Whirlpool_Length, 6
Cannon_Y_Position := Whirlpool_Length

RESERVE Whirlpool_Flag, 6
Cannon_Timer := Whirlpool_Flag

RESERVE BowserHitPoints, 1
RESERVE StompChainCounter, 1
RESERVE Player_CollisionBits, 1
RESERVE Enemy_CollisionBits, 8

RESERVE Player_BoundBoxCtrl, 1
SprObj_BoundBoxCtrl := Player_BoundBoxCtrl

RESERVE Enemy_BoundBoxCtrl, 6
RESERVE Fireball_BoundBoxCtrl, 2
RESERVE Misc_BoundBoxCtrl, 10

RESERVE BoundingBox_UL_Corner, 1
BoundingBox_UL_XPos := BoundingBox_UL_Corner
RESERVE BoundingBox_UL_YPos, 1
RESERVE BoundingBox_LR_Corner, 1
BoundingBox_DR_XPos := BoundingBox_LR_Corner
RESERVE BoundingBox_DR_YPos, 1
RESERVE EnemyBoundingBoxCoord, 80
RESERVE HammerEnemyOffset, 9
RESERVE JumpCoinMiscOffset, 5
RESERVE BrickCoinTimerFlag, 2
RESERVE Misc_Collision_Flag, 13
RESERVE EnemyFrenzyBuffer, 1
RESERVE SecondaryHardMode, 1
RESERVE EnemyFrenzyQueue, 1
RESERVE FireballCounter, 1
RESERVE DuplicateObj_Offset, 2
RESERVE LakituReappearTimer, 2
RESERVE NumberofGroupEnemies, 1
RESERVE ColorRotateOffset, 1
RESERVE PlayerGfxOffset, 1
RESERVE WarpZoneControl, 1
RESERVE FireworksCounter, 2
RESERVE MultiLoopCorrectCntr, 1
RESERVE MultiLoopPassCntr, 1
RESERVE JumpspringForce, 1
RESERVE MaxRangeFromOrigin, 1
RESERVE BitMFilter, 1
RESERVE ChangeAreaTimer, 2

; RESERVE PlayerOAMOffset, 1
RESERVE CurrentOAMOffset, 1
RESERVE OriginalOAMOffset, 1
RESERVE SpriteShuffleOffset, 1

RESERVE PlayerMetasprite, 1
ObjectMetasprite := PlayerMetasprite
RESERVE EnemyMetasprite, 6
RESERVE FireballMetasprite, 2
RESERVE BlockMetasprite, 4
RESERVE MiscMetasprite, 9
RESERVE BubbleMetasprite, 3

RESERVE PlayerVerticalFlip, 1
ObjectVerticalFlip := PlayerVerticalFlip
RESERVE EnemyVerticalFlip, 6

RESERVE Player_X_Scroll, 1
RESERVE Player_XSpeedAbsolute, 1
RESERVE FrictionAdderHigh, 1
RESERVE FrictionAdderLow, 1
RESERVE RunningSpeed, 1
RESERVE SwimmingFlag, 1
RESERVE Player_X_MoveForce, 1
RESERVE DiffToHaltJump, 1
RESERVE JumpOrigin_Y_HighPos, 1
RESERVE JumpOrigin_Y_Position, 1
RESERVE VerticalForce, 1
RESERVE VerticalForceDown, 1
RESERVE PlayerChangeSizeFlag, 1
RESERVE PlayerAnimTimerSet, 1
RESERVE PlayerAnimCtrl, 1
RESERVE JumpspringAnimCtrl, 1
RESERVE FlagpoleCollisionYPos, 1
RESERVE PlayerEntranceCtrl, 1
RESERVE FireballThrowingTimer, 1
RESERVE DeathMusicLoaded, 1
RESERVE FlagpoleSoundQueue, 1
RESERVE CrouchingFlag, 1
RESERVE GameTimerSetting, 1
RESERVE DisableCollisionDet, 1
RESERVE DemoAction, 1
RESERVE DemoActionTimer, 1
RESERVE PrimaryMsgCounter, 1

ScreenEdge_PageLoc := ScreenLeft_PageLoc
RESERVE ScreenLeft_PageLoc, 1
RESERVE ScreenRight_PageLoc, 1

ScreenEdge_X_Pos := ScreenLeft_X_Pos
RESERVE ScreenLeft_X_Pos, 1
RESERVE ScreenRight_X_Pos, 1

RESERVE ColumnSets, 1
RESERVE AreaParserTaskNum, 1
RESERVE CurrentNTAddr_High, 1
RESERVE CurrentNTAddr_Low, 1
RESERVE Sprite0HitDetectFlag, 1
RESERVE ScrollLock, 2
RESERVE CurrentPageLoc, 1
RESERVE CurrentColumnPos, 1
RESERVE TerrainControl, 1
RESERVE BackloadingFlag, 1
RESERVE BehindAreaParserFlag, 1
RESERVE AreaObjectPageLoc, 1
RESERVE AreaObjectPageSel, 1 
RESERVE AreaDataOffset, 1
RESERVE AreaObjOffsetBuffer, 3
RESERVE AreaObjectLength, 3
RESERVE AreaStyle, 1
RESERVE StaircaseControl, 1
RESERVE AreaObjectHeight, 1
RESERVE MushroomLedgeHalfLen, 3
RESERVE EnemyDataOffset, 1
RESERVE EnemyObjectPageLoc, 1
RESERVE EnemyObjectPageSel, 1
RESERVE ScreenRoutineTask, 1
RESERVE ScrollThirtyTwo, 2
RESERVE HorizontalScroll, 1
RESERVE VerticalScroll, 1
RESERVE ForegroundScenery, 1
RESERVE BackgroundScenery, 1
RESERVE CloudTypeOverride, 1
RESERVE BackgroundColorCtrl, 1
RESERVE LoopCommand, 1
RESERVE StarFlagTaskControl, 1
RESERVE TimerControl, 1
RESERVE CoinTallyFor1Ups, 1
RESERVE SecondaryMsgCounter, 1

FirebarSpinDirection := DestinationPageLoc
RESERVE DestinationPageLoc, 1
RESERVE VictoryWalkControl, 5

; notes:
; AreaType:
; Water = 0
; Ground = 1
; UnderGround = 2
; Castle = 3
RESERVE AreaType, 1

RESERVE AreaAddrsLOffset, 1
RESERVE AreaPointer, 1
RESERVE EntrancePage, 1
RESERVE AltEntranceControl, 1
RESERVE CurrentPlayer, 1    ; 0 = mario, 1 = luigi
RESERVE PlayerSize, 1       ; 1 = small, 0 = big
RESERVE Player_Pos_ForScroll, 1
RESERVE PlayerStatus, 1     ; 0 = small, 1 = super, 2 = firey
RESERVE FetchNewGameTimerFlag, 1
RESERVE JoypadOverride, 1
RESERVE GameTimerExpiredFlag, 1

OnscreenPlayerInfo := NumberofLives
RESERVE NumberofLives, 1
RESERVE HalfwayPage, 1
RESERVE LevelNumber, 1
RESERVE Hidden1UpFlag, 1
RESERVE CoinTally, 1
RESERVE WorldNumber, 1
RESERVE AreaNumber, 1

OffscreenPlayerInfo := OffScr_NumberofLives
RESERVE OffScr_NumberofLives, 1
RESERVE OffScr_HalfwayPage, 1
RESERVE OffScr_LevelNumber, 1
RESERVE OffScr_Hidden1UpFlag, 1
RESERVE OffScr_CoinTally, 1
RESERVE OffScr_WorldNumber, 1
RESERVE OffScr_AreaNumber, 1


RESERVE ScrollFractional, 1
RESERVE DisableIntermediate, 1
RESERVE PrimaryHardMode, 1
RESERVE WorldSelectNumber, 1

; $0770: .proc InitializeGame leaves ram below here alone ( y = $6f )

RESERVE OperMode, 2
RESERVE OperMode_Task, 1
RESERVE VRAM_Buffer_AddrCtrl, 1
RESERVE DisableScreenFlag, 1
RESERVE ScrollAmount, 1
RESERVE GamePauseStatus, 1
RESERVE GamePauseTimer, 1
RESERVE Mirror_PPUCTRL, 1
RESERVE Mirror_PPUMASK, 1
RESERVE NumberOfPlayers, 1

RESERVE IntervalTimerControl, 1

Timers := SelectTimer
RESERVE SelectTimer, 1
RESERVE PlayerAnimTimer, 1
RESERVE JumpSwimTimer, 1
RESERVE RunningTimer, 1
RESERVE BlockBounceTimer, 1
RESERVE SideCollisionTimer, 1
RESERVE JumpspringTimer, 1
RESERVE GameTimerCtrlTimer, 2
RESERVE ClimbSideTimer, 1
RESERVE EnemyFrameTimer, 5
RESERVE FrenzyEnemyTimer, 1
RESERVE BowserFireBreathTimer, 1
RESERVE StompTimer, 1
RESERVE AirBubbleTimer, 3

FRAME_TIMER_COUNT = AirBubbleTimer - Timers

RESERVE ScrollIntervalTimer, 1
RESERVE EnemyIntervalTimer, 7
RESERVE BrickCoinTimer, 1
RESERVE InjuryTimer, 1
RESERVE StarInvincibleTimer, 1
RESERVE ScreenTimer, 1
RESERVE WorldEndTimer, 1
RESERVE DemoTimer, 1

ALL_TIMER_COUNT = DemoTimer - Timers

RESERVE PseudoRandomBitReg, 9

RESERVE TopScoreDisplay, 6
RESERVE Player1ScoreDisplay, 6
RESERVE Player2ScoreDisplay, 6
RESERVE Player1CoinDisplay, 2
RESERVE Player2CoinDisplay, 2
RESERVE GameTimerDisplay, 3

DisplayDigits := TopScoreDisplay
PlayerScoreDisplay := Player1ScoreDisplay
ScoreAndCoinDisplay := Player1ScoreDisplay

TopScoreLastIndex = 5
PlayerScoreLastIndex = 5
PlayerCoinLastIndex = 1
GameTimerLastIndex = 2

RESERVE WorldSelectEnableFlag, 1

RESERVE ContinueWorld, 1

_ColdBootOffset = WarmBootValidation

.if DEBUG_WORLD_SELECT
RESERVE DebugCooldown, 1
.endif

RESERVE WarmBootValidation, 1

.popseg
