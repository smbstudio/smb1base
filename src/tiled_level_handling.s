.segment "FIXED"
.include "tiled_levels/!level_structure.s"

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

	ldy #0
  sty curRow
  sty curCol
	lda (hm_node),y
	sta levelWidth
  sta widthLeft
  iny
	lda (hm_node),y
	sta levelWidth+1
  sta widthLeft+1

  ; init huffmunch
  lda hm_node
  clc
  adc #2
  sta hm_node
  bcc :+
    inc hm_node+1
  :
	;select entry $0000 (first one)
	ldy #$00
	ldx #$00
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