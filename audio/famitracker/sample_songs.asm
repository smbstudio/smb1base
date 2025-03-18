; Dn-FamiTracker exported music data: sample_songs.ftm
;

; Module header
	.word ft_song_list
	.word ft_instrument_list
	.word ft_sample_list
	.word ft_samples
	.word ft_groove_list
	.byte 0 ; flags
	.word 3600 ; NTSC speed
	.word 3000 ; PAL speed

; Instrument pointer list
ft_instrument_list:
	.word ft_inst_0
	.word ft_inst_1
	.word ft_inst_2
	.word ft_inst_3
	.word ft_inst_4
	.word ft_inst_5
	.word ft_inst_6
	.word ft_inst_7
	.word ft_inst_8
	.word ft_inst_9
	.word ft_inst_10
	.word ft_inst_11
	.word ft_inst_12
	.word ft_inst_13

; Instruments
ft_inst_0:
	.byte 0
	.byte $01
	.word ft_seq_2a03_45

ft_inst_1:
	.byte 0
	.byte $01
	.word ft_seq_2a03_5

ft_inst_2:
	.byte 0
	.byte $03
	.word ft_seq_2a03_10
	.word ft_seq_2a03_6

ft_inst_3:
	.byte 0
	.byte $03
	.word ft_seq_2a03_15
	.word ft_seq_2a03_6

ft_inst_4:
	.byte 0
	.byte $03
	.word ft_seq_2a03_15
	.word ft_seq_2a03_11

ft_inst_5:
	.byte 0
	.byte $11
	.word ft_seq_2a03_40
	.word ft_seq_2a03_9

ft_inst_6:
	.byte 0
	.byte $11
	.word ft_seq_2a03_0
	.word ft_seq_2a03_9

ft_inst_7:
	.byte 0
	.byte $11
	.word ft_seq_2a03_20
	.word ft_seq_2a03_4

ft_inst_8:
	.byte 0
	.byte $11
	.word ft_seq_2a03_50
	.word ft_seq_2a03_9

ft_inst_9:
	.byte 0
	.byte $11
	.word ft_seq_2a03_25
	.word ft_seq_2a03_9

ft_inst_10:
	.byte 0
	.byte $11
	.word ft_seq_2a03_55
	.word ft_seq_2a03_14

ft_inst_11:
	.byte 0
	.byte $11
	.word ft_seq_2a03_50
	.word ft_seq_2a03_14

ft_inst_12:
	.byte 0
	.byte $11
	.word ft_seq_2a03_60
	.word ft_seq_2a03_19

ft_inst_13:
	.byte 0
	.byte $11
	.word ft_seq_2a03_65
	.word ft_seq_2a03_29

; Sequences
ft_seq_2a03_0:
	.byte $09, $FF, $00, $00, $00, $08, $07, $06, $05, $05, $04, $04, $00
ft_seq_2a03_4:
	.byte $02, $FF, $00, $00, $00, $02
ft_seq_2a03_5:
	.byte $09, $FF, $00, $00, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $00
ft_seq_2a03_6:
	.byte $01, $00, $00, $01, $0C
ft_seq_2a03_9:
	.byte $01, $FF, $00, $00, $02
ft_seq_2a03_10:
	.byte $06, $FF, $00, $00, $0C, $0C, $0C, $0C, $0C, $00
ft_seq_2a03_11:
	.byte $01, $00, $00, $01, $03
ft_seq_2a03_14:
	.byte $01, $FF, $00, $00, $01
ft_seq_2a03_15:
	.byte $02, $FF, $00, $00, $0C, $00
ft_seq_2a03_19:
	.byte $02, $FF, $00, $00, $00, $01
ft_seq_2a03_20:
	.byte $29, $FF, $00, $00, $05, $03, $04, $05, $05, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
	.byte $06, $06, $06, $06, $06, $06, $05, $05, $05, $05, $05, $05, $04, $04, $04, $04, $04, $04, $03, $03
	.byte $03, $02, $02, $01, $00
ft_seq_2a03_25:
	.byte $05, $FF, $00, $00, $00, $0B, $0A, $09, $08
ft_seq_2a03_29:
	.byte $02, $FF, $02, $00, $00, $02
ft_seq_2a03_40:
	.byte $0C, $FF, $00, $00, $0E, $0D, $0B, $0A, $09, $07, $06, $05, $03, $02, $01, $00
ft_seq_2a03_45:
	.byte $01, $FF, $00, $00, $0F
ft_seq_2a03_50:
	.byte $1D, $FF, $00, $00, $05, $0A, $09, $09, $08, $08, $07, $06, $06, $05, $05, $04, $04, $04, $04, $04
	.byte $04, $04, $04, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03
ft_seq_2a03_55:
	.byte $0A, $FF, $00, $00, $0E, $0D, $0C, $0A, $09, $08, $06, $05, $04, $03
ft_seq_2a03_60:
	.byte $4D, $FF, $00, $00, $0F, $0B, $0B, $0B, $08, $05, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	.byte $04, $04, $04, $04, $04, $04, $04, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $02, $02
	.byte $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	.byte $02, $02, $02, $02, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	.byte $00
ft_seq_2a03_65:
	.byte $2A, $FF, $2A, $00, $0F, $0D, $0D, $0C, $0C, $0B, $0B, $0A, $0A, $0A, $09, $09, $09, $09, $09, $08
	.byte $08, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06, $06, $05, $05, $05, $05, $05, $04, $04, $04
	.byte $04, $04, $03, $03, $03, $02

; DPCM instrument list (pitch, sample index)
ft_sample_list:

; DPCM samples list (location, size, bank)
ft_samples:

; Groove list
ft_groove_list:
	.byte $00
; Grooves (size, terms)

; Song pointer list
ft_song_list:
	.word ft_song_0
	.word ft_song_1
	.word ft_song_2
	.word ft_song_3
	.word ft_song_4
	.word ft_song_5
	.word ft_song_6
	.word ft_song_7
	.word ft_song_8
	.word ft_song_9
	.word ft_song_10
	.word ft_song_11
	.word ft_song_12
	.word ft_song_13

; Song info
ft_song_0:
	.word ft_s0_frames
	.byte 22	; frame count
	.byte 64	; pattern length
	.byte 5	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte <.bank(ft_s0_frames)	; initial bank

ft_song_1:
	.word ft_s1_frames
	.byte 3	; frame count
	.byte 128	; pattern length
	.byte 3	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte <.bank(ft_s1_frames)	; initial bank

ft_song_2:
	.word ft_s2_frames
	.byte 17	; frame count
	.byte 128	; pattern length
	.byte 3	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte <.bank(ft_s2_frames)	; initial bank

ft_song_3:
	.word ft_s3_frames
	.byte 9	; frame count
	.byte 64	; pattern length
	.byte 7	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte <.bank(ft_s3_frames)	; initial bank

ft_song_4:
	.word ft_s4_frames
	.byte 2	; frame count
	.byte 48	; pattern length
	.byte 2	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte <.bank(ft_s4_frames)	; initial bank

ft_song_5:
	.word ft_s5_frames
	.byte 1	; frame count
	.byte 48	; pattern length
	.byte 3	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte <.bank(ft_s5_frames)	; initial bank

ft_song_6:
	.word ft_s6_frames
	.byte 5	; frame count
	.byte 64	; pattern length
	.byte 3	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte <.bank(ft_s6_frames)	; initial bank

ft_song_7:
	.word ft_s7_frames
	.byte 2	; frame count
	.byte 45	; pattern length
	.byte 3	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte <.bank(ft_s7_frames)	; initial bank

ft_song_8:
	.word ft_s8_frames
	.byte 1	; frame count
	.byte 75	; pattern length
	.byte 3	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte <.bank(ft_s8_frames)	; initial bank

ft_song_9:
	.word ft_s9_frames
	.byte 12	; frame count
	.byte 64	; pattern length
	.byte 4	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte <.bank(ft_s9_frames)	; initial bank

ft_song_10:
	.word ft_s10_frames
	.byte 1	; frame count
	.byte 96	; pattern length
	.byte 4	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte <.bank(ft_s10_frames)	; initial bank

ft_song_11:
	.word ft_s11_frames
	.byte 1	; frame count
	.byte 96	; pattern length
	.byte 4	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte <.bank(ft_s11_frames)	; initial bank

ft_song_12:
	.word ft_s12_frames
	.byte 1	; frame count
	.byte 56	; pattern length
	.byte 3	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte <.bank(ft_s12_frames)	; initial bank

ft_song_13:
	.word ft_s13_frames
	.byte 3	; frame count
	.byte 128	; pattern length
	.byte 2	; speed
	.byte 150	; tempo
	.byte 0	; groove position
	.byte <.bank(ft_s13_frames)	; initial bank


;
; Pattern and frame data for all songs below
;

ft_s0_frames:
	.word ft_s0f0
	.word ft_s0f1
	.word ft_s0f2
	.word ft_s0f3
	.word ft_s0f4
	.word ft_s0f5
	.word ft_s0f6
	.word ft_s0f7
	.word ft_s0f8
	.word ft_s0f9
	.word ft_s0f10
	.word ft_s0f11
	.word ft_s0f12
	.word ft_s0f13
	.word ft_s0f14
	.word ft_s0f15
	.word ft_s0f16
	.word ft_s0f17
	.word ft_s0f18
	.word ft_s0f19
	.word ft_s0f20
	.word ft_s0f21
ft_s0f0:
	.word ft_s0p0c0, ft_s0p0c1, ft_s0p0c2, ft_s0p0c3, ft_s0p0c4
	.byte <.bank(ft_s0p0c0), <.bank(ft_s0p0c1), <.bank(ft_s0p0c2), <.bank(ft_s0p0c3), <.bank(ft_s0p0c4)
ft_s0f1:
	.word ft_s0p1c0, ft_s0p1c1, ft_s0p1c2, ft_s0p1c3, ft_s0p0c4
	.byte <.bank(ft_s0p1c0), <.bank(ft_s0p1c1), <.bank(ft_s0p1c2), <.bank(ft_s0p1c3), <.bank(ft_s0p0c4)
ft_s0f2:
	.word ft_s0p2c0, ft_s0p2c1, ft_s0p2c2, ft_s0p2c3, ft_s0p0c4
	.byte <.bank(ft_s0p2c0), <.bank(ft_s0p2c1), <.bank(ft_s0p2c2), <.bank(ft_s0p2c3), <.bank(ft_s0p0c4)
ft_s0f3:
	.word ft_s0p4c0, ft_s0p3c1, ft_s0p0c2, ft_s0p2c3, ft_s0p0c4
	.byte <.bank(ft_s0p4c0), <.bank(ft_s0p3c1), <.bank(ft_s0p0c2), <.bank(ft_s0p2c3), <.bank(ft_s0p0c4)
ft_s0f4:
	.word ft_s0p3c0, ft_s0p4c1, ft_s0p2c2, ft_s0p2c3, ft_s0p0c4
	.byte <.bank(ft_s0p3c0), <.bank(ft_s0p4c1), <.bank(ft_s0p2c2), <.bank(ft_s0p2c3), <.bank(ft_s0p0c4)
ft_s0f5:
	.word ft_s0p4c0, ft_s0p5c1, ft_s0p0c2, ft_s0p2c3, ft_s0p0c4
	.byte <.bank(ft_s0p4c0), <.bank(ft_s0p5c1), <.bank(ft_s0p0c2), <.bank(ft_s0p2c3), <.bank(ft_s0p0c4)
