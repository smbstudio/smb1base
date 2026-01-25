
.segment "FIXED"

.pushseg
.segment "SHORTRAM"
RESERVE MusicLooped, 1
RESERVE MusicBank, 1
.popseg

.macro MusicInit
  DriverMusicInit
  lda #0
  sta MusicLooped
  sta MusicBank
.endmacro

.macro MusicClear
  DriverMusicStop
.endmacro

.macro MusicPlayback
  CustomMusicEngine
.endmacro

.if .not ::USE_VANILLA_SFX
.macro SFXPlayback
  BankPRGA #.bank(sfx_data)
  CustomSfxEngine
.endmacro
.endif


; Data used to convert from the SMB1 queue to a regular driver

Overworld = $00 ; : Overworld
Underworld = $01 ; : Underworld
Waterworld = $02 ; : Waterworld
Castleworld = $03 ; : Castleworld
Cloud = $04 ; : Cloud
EnterPipe = $05 ; : Enter in a pipe
Starman = $06 ; : Starman
Death = $07 ; : Death
GameOver = $08 ; : Game Over
SavedPrincess = $09 ; : You saved the princess
InAnotherCastle = $0a ; : In an other castle
Victory = $0b ; : Victory
HurryUp = $0c ; : Hurry up
Intermediate = $0d ; : Intermediate
SilenceTrack = -1


AreaMusicLUT:
  .byte Overworld, Underworld, Waterworld, Castleworld, Cloud, EnterPipe, Starman, SilenceTrack

EventMusicLUT:
  .byte SilenceTrack, HurryUp, Victory, Waterworld, InAnotherCastle, SavedPrincess, GameOver, Death

; LeadingBitLookup:
; .repeat 256,I
; HI_BIT .set 8
; .repeat 8, J
; .if HI_BIT = 8 .and (I & (1 << (7 - J))) <> 0
; HI_BIT .set J
; .endif
; .endrepeat
;   .byte HI_BIT
; .endrepeat

.proc FindMostSigBit
  txa
  ldy #$ff
  sec
  :
    iny
    rol
    bcc :-
  rts
.endproc


.macro CustomMusicEngine
.scope
  lda PauseModeFlag         ;is sound already in pause mode?
  bne InPause
    lda PauseSoundQueue       ;if not, check pause sfx queue
    beq RunSoundSubroutines   ;if queue is empty, skip pause mode routine
    bne PerformPause
InPause:
  ; Check if the Pause is just starting to change
  lda GamePauseTimer
  cmp #1
  beq FinishedPauseTimer
  cmp #$2b
  jne SkipToUpdate
PerformPause:
    lda PauseSoundQueue       ;check pause queue
    cmp #2
    beq UnPause
      ; DriverMusicPause Macro
      DriverMusicPause
      
      lda #0
      sta PauseSoundQueue
      lda #1
      sta PauseModeFlag         ;pause mode to interrupt game sounds
.if ::USE_CUSTOM_ENGINE_SFX
      DriverSFXPlay #Pause
.endif
      jmp SkipToUpdate
UnPause:
  lda #0
  ; sta PauseModeFlag
  sta PauseSoundQueue
  .if ::USE_CUSTOM_ENGINE_SFX
    DriverSFXPlay #Pause
  .endif

  jmp RunSoundSubroutines
FinishedPauseTimer:
  lda PauseModeFlag
  cmp #1
  beq FirstTimePause
SecondTimePause:
    lda #0
    sta PauseModeFlag ; unpause
    ; DriverMusicUnpause Macro
    DriverMusicUnpause
    jmp RunSoundSubroutines
FirstTimePause:
  inc PauseModeFlag
  jmp RunSoundSubroutines

MusicLoopBack:
  DriverSpeedUpAudio
  ldx AreaMusicBuffer_Alt
  stx AreaMusicBuffer
  jmp FindAreaMusic

