.segment "LEVEL"
.proc AreaParserCore
ramPtr = R0
	ldy	CurrentPageLoc
	lda PageAddresses,y
	sta ramPtr
	lda PageAddressesHi,y
	sta ramPtr+1

FillForegroundBuff:
	ldx #0
	ldy CurrentColumnPos
FGLoop:
	lda ($00),y
	sta MetatileBuffer,x
	tya
	clc
	adc #$10
	tay
	inx
	cpx #14
	bcc FGLoop

  rts
.endproc

.segment "FIXED"
.include "tiled_levels/!level_structure.s"
NUM_OF_PAGES = 20
PageAddressesHi = PageAddresses + NUM_OF_PAGES
PageAddresses:
	;low
	i .set 0
	.repeat NUM_OF_PAGES
	.lobytes $d0*i
	i .set i + 1
	.endrep
	;high
	i .set 0
	.repeat NUM_OF_PAGES
	.hibytes $d0*i+$6000
	i .set i + 1
	.endrep

.proc LoadLevel
levelWidth = B0 ;B1
widthLeft = R0 ;R1
ramPtr = R2 ;R3
curRow = R4 
curCol = R5 
	; handle header
  lda CurrentBank
  pha 

	ldy #0
  lda ForegroundDataLo,y
  sta hm_node
  lda ForegroundDataHi,y
  sta hm_node+1
	lda ForegroundBanks,y
  sta CurrentBank
  BankPRGA a

  ; get level timer
	lda (hm_node),y
  sta R0
  iny
	lda (hm_node),y  
  sta R1
  jsr bcdConvert
  lda R3+4
  sta GameTimerDisplay+2
  lda R3+3
  sta GameTimerDisplay+1
  lda R3+2
  sta GameTimerDisplay+0

  ; get level width
	ldy #2
	lda (hm_node),y
	sta levelWidth
  sta widthLeft
  pha
  iny
	lda (hm_node),y
	sta levelWidth+1
  sta widthLeft+1

  ; set background's starting address ($xx00) 
  ; (the widthLeft+1 is only lsr'd once, because the maximum number of pages is 19 anyway)
  lsr
  lda widthLeft
  ror
  lsr
  lsr
  lsr
  tay
  ; restore original value
  pla
  sta widthLeft
  ; set bg addr
  iny
  lda PageAddresses,y
  sta BackgroundBufferAddr
  lda PageAddressesHi,y
  sta BackgroundBufferAddr+1

  ; init huffmunch
  lda hm_node
  clc
  adc #4
  sta hm_node
  bcc :+
    inc hm_node+1
  :
	;select entry $0000 (first one)
	ldy #$00
	ldx #$00
  sty curRow
  sty curCol  
	jsr huffmunch_load
	;out: Y:X data length size
	;stx Length
	;sty Length+1

  lda #$00
	sta ramPtr
	lda #$60
	sta ramPtr+1
ReadData:
  ; check how many bytes left
  ldx widthLeft
  beq Lwlo0
  dex
  jmp ReadByte
Lwlo0:
  ldy widthLeft+1
  beq DoneRow
  dey
  sty widthLeft+1
  dex 
ReadByte:
  stx widthLeft

  ; read byte
	jsr huffmunch_read
  ldy curCol
  sta (ramPtr),y
  ; check if moving onto next page 
  iny
  tya
  and #$0f
  sta curCol
  bne ReadData
  ; next page!
  lda ramPtr
  clc
  adc #16*13
  sta ramPtr
  bcc ReadData
  inc ramPtr+1
  jmp ReadData

DoneRow:
  inc curRow
  lda curRow
  cmp #13
  beq LevelLoaded
  asl
  asl
  asl
  asl
	sta ramPtr
	lda #$60
	sta ramPtr+1
  lda #0
  sta curCol
  lda levelWidth
  sta widthLeft
  lda levelWidth+1
  sta widthLeft+1
  jmp ReadData

LevelLoaded:
  pla
  sta CurrentBank
  BankPRGA a
  rts
.endproc