ft_s0f6:
	.word ft_s0p5c0, ft_s0p6c1, ft_s0p2c2, ft_s0p3c3, ft_s0p0c4
	.byte <.bank(ft_s0p5c0), <.bank(ft_s0p6c1), <.bank(ft_s0p2c2), <.bank(ft_s0p3c3), <.bank(ft_s0p0c4)
ft_s0f7:
	.word ft_s0p6c0, ft_s0p7c1, ft_s0p0c2, ft_s0p3c3, ft_s0p0c4
	.byte <.bank(ft_s0p6c0), <.bank(ft_s0p7c1), <.bank(ft_s0p0c2), <.bank(ft_s0p3c3), <.bank(ft_s0p0c4)
ft_s0f8:
	.word ft_s0p7c0, ft_s0p8c1, ft_s0p2c2, ft_s0p3c3, ft_s0p0c4
	.byte <.bank(ft_s0p7c0), <.bank(ft_s0p8c1), <.bank(ft_s0p2c2), <.bank(ft_s0p3c3), <.bank(ft_s0p0c4)
ft_s0f9:
	.word ft_s0p8c0, ft_s0p9c1, ft_s0p4c2, ft_s0p4c3, ft_s0p0c4
	.byte <.bank(ft_s0p8c0), <.bank(ft_s0p9c1), <.bank(ft_s0p4c2), <.bank(ft_s0p4c3), <.bank(ft_s0p0c4)
ft_s0f10:
	.word ft_s0p9c0, ft_s0p10c1, ft_s0p4c2, ft_s0p1c3, ft_s0p0c4
	.byte <.bank(ft_s0p9c0), <.bank(ft_s0p10c1), <.bank(ft_s0p4c2), <.bank(ft_s0p1c3), <.bank(ft_s0p0c4)
ft_s0f11:
	.word ft_s0p0c0, ft_s0p10c1, ft_s0p4c2, ft_s0p5c3, ft_s0p0c4
	.byte <.bank(ft_s0p0c0), <.bank(ft_s0p10c1), <.bank(ft_s0p4c2), <.bank(ft_s0p5c3), <.bank(ft_s0p0c4)
ft_s0f12:
	.word ft_s0p10c0, ft_s0p11c1, ft_s0p4c2, ft_s0p5c3, ft_s0p0c4
	.byte <.bank(ft_s0p10c0), <.bank(ft_s0p11c1), <.bank(ft_s0p4c2), <.bank(ft_s0p5c3), <.bank(ft_s0p0c4)
ft_s0f13:
	.word ft_s0p11c0, ft_s0p11c1, ft_s0p4c2, ft_s0p5c3, ft_s0p0c4
	.byte <.bank(ft_s0p11c0), <.bank(ft_s0p11c1), <.bank(ft_s0p4c2), <.bank(ft_s0p5c3), <.bank(ft_s0p0c4)
ft_s0f14:
	.word ft_s0p12c0, ft_s0p11c1, ft_s0p4c2, ft_s0p5c3, ft_s0p0c4
	.byte <.bank(ft_s0p12c0), <.bank(ft_s0p11c1), <.bank(ft_s0p4c2), <.bank(ft_s0p5c3), <.bank(ft_s0p0c4)
ft_s0f15:
	.word ft_s0p13c0, ft_s0p11c1, ft_s0p4c2, ft_s0p5c3, ft_s0p0c4
	.byte <.bank(ft_s0p13c0), <.bank(ft_s0p11c1), <.bank(ft_s0p4c2), <.bank(ft_s0p5c3), <.bank(ft_s0p0c4)
ft_s0f16:
	.word ft_s0p14c0, ft_s0p11c1, ft_s0p4c2, ft_s0p5c3, ft_s0p0c4
	.byte <.bank(ft_s0p14c0), <.bank(ft_s0p11c1), <.bank(ft_s0p4c2), <.bank(ft_s0p5c3), <.bank(ft_s0p0c4)
ft_s0f17:
	.word ft_s0p15c0, ft_s0p11c1, ft_s0p4c2, ft_s0p5c3, ft_s0p0c4
	.byte <.bank(ft_s0p15c0), <.bank(ft_s0p11c1), <.bank(ft_s0p4c2), <.bank(ft_s0p5c3), <.bank(ft_s0p0c4)
ft_s0f18:
	.word ft_s0p14c0, ft_s0p11c1, ft_s0p4c2, ft_s0p5c3, ft_s0p0c4
	.byte <.bank(ft_s0p14c0), <.bank(ft_s0p11c1), <.bank(ft_s0p4c2), <.bank(ft_s0p5c3), <.bank(ft_s0p0c4)
ft_s0f19:
	.word ft_s0p15c0, ft_s0p11c1, ft_s0p4c2, ft_s0p5c3, ft_s0p0c4
	.byte <.bank(ft_s0p15c0), <.bank(ft_s0p11c1), <.bank(ft_s0p4c2), <.bank(ft_s0p5c3), <.bank(ft_s0p0c4)
ft_s0f20:
	.word ft_s0p14c0, ft_s0p11c1, ft_s0p4c2, ft_s0p5c3, ft_s0p0c4
	.byte <.bank(ft_s0p14c0), <.bank(ft_s0p11c1), <.bank(ft_s0p4c2), <.bank(ft_s0p5c3), <.bank(ft_s0p0c4)
ft_s0f21:
	.word ft_s0p15c0, ft_s0p11c1, ft_s0p4c2, ft_s0p5c3, ft_s0p0c4
	.byte <.bank(ft_s0p15c0), <.bank(ft_s0p11c1), <.bank(ft_s0p4c2), <.bank(ft_s0p5c3), <.bank(ft_s0p0c4)
ft_s0p0c0:
	.byte $82, $01, $E6, $31, $25, $30, $24, $2E, $22, $2B, $1F, $2C, $20, $2E, $22, $30, $24, $2B, $1F, $2C
	.byte $20, $2E, $22, $2B, $1F, $2C, $20, $2E, $22, $30, $24, $31, $25, $33, $83, $27, $01

ft_s0p0c1:
	.byte $82, $03, $E6, $38, $3A, $3C, $3A, $38, $83, $35, $01, $38, $03, $33, $01, $35, $01, $33, $01, $38
	.byte $03, $3A, $01, $3A, $01, $3C, $03, $3A, $01, $38, $0B, $33, $01, $35, $01, $33, $01

ft_s0p0c2:
	.byte $82, $01, $E1, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C
	.byte $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $83, $2C, $01

ft_s0p0c3:
	.byte $82, $01, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D
	.byte $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D
	.byte $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D
	.byte $E3, $1D, $E4, $1D, $83, $E3, $1D, $01

ft_s0p0c4:
	.byte $00, $3F

ft_s0p1c0:
	.byte $82, $01, $E6, $2C, $20, $2E, $22, $30, $24, $2E, $22, $2C, $20, $2E, $22, $30, $24, $2E, $22, $83
	.byte $2C, $00, $20, $00, $2E, $01, $30, $00, $24, $00, $2E, $01, $2C, $00, $20, $00, $2E, $01, $30, $00
	.byte $24, $00, $2E, $11

ft_s0p1c1:
	.byte $82, $03, $E6, $38, $3A, $3C, $3A, $38, $83, $35, $01, $38, $03, $33, $01, $35, $01, $33, $01, $38
	.byte $02, $22, $00, $37, $01, $37, $00, $22, $00, $38, $02, $22, $00, $37, $01, $38, $00, $22, $10

ft_s0p1c2:
	.byte $82, $01, $E1, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C
	.byte $2C, $2C, $2C, $2C, $2C, $2C, $2C, $83, $2C, $0F

ft_s0p1c3:
	.byte $82, $01, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D
	.byte $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D
	.byte $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $1D, $1D, $E2, $1D, $E3, $1D
	.byte $E2, $1D, $83, $1D, $01

ft_s0p2c0:
	.byte $E6, $33, $0B, $31, $01, $33, $0D, $31, $03, $33, $03, $33, $03, $33, $01, $33, $03, $35, $0B, $2C
	.byte $01, $2E, $03

ft_s0p2c1:
	.byte $E6, $3F, $0B, $3D, $01, $3F, $0D, $3D, $03, $3F, $03, $3F, $03, $3F, $01, $3F, $03, $41, $0B, $38
	.byte $01, $3A, $03

ft_s0p2c2:
	.byte $82, $01, $E1, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31
	.byte $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $83, $31, $01

ft_s0p2c3:
	.byte $82, $01, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D
	.byte $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D
	.byte $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D
	.byte $E3, $1D, $E2, $1D, $83, $E3, $1D, $01

ft_s0p3c0:
	.byte $E6, $33, $0B, $31, $01, $33, $0B, $82, $01, $30, $31, $32, $33, $83, $33, $03, $33, $01, $33, $03
	.byte $33, $01, $35, $0B, $2C, $01, $2E, $01, $2F, $01

ft_s0p3c1:
	.byte $82, $03, $E6, $3C, $3A, $38, $35, $83, $3C, $01, $3A, $03, $38, $09, $3C, $03, $3A, $03, $38, $03
	.byte $3A, $01, $3C, $09, $38, $03, $3C, $03

ft_s0p3c3:
	.byte $E2, $1D, $03, $E3, $1D, $01, $E4, $1D, $01, $1D, $03, $E3, $1D, $01, $E4, $1D, $01, $1D, $03, $E3
	.byte $1D, $01, $E4, $1D, $01, $1D, $03, $E3, $1D, $01, $1D, $01, $E2, $1D, $03, $E3, $1D, $01, $E4, $1D
	.byte $01, $1D, $03, $E3, $1D, $01, $E4, $1D, $01, $1D, $03, $E3, $1D, $01, $E4, $1D, $01, $1D, $03, $E3
	.byte $1D, $01, $E4, $1D, $01

ft_s0p4c0:
	.byte $82, $01, $E6, $29, $35, $27, $24, $83, $27, $03, $29, $03, $82, $01, $29, $35, $27, $24, $83, $27
	.byte $03, $29, $03, $82, $01, $29, $35, $27, $24, $83, $27, $03, $29, $03, $29, $01, $35, $01, $24, $03
	.byte $24, $03, $27, $03

ft_s0p4c1:
	.byte $E6, $3F, $0B, $3D, $01, $3F, $0B, $82, $01, $3C, $3D, $3E, $3F, $83, $3F, $03, $3F, $01, $3F, $03
	.byte $3F, $01, $41, $0B, $38, $01, $3A, $01, $3B, $01

ft_s0p4c2:
	.byte $82, $01, $E1, $29, $29, $29, $29, $29, $29, $29, $29, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $2C, $31
	.byte $31, $31, $31, $31, $31, $31, $31, $30, $30, $30, $30, $27, $27, $27, $83, $27, $01

ft_s0p4c3:
	.byte $E2, $1D, $03, $E3, $1D, $01, $E4, $1D, $01, $1D, $03, $E3, $1D, $01, $E4, $1D, $01, $1D, $03, $E3
	.byte $1D, $01, $E4, $1D, $01, $1D, $03, $E3, $1D, $01, $1D, $01, $E2, $1D, $03, $E3, $1D, $01, $1D, $01
	.byte $E2, $1D, $03, $E3, $1D, $01, $1D, $01, $E4, $1D, $03, $1D, $03, $1D, $01, $E2, $1D, $01, $1D, $03

