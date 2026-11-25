

.segment "FIXED"

.pushseg
.segment "SHORTRAM"
AUDIO_RAM_START = *
RESERVE EventMusicBuffer, 1
RESERVE AreaMusicBuffer, 1
RESERVE AreaMusicBuffer_Alt, 1
RESERVE Square1SoundBuffer, 1
RESERVE Square2SoundBuffer, 1
RESERVE TriangleSoundBuffer, 1 ; Newly added
RESERVE NoiseSoundBuffer, 1
AUDIO_RAM_END = *

.segment "BSS"

RESERVE PauseModeFlag, 1

.popseg



.if ::USE_SMB2J_FEATURES
.include "vanilla_music_smb2j.s"

.elseif ::USE_VANILLA_MUSIC
.include "vanilla_music.s"

.else

.if ::USE_VANILLA_SFX
.include "vanilla_sfx.s"
.endif

.if ::USE_VANILLA_MUSIC = 0

.proc CustomMusicLoopCallback
  lda #1
  sta MusicLooped
  rts
.endproc

.if ::USE_FAMISTUDIO_MUSIC
.include "driver_famistudio.s"
.include "custom_music.s"
.endif

.if ::USE_BHOP_MUSIC
.include "driver_bhop.s"
.include "custom_music.s"
.endif

.endif ; ::USE_VANILLA_MUSIC = 0

.endif


.proc AudioInit
  lda #0
  sta PauseModeFlag
  ldy #AUDIO_RAM_END - AUDIO_RAM_START - 1
:   sta AUDIO_RAM_START,y     ;clear out memory used
    dey                       ;by the sound engines
    bpl :-
  lda CurrentBank
  pha
    MusicInit
    SFXInit
  pla
  BankPRGA a
  rts
.endproc

.proc AudioClear
  MusicClear
  rts
.endproc

.proc AudioUpdate
  lda CurrentBank
  pha
    SFXPlayback

  .if ::USE_VANILLA_SFX = 1 && ::USE_VANILLA_MUSIC <> 1
    .if ::USE_FAMISTUDIO_MUSIC
      MusicPlayback
      DriverMusicMixAudio
    .elseif ::USE_BHOP_MUSIC
      DriverMusicMixAudio
      MusicPlayback
    .endif
  .else
    MusicPlayback
  .endif

  pla
  BankPRGA a
  rts
.endproc