RunSoundSubroutines:
  ; First check if the music has just looped
  lda MusicLooped
  beq NotTRO
    lda EventMusicBuffer
    ldx #0
    stx EventMusicBuffer
    stx MusicLooped
    cmp #TimeRunningOutMusic
    bne NotTRO
      ; It was a hurry up time warning, so restart the alt music
      lda AreaMusicBuffer_Alt  ;load previously saved contents of primary buffer
      bne MusicLoopBack        ;and start playing the song again if there is one
NotTRO:
  lda EventMusicQueue
  ora AreaMusicQueue
  beq SkipToUpdate
    ldx AreaMusicQueue
    beq SkipAreaProcessing
      lda #0
      sta AreaMusicQueue
      stx AreaMusicBuffer
FindAreaMusic:
      ; jsr FindMostSigBit
      lda AreaMusicLUT, x
SkipAreaProcessing:
    ldx EventMusicQueue
    beq PlayNewSong
      lda AreaMusicBuffer
      sta AreaMusicBuffer_Alt   ;save current area music buffer to be re-obtained later
      ; Music from EventMusicQueue will override the AreaMusicQueue
      stx EventMusicBuffer
      lda #0
      sta AreaMusicBuffer
      sta EventMusicQueue
      jsr FindMostSigBit
      lda EventMusicLUT, y
PlayNewSong:
  cmp #SilenceTrack
  beq StopMusic
    ; Macro DriverMusicPlay a
    DriverMusicPlay a
    jmp SkipToUpdate
StopMusic:
  ; Macro DriverMusicStop
  DriverMusicStop

;   jmp SkipAreaProcessing

SkipToUpdate:

  ; Macro DriverMusicUpdate
  DriverMusicUpdate

.endscope
.endmacro

.if ::USE_CUSTOM_ENGINE_SFX


OneUp =       0
BigJump =     1
Blast =       2
BowserFall =  3
BrickBreak =  4
Bump =        5
Coin =        6
EnemySmack =  7
Stomp_Swim =  8
FireBreath =  9
Fireball =    10
Flagpole =    11
GrowUp =      12
SpawnPup =    13
Injure_Pipe = 14
Pause =       15
SmallJump =   16
TimerTick =   17
Vine =        18

Sq2SfxTable:
  .byte BowserFall
  .byte OneUp     
  .byte GrowUp    
  .byte TimerTick 
  .byte Blast     
  .byte Vine      
  .byte SpawnPup  
  .byte Coin      

Sq1SfxTable:
  .byte SmallJump  
  .byte Flagpole   
  .byte Fireball   
  .byte Injure_Pipe     
  .byte EnemySmack 
  .byte Stomp_Swim 
  .byte Bump       
  .byte BigJump    

NoiseSfxTable:
  .byte $00        
  .byte $00        
  .byte $00        
  .byte $00        
  .byte $00        
  .byte Pause      
  .byte FireBreath 
  .byte BrickBreak


.macro CustomSfxEngine
.scope
  lda OperMode
  jeq SkipToUpdate
  lda PauseModeFlag         ;is sound already in pause mode?
  jne SkipToUpdate

RunSoundSubroutines:
  ; Now check for sound effects
  ldx Square2SoundQueue
  beq :+
    jsr FindMostSigBit
    lda Sq2SfxTable,y
    ; DriverSFXPlay a, 0 Macro
    DriverSFXPlay a, 0
    lda #0
    sta Square2SoundQueue
  :
  ldx Square1SoundQueue
  beq :+
    jsr FindMostSigBit
    lda Sq1SfxTable,y
    ; DriverSFXPlay a, 1 Macro
    DriverSFXPlay a, 1
    lda #0
    sta Square1SoundQueue
  :
  ldx NoiseSoundQueue
  beq :+
    jsr FindMostSigBit
    lda NoiseSfxTable,y
    ; DriverSFXPlay a, 2 Macro
    DriverSFXPlay a, 2
    lda #0
    sta NoiseSoundQueue
  :
  
SkipToUpdate:
  DriverSFXUpdate

.endscope
.endmacro
.endif ; USE_CUSTOM_ENGINE_SFX