ft_s0p5c0:
	.byte $82, $0F, $E6, $25, $27, $29, $83, $24, $0F

ft_s0p5c1:
	.byte $E6, $3F, $03, $3F, $03, $82, $01, $3F, $3F, $3D, $3C, $3A, $83, $3C, $03, $38, $07, $3C, $01, $3C
	.byte $01, $82, $03, $3A, $38, $35, $3C, $3A, $38, $35, $83, $3A, $01

ft_s0p5c3:
	.byte $82, $01, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D
	.byte $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D
	.byte $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D
	.byte $E2, $1D, $1D, $83, $E3, $1D, $01

ft_s0p6c0:
	.byte $82, $0F, $E6, $24, $2C, $29, $83, $27, $0F

ft_s0p6c1:
	.byte $E6, $3C, $07, $33, $01, $35, $01, $38, $03, $33, $01, $35, $01, $38, $03, $33, $01, $35, $01, $38
	.byte $0B, $82, $01, $33, $35, $38, $33, $33, $35, $83, $38, $03, $33, $01, $38, $03, $33, $01

ft_s0p7c0:
	.byte $82, $0F, $E6, $2C, $2E, $2E, $83, $2B, $0F

ft_s0p7c1:
	.byte $E6, $3A, $01, $3A, $01, $3A, $03, $38, $03, $38, $01, $38, $01, $37, $01, $37, $03, $38, $07, $33
	.byte $01, $3A, $01, $3A, $01, $3A, $03, $38, $03, $38, $01, $38, $01, $37, $01, $37, $03, $38, $09

ft_s0p8c0:
	.byte $E6, $2B, $0F, $30, $0F, $2B, $0F, $37, $01, $37, $03, $38, $07, $30, $01

ft_s0p8c1:
	.byte $00, $07, $E6, $33, $01, $35, $01, $38, $03, $33, $01, $35, $01, $38, $03, $33, $01, $35, $01, $38
	.byte $03, $33, $01, $35, $01, $38, $03, $82, $01, $33, $35, $38, $33, $33, $35, $83, $38, $03, $33, $01
	.byte $38, $03, $33, $01

ft_s0p9c0:
	.byte $82, $01, $E6, $2C, $20, $2E, $22, $30, $24, $2E, $22, $2C, $20, $2E, $22, $30, $24, $2E, $22, $2C
	.byte $20, $2E, $22, $30, $24, $2E, $22, $2C, $20, $2E, $22, $30, $24, $2E, $83, $22, $01

ft_s0p9c1:
	.byte $E6, $3A, $01, $3A, $01, $3A, $03, $38, $03, $38, $01, $38, $01, $37, $01, $37, $03, $38, $07, $82
	.byte $01, $33, $3A, $3A, $3A, $3A, $38, $83, $38, $05, $82, $01, $3C, $35, $3A, $33, $3C, $35, $3F, $83
	.byte $38, $01

ft_s0p10c0:
	.byte $E6, $29, $0D, $82, $03, $29, $27, $24, $22, $83, $20, $01, $29, $01, $29, $05, $29, $01, $82, $03
	.byte $29, $29, $27, $24, $22, $83, $24, $01

ft_s0p10c1:
	.byte $E6, $3C, $0D, $82, $03, $3C, $3A, $38, $35, $83, $33, $01, $3C, $01, $3C, $05, $3C, $01, $82, $03
	.byte $3C, $3C, $38, $3A, $35, $83, $30, $01

ft_s0p11c0:
	.byte $E6, $29, $0D, $82, $03, $29, $27, $24, $22, $83, $20, $01, $29, $01, $29, $05, $29, $01, $82, $03
	.byte $29, $29, $24, $35, $83, $33, $01, $24, $03

ft_s0p11c1:
	.byte $E6, $35, $01, $35, $01, $35, $03, $35, $03, $33, $01, $30, $01, $38, $03, $35, $09, $30, $01, $35
	.byte $01, $35, $01, $35, $03, $35, $03, $33, $01, $30, $01, $38, $03, $35, $09, $30, $01

ft_s0p12c0:
	.byte $E6, $2C, $0D, $2B, $05, $29, $05, $27, $05, $29, $0D, $82, $03, $29, $27, $24, $22, $83, $20, $01

ft_s0p13c0:
	.byte $E6, $2C, $0D, $2B, $05, $29, $05, $27, $05, $29, $0D, $29, $03, $24, $03, $35, $03, $33, $01, $24
	.byte $03

ft_s0p14c0:
	.byte $E6, $2C, $07, $2C, $05, $2C, $03, $29, $03, $2C, $03, $27, $01, $29, $01, $27, $01, $2C, $07, $2C
	.byte $05, $2C, $03, $29, $03, $2C, $03, $27, $01, $29, $01, $27, $01

ft_s0p15c0:
	.byte $E6, $2C, $07, $2C, $05, $2C, $03, $29, $03, $2C, $03, $27, $01, $29, $01, $27, $01, $2C, $07, $2C
	.byte $05, $29, $03, $27, $03, $24, $03, $27, $01, $20, $03

ft_s1_frames:
	.word ft_s1f0
	.word ft_s1f1
	.word ft_s1f2
ft_s1f0:
	.word ft_s1p0c0, ft_s1p0c1, ft_s1p0c2, ft_s1p0c3, ft_s1p0c4
	.byte <.bank(ft_s1p0c0), <.bank(ft_s1p0c1), <.bank(ft_s1p0c2), <.bank(ft_s1p0c3), <.bank(ft_s1p0c4)
ft_s1f1:
	.word ft_s1p0c0, ft_s1p0c1, ft_s1p0c2, ft_s1p0c3, ft_s1p0c4
	.byte <.bank(ft_s1p0c0), <.bank(ft_s1p0c1), <.bank(ft_s1p0c2), <.bank(ft_s1p0c3), <.bank(ft_s1p0c4)
ft_s1f2:
	.word ft_s1p1c0, ft_s1p1c1, ft_s1p1c2, ft_s1p1c3, ft_s1p0c4
	.byte <.bank(ft_s1p1c0), <.bank(ft_s1p1c1), <.bank(ft_s1p1c2), <.bank(ft_s1p1c3), <.bank(ft_s1p0c4)
ft_s1p0c0:
	.byte $E8, $25, $13, $28, $03, $27, $03, $25, $03, $21, $13, $28, $03, $27, $03, $25, $03, $23, $13, $27
	.byte $03, $25, $03, $23, $03, $20, $0F, $23, $07, $24, $07

ft_s1p0c1:
	.byte $E8, $31, $13, $34, $03, $33, $03, $31, $03, $2D, $13, $34, $03, $33, $03, $31, $03, $2F, $13, $33
	.byte $03, $31, $03, $2F, $03, $2C, $0F, $2F, $07, $30, $07

ft_s1p0c2:
	.byte $E1, $25, $03, $25, $01, $25, $01, $25, $03, $25, $01, $25, $01, $25, $03, $25, $01, $25, $01, $25
	.byte $03, $25, $01, $25, $01, $21, $03, $21, $01, $21, $01, $21, $03, $21, $01, $21, $01, $21, $03, $21
	.byte $01, $21, $01, $21, $03, $21, $01, $21, $01, $23, $03, $23, $01, $23, $01, $23, $03, $23, $01, $23
	.byte $01, $23, $03, $23, $01, $23, $01, $23, $03, $23, $01, $23, $01, $28, $03, $28, $01, $28, $01, $28
	.byte $03, $28, $01, $28, $01, $28, $03, $28, $01, $28, $01, $27, $03, $27, $01, $27, $01

ft_s1p0c3:
	.byte $E4, $1D, $03, $E3, $1D, $01, $1D, $01, $E2, $1D, $03, $E3, $1D, $01, $1D, $01, $E4, $1D, $03, $E3
	.byte $1D, $01, $1D, $01, $E2, $1D, $03, $E3, $1D, $01, $1D, $01, $E4, $1D, $03, $E3, $1D, $01, $1D, $01
	.byte $E2, $1D, $03, $E3, $1D, $01, $1D, $01, $E4, $1D, $03, $E3, $1D, $01, $1D, $01, $E2, $1D, $03, $E3
	.byte $1D, $01, $1D, $01, $E4, $1D, $03, $E3, $1D, $01, $1D, $01, $E2, $1D, $03, $E3, $1D, $01, $1D, $01
	.byte $E4, $1D, $03, $E3, $1D, $01, $1D, $01, $E2, $1D, $03, $E3, $1D, $01, $1D, $01, $E4, $1D, $03, $E3
	.byte $1D, $01, $1D, $01, $E2, $1D, $03, $E3, $1D, $01, $1D, $01, $E4, $1D, $03, $E3, $1D, $01, $1D, $01
	.byte $E2, $1D, $03, $E3, $1D, $01, $1D, $01

ft_s1p0c4:
	.byte $00, $7F

ft_s1p1c0:
	.byte $82, $03, $E8, $25, $28, $27, $28, $27, $25, $23, $21, $28, $27, $28, $2A, $2D, $2C, $2A, $28, $25
	.byte $28, $27, $28, $27, $25, $23, $21, $28, $27, $28, $2A, $2D, $2C, $2A, $83, $28, $03

ft_s1p1c1:
	.byte $82, $03, $E8, $31, $34, $33, $34, $33, $31, $2F, $2D, $34, $33, $34, $36, $39, $38, $36, $34, $31
	.byte $34, $33, $34, $33, $31, $2F, $2D, $34, $33, $34, $36, $39, $38, $36, $83, $34, $03

ft_s1p1c2:
	.byte $E1, $25, $03, $25, $01, $25, $01, $25, $03, $25, $01, $25, $01, $21, $03, $21, $01, $21, $01, $21
	.byte $03, $21, $01, $21, $01, $23, $03, $23, $01, $23, $01, $23, $03, $23, $01, $23, $01, $28, $03, $28
	.byte $01, $28, $01, $27, $03, $27, $01, $27, $01, $25, $03, $25, $01, $25, $01, $25, $03, $25, $01, $25
	.byte $01, $21, $03, $21, $01, $21, $01, $21, $03, $21, $01, $21, $01, $23, $03, $23, $01, $23, $01, $23
	.byte $03, $23, $01, $23, $01, $28, $03, $28, $01, $28, $01, $27, $03, $27, $01, $27, $01

ft_s1p1c3:
	.byte $E4, $1D, $03, $E3, $1D, $01, $1D, $01, $E4, $1D, $03, $E3, $1D, $01, $1D, $01, $E4, $1D, $03, $82
	.byte $01, $E3, $1D, $1D, $E2, $1D, $1D, $1D, $1D, $83, $E4, $1D, $03, $E3, $1D, $01, $1D, $01, $E4, $1D
	.byte $03, $E3, $1D, $01, $1D, $01, $E4, $1D, $03, $82, $01, $E3, $1D, $1D, $E2, $1D, $1D, $1D, $1D, $83
	.byte $E4, $1D, $03, $E3, $1D, $01, $1D, $01, $E4, $1D, $03, $E3, $1D, $01, $1D, $01, $E4, $1D, $03, $82
	.byte $01, $E3, $1D, $1D, $E2, $1D, $1D, $1D, $1D, $83, $E4, $1D, $03, $E3, $1D, $01, $1D, $01, $E4, $1D
	.byte $03, $E3, $1D, $01, $1D, $01, $E4, $1D, $03, $82, $01, $E3, $1D, $1D, $E2, $1D, $1D, $1D, $83, $1D
	.byte $01

