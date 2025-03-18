.ifndef DRIVER_BHOP_S
.define DRIVER_BHOP_S

.include "bhop/bhop.inc"

.pushseg
.segment "SHORTRAM"
RESERVE BhopMusicPause, 1
RESERVE BhopTempo, 2
.popseg


.define MUSIC_PATH "audio/famitracker"
.define MUSIC_PROJECT_NAME "sample_songs"

.macro DriverMusicInit
  lda #.bank(bhop_music_data) | BANK_ADJUST
  jsr bhop_set_module_bank
  lda #0
  sta BhopMusicPause
  ldx #<bhop_music_data
  ldy #>bhop_music_data
  jsr BHOP::bhop_init
.endmacro

.macro DriverMusicPlay song
.if .match(song, a)
  ; Nothing
.elseif .match(song, x)
  txa
.elseif .match(song, y)
  tya
.else
  .if (.match (.left (1, {song}), #))
    lda #.right (.tcount ({song})-1, {song})
  .else
    lda song
  .endif
.endif
  ldx #<bhop_music_data
  ldy #>bhop_music_data
  jsr BHOP::bhop_init
  lda #0
  sta BhopMusicPause
.endmacro
.macro DriverMusicStop
  ; lda #1
  ; sta BhopMusicPause
  DriverMusicPause
.endmacro

.macro DriverMusicPause
.scope

  jsr bhop_pause
  ; lda BHOP::tempo
  ; sta BhopTempo
  ; lda #0
  ; sta BHOP::tempo
  ; jsr MuteChannels
  ; sta BHOP::channel_status + BHOP::PULSE_2_INDEX
  ; sta BHOP::channel_status + BHOP::TRIANGLE_INDEX
  ; sta BHOP::channel_status + BHOP::NOISE_INDEX
  ; sta BHOP::channel_status + BHOP::DPCM_INDEX
.endscope
.endmacro

.macro DriverMusicUnpause
.scope
  jsr bhop_unpause
.endscope
.endmacro

.macro DriverMusicUpdate
  ; lda BhopMusicPause
  ; bne :+
    ; BankPRGA #.bank(bhop_music_data)
    jsr BHOP::bhop_play
  ; :
.endmacro

.macro DriverSpeedUpAudio
  ; unimplemented
.endmacro

.macro DriverSFXPlay sfx, chan
  ; unimplemented
.endmacro

.if USE_VANILLA_SFX

.macro DriverMusicMixAudio
.scope
  ; check which channels are playing sound effects and mute them
  lda BhopMusicPause
  bne @skippause
  ldy #4-1
@loop:
    lda Square1SoundBuffer,y
    beq @unmute
    tya
    jsr bhop_mute_channel
    jmp @next
@unmute:
    tya
    jsr bhop_unmute_channel
@next:
    dey
    bpl @loop
@skippause:

.endscope
.endmacro

.endif

.define BHOP_PLAYER_SEGMENT "FIXED"
.define BHOP_RAM_SEGMENT "SRAM"
.define BHOP_ZP_SEGMENT "MUSIC_ZEROPAGE_OVERLAY"

.proc bhop_apply_music_bank
  BankPRGA a
  rts
.endproc
.proc bhop_apply_dpcm_bank
  BankPRGC a
  rts
.endproc

.pushseg
.include "bhop.s"
.segment "MUSIC"
bhop_music_data:
  .include .sprintf("%s/%s.asm", MUSIC_PATH, MUSIC_PROJECT_NAME)
  .export bhop_music_data
.popseg
.endif