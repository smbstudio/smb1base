
.ifndef __CONSTANTS_INC
__CONSTANTS_INC = 1

;-------------------------------------------------------------------------------------
;DEFINES

;NES specific hardware defines

PPUCTRL               = $2000
PPUMASK               = $2001
PPUSTATUS             = $2002
OAMADDR               = $2003
OAMDATA               = $2004
PPUSCROLL             = $2005
PPUADDR               = $2006
PPUDATA               = $2007

SND_REGISTER          = $4000
SND_SQUARE1_REG       = $4000
SND_SQUARE2_REG       = $4004
SND_TRIANGLE_REG      = $4008
SND_NOISE_REG         = $400c
SND_DELTA_REG         = $4010
SND_MASTERCTRL_REG    = $4015

OAM                   = $02
OAM_DMA               = $4014
JOYPAD_PORT           = $4016
JOYPAD_PORT1          = $4016
JOYPAD_PORT2          = $4017
APU_FRAMECOUNTER      = $4017

OAM_FLIP_V            = %10000000
OAM_FLIP_H            = %01000000
OAM_BACKGROUND_PRIORTY= %00100000
OAM_PALLETE_0         = %00000000
OAM_PALLETE_1         = %00000001
OAM_PALLETE_2         = %00000010
OAM_PALLETE_3         = %00000011

;-------------------------------------------------------------------------------------
;CONSTANTS

;sound effects constants
Sfx_SmallJump         = %10000000
Sfx_Flagpole          = %01000000
Sfx_Fireball          = %00100000
Sfx_PipeDown_Injury   = %00010000
Sfx_EnemySmack        = %00001000
Sfx_EnemyStomp        = %00000100
Sfx_Bump              = %00000010
Sfx_BigJump           = %00000001

Sfx_BowserFall        = %10000000
Sfx_ExtraLife         = %01000000
Sfx_PowerUpGrab       = %00100000
Sfx_TimerTick         = %00010000
Sfx_Blast             = %00001000
Sfx_GrowVine          = %00000100
Sfx_GrowPowerUp       = %00000010
Sfx_CoinGrab          = %00000001

Sfx_BowserFlame       = %00000010
Sfx_BrickShatter      = %00000001

;music constants
Silence               = %10000000

StarPowerMusic        = %01000000
PipeIntroMusic        = %00100000
CloudMusic            = %00010000
CastleMusic           = %00001000
UndergroundMusic      = %00000100
WaterMusic            = %00000010
GroundMusic           = %00000001

TimeRunningOutMusic   = %01000000
EndOfLevelMusic       = %00100000
AltGameOverMusic      = %00010000
EndOfCastleMusic      = %00001000
VictoryMusic          = %00000100
GameOverMusic         = %00000010
DeathMusic            = %00000001

;enemy object constants 
GreenKoopa            = $00
BuzzyBeetle           = $02
RedKoopa              = $03
HammerBro             = $05
Goomba                = $06
Bloober               = $07
BulletBill_FrenzyVar  = $08
GreyCheepCheep        = $0a
RedCheepCheep         = $0b
Podoboo               = $0c
PiranhaPlant          = $0d
GreenParatroopaJump   = $0e
RedParatroopa         = $0f
GreenParatroopaFly    = $10
Lakitu                = $11
Spiny                 = $12
FlyCheepCheepFrenzy   = $14
FlyingCheepCheep      = $14
BowserFlame           = $15
Fireworks             = $16
BBill_CCheep_Frenzy   = $17
Stop_Frenzy           = $18
Bowser                = $2d
PowerUpObject         = $2e
VineObject            = $2f
FlagpoleFlagObject    = $30
StarFlagObject        = $31
JumpspringObject      = $32
BulletBill_CannonVar  = $33
RetainerObject        = $35
TallEnemy             = $09
; powerup constants
PowerMushroom = $00
FireFlower    = $01
PowerStar     = $02
OneupMushroom = $03

; CHR rom tile constants. PPU address to be specific

.if MAPPER_MMC5
CHR_BG_WATER = $00
CHR_BG_GROUND = CHR_BG_WATER + $04
CHR_BG_UNDERGROUND = CHR_BG_GROUND + $04
CHR_BG_CASTLE = CHR_BG_UNDERGROUND + $04
CHR_BIGMARIO = CHR_BG_CASTLE + $04
CHR_MARIOACTION = CHR_BIGMARIO + $01
CHR_SMALLMARIO = CHR_MARIOACTION + $01
CHR_SMALLFIRE = CHR_SMALLMARIO + $01
CHR_MISC = CHR_SMALLFIRE + $01
CHR_SPRITES = CHR_MISC + $01
.else
; For Mappers without the additional 8kb sprite window, we need to have additional area specific sprites
CHR_BG_WATER = $00
CHR_BG_GROUND = CHR_BG_WATER + $04
CHR_BG_UNDERGROUND = CHR_BG_GROUND + $04
CHR_BG_CASTLE = CHR_BG_UNDERGROUND + $04
CHR_BIGMARIO = CHR_BG_CASTLE + $04
CHR_MARIOACTION = CHR_BIGMARIO + $01
CHR_SMALLMARIO = CHR_MARIOACTION + $01
CHR_SMALLFIRE = CHR_SMALLMARIO + $01
CHR_MISC = CHR_SMALLFIRE + $01
CHR_SPR_WATER = CHR_MISC + $01
CHR_SPR_GROUND = CHR_SPR_WATER + $02
CHR_SPR_UNDERGROUND = CHR_SPR_GROUND + $02
CHR_SPR_CASTLE = CHR_SPR_UNDERGROUND + $02
.endif

; Metatile constants
.global BUSH_LEFT_METATILE
.global BUSH_MIDDLE_METATILE
.global BUSH_RIGHT_METATILE
.global BUSH_TOPLEFT_METATILE
.global BUSH_TOPMIDDLE_METATILE

.global MOUNTAIN_MIDLEFT_METATILE
.global MOUNTAIN_MIDMID_METATILE
.global MOUNTAIN_MIDTOP_METATILE
.global MOUNTAIN_MIDRIGHT_METATILE
.global MOUNTAIN_BOTRIGHT_METATILE
.global MOUNTAIN_BOTMID_METATILE
.global MOUNTAIN_TOPRIGHT_METATILE

.global CRACKED_BRICK_NONSOLID
.global CLOUD_MT
.global CRACKED_BRICK_METATILE
.global CRACKED_BRICK_METATILE2
.global BRIDGE_MT

MUSHROOM_BOX_METATILE   = $c0
FIREFLOWER_BOX_METATILE = $c1


.enum
  World1
  World2
  World3
  World4
  World5
  World6
  World7
  World8
.endenum

.enum
  Level1
  Level2
  Level3
  Level4
.endenum

.enum
  MODE_TITLESCREEN
  MODE_GAMEPLAY
  MODE_VICTORY
  MODE_GAMEOVER
.endenum


WarmBootOffset        = <DisplayDigits
ColdBootOffset        = <WarmBootValidation


A_Button              = %10000000
B_Button              = %01000000
Select_Button         = %00100000
Start_Button          = %00010000
Up_Dir                = %00001000
Down_Dir              = %00000100
Left_Dir              = %00000010
Right_Dir             = %00000001

.endif ;__CONSTANTS_INC