ft_s2_frames:
	.word ft_s2f0
	.word ft_s2f1
	.word ft_s2f2
	.word ft_s2f3
	.word ft_s2f4
	.word ft_s2f5
	.word ft_s2f6
	.word ft_s2f7
	.word ft_s2f8
	.word ft_s2f9
	.word ft_s2f10
	.word ft_s2f11
	.word ft_s2f12
	.word ft_s2f13
	.word ft_s2f14
	.word ft_s2f15
	.word ft_s2f16
ft_s2f0:
	.word ft_s1p0c4, ft_s2p0c1, ft_s2p0c2, ft_s1p0c4, ft_s1p0c4
	.byte <.bank(ft_s1p0c4), <.bank(ft_s2p0c1), <.bank(ft_s2p0c2), <.bank(ft_s1p0c4), <.bank(ft_s1p0c4)
ft_s2f1:
	.word ft_s2p1c0, ft_s2p1c1, ft_s2p1c2, ft_s2p1c3, ft_s1p0c4
	.byte <.bank(ft_s2p1c0), <.bank(ft_s2p1c1), <.bank(ft_s2p1c2), <.bank(ft_s2p1c3), <.bank(ft_s1p0c4)
ft_s2f2:
	.word ft_s2p2c0, ft_s2p2c1, ft_s2p2c2, ft_s2p2c3, ft_s1p0c4
	.byte <.bank(ft_s2p2c0), <.bank(ft_s2p2c1), <.bank(ft_s2p2c2), <.bank(ft_s2p2c3), <.bank(ft_s1p0c4)
ft_s2f3:
	.word ft_s2p3c0, ft_s2p3c1, ft_s2p3c2, ft_s2p1c3, ft_s1p0c4
	.byte <.bank(ft_s2p3c0), <.bank(ft_s2p3c1), <.bank(ft_s2p3c2), <.bank(ft_s2p1c3), <.bank(ft_s1p0c4)
ft_s2f4:
	.word ft_s2p3c0, ft_s2p4c1, ft_s2p3c2, ft_s2p3c3, ft_s1p0c4
	.byte <.bank(ft_s2p3c0), <.bank(ft_s2p4c1), <.bank(ft_s2p3c2), <.bank(ft_s2p3c3), <.bank(ft_s1p0c4)
ft_s2f5:
	.word ft_s2p3c0, ft_s2p3c1, ft_s2p3c2, ft_s2p1c3, ft_s1p0c4
	.byte <.bank(ft_s2p3c0), <.bank(ft_s2p3c1), <.bank(ft_s2p3c2), <.bank(ft_s2p1c3), <.bank(ft_s1p0c4)
ft_s2f6:
	.word ft_s2p4c0, ft_s2p5c1, ft_s2p4c2, ft_s2p4c3, ft_s1p0c4
	.byte <.bank(ft_s2p4c0), <.bank(ft_s2p5c1), <.bank(ft_s2p4c2), <.bank(ft_s2p4c3), <.bank(ft_s1p0c4)
ft_s2f7:
	.word ft_s2p5c0, ft_s2p6c1, ft_s2p5c2, ft_s2p1c3, ft_s1p0c4
	.byte <.bank(ft_s2p5c0), <.bank(ft_s2p6c1), <.bank(ft_s2p5c2), <.bank(ft_s2p1c3), <.bank(ft_s1p0c4)
ft_s2f8:
	.word ft_s2p6c0, ft_s2p7c1, ft_s2p5c2, ft_s2p3c3, ft_s1p0c4
	.byte <.bank(ft_s2p6c0), <.bank(ft_s2p7c1), <.bank(ft_s2p5c2), <.bank(ft_s2p3c3), <.bank(ft_s1p0c4)
ft_s2f9:
	.word ft_s2p3c0, ft_s2p3c1, ft_s2p3c2, ft_s2p1c3, ft_s1p0c4
	.byte <.bank(ft_s2p3c0), <.bank(ft_s2p3c1), <.bank(ft_s2p3c2), <.bank(ft_s2p1c3), <.bank(ft_s1p0c4)
ft_s2f10:
	.word ft_s2p4c0, ft_s2p4c1, ft_s2p3c2, ft_s2p3c3, ft_s1p0c4
	.byte <.bank(ft_s2p4c0), <.bank(ft_s2p4c1), <.bank(ft_s2p3c2), <.bank(ft_s2p3c3), <.bank(ft_s1p0c4)
ft_s2f11:
	.word ft_s2p1c0, ft_s2p1c1, ft_s2p1c2, ft_s2p1c3, ft_s1p0c4
	.byte <.bank(ft_s2p1c0), <.bank(ft_s2p1c1), <.bank(ft_s2p1c2), <.bank(ft_s2p1c3), <.bank(ft_s1p0c4)
ft_s2f12:
	.word ft_s2p2c0, ft_s2p2c1, ft_s2p2c2, ft_s2p2c3, ft_s1p0c4
	.byte <.bank(ft_s2p2c0), <.bank(ft_s2p2c1), <.bank(ft_s2p2c2), <.bank(ft_s2p2c3), <.bank(ft_s1p0c4)
ft_s2f13:
	.word ft_s2p7c0, ft_s2p8c1, ft_s2p5c2, ft_s2p1c3, ft_s1p0c4
	.byte <.bank(ft_s2p7c0), <.bank(ft_s2p8c1), <.bank(ft_s2p5c2), <.bank(ft_s2p1c3), <.bank(ft_s1p0c4)
ft_s2f14:
	.word ft_s2p8c0, ft_s2p9c1, ft_s2p6c2, ft_s2p4c3, ft_s1p0c4
	.byte <.bank(ft_s2p8c0), <.bank(ft_s2p9c1), <.bank(ft_s2p6c2), <.bank(ft_s2p4c3), <.bank(ft_s1p0c4)
ft_s2f15:
	.word ft_s2p3c0, ft_s2p3c1, ft_s2p3c2, ft_s2p1c3, ft_s1p0c4
	.byte <.bank(ft_s2p3c0), <.bank(ft_s2p3c1), <.bank(ft_s2p3c2), <.bank(ft_s2p1c3), <.bank(ft_s1p0c4)
ft_s2f16:
	.word ft_s2p4c0, ft_s2p4c1, ft_s2p3c2, ft_s2p3c3, ft_s1p0c4
	.byte <.bank(ft_s2p4c0), <.bank(ft_s2p4c1), <.bank(ft_s2p3c2), <.bank(ft_s2p3c3), <.bank(ft_s1p0c4)
ft_s2p0c1:
	.byte $EA, $2A, $03, $82, $01, $2C, $2E, $2F, $31, $33, $35, $83, $36, $03, $31, $03, $2A, $06, $87, $01
	.byte $00, $60

ft_s2p0c2:
	.byte $E1, $2A, $03, $82, $01, $2C, $2E, $2F, $31, $33, $35, $83, $36, $03, $31, $03, $2A, $67

ft_s2p1c0:
	.byte $EA, $22, $03, $2A, $07, $82, $03, $2E, $31, $2C, $2A, $2C, $22, $83, $2A, $07, $82, $03, $2E, $31
	.byte $2C, $2A, $2C, $22, $83, $2A, $07, $82, $03, $2E, $31, $2C, $2A, $2C, $22, $83, $2A, $07, $82, $03
	.byte $2E, $31, $2C, $2A, $83, $2C, $03

ft_s2p1c1:
	.byte $82, $03, $EA, $2A, $31, $36, $31, $35, $33, $31, $2F, $2A, $31, $36, $31, $35, $33, $31, $2F, $2A
	.byte $31, $36, $31, $35, $33, $31, $2F, $2A, $31, $36, $31, $35, $33, $31, $83, $2F, $03

ft_s2p1c2:
	.byte $82, $03, $E1, $2A, $2A, $2E, $31, $29, $29, $2F, $31, $2A, $2A, $2E, $31, $29, $29, $2F, $31, $2A
	.byte $2A, $2E, $31, $29, $29, $2F, $31, $2A, $2A, $2E, $31, $29, $29, $2F, $83, $31, $03

ft_s2p1c3:
	.byte $82, $03, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D
	.byte $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D
	.byte $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $82, $01, $E4, $1D, $E3, $1D, $1D, $1D, $E2, $1D
	.byte $E3, $1D, $1D, $1D, $E4, $1D, $E3, $1D, $1D, $1D, $E2, $1D, $E3, $1D, $1D, $83, $1D, $01

ft_s2p2c0:
	.byte $EA, $22, $03, $2A, $07, $82, $03, $2E, $31, $2C, $2A, $2C, $22, $83, $2A, $07, $82, $03, $2E, $31
	.byte $2C, $2A, $2C, $22, $2A, $22, $2A, $22, $2A, $22, $2A, $22, $2A, $22, $2A, $31, $2C, $31, $83, $2C
	.byte $03

ft_s2p2c1:
	.byte $82, $03, $EA, $2A, $31, $36, $31, $35, $33, $31, $2F, $2A, $31, $36, $31, $35, $33, $31, $2F, $2A
	.byte $2E, $2A, $2E, $2A, $2E, $2A, $2E, $2A, $2E, $2A, $2E, $35, $33, $35, $83, $33, $03

ft_s2p2c2:
	.byte $82, $03, $2A, $2A, $2E, $31, $29, $29, $2F, $31, $2A, $2A, $2E, $31, $29, $29, $2F, $31, $2A, $2A
	.byte $2A, $2A, $2A, $2A, $2A, $2A, $2A, $2A, $2A, $2A, $29, $29, $29, $83, $29, $03

ft_s2p2c3:
	.byte $82, $03, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D
	.byte $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D
	.byte $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $82, $01, $1D, $1D, $1D, $1D, $1D, $1D, $1D, $1D
	.byte $E2, $1D, $1D, $1D, $1D, $1D, $1D, $1D, $83, $1D, $01

ft_s2p3c0:
	.byte $82, $03, $EA, $1E, $25, $2A, $25, $29, $27, $25, $23, $1E, $25, $2A, $25, $29, $27, $25, $29, $23
	.byte $2F, $3B, $2A, $29, $38, $33, $29, $1E, $25, $2A, $25, $1E, $25, $2A, $83, $25, $03

ft_s2p3c1:
	.byte $EA, $36, $07, $36, $07, $35, $07, $33, $03, $35, $03, $36, $03, $3A, $07, $31, $13, $82, $03, $36
	.byte $36, $36, $36, $83, $35, $07, $82, $03, $3D, $35, $36, $38, $36, $83, $3A, $13

ft_s2p3c2:
	.byte $82, $03, $E1, $2A, $2A, $2E, $31, $29, $29, $2F, $31, $2A, $2A, $2E, $31, $29, $29, $2F, $31, $2C
	.byte $2C, $33, $36, $29, $29, $2F, $31, $2A, $2A, $2E, $31, $2A, $2A, $2E, $83, $31, $03

ft_s2p3c3:
	.byte $82, $03, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D
	.byte $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D
	.byte $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $82, $01, $E4, $1D, $E3, $1D, $1D, $1D, $E2, $1D
	.byte $E3, $1D, $1D, $1D, $E2, $1D, $1D, $83, $1D, $03, $1D, $01, $1D, $01, $1D, $03

ft_s2p4c0:
	.byte $82, $03, $EA, $1E, $25, $2A, $25, $29, $27, $25, $23, $1E, $25, $2A, $25, $29, $27, $25, $29, $23
	.byte $2F, $3B, $36, $29, $38, $38, $35, $1E, $83, $7F, $1B

