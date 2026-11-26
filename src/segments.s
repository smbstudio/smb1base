; Memory map and segment layout. This replaces the old ld65 config.
; Included once from entrypoint.s, right after options.s.

; RAM
.segment "ZEROPAGE"  :mem $0000 :size $0100 :zp
.segment "SHORTRAM"  :mem $0100 :size $0100 :bss
.segment "OAM"       :mem $0200 :size $0100 :bss
.segment "BSS"       :mem $0300 :size $0500 :bss
; Exclude user save data from all engine SRAM allocations.
.segment "SRAM"      :mem $6000 + USER_SRAM_SIZE :size $2000 - USER_SRAM_SIZE :bss
; Give audio its own segment so its actual SRAM use can be checked at link time.
.segment "AUDIO_SRAM" :load "SRAM" :bss :define
; The audio driver ZP shares the NMI temps at $00. This has to be its own RAM segment because
; a :load segment can't be placed on top of bytes that ZEROPAGE already hands out.
.segment "MUSIC_ZEROPAGE_OVERLAY" :mem $00 :size $10 :zp

; ROM - file offset = $10 + bank * $2000
.segment "INESHDR" :mem $0000 :size $10 :off $00000 :fill $00 :out
.segment "PRGA_00" :bank $00 :mem $a000 :size $2000 :off $00010 :fill $ff :out
.segment "PRGA_01" :bank $01 :mem $a000 :size $2000 :off $02010 :fill $ff :out
.segment "PRGA_02" :bank $02 :mem $a000 :size $2000 :off $04010 :fill $ff :out
.segment "PRGA_03" :bank $03 :mem $a000 :size $2000 :off $06010 :fill $ff :out
.segment "PRGA_04" :bank $04 :mem $a000 :size $2000 :off $08010 :fill $ff :out
.segment "PRGA_05" :bank $05 :mem $a000 :size $2000 :off $0a010 :fill $ff :out
.segment "PRGA_06" :bank $06 :mem $a000 :size $2000 :off $0c010 :fill $ff :out
.segment "PRGA_07" :bank $07 :mem $a000 :size $2000 :off $0e010 :fill $ff :out
.segment "PRGA_08" :bank $08 :mem $a000 :size $2000 :off $10010 :fill $ff :out
.segment "PRGA_09" :bank $09 :mem $a000 :size $2000 :off $12010 :fill $ff :out
.segment "PRGA_0a" :bank $0a :mem $a000 :size $2000 :off $14010 :fill $ff :out
.segment "PRGA_0b" :bank $0b :mem $a000 :size $2000 :off $16010 :fill $ff :out
; $C000 banks hold DPCM samples at the start and the custom audio driver at the end.
.segment "PRGC_00" :bank $0c :mem $c000 :size $2000 :off $18010 :fill $ff :out
.segment "PRGC_01" :bank $0d :mem $c000 :size $2000 :off $1a010 :fill $ff :out
.segment "PRGLow"  :bank $0e :mem $8000 :size $2000 :off $1c010 :fill $ff :out
; The fixed bank is one segment so that .org $e000 can pin the timing sensitive joypad code to the start of the page
.segment "FIXED"   :bank $0f :mem $e000 :size $2000 :off $1e010 :fill $ff :out
.segment "CHR"                :mem $0000 :size $10000 :off $20010 :fill $00 :out

; Logical segments
; User created code defaults to the first A0 bank
.segment "OBJECT"     :load "PRGA_00"
; Extra bank for object code since the first one is almost full
.segment "OBJECT_EX"  :load "PRGA_07"
.segment "PLAYER"     :load "PRGA_01"
.segment "SMCCODE"    :load "PRGA_01" :run "SHORTRAM" :define
.segment "LEVEL"      :load "PRGA_02"
.segment "TITLE"      :load "PRGA_03"
.segment "RENDER"     :load "PRGA_03"
.segment "METASPRITE" :load "PRGA_04"

; Famitracker Music Segments
.segment "MUSIC"      :load "PRGA_05" :define

; Famistudio Music Segments. Change the bank here to move a song to a different bank.
.segment "MUSIC_overworld" :load "PRGA_05" :define
.segment "MUSIC_underworld" :load "PRGA_05" :define
.segment "MUSIC_waterworld" :load "PRGA_05" :define
.segment "MUSIC_castleworld" :load "PRGA_05" :define
.segment "MUSIC_cloud" :load "PRGA_05" :define
.segment "MUSIC_enter_in_a_pipe" :load "PRGA_06" :define
.segment "MUSIC_starman" :load "PRGA_06" :define
.segment "MUSIC_death" :load "PRGA_06" :define
.segment "MUSIC_game_over" :load "PRGA_06" :define
.segment "MUSIC_you_saved_the_princess" :load "PRGA_06" :define
.segment "MUSIC_in_an_other_castle" :load "PRGA_06" :define
.segment "MUSIC_victory" :load "PRGA_06" :define
.segment "MUSIC_hurry_up" :load "PRGA_06" :define
.segment "MUSIC_new_song" :load "PRGA_06" :define

.segment "CODE"       :load "PRGLow"
.segment "LOWCODE"    :load "PRGLow"
.segment "COLLISION"  :load "PRGLow"


; DPCM samples go at the start of each $c000 bank.
; When adding a DPCM bank, add a PRGC_xx area and a DPCM_BANKn segment here, and add it to the AUDIODRV list below.
.segment "DPCM_BANK0" :load "PRGC_00" :mem $c000
.segment "DPCM_BANK1" :load "PRGC_01" :mem $c000
; Custom audio driver. The linker places one identical copy in each DPCM bank at the same address,
; since the driver must stay mapped while the DPCM banks are switched.
.segment "AUDIODRV" :mirror {"PRGC_00", "PRGC_01"}
