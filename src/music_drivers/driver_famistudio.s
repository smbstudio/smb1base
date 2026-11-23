.ifndef DRIVER_FAMISTUDIO_S
.define DRIVER_FAMISTUDIO_S


; INSTRUCTIONS FOR FAMISTUDIO AUDIO

; When exporting the data you must export it twice.
; Once as a combine project and once as separate files.
; This allows us to bank include the files in such a way that the DPCM samples
; are banked independantly from the songs, and we can have as much of each as we want.

; When exporting the project, do NOT change the file name pattern in the export window
; Make sure you export both times using the same project name and the same folder.

; If everything fits into one bank, then all you need to do is edit the lines below
; to use the correct path and project name (you choose these when exporting from famistudio)

; IMPORTANT: When you export the single file song data, famistudio will show a log that
; contains a list of settings that you MUST configure in order for the engine to work.
; Replace whatever settings you find in the `build_options.ini` under the `CUSTOM AUDIO CONFIGURATION`
; section with all of the required settings that famistudio export requires.

; NOTE: If you are using more than one bank for music, then you will need to update the `smb1base.cfg` linker script
; Inside you will find a list of lines that look something like
; MUSIC_overworld:    load = PRGA_05 .....
;
; This `PRGA_05` determines what bank the song is in. All you need to do is move some songs over to new banks in order
; to get it to work. So for this example, you can move it to PRGA_06 to free up song space in PRGA_05
; MUSIC_overworld:    load = PRGA_06 .....

; NOTE: When using DPCM bank switching, you must set the banks that you want each sample 
; to go to in the famistudio editor. After that, you may need to add new DPCM_BANK(n) lines to the
; linker script (smb1base.cfg). When you do this, do NOT edit the `MEMORY` section unless you know what
; you are doing. Instead, just change the SEGMENT section and add another DPCM_BANK there as needed.
; These must be numbered from 0..n and be in consecutive PRGC banks, since each DPCM bank also holds
; a copy of the driver code.
; Also, you need to set the build_option DPCM_BANK_COUNT to the number of banks you are using.

.define MUSIC_PATH "audio/examples/famistudio"
.define MUSIC_PROJECT_NAME "disco_mario"

; Space reserved at the end of every DPCM bank for the driver code. The rest of the 8kb bank is for samples.
; Raise this if the linker reports an overflow in PRGC_00_DRV, lower it if the samples overflow PRGC_00.
.export AUDIO_DRIVER_SIZE = $900


;;;
; NOTICE:
; Try to avoid editing below this line if possible :)

.pushseg
.segment "SHORTRAM"
RESERVE ReloadChannel, 2

.popseg

.ifdef MMC5_PRG_ROM
BANK_ADJUST .set $80
.endif


.macro DriverMusicInit
  ; Normally we would init the song here, but to support banked music data, we split the songs into their own
  ; files, and each of those need to be initialized independently.
  BankPRGA #.bank(music_data_overworld_start)
  ldx #<music_data_overworld_start
  ldy #>music_data_overworld_start
  lda #0
  jsr famistudio_init
.if ::USE_VANILLA_SFX
  lda #1
  sta ReloadChannel+0
  sta ReloadChannel+1
.endif
.endmacro

.if ::USE_CUSTOM_ENGINE_SFX
.macro SFXInit
  BankPRGA #.bank(sfx_data)
  ldx #<sfx_data
  ldy #>sfx_data
  jsr famistudio_sfx_init
.endmacro
.endif

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
  ; Load the data pointer into x/y and bank switch to the correct A bank
  tax
  ldy music_data_hi_table,x
  lda music_data_bank_table,x
  BankPRGA a
  sta MusicBank
  lda music_data_lo_table,x
  tax
  ; Use NTSC playback speed and then reinit + start the song
  lda #0
  jsr famistudio_init
  lda #0
  jsr famistudio_music_play
.endmacro

.macro DriverMusicStop
  jsr famistudio_music_stop
.endmacro

.macro DriverMusicPause
  lda #1
  jsr famistudio_music_pause
.endmacro

.macro DriverMusicUnpause
  lda #0
  jsr famistudio_music_pause
.endmacro

.macro DriverMusicUpdate
  BankPRGA MusicBank
  jsr famistudio_update
.endmacro

.macro DriverSpeedUpAudio
  ; TODO figure this out if we want to support it
.endmacro

.if ::USE_CUSTOM_ENGINE_SFX

.macro DriverSFXPlay sfx, chan
.if .match(sfx, a)
  ; Nothing
.elseif .match(sfx, x)
  txa
.elseif .match(sfx, y)
  tya