ft_s2p4c1:
	.byte $EA, $36, $07, $36, $07, $35, $07, $33, $03, $35, $03, $36, $03, $3A, $07, $31, $07, $82, $03, $36
	.byte $38, $3A, $3B, $3A, $38, $36, $35, $36, $3D, $35, $83, $36, $1F

ft_s2p4c2:
	.byte $82, $03, $E1, $2A, $2A, $2E, $31, $29, $29, $2F, $31, $2A, $2A, $2E, $31, $29, $29, $2F, $31, $2C
	.byte $2C, $33, $36, $29, $29, $2F, $31, $83, $2A, $17, $82, $01, $2A, $29, $28, $83, $27, $01

ft_s2p4c3:
	.byte $82, $03, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D
	.byte $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D
	.byte $E3, $1D, $E4, $1D, $E3, $1D, $E2, $1D, $E3, $1D, $83, $E4, $1D, $1F

ft_s2p5c0:
	.byte $EA, $31, $03, $2E, $07, $2A, $07, $2A, $07, $82, $03, $27, $25, $27, $2E, $83, $33, $07, $82, $03
	.byte $31, $2E, $2C, $2F, $83, $2C, $07, $2A, $07, $2A, $07, $82, $03, $28, $25, $28, $2A, $83, $22, $07
	.byte $31, $03, $2F, $01, $2E, $01, $2A, $03

ft_s2p5c1:
	.byte $EA, $36, $07, $36, $07, $35, $07, $33, $03, $35, $03, $36, $03, $3A, $07, $31, $07, $82, $03, $36
	.byte $38, $3A, $3B, $3A, $38, $36, $35, $36, $3D, $35, $2A, $82, $01, $2C, $2E, $2F, $31, $33, $35, $83
	.byte $36, $03, $31, $03, $2A, $07

ft_s2p5c2:
	.byte $E1, $23, $03, $2F, $03, $23, $03, $28, $07, $82, $03, $34, $28, $29, $2A, $36, $2A, $83, $2A, $07
	.byte $25, $07, $1E, $03, $23, $07, $2F, $03, $23, $03, $28, $07, $34, $03, $82, $07, $28, $2A, $2A, $2A
	.byte $83, $2A, $03

ft_s2p6c0:
	.byte $EA, $20, $0B, $20, $07, $82, $03, $20, $25, $2A, $29, $2A, $2C, $31, $33, $31, $36, $83, $35, $07
	.byte $38, $03, $31, $0F, $33, $03, $31, $07, $31, $07, $31, $07, $31, $03, $2F, $01, $2E, $01, $2A, $03

ft_s2p6c1:
	.byte $EA, $38, $03, $35, $07, $31, $07, $31, $07, $82, $03, $2F, $2E, $2F, $31, $83, $3A, $07, $82, $03
	.byte $38, $36, $34, $36, $83, $34, $07, $31, $07, $31, $07, $82, $03, $2F, $2E, $2F, $31, $83, $2A, $13

ft_s2p6c2:
	.byte $E1, $23, $03, $2F, $03, $23, $03, $28, $07, $82, $03, $34, $28, $29, $2A, $36, $2A, $83, $2A, $07
	.byte $25, $07, $1E, $03, $23, $07, $2F, $03, $23, $03, $28, $07, $34, $03, $28, $23

ft_s2p7c0:
	.byte $EA, $31, $0B, $31, $13, $31, $0B, $31, $13, $31, $07, $31, $07, $2C, $07, $2C, $03, $31, $03, $33
	.byte $03, $35, $07, $2C, $13

ft_s2p7c1:
	.byte $EA, $25, $0B, $25, $07, $82, $03, $25, $2A, $2F, $2E, $2F, $31, $36, $38, $36, $3B, $83, $3A, $07
	.byte $3D, $03, $36, $0F, $38, $03, $36, $23

ft_s2p8c0:
	.byte $EA, $31, $0B, $31, $13, $31, $0B, $31, $13, $31, $07, $31, $07, $31, $07, $82, $03, $2C, $2E, $31
	.byte $35, $31, $35, $31, $35, $31, $83, $35, $03

ft_s2p8c1:
	.byte $EA, $36, $0B, $36, $13, $36, $0B, $36, $13, $36, $07, $36, $07, $35, $07, $33, $03, $35, $03, $36
	.byte $03, $3A, $07, $31, $13

ft_s2p9c1:
	.byte $EA, $36, $0B, $36, $13, $36, $0B, $36, $13, $36, $07, $36, $07, $35, $07, $82, $03, $33, $35, $36
	.byte $3B, $36, $3B, $36, $3B, $36, $83, $3B, $03

ft_s3_frames:
	.word ft_s3f0
	.word ft_s3f1
	.word ft_s3f2
	.word ft_s3f3
	.word ft_s3f4
	.word ft_s3f5
	.word ft_s3f6
	.word ft_s3f7
	.word ft_s3f8
ft_s3f0:
	.word ft_s3p0c0, ft_s3p0c1, ft_s3p0c2, ft_s3p0c3, ft_s0p0c4
	.byte <.bank(ft_s3p0c0), <.bank(ft_s3p0c1), <.bank(ft_s3p0c2), <.bank(ft_s3p0c3), <.bank(ft_s0p0c4)
ft_s3f1:
	.word ft_s3p1c0, ft_s3p1c1, ft_s3p0c2, ft_s3p1c3, ft_s0p0c4
	.byte <.bank(ft_s3p1c0), <.bank(ft_s3p1c1), <.bank(ft_s3p0c2), <.bank(ft_s3p1c3), <.bank(ft_s0p0c4)
ft_s3f2:
	.word ft_s3p3c0, ft_s3p2c1, ft_s3p1c2, ft_s3p2c3, ft_s0p0c4
	.byte <.bank(ft_s3p3c0), <.bank(ft_s3p2c1), <.bank(ft_s3p1c2), <.bank(ft_s3p2c3), <.bank(ft_s0p0c4)
ft_s3f3:
	.word ft_s3p1c0, ft_s3p1c1, ft_s3p0c2, ft_s3p1c3, ft_s0p0c4
	.byte <.bank(ft_s3p1c0), <.bank(ft_s3p1c1), <.bank(ft_s3p0c2), <.bank(ft_s3p1c3), <.bank(ft_s0p0c4)
ft_s3f4:
	.word ft_s3p3c0, ft_s3p2c1, ft_s3p1c2, ft_s3p2c3, ft_s0p0c4
	.byte <.bank(ft_s3p3c0), <.bank(ft_s3p2c1), <.bank(ft_s3p1c2), <.bank(ft_s3p2c3), <.bank(ft_s0p0c4)
ft_s3f5:
	.word ft_s3p2c0, ft_s3p3c1, ft_s3p2c2, ft_s3p1c3, ft_s0p0c4
	.byte <.bank(ft_s3p2c0), <.bank(ft_s3p3c1), <.bank(ft_s3p2c2), <.bank(ft_s3p1c3), <.bank(ft_s0p0c4)
ft_s3f6:
	.word ft_s3p2c0, ft_s3p3c1, ft_s3p2c2, ft_s3p1c3, ft_s0p0c4
	.byte <.bank(ft_s3p2c0), <.bank(ft_s3p3c1), <.bank(ft_s3p2c2), <.bank(ft_s3p1c3), <.bank(ft_s0p0c4)
ft_s3f7:
	.word ft_s3p4c0, ft_s3p4c1, ft_s3p3c2, ft_s3p3c3, ft_s0p0c4
	.byte <.bank(ft_s3p4c0), <.bank(ft_s3p4c1), <.bank(ft_s3p3c2), <.bank(ft_s3p3c3), <.bank(ft_s0p0c4)
ft_s3f8:
	.word ft_s3p5c0, ft_s3p5c1, ft_s3p4c2, ft_s3p3c3, ft_s0p0c4
	.byte <.bank(ft_s3p5c0), <.bank(ft_s3p5c1), <.bank(ft_s3p4c2), <.bank(ft_s3p3c3), <.bank(ft_s0p0c4)
ft_s3p0c0:
	.byte $E8, $20, $3F

ft_s3p0c1:
	.byte $E8, $25, $0E, $87, $01, $00, $30

ft_s3p0c2:
	.byte $82, $01, $E1, $19, $25, $19, $25, $19, $25, $19, $25, $19, $25, $19, $25, $19, $25, $19, $25, $19
	.byte $25, $19, $25, $19, $25, $19, $25, $12, $1E, $12, $1E, $12, $1E, $12, $83, $1E, $01

ft_s3p0c3:
	.byte $82, $01, $E4, $15, $E3, $15, $E4, $15, $E3, $15, $E4, $15, $E3, $15, $83, $E4, $15, $00, $15, $00
	.byte $15, $00, $15, $30

ft_s3p1c0:
	.byte $7F, $01, $E8, $25, $00, $7F, $02, $25, $00, $7F, $02, $25, $00, $7F, $02, $25, $00, $7F, $02, $25
	.byte $00, $7F, $02, $25, $00, $7F, $02, $25, $00, $7F, $02, $25, $00, $7F, $02, $25, $00, $7F, $02, $25
	.byte $00, $7F, $02, $25, $00, $7F, $02, $25, $00, $7F, $02, $2A, $00, $7F, $02, $2A, $00, $7F, $02, $2A
	.byte $00, $7F, $02, $2A, $00, $7F, $00

ft_s3p1c1:
	.byte $82, $01, $E8, $31, $31, $32, $31, $2F, $31, $83, $32, $03, $31, $01, $31, $01, $31, $00, $31, $00
	.byte $31, $01, $2F, $01, $31, $01, $32, $03, $7F, $01, $31, $00, $31, $00, $82, $01, $31, $31, $31, $31
	.byte $32, $31, $31, $31, $32, $31, $2F, $2D, $83, $31, $03

ft_s3p1c2:
	.byte $82, $01, $E1, $25, $25, $26, $25, $23, $21, $83, $25, $33

ft_s3p1c3:
	.byte $82, $01, $E4, $15, $E3, $15, $E2, $15, $E3, $15, $E4, $15, $E3, $15, $E2, $15, $E3, $15, $E4, $15
	.byte $E3, $15, $E2, $15, $E3, $15, $E4, $15, $E3, $15, $E2, $15, $E3, $15, $E4, $15, $E3, $15, $E2, $15
	.byte $E3, $15, $E4, $15, $E3, $15, $E2, $15, $E3, $15, $E4, $15, $E3, $15, $E2, $15, $E3, $15, $E4, $15
	.byte $E3, $15, $E2, $15, $83, $E3, $15, $01

ft_s3p2c0:
	.byte $7F, $01, $E8, $2C, $00, $7F, $02, $31, $00, $7F, $02, $32, $00, $7F, $06, $2C, $00, $7F, $02, $31
	.byte $00, $7F, $02, $32, $00, $7F, $06, $2C, $00, $7F, $02, $31, $00, $7F, $02, $32, $00, $7F, $06, $31
	.byte $00, $7F, $02, $31, $00, $7F, $08

ft_s3p2c1:
	.byte $82, $01, $E8, $25, $25, $26, $25, $23, $21, $83, $25, $02, $87, $01, $00, $30

