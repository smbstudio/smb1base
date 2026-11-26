.ifndef __VRAM_INC
__VRAM_INC = 1

; Popslide vram buffer packet format.
;   literal: addr hi, addr lo, .word VramBufEntry(len),  len data bytes
;   fill:    addr hi, addr lo, .word VramFillStub - 1, value, .word VramFillEntry(len)
;   end:     $00 in place of addr hi
;
; Theres two different lists like vanilla. Column is for scrolling and it takes priority
; and queue is for everything else.
;   queue  - starts at $100
;   column - from VRAM_COLUMN_BASE, or from $100 during area setup when the queue is empty.
VRAM_BUFFER_SIZE = 160
VRAM_COLUMN_BASE = 120

VramQueue := VramBuffer

; Entry words are pushed as return addresses into the chain of sta PPUDATA
.define VramBufEntry(len)  (VramBufChain + 4 * (64 - (len)) - 1)
.define VramFillEntry(len) (VramFillChain + 3 * (64 - (len)) - 1)

; `addr | $8000` will set vertical mode
.macro VramBuf addr, len
  .byte >(addr), <(addr)
  .word VramBufEntry(len)
.endmacro

.macro VramFill addr, len, value
  .byte >(addr), <(addr)
  .word VramFillStub - 1
  .byte value
  .word VramFillEntry(len)
.endmacro

; Writes the entry word of a literal packet into a buffer slot
.macro VramStoreEntry len, dest, index
  lda #<VramBufEntry(len)
  sta dest,index
  lda #>VramBufEntry(len)
  sta dest+1,index
.endmacro

; Maximimum size of the buffer that we allow before skipping the VRAM update for this type.
; So if we have that many updates already in the queue, we'll SKIP climb rope this frame for instance.
VRAM_LIMIT_CLIMB_ROPE   = $25
VRAM_LIMIT_COLOR_ROTATE = $38

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

.endif ;__VRAM_INC
