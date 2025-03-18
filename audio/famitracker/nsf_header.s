;
; NSF Header
;
.import __FTR_FILEOFFS__
NSF2_SIZE = __FTR_FILEOFFS__


.segment "HEADER1"
.byte $4E, $45, $53, $4D, $1A	; ID
.byte $01						; Version
.byte $0E							; Number of songs
.byte $01							; Start song
.word LOAD						; LOAD address
.word INIT						; INIT address
.word PLAY						; PLAY address

.segment "HEADER2"
.byte ""	; Name, 32 bytes

.segment "HEADER3"
.byte ""	; Artist, 32 bytes

.segment "HEADER4"
.byte ""	; Copyright, 32 bytes

.segment "HEADER5"
.word $411A						; NTSC speed
.byte $00, $00, $00, $00, $00, $00, $00, $00	; Bank values
.word $4E20						; PAL speed
.byte $00						; Region flags
.byte EXPANSION_FLAG			; Expansion audio flags
.byte $00						; NSF2 flags
.faraddr NSF2_SIZE				; NSF data length