ft_s3p2c2:
	.byte $82, $01, $E1, $19, $25, $19, $25, $19, $25, $19, $25, $19, $25, $19, $25, $19, $25, $19, $25, $12
	.byte $1E, $12, $1E, $12, $1E, $12, $1E, $19, $25, $19, $25, $19, $25, $19, $83, $25, $01

ft_s3p2c3:
	.byte $82, $01, $E4, $11, $E3, $11, $E2, $11, $E3, $11, $E4, $11, $E3, $11, $83, $E4, $11, $00, $E2, $11
	.byte $00, $11, $00, $11, $30

ft_s3p3c0:
	.byte $7F, $3F

ft_s3p3c1:
	.byte $E8, $2C, $01, $2E, $00, $7F, $00, $31, $01, $32, $00, $31, $01, $82, $00, $7F, $31, $31, $31, $7F
	.byte $31, $7F, $83, $2C, $01, $2E, $00, $7F, $00, $31, $01, $32, $00, $31, $01, $82, $00, $7F, $31, $31
	.byte $31, $7F, $31, $7F, $83, $2C, $01, $2E, $00, $7F, $00, $31, $01, $32, $00, $31, $01, $82, $00, $7F
	.byte $31, $31, $31, $7F, $31, $7F, $2F, $31, $32, $31, $2F, $31, $32, $2F, $83, $31, $07

ft_s3p3c2:
	.byte $E1, $19, $09, $25, $00, $25, $00, $25, $01, $25, $01, $19, $09, $25, $01, $25, $01, $25, $01, $19
	.byte $09, $25, $00, $25, $00, $25, $01, $25, $01, $19, $09, $25, $01, $25, $01, $25, $01

ft_s3p3c3:
	.byte $82, $01, $E2, $15, $E3, $15, $E2, $15, $E3, $15, $E2, $15, $E3, $15, $82, $00, $E2, $15, $E4, $15
	.byte $15, $15, $82, $01, $E2, $15, $E3, $15, $E2, $15, $E3, $15, $E2, $15, $E3, $15, $E2, $15, $E4, $15
	.byte $E2, $15, $E3, $15, $E2, $15, $E3, $15, $E2, $15, $E3, $15, $82, $00, $E2, $15, $E4, $15, $15, $15
	.byte $82, $01, $E2, $15, $E3, $15, $E2, $15, $E3, $15, $E2, $15, $E3, $15, $E2, $15, $83, $E4, $15, $01

ft_s3p4c0:
	.byte $7F, $01, $E8, $2C, $00, $7F, $02, $31, $00, $7F, $08, $7F, $01, $2C, $00, $7F, $02, $31, $00, $7F
	.byte $08, $7F, $01, $2C, $00, $7F, $02, $31, $00, $7F, $08, $7F, $01, $2C, $00, $7F, $02, $31, $00, $7F
	.byte $08

ft_s3p4c1:
	.byte $E8, $2C, $01, $2E, $00, $7F, $00, $31, $01, $32, $00, $31, $01, $82, $00, $7F, $25, $25, $25, $7F
	.byte $25, $7F, $83, $2C, $01, $2E, $00, $7F, $00, $31, $01, $32, $00, $31, $01, $82, $00, $7F, $25, $7F
	.byte $25, $7F, $25, $7F, $83, $2C, $01, $2E, $00, $7F, $00, $31, $01, $32, $00, $31, $01, $82, $00, $7F
	.byte $25, $25, $25, $7F, $25, $7F, $83, $2C, $01, $2E, $00, $7F, $00, $31, $01, $32, $00, $31, $01, $82
	.byte $00, $7F, $25, $7F, $25, $7F, $25, $83, $7F, $00

ft_s3p4c2:
	.byte $82, $01, $E1, $19, $25, $19, $25, $19, $83, $25, $00, $25, $00, $82, $01, $19, $25, $19, $25, $19
	.byte $25, $19, $83, $25, $00, $25, $00, $82, $01, $19, $25, $12, $1E, $12, $1E, $12, $83, $1E, $00, $1E
	.byte $00, $82, $01, $12, $1E, $12, $1E, $12, $1E, $12, $1E, $12, $83, $1E, $01

ft_s3p5c0:
	.byte $7F, $01, $E8, $2C, $00, $7F, $02, $31, $00, $7F, $08, $7F, $01, $2C, $00, $7F, $02, $31, $00, $7F
	.byte $08, $7F, $01, $2C, $00, $7F, $02, $31, $00, $7F, $0A, $31, $00, $7F, $02, $31, $00, $7F, $08

ft_s3p5c1:
	.byte $E8, $2C, $01, $2E, $00, $7F, $00, $31, $01, $32, $00, $31, $01, $82, $00, $7F, $25, $25, $25, $7F
	.byte $25, $7F, $83, $2C, $01, $2E, $00, $7F, $00, $31, $01, $32, $00, $31, $01, $82, $00, $7F, $25, $25
	.byte $25, $7F, $25, $7F, $83, $2C, $01, $2E, $00, $7F, $00, $31, $01, $32, $00, $31, $01, $82, $00, $7F
	.byte $25, $25, $25, $7F, $25, $7F, $2F, $31, $32, $31, $2F, $31, $32, $2F, $83, $31, $07

ft_s4_frames:
	.word ft_s4f0
	.word ft_s4f1
ft_s4f0:
	.word ft_s4p0c0, ft_s4p0c1, ft_s4p0c2, ft_s4p0c3, ft_s4p0c4
	.byte <.bank(ft_s4p0c0), <.bank(ft_s4p0c1), <.bank(ft_s4p0c2), <.bank(ft_s4p0c3), <.bank(ft_s4p0c4)
ft_s4f1:
	.word ft_s4p1c0, ft_s4p1c1, ft_s4p1c2, ft_s4p0c3, ft_s4p0c4
	.byte <.bank(ft_s4p1c0), <.bank(ft_s4p1c1), <.bank(ft_s4p1c2), <.bank(ft_s4p0c3), <.bank(ft_s4p0c4)
ft_s4p0c0:
	.byte $E6, $2A, $05, $2A, $05, $2A, $05, $27, $02, $2A, $05, $2A, $05, $27, $02, $2A, $02, $27, $02, $2A
	.byte $05

ft_s4p0c1:
	.byte $E6, $31, $05, $31, $05, $31, $08, $31, $02, $7F, $02, $31, $08, $31, $05, $31, $05

ft_s4p0c2:
	.byte $E1, $27, $0B, $2E, $08, $33, $0E, $2E, $05, $33, $05

ft_s4p0c3:
	.byte $E4, $14, $05, $E3, $1D, $03, $1D, $01, $E2, $1D, $05, $E3, $1D, $03, $1D, $01, $E4, $14, $05, $E3
	.byte $1D, $03, $1D, $01, $E2, $1D, $05, $E3, $1D, $03, $1D, $01

ft_s4p0c4:
	.byte $00, $2F

ft_s4p1c0:
	.byte $E6, $29, $05, $29, $05, $29, $05, $25, $02, $29, $05, $29, $05, $25, $02, $29, $02, $25, $02, $29
	.byte $05

ft_s4p1c1:
	.byte $E6, $30, $05, $30, $05, $30, $08, $30, $02, $7F, $02, $30, $08, $30, $05, $30, $05

ft_s4p1c2:
	.byte $E1, $25, $0B, $2C, $08, $31, $0E, $2C, $05, $31, $05

ft_s5_frames:
	.word ft_s5f0
ft_s5f0:
	.word ft_s5p0c0, ft_s5p0c1, ft_s5p0c2, ft_s5p0c3, ft_s4p0c4
	.byte <.bank(ft_s5p0c0), <.bank(ft_s5p0c1), <.bank(ft_s5p0c2), <.bank(ft_s5p0c3), <.bank(ft_s4p0c4)
ft_s5p0c0:
	.byte $E6, $2B, $02, $2B, $05, $2B, $05, $2B, $02, $2B, $05, $30, $0B, $2C, $0B

ft_s5p0c1:
	.byte $E6, $35, $02, $35, $05, $35, $05, $31, $02, $35, $05, $38, $16, $88, $00, $00, $00

ft_s5p0c2:
	.byte $E1, $27, $02, $27, $05, $27, $05, $27, $02, $27, $05, $38, $0B, $2C, $0B

ft_s5p0c3:
	.byte $E2, $1D, $05, $E3, $1D, $02, $E2, $1D, $05, $E3, $1D, $02, $E2, $1D, $05, $1D, $08, $1D, $05, $E3
	.byte $1D, $02, $1D, $02, $1D, $02

ft_s6_frames:
	.word ft_s6f0
	.word ft_s6f1
	.word ft_s6f2
	.word ft_s6f3
	.word ft_s6f4
ft_s6f0:
	.word ft_s6p0c0, ft_s6p0c1, ft_s6p0c2, ft_s6p0c3, ft_s0p0c4
	.byte <.bank(ft_s6p0c0), <.bank(ft_s6p0c1), <.bank(ft_s6p0c2), <.bank(ft_s6p0c3), <.bank(ft_s0p0c4)
ft_s6f1:
	.word ft_s6p1c0, ft_s6p1c1, ft_s6p1c2, ft_s6p1c3, ft_s0p0c4
	.byte <.bank(ft_s6p1c0), <.bank(ft_s6p1c1), <.bank(ft_s6p1c2), <.bank(ft_s6p1c3), <.bank(ft_s0p0c4)
ft_s6f2:
	.word ft_s6p2c0, ft_s6p2c1, ft_s6p2c2, ft_s6p2c3, ft_s0p0c4
	.byte <.bank(ft_s6p2c0), <.bank(ft_s6p2c1), <.bank(ft_s6p2c2), <.bank(ft_s6p2c3), <.bank(ft_s0p0c4)
ft_s6f3:
	.word ft_s6p1c0, ft_s6p3c1, ft_s6p1c2, ft_s6p3c3, ft_s0p0c4
	.byte <.bank(ft_s6p1c0), <.bank(ft_s6p3c1), <.bank(ft_s6p1c2), <.bank(ft_s6p3c3), <.bank(ft_s0p0c4)
ft_s6f4:
	.word ft_s6p2c0, ft_s6p4c1, ft_s6p2c2, ft_s6p4c3, ft_s0p0c4
	.byte <.bank(ft_s6p2c0), <.bank(ft_s6p4c1), <.bank(ft_s6p2c2), <.bank(ft_s6p4c3), <.bank(ft_s0p0c4)
ft_s6p0c0:
	.byte $ED, $36, $3F

ft_s6p0c1:
	.byte $00, $06, $87, $01, $00, $38

ft_s6p0c2:
	.byte $E0, $23, $3F

ft_s6p0c3:
	.byte $E4, $15, $03, $15, $01, $15, $39

ft_s6p1c0:
	.byte $82, $07, $ED, $2A, $2A, $2A, $2A, $25, $25, $2A, $83, $2A, $07

ft_s6p1c1:
	.byte $ED, $33, $03, $82, $01, $2F, $7E, $2F, $7E, $83, $36, $03, $33, $03, $82, $01, $2F, $7E, $2F, $7E
	.byte $83, $2F, $03, $82, $00, $31, $7E, $31, $7E, $83, $31, $03, $82, $00, $31, $7E, $31, $7E, $2F, $7E
	.byte $31, $7E, $83, $33, $03, $82, $01, $2F, $7E, $2F, $7E, $83, $36, $03

ft_s6p1c2:
	.byte $82, $03, $E0, $17, $23, $17, $23, $17, $23, $17, $23, $12, $1E, $12, $1E, $17, $23, $17, $83, $23
	.byte $03