.else
  .if (.match (.left (1, {sfx}), #))
    lda #.right (.tcount ({sfx})-1, {sfx})
  .else
    lda sfx
  .endif
.endif

.local Channel
.ifblank chan
Channel = 0
.else
Channel = chan
.endif

.if Channel = 0
  ldx #FAMISTUDIO_SFX_CH0
.elseif Channel = 1
  ldx #FAMISTUDIO_SFX_CH1
.elseif Channel = 2
  ldx #FAMISTUDIO_SFX_CH2
.else
  .error "Using unknown SFX channel"
.endif
  jsr famistudio_sfx_play
.endmacro

.macro DriverSFXUpdate

.endmacro

.endif ; USE_CUSTOM_ENGINE_SFX



; Setup FAMISTUDIO config stuff
; The user is expected to provide the exported values in the 

FAMISTUDIO_CFG_EXTERNAL = 1
; The exported song files check this, so it needs a value when not using C
.ifndef FAMISTUDIO_CFG_C_BINDINGS
FAMISTUDIO_CFG_C_BINDINGS = 0
.endif

.define FAMISTUDIO_CA65_ZP_SEGMENT   MUSIC_ZEROPAGE_OVERLAY
.define FAMISTUDIO_CA65_RAM_SEGMENT  SRAM
.define FAMISTUDIO_CA65_CODE_SEGMENT AUDIODRV

.if ::USE_CUSTOM_ENGINE_SFX
FAMISTUDIO_CFG_SFX_SUPPORT = 1
FAMISTUDIO_CFG_SFX_STREAMS = 3
.endif

.global famistudio_dpcm_bank_callback
.proc famistudio_dpcm_bank_callback
  clc
  adc #.bank(DPCM_BANK0) | BANK_ADJUST
  BankPRGC a
  rts
.endproc

.include "famistudio_ca65.s"

; Custom table listing song pointers and what bank they are in

.define MUSIC_LIST \
  "overworld", \
  "underworld", \
  "waterworld", \
  "castleworld", \
  "cloud", \
  "enter_in_a_pipe", \
  "starman", \
  "death", \
  "game_over", \
  "you_saved_the_princess", \
  "in_an_other_castle", \
  "victory", \
  "hurry_up"
  ; "new_song"

BANK_ADJUST .set $00
.define MUSIC_TABLE_OP .lobyte
music_data_lo_table:
  music_table MUSIC_LIST

.undefine MUSIC_TABLE_OP
.define MUSIC_TABLE_OP .hibyte
music_data_hi_table:
  music_table MUSIC_LIST

music_data_bank_table:
.ifdef MMC5_PRG_ROM
BANK_ADJUST .set $80
.endif
.undefine MUSIC_TABLE_OP
.define MUSIC_TABLE_OP .bank
  music_table MUSIC_LIST

.pushseg
; music_include MUSIC_LIST

; very annoyingly, i can't put this in a loop :/

.segment .concat("MUSIC_", "overworld")
.ident(.sprintf("music_data_%s_start", "overworld")):
.include .sprintf("%s/%s_%s.s", MUSIC_PATH, MUSIC_PROJECT_NAME, "overworld")

.segment .concat("MUSIC_", "underworld")
.ident(.sprintf("music_data_%s_start", "underworld")):
.include .sprintf("%s/%s_%s.s", MUSIC_PATH, MUSIC_PROJECT_NAME, "underworld")

.segment .concat("MUSIC_", "waterworld")
.ident(.sprintf("music_data_%s_start", "waterworld")):
.include .sprintf("%s/%s_%s.s", MUSIC_PATH, MUSIC_PROJECT_NAME, "waterworld")

.segment .concat("MUSIC_", "castleworld")
.ident(.sprintf("music_data_%s_start", "castleworld")):
.include .sprintf("%s/%s_%s.s", MUSIC_PATH, MUSIC_PROJECT_NAME, "castleworld")

.segment .concat("MUSIC_", "cloud")
.ident(.sprintf("music_data_%s_start", "cloud")):
.include .sprintf("%s/%s_%s.s", MUSIC_PATH, MUSIC_PROJECT_NAME, "cloud")

.segment .concat("MUSIC_", "enter_in_a_pipe")
.ident(.sprintf("music_data_%s_start", "enter_in_a_pipe")):
.include .sprintf("%s/%s_%s.s", MUSIC_PATH, MUSIC_PROJECT_NAME, "enter_in_a_pipe")

.segment .concat("MUSIC_", "starman")
.ident(.sprintf("music_data_%s_start", "starman")):
.include .sprintf("%s/%s_%s.s", MUSIC_PATH, MUSIC_PROJECT_NAME, "starman")

.segment .concat("MUSIC_", "death")
.ident(.sprintf("music_data_%s_start", "death")):
.include .sprintf("%s/%s_%s.s", MUSIC_PATH, MUSIC_PROJECT_NAME, "death")

.segment .concat("MUSIC_", "game_over")
.ident(.sprintf("music_data_%s_start", "game_over")):
.include .sprintf("%s/%s_%s.s", MUSIC_PATH, MUSIC_PROJECT_NAME, "game_over")

.segment .concat("MUSIC_", "you_saved_the_princess")
.ident(.sprintf("music_data_%s_start", "you_saved_the_princess")):
.include .sprintf("%s/%s_%s.s", MUSIC_PATH, MUSIC_PROJECT_NAME, "you_saved_the_princess")

.segment .concat("MUSIC_", "in_an_other_castle")
.ident(.sprintf("music_data_%s_start", "in_an_other_castle")):
.include .sprintf("%s/%s_%s.s", MUSIC_PATH, MUSIC_PROJECT_NAME, "in_an_other_castle")

.segment .concat("MUSIC_", "victory")
.ident(.sprintf("music_data_%s_start", "victory")):
.include .sprintf("%s/%s_%s.s", MUSIC_PATH, MUSIC_PROJECT_NAME, "victory")

.segment .concat("MUSIC_", "hurry_up")
.ident(.sprintf("music_data_%s_start", "hurry_up")):
.include .sprintf("%s/%s_%s.s", MUSIC_PATH, MUSIC_PROJECT_NAME, "hurry_up")

.if ::USE_CUSTOM_ENGINE_SFX
sfx_data:
.include .sprintf("%s/%s_%s.s", MUSIC_PATH, MUSIC_PROJECT_NAME, "sfx")
.endif

.if DPCM_BANK_COUNT > 1
.segment .concat("DPCM_BANK", .string(0))
.incbin .sprintf("%s/%s_bank%d.dmc", MUSIC_PATH, MUSIC_PROJECT_NAME, 0)

.segment .concat("DPCM_BANK", .string(1))
.incbin .sprintf("%s/%s_bank%d.dmc", MUSIC_PATH, MUSIC_PROJECT_NAME, 1)
.else
; Not using banked dpcm, so just load without the bank tag at the end
.segment .concat("DPCM_BANK", .string(0))
.incbin .sprintf("%s/%s.dmc", MUSIC_PATH, MUSIC_PROJECT_NAME)

.endif

.if DPCM_BANK_COUNT > 2
.segment .concat("DPCM_BANK", .string(2))
.incbin .sprintf("%s/%s_bank%d.dmc", MUSIC_PATH, MUSIC_PROJECT_NAME, 2)
.endif

.popseg

.endif
 
; ======================================================================================================================
; SMBStudio:
; Mix Famistudio output with the vanilla sfx output

.if USE_VANILLA_SFX

.macro DriverMusicMixAudio
.scope
  ; if bit 7 (paused) then don't mix any audio
  ; lda famistudio_song_speed
  ; bpl :+
  ;   rts
  ; :
  ; load the data from the famistudio output buffer
  lda Square1SoundBuffer
  beq @music_pulse1_upd
    lda #1
    sta ReloadChannel+0
    jmp @no_pulse1_upd

@music_pulse1_upd:
    lda famistudio_output_buf      ; Pulse 1 volume
    sta FAMISTUDIO_APU_PL1_VOL
    lda #$08
    sta FAMISTUDIO_APU_PL1_SWEEP
    lda famistudio_output_buf+1    ; Pulse 1 period LSB
    sta FAMISTUDIO_APU_PL1_LO
    lda famistudio_output_buf+2    ; Pulse 1 period MSB, only applied when changed
    ldx ReloadChannel+0
    bne @force_update1
      cmp famistudio_pulse1_prev
      beq @no_pulse1_upd
@force_update1:
        sta famistudio_pulse1_prev
        sta FAMISTUDIO_APU_PL1_HI
        lda #0
        sta ReloadChannel+0

@no_pulse1_upd:
  lda Square2SoundBuffer
  beq @music_pulse2_upd
    lda #1
    sta ReloadChannel+1
    jmp @no_pulse2_upd

@music_pulse2_upd:
    lda famistudio_output_buf+3    ; Pulse 2 volume
    sta FAMISTUDIO_APU_PL2_VOL
    lda #$08    ; Pulse 2 Sweep
    sta FAMISTUDIO_APU_PL2_SWEEP
    lda famistudio_output_buf+4    ; Pulse 2 period LSB
    sta FAMISTUDIO_APU_PL2_LO
    lda famistudio_output_buf+5    ; Pulse 2 period MSB, only applied when changed
    ldx ReloadChannel+1
    bne @force_update2
      cmp famistudio_pulse2_prev
      beq @no_pulse2_upd
@force_update2:
        sta famistudio_pulse2_prev
        sta FAMISTUDIO_APU_PL2_HI
        lda #0
        sta ReloadChannel+1
@no_pulse2_upd:
    ; No triangle used in vanilla sfx
    lda famistudio_output_buf+6    ; Triangle volume (plays or not)
    sta FAMISTUDIO_APU_TRI_LINEAR
    lda famistudio_output_buf+7    ; Triangle period LSB
    sta FAMISTUDIO_APU_TRI_LO
    lda famistudio_output_buf+8    ; Triangle period MSB
    sta FAMISTUDIO_APU_TRI_HI

  lda NoiseSoundBuffer
  bne @no_noise_upd
@music_noise_upd:
    lda famistudio_output_buf+9    ; Noise volume
    sta FAMISTUDIO_APU_NOISE_VOL
    lda famistudio_output_buf+10   ; Noise period
    sta FAMISTUDIO_APU_NOISE_LO

@no_noise_upd:
.endscope
.endmacro

.endif
