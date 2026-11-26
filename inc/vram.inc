
.ifndef __VRAM_INC
__VRAM_INC = 1

VramQueue       := VRAM_Buffer1
VramQueueIndex  := VRAM_Buffer1_Offset
VramColumn      := VRAM_Buffer2
VramColumnIndex := VRAM_Buffer2_Offset

; DrawMushroomIcon and the world select copy the index and the packets as a single block
.assert VramQueue = VramQueueIndex + 1, error, "VramQueueIndex must directly precede VramQueue"

; Added to a queue index so that queue-relative writes land in the column queue instead
VramColumnAsQueueIndex = VramColumn - VramQueue

; Source ids. The ROM sources are the other *Offset values in constants.inc
VramSrcQueue  = VRAM_Buffer1Offset
VramSrcColumn = VRAM_Buffer2Offset

; Maximimum size of the buffer that we allow before skipping the VRAM update for this type.
; So if we have that many updates already in the queue, we'll SKIP climb rope this frame for instance.
VRAM_LIMIT_CLIMB_ROPE   = $20
VRAM_LIMIT_COLOR_ROTATE = $31

.macro VramSelectSourceA
  sta VRAM_Buffer_AddrCtrl
.endmacro

.macro VramSelectSourceX
  stx VRAM_Buffer_AddrCtrl
.endmacro

.macro VramSelectSource source
  lda #source
  VramSelectSourceA
.endmacro

.macro VramSkipIfColumnSelected target
  lda VRAM_Buffer_AddrCtrl
  cmp #VramSrcColumn
  beq target
.endmacro

.macro VramSkipIfQueueUsed target
  lda VramQueue
  bne target
.endmacro

; X holds the queue index
.macro VramSkipIfQueueAtLimitX limit, target
  cpx #limit
  bcs target
.endmacro

; A must be 0
.macro VramQueueReset
  sta VramQueueIndex
  sta VramQueue
.endmacro

; A must be 0
.macro VramColumnReset
  sta VramColumnIndex
.endmacro

.endif ;__VRAM_INC