ft_s6p1c3:
	.byte $82, $03, $E4, $15, $E3, $15, $E2, $15, $E3, $15, $E4, $15, $E3, $15, $E2, $15, $E3, $15, $E4, $15
	.byte $E3, $15, $E2, $15, $E3, $15, $E4, $15, $E3, $15, $E2, $15, $83, $E3, $15, $01, $15, $01

ft_s6p2c0:
	.byte $82, $07, $ED, $2A, $2A, $23, $23, $25, $25, $2A, $83, $2A, $07

ft_s6p2c1:
	.byte $ED, $33, $03, $82, $01, $2F, $7E, $2F, $7E, $83, $36, $03, $33, $03, $82, $01, $2F, $7E, $2F, $7E
	.byte $83, $2F, $03, $82, $00, $31, $7E, $31, $7E, $83, $31, $03, $82, $00, $31, $7E, $31, $7E, $2F, $7E
	.byte $31, $7E, $83, $33, $03, $82, $01, $2F, $7E, $2F, $7E, $83, $38, $03

ft_s6p2c2:
	.byte $82, $03, $E0, $17, $23, $17, $23, $10, $1C, $10, $1C, $12, $1E, $12, $1E, $17, $23, $17, $83, $23
	.byte $03

ft_s6p2c3:
	.byte $82, $03, $E4, $15, $E3, $15, $E2, $15, $E3, $15, $E4, $15, $E3, $15, $E2, $15, $E3, $15, $E4, $15
	.byte $E3, $15, $E2, $15, $E3, $15, $E4, $15, $E3, $15, $E2, $15, $83, $15, $01, $15, $01

ft_s6p3c1:
	.byte $ED, $36, $07, $33, $00, $7E, $02, $38, $03, $36, $07, $33, $00, $7E, $02, $2F, $01, $7E, $01, $82
	.byte $00, $31, $7E, $31, $7E, $83, $31, $03, $82, $00, $31, $7E, $31, $7E, $2F, $7E, $31, $7E, $83, $33
	.byte $03, $82, $01, $2F, $7E, $2F, $7E, $83, $38, $03

ft_s6p3c3:
	.byte $E4, $15, $03, $E3, $15, $03, $E2, $15, $00, $15, $02, $E3, $15, $03, $E4, $15, $03, $E3, $15, $03
	.byte $E2, $15, $00, $15, $02, $82, $03, $E3, $15, $E4, $15, $E3, $15, $E2, $15, $E3, $15, $E4, $15, $E3
	.byte $15, $E2, $15, $83, $E3, $15, $01, $15, $01

ft_s6p4c1:
	.byte $ED, $36, $07, $33, $00, $7E, $02, $38, $03, $36, $07, $33, $00, $7E, $02, $2F, $01, $7E, $01, $82
	.byte $00, $31, $7E, $31, $7E, $83, $31, $03, $82, $00, $31, $7E, $31, $7E, $2F, $7E, $31, $7E, $83, $33
	.byte $03, $82, $01, $2F, $7E, $2F, $7E, $83, $36, $02, $86, $02, $00, $00

ft_s6p4c3:
	.byte $E4, $15, $03, $E3, $15, $03, $E2, $15, $00, $15, $02, $E3, $15, $03, $E4, $15, $03, $E3, $15, $03
	.byte $E2, $15, $00, $15, $02, $82, $03, $E3, $15, $E4, $15, $E3, $15, $E2, $15, $82, $01, $E3, $15, $15
	.byte $E4, $15, $E2, $15, $15, $E4, $15, $E2, $15, $E4, $15, $15, $83, $E2, $15, $01

ft_s7_frames:
	.word ft_s7f0
	.word ft_s7f1
ft_s7f0:
	.word ft_s7p0c0, ft_s7p0c1, ft_s7p0c2, ft_s7p0c2, ft_s7p0c2
	.byte <.bank(ft_s7p0c0), <.bank(ft_s7p0c1), <.bank(ft_s7p0c2), <.bank(ft_s7p0c2), <.bank(ft_s7p0c2)
ft_s7f1:
	.word ft_s7p1c0, ft_s7p1c1, ft_s7p1c2, ft_s7p0c2, ft_s7p0c2
	.byte <.bank(ft_s7p1c0), <.bank(ft_s7p1c1), <.bank(ft_s7p1c2), <.bank(ft_s7p0c2), <.bank(ft_s7p0c2)
ft_s7p0c0:
	.byte $E5, $95, $94, $2E, $00, $95, $94, $2F, $00, $95, $94, $30, $01, $7F, $28

ft_s7p0c1:
	.byte $00, $0A, $87, $01, $00, $21

ft_s7p0c2:
	.byte $00, $2C

ft_s7p1c0:
	.byte $E5, $95, $94, $2B, $02, $95, $94, $32, $05, $95, $94, $32, $02, $95, $94, $32, $03, $95, $94, $30
	.byte $03, $95, $94, $2F, $03, $95, $94, $2B, $02, $95, $94, $28, $05, $95, $94, $28, $02, $95, $94, $24
	.byte $08

ft_s7p1c1:
	.byte $E5, $30, $02, $36, $05, $36, $02, $36, $03, $35, $03, $33, $03, $31, $13, $88, $00, $00, $00

ft_s7p1c2:
	.byte $E1, $2C, $08, $2C, $02, $2C, $03, $2E, $03, $30, $03, $31, $05, $2C, $05, $25, $08

ft_s8_frames:
	.word ft_s8f0
ft_s8f0:
	.word ft_s8p0c0, ft_s8p0c1, ft_s8p0c2, ft_s8p0c3, ft_s8p0c3
	.byte <.bank(ft_s8p0c0), <.bank(ft_s8p0c1), <.bank(ft_s8p0c2), <.bank(ft_s8p0c3), <.bank(ft_s8p0c3)
ft_s8p0c0:
	.byte $E7, $29, $02, $7F, $05, $25, $02, $7F, $05, $20, $05, $2A, $0B, $2A, $11, $29, $02, $27, $02, $29
	.byte $0B, $7F, $02

ft_s8p0c1:
	.byte $E7, $31, $02, $7F, $05, $2C, $02, $7F, $05, $29, $05, $2E, $03, $30, $03, $2E, $03, $2D, $05, $2F
	.byte $05, $2D, $05, $2C, $13, $88, $00, $00, $00

ft_s8p0c2:
	.byte $E0, $2C, $02, $7F, $05, $29, $02, $7F, $05, $25, $05, $2A, $0B, $26, $11, $25, $11, $7F, $02

ft_s8p0c3:
	.byte $00, $4A

ft_s9_frames:
	.word ft_s9f0
	.word ft_s9f1
	.word ft_s9f2
	.word ft_s9f3
	.word ft_s9f4
	.word ft_s9f5
	.word ft_s9f6
	.word ft_s9f7
	.word ft_s9f8
	.word ft_s9f9
	.word ft_s9f10
	.word ft_s9f11
ft_s9f0:
	.word ft_s9p0c0, ft_s9p0c1, ft_s9p0c2, ft_s0p0c4, ft_s0p0c4
	.byte <.bank(ft_s9p0c0), <.bank(ft_s9p0c1), <.bank(ft_s9p0c2), <.bank(ft_s0p0c4), <.bank(ft_s0p0c4)
ft_s9f1:
	.word ft_s9p0c0, ft_s9p0c1, ft_s9p1c2, ft_s0p0c4, ft_s0p0c4
	.byte <.bank(ft_s9p0c0), <.bank(ft_s9p0c1), <.bank(ft_s9p1c2), <.bank(ft_s0p0c4), <.bank(ft_s0p0c4)
ft_s9f2:
	.word ft_s9p1c0, ft_s9p1c1, ft_s9p0c2, ft_s0p0c4, ft_s0p0c4
	.byte <.bank(ft_s9p1c0), <.bank(ft_s9p1c1), <.bank(ft_s9p0c2), <.bank(ft_s0p0c4), <.bank(ft_s0p0c4)
ft_s9f3:
	.word ft_s9p1c0, ft_s9p2c1, ft_s9p0c2, ft_s0p0c4, ft_s0p0c4
	.byte <.bank(ft_s9p1c0), <.bank(ft_s9p2c1), <.bank(ft_s9p0c2), <.bank(ft_s0p0c4), <.bank(ft_s0p0c4)
ft_s9f4:
	.word ft_s9p2c0, ft_s9p3c1, ft_s9p3c2, ft_s0p0c4, ft_s0p0c4
	.byte <.bank(ft_s9p2c0), <.bank(ft_s9p3c1), <.bank(ft_s9p3c2), <.bank(ft_s0p0c4), <.bank(ft_s0p0c4)
ft_s9f5:
	.word ft_s9p3c0, ft_s9p4c1, ft_s9p4c2, ft_s0p0c4, ft_s0p0c4
	.byte <.bank(ft_s9p3c0), <.bank(ft_s9p4c1), <.bank(ft_s9p4c2), <.bank(ft_s0p0c4), <.bank(ft_s0p0c4)
ft_s9f6:
	.word ft_s9p4c0, ft_s9p5c1, ft_s9p5c2, ft_s0p0c4, ft_s0p0c4
	.byte <.bank(ft_s9p4c0), <.bank(ft_s9p5c1), <.bank(ft_s9p5c2), <.bank(ft_s0p0c4), <.bank(ft_s0p0c4)
ft_s9f7:
	.word ft_s9p5c0, ft_s9p6c1, ft_s9p6c2, ft_s0p0c4, ft_s0p0c4
	.byte <.bank(ft_s9p5c0), <.bank(ft_s9p6c1), <.bank(ft_s9p6c2), <.bank(ft_s0p0c4), <.bank(ft_s0p0c4)
ft_s9f8:
	.word ft_s9p6c0, ft_s9p7c1, ft_s9p7c2, ft_s0p0c4, ft_s0p0c4
	.byte <.bank(ft_s9p6c0), <.bank(ft_s9p7c1), <.bank(ft_s9p7c2), <.bank(ft_s0p0c4), <.bank(ft_s0p0c4)
ft_s9f9:
	.word ft_s9p7c0, ft_s9p8c1, ft_s9p8c2, ft_s0p0c4, ft_s0p0c4
	.byte <.bank(ft_s9p7c0), <.bank(ft_s9p8c1), <.bank(ft_s9p8c2), <.bank(ft_s0p0c4), <.bank(ft_s0p0c4)
ft_s9f10:
	.word ft_s9p8c0, ft_s9p9c1, ft_s9p9c2, ft_s0p0c4, ft_s0p0c4
	.byte <.bank(ft_s9p8c0), <.bank(ft_s9p9c1), <.bank(ft_s9p9c2), <.bank(ft_s0p0c4), <.bank(ft_s0p0c4)
ft_s9f11:
	.word ft_s9p9c0, ft_s9p10c1, ft_s9p0c2, ft_s0p0c4, ft_s0p0c4
	.byte <.bank(ft_s9p9c0), <.bank(ft_s9p10c1), <.bank(ft_s9p0c2), <.bank(ft_s0p0c4), <.bank(ft_s0p0c4)
ft_s9p0c0:
	.byte $82, $03, $7F, $EB, $22, $29, $22, $27, $22, $29, $22, $83, $2A, $07, $2C, $03, $2A, $03, $29, $07
	.byte $27, $07

ft_s9p0c1:
	.byte $82, $07, $7F, $EB, $31, $30, $31, $33, $83, $35, $03, $33, $03, $31, $07, $30, $07

ft_s9p0c2:
	.byte $E0, $22, $3F

ft_s9p1c0:
	.byte $EB, $25, $1F, $25, $1F

ft_s9p1c1:
	.byte $EB, $2E, $03, $29, $03, $2E, $03, $30, $07, $35, $0B, $2E, $03, $29, $03, $2E, $03, $30, $07, $35
	.byte $0B

ft_s9p1c2:
	.byte $82, $0F, $E0, $22, $20, $1B, $83, $1D, $0F

ft_s9p2c0:
	.byte $EB, $24, $1F, $25, $17, $24, $07

ft_s9p2c1:
	.byte $EB, $2E, $03, $30, $0B, $31, $07, $31, $03, $31, $07, $31, $1B

ft_s9p3c0:
	.byte $EB, $29, $1F, $29, $1F

ft_s9p3c1:
	.byte $EB, $30, $07, $2E, $03, $2D, $07, $30, $0B, $2E, $07, $2E, $17

ft_s9p3c2:
	.byte $E0, $21, $1F, $22, $17, $20, $07

ft_s9p4c0:
	.byte $EB, $24, $1F, $29, $1F

ft_s9p4c1:
	.byte $EB, $31, $07, $33, $03, $35, $0B, $35, $03, $35, $07, $35, $1B

ft_s9p4c2:
	.byte $E0, $25, $3F

ft_s9p5c0:
	.byte $EB, $25, $1F, $2A, $1F

ft_s9p5c1:
	.byte $EB, $33, $03, $31, $0B, $30, $07, $33, $03, $31, $07, $31, $1B

ft_s9p5c2:
	.byte $E0, $20, $1F, $25, $1F

ft_s9p6c0:
	.byte $EB, $2A, $1F, $25, $1F

ft_s9p6c1:
	.byte $EB, $35, $07, $33, $0F, $31, $03, $35, $03, $33, $07, $33, $17

ft_s9p6c2:
	.byte $E0, $22, $1F, $27, $1F

ft_s9p7c0:
	.byte $EB, $25, $1F, $24, $1F

ft_s9p7c1:
	.byte $EB, $33, $07, $31, $07, $30, $0B, $33, $03, $31, $07, $31, $17

ft_s9p7c2:
	.byte $E0, $27, $1F, $22, $1F

ft_s9p8c0:
	.byte $EB, $24, $3F

ft_s9p8c1:
	.byte $7F, $07, $EB, $31, $07, $31, $05, $30, $05, $2E, $01, $31, $01, $30, $07, $30, $17

ft_s9p8c2:
	.byte $E0, $22, $1F, $21, $1F

ft_s9p9c0:
	.byte $82, $03, $7F, $EB, $22, $31, $29, $83, $30, $07, $29, $03, $22, $03, $2A, $07, $2C, $03, $2A, $03
	.byte $29, $07, $27, $07

ft_s9p9c1:
	.byte $EB, $30, $0B, $2E, $03, $2D, $07, $30, $06, $87, $01, $00, $20

ft_s9p9c2:
	.byte $E0, $21, $3F

ft_s9p10c1:
	.byte $EB, $2E, $07, $2E, $0B, $27, $03, $31, $07, $33, $07, $35, $03, $33, $03, $31, $07, $30, $06, $86
	.byte $02, $00, $00

ft_s10_frames:
	.word ft_s10f0
ft_s10f0:
	.word ft_s10p0c0, ft_s10p0c1, ft_s10p0c2, ft_s10p0c3, ft_s10p0c3
	.byte <.bank(ft_s10p0c0), <.bank(ft_s10p0c1), <.bank(ft_s10p0c2), <.bank(ft_s10p0c3), <.bank(ft_s10p0c3)
ft_s10p0c0:
	.byte $82, $01, $E9, $29, $25, $20, $29, $25, $20, $29, $83, $29, $00, $29, $00, $82, $01, $29, $29, $29
	.byte $29, $2A, $26, $21, $2A, $26, $21, $2A, $83, $2A, $00, $2A, $00, $82, $01, $2A, $2A, $2A, $2A, $2C
	.byte $28, $23, $2C, $28, $23, $2C, $83, $2C, $00, $2C, $00, $2C, $01, $2E, $02, $2E, $02, $2E, $02, $30
	.byte $0F, $7F, $04

ft_s10p0c1:
	.byte $82, $01, $E9, $31, $2C, $29, $31, $2C, $29, $83, $31, $0B, $82, $01, $32, $2D, $2A, $32, $2D, $2A
	.byte $83, $32, $0B, $82, $01, $34, $2F, $2C, $34, $2F, $2C, $83, $34, $05, $36, $02, $36, $02, $36, $02
	.byte $38, $0F, $7F, $04

ft_s10p0c2:
	.byte $E0, $25, $0C, $7F, $00, $25, $02, $82, $00, $7F, $25, $7F, $25, $7F, $25, $7F, $83, $26, $0C, $7F
	.byte $00, $26, $02, $82, $00, $7F, $26, $7F, $26, $7F, $26, $7F, $2F, $7F, $2C, $7F, $28, $7F, $2F, $7F
	.byte $2C, $7F, $28, $7F, $2F, $7F, $83, $2F, $02, $7F, $00, $31, $00, $7F, $01, $31, $00, $7F, $01, $31
	.byte $00, $7F, $01, $33, $0F, $7F, $04

ft_s10p0c3:
	.byte $00, $5F

ft_s11_frames:
	.word ft_s11f0
ft_s11f0:
	.word ft_s11p0c0, ft_s11p0c1, ft_s11p0c2, ft_s10p0c3, ft_s10p0c3
	.byte <.bank(ft_s11p0c0), <.bank(ft_s11p0c1), <.bank(ft_s11p0c2), <.bank(ft_s10p0c3), <.bank(ft_s10p0c3)
ft_s11p0c0:
	.byte $82, $01, $E7, $20, $25, $29, $2C, $31, $35, $83, $38, $05, $35, $05, $82, $01, $21, $25, $28, $2D
	.byte $31, $34, $83, $39, $05, $34, $05, $82, $01, $23, $27, $2A, $2F, $33, $36, $83, $3B, $05, $3B, $01
	.byte $3B, $01, $3B, $01, $35, $08, $7F, $0E

ft_s11p0c1:
	.byte $82, $01, $7F, $E7, $1D, $20, $25, $29, $2C, $83, $31, $05, $2C, $05, $82, $01, $7F, $1C, $21, $25
	.byte $28, $2D, $83, $31, $05, $2D, $05, $82, $01, $7F, $1E, $23, $27, $2A, $2F, $83, $33, $05, $33, $05
	.byte $3D, $08, $7F, $0D, $88, $00, $00, $00

ft_s11p0c2:
	.byte $00, $05, $E0, $25, $01, $29, $01, $2C, $01, $35, $05, $31, $01, $7F, $09, $25, $01, $28, $01, $2D
	.byte $01, $34, $05, $31, $01, $7F, $09, $27, $01, $2A, $01, $2F, $01, $36, $05, $33, $05, $31, $08, $7F
	.byte $0E

ft_s12_frames:
	.word ft_s12f0
ft_s12f0:
	.word ft_s12p0c0, ft_s12p0c1, ft_s12p0c2, ft_s12p0c3, ft_s12p0c3
	.byte <.bank(ft_s12p0c0), <.bank(ft_s12p0c1), <.bank(ft_s12p0c2), <.bank(ft_s12p0c3), <.bank(ft_s12p0c3)
ft_s12p0c0:
	.byte $E7, $1D, $01, $2D, $03, $2D, $01, $2D, $03, $1E, $01, $2E, $03, $2E, $01, $2E, $03, $1F, $01, $2F
	.byte $03, $2F, $01, $2F, $03, $30, $01, $7F, $01, $30, $0F

ft_s12p0c1:
	.byte $E7, $29, $01, $33, $03, $33, $01, $33, $03, $2A, $01, $34, $03, $34, $01, $34, $03, $2B, $01, $35
	.byte $03, $35, $01, $35, $03, $36, $01, $7F, $01, $36, $0E, $88, $00, $00, $00

ft_s12p0c2:
	.byte $82, $01, $E0, $30, $3C, $7F, $3C, $3C, $7F, $31, $3D, $7F, $3D, $3D, $7F, $32, $3E, $7F, $3E, $3E
	.byte $7F, $2C, $7F, $83, $2C, $0A, $7F, $04

ft_s12p0c3:
	.byte $00, $37

ft_s13_frames:
	.word ft_s13f0
	.word ft_s13f1
	.word ft_s13f2
ft_s13f0:
	.word ft_s13p0c0, ft_s13p0c1, ft_s13p0c2, ft_s1p0c4, ft_s1p0c4
	.byte <.bank(ft_s13p0c0), <.bank(ft_s13p0c1), <.bank(ft_s13p0c2), <.bank(ft_s1p0c4), <.bank(ft_s1p0c4)
ft_s13f1:
	.word ft_s13p1c0, ft_s13p1c1, ft_s13p1c2, ft_s1p0c4, ft_s1p0c4
	.byte <.bank(ft_s13p1c0), <.bank(ft_s13p1c1), <.bank(ft_s13p1c2), <.bank(ft_s1p0c4), <.bank(ft_s1p0c4)
ft_s13f2:
	.word ft_s13p2c0, ft_s13p2c1, ft_s13p2c0, ft_s1p0c4, ft_s1p0c4
	.byte <.bank(ft_s13p2c0), <.bank(ft_s13p2c1), <.bank(ft_s13p2c0), <.bank(ft_s1p0c4), <.bank(ft_s1p0c4)
ft_s13p0c0:
	.byte $82, $0F, $EC, $35, $30, $31, $2C, $2B, $28, $29, $83, $24, $0F

ft_s13p0c1:
	.byte $82, $03, $EC, $2C, $29, $24, $20, $2B, $29, $24, $20, $29, $28, $24, $20, $2E, $29, $25, $22, $83
	.byte $28, $07, $24, $07, $2E, $01, $30, $01, $2E, $03, $2C, $07, $82, $03, $2B, $20, $24, $20, $83, $29
	.byte $07, $28, $07

ft_s13p0c2:
	.byte $82, $0F, $E0, $35, $30, $31, $2C, $2B, $28, $29, $83, $24, $0F

ft_s13p1c0:
	.byte $82, $0F, $EC, $35, $33, $31, $2C, $83, $2B, $1F, $30, $1F

ft_s13p1c1:
	.byte $EC, $29, $01, $2B, $01, $29, $03, $82, $07, $28, $20, $24, $25, $19, $82, $03, $25, $1D, $24, $1D
	.byte $82, $07, $1F, $18, $1D, $18, $1C, $18, $83, $1D, $01, $1F, $01, $1D, $03, $1C, $07

ft_s13p1c2:
	.byte $82, $0F, $E0, $29, $27, $25, $20, $83, $1F, $1F, $24, $1F

ft_s13p2c0:
	.byte $7F, $7F

ft_s13p2c1:
	.byte $82, $03, $EC, $2C, $24, $2B, $24, $29, $24, $2E, $24, $2C, $24, $28, $24, $2C, $24, $2B, $24, $83
	.byte $1D, $07, $82, $03, $1F, $20, $22, $1D, $24, $83, $1D, $23


; DPCM samples (located at DPCM segment)
