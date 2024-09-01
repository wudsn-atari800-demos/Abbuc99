; 
; ABBUC 99 Intro - NetBalls Main Include
;
; (c) 2009-11-29 by JAC!


; This section must start on a page boundary

; A normal balls line is two scan line high. For soft scrolling $0d becomes $0e on uneven positions.
ballsdc	= $0d

;	17 bytes
	.macro define_balls_dl_row
	.word 0
	.byte ballsdc,ballsdc,ballsdc,ballsdc,ballsdc,ballsdc,ballsdc
	.byte ballsdc,ballsdc,ballsdc,ballsdc,ballsdc,ballsdc,ballsdc,$90
	.byte $40+ballsdc
	.endm

ballsdl		.byte $40+ballsdc
ballsdllms1	define_balls_dl_row
ballsdllms2	define_balls_dl_row
ballsdllms3	define_balls_dl_row
ballsdllms4	define_balls_dl_row
ballsdllms5	define_balls_dl_row
ballsdllms6	define_balls_dl_row
ballsdllms7	define_balls_dl_row
ballsdllms8	define_balls_dl_row
ballsdllms9	.word 0
		.byte ballsdc,ballsdc,ballsdc,ballsdc,ballsdc,ballsdc,ballsdc
		.byte ballsdc,ballsdc,ballsdc,ballsdc,ballsdc,ballsdc,ballsdc,$90

ballsdllmstmp	.word 0

; Pattern to fill the first section of the dl up to dllms1
ballsdlpattern	.byte $40+ballsdc
		define_balls_dl_row

; Macro	6*$280 = $f00 bytes per $1000 block to pervent LMS overrun
	.macro define_balls_sm_offset
	.word %1+ballssmsize*$00,%1+ballssmsize*$01,%1+ballssmsize*$02,%1+ballssmsize*$03,%1+ballssmsize*$04,%1+ballssmsize*$05
	.endm

; Macro	7*6 = 42 entries, each $280 bytes
	.macro define_balls_sm_offsets
	define_balls_sm_offset $4000
	define_balls_sm_offset $6000
	define_balls_sm_offset $7000
	define_balls_sm_offset $9000
	define_balls_sm_offset $a000
	define_balls_sm_offset $b000
	define_balls_sm_offset $c000
	.endm

; This one should not cross a page boundary	
ballssmtab	
	define_balls_sm_offsets
	define_balls_sm_offsets

; This one should not cross a page boundary
ballscolors
	.byte $30,$20,$e0,$c0,$a0,$80,$60,$40,$10,$20,$d0,$b0,$90,$00

; Used by macro "set_balls_dllms". This one should not cross a page boundary
ballslmsoffset
	.byte 0,2,4,6,8,10,12,14,12,10,8,6,4,2
	.byte 0,2,4,6,8,10,12,14,12,10,8,6,4,2	; roll-over copy

; LMS pointers set by "set_balls_lms"
ballslms1	.ds 2
ballslms2	.ds 2
ballslms3	.ds 2
ballslms4	.ds 2
ballslms5	.ds 2
ballslms6	.ds 2
ballslms7	.ds 2
ballslms8	.ds 2
ballssmadr	.ds 2

; Addresses of the unrolled draw routines
ballsdrawlo .ds 4
ballsdrawhi .ds 4

; Counters for the sin(x)+sin(y) animation
ballssin1	.ds 1
ballssin2	.ds 1

;==========================================================
; VBI sub routines before and after the counter increment

balls_vbi_jsr1
	jsr set_balls_dl
	jsr set_balls_colors
	lda #$3e 
	sta $d400 
	set [dli_jsr+1], balls_dli_jsr
	rts

balls_vbi_jsr2
	jsr animate_balls 
	jsr set_balls_lms 
	jsr clear_balls_sm
	jmp draw_balls

;==========================================================
; DLI sub routine to set the ball colors.

balls_dli_jsr

set_balls_colors
	ldx ballsycntdli 
	lda ballscolortab1,x 
	sta $d018 ;COLPF2 
	lda ballscolortab2,x 
	sta $d017 ;COLPF1 
	lda ballscolortab3,x 
	sta $d016 ;COLPF0 
	inc ballsycntdli
	rts

;==========================================================
; Macro to copy the LMS offsets into the actual DL instructions
	.macro set_balls_dllms
	ldy [ballslmsoffset+%1],x
	lda ballslms1,y
	sta %2
	lda ballslms1+1,y
	sta %2+1
	.endm

; VBI routine to set LMS offsets into the actual DL instructions and $d402
set_balls_dl
;	Restore the first part of the DL for later modification
	ldx #17
set_balls_dl1
	lda ballsdlpattern,x
	sta ballsdl,x
	dex
	bpl set_balls_dl1

;	Prepare next DLI sequence
	ldx ballsycnt
	stx ballsycntdli

;	Copy the LMS points for every ball line
	set_balls_dllms 0,ballsdllmstmp
	set_balls_dllms 1,ballsdllms2
	set_balls_dllms 2,ballsdllms3
	set_balls_dllms 3,ballsdllms4
	set_balls_dllms 4,ballsdllms5
	set_balls_dllms 5,ballsdllms6
	set_balls_dllms 6,ballsdllms7
	set_balls_dllms 7,ballsdllms8
	set_balls_dllms 8,ballsdllms9

;	Compute additional LMS offset for first LMS command
	lda ballsxcnt
	and #$1e
	tax
	lda lineoffsettab,x
	clc
	adc ballsdllmstmp
	sta ballsdllmstmp
	lda lineoffsettab+1,x
	adc ballsdllmstmp+1
	sta ballsdllmstmp+1

;	The single line scrolling is achieved by toggling the first DL line between $0d and $0e
	lda ballsxcnt
	lsr
	tax

;	Compute DL command for the first DL line
	lda #$40+ballsdc
	adc #0
	cpx #15
	bcc set_balls_dlline0to14	;lines 0-14
	ldx #17		;line 15 (index for blank)
	lda ballsxcnt
	and #1
	bne set_balls_dlline15a
	lda #$10	;line 15 (dc for two lines blank)
	bne *+4
set_balls_dlline15a
	lda #$00	;line 15 (dc for one line blank)
	sta ballsdl,x
	inc ballsycntdli ;instead of DLI flag in blank lines
	jmp set_balls_dllastline

set_balls_dlline0to14
	sta ballsdl,x
	lda ballsdllmstmp
	sta ballsdllms1,x

	lda ballsdllmstmp+1
	sta ballsdllms1+1,x

set_balls_dllastline
	stx $d402 	;dlistl 
	lda #>ballsdl 
	sta $d403 	;dlisth 
	rts

;==========================================================
; VBI routine to set the LMS values from the buffers to the actual DL 
	.macro set_balls_lm
	lda ballssmtab+[%1*2*4],x 
	sta %2
	lda ballssmtab+[%1*2*4]+1,x 
	sta %2+1
	.endm

set_balls_lms
	lda ballssmcnt 
	asl 
	tax
	set_balls_lm 0,ballslms1
	set_balls_lm 1,ballslms2
	set_balls_lm 2,ballslms3
	set_balls_lm 3,ballslms4
	set_balls_lm 4,ballslms5
	set_balls_lm 5,ballslms6
	set_balls_lm 6,ballslms7
	set_balls_lm 7,ballslms8
	set_balls_lm 8,ballssmadr
	rts 

;==========================================================
; VBI routine to animate the ball, i.e. count ballsxcnt and ballsycnt

animate_balls
	inc ballssmcnt 
	lda ballssmcnt
	cmp #ballssmcntmax 
	bne animate_balls1
	lda #0 
	sta ballssmcnt

animate_balls1
	inc ballsxcnt
	lda ballsxcnt
	cmp #ballsxcntmax
	bne animate_balls2
	lda #0
	sta ballsxcnt

	inc ballsycnt
	lda ballsycnt
	cmp #ballsycntmax
	bne animate_balls3
	lda #0
	sta ballsycnt
animate_balls3
	clc
	adc #8
	cmp #ballsycntmax
	bcc *+4
	sbc #ballsycntmax
	tay

animate_balls4
	lda ballsflag
	beq animate_balls5
	lda $d20a
	and #14
	cmp #12
	bcs animate_balls4
	cmp #4
	bcc animate_balls4
	
	ora ballscolors,y

	sta ballscolortab1,y
	sta ballscolortab1+ballsycntmax,y
	clc
	adc #2
	sta ballscolortab2,y
	sta ballscolortab2+ballsycntmax,y
	adc #2
	sta ballscolortab3,y
	sta ballscolortab3+ballsycntmax,y
	rts

animate_balls5
	sta ballscolortab1,y
	sta ballscolortab1+ballsycntmax,y
	sta ballscolortab2,y
	sta ballscolortab2+ballsycntmax,y
	sta ballscolortab3,y
	sta ballscolortab3+ballsycntmax,y
animate_balls2
	rts

;==========================================================
; Clear $280 bytes of balls memory starting at "smadr"
clear_balls_sm
	lda ballssmadr 
	sta clear_balls_sm1+1	;offset+$000, low byte
	sta clear_balls_sm3+1	;offset+$100, low byte
	sta clear_balls_sm5+1	;offset+$200, low byte
	ldx ballssmadr+1
	stx clear_balls_sm1+2	;offset+$000, high byte 
	inx
	stx clear_balls_sm3+2	;offset+$100, high byte
	inx 
	stx clear_balls_sm5+2	;offset+$200, high byte

	clc 
	lda ballssmadr
	adc #$80 
	sta clear_balls_sm2+1	;offset+$080, low byte
	sta clear_balls_sm4+1	;offset+$180, low byte
	lda ballssmadr+1
	adc #0 
	sta clear_balls_sm2+2 	;offset+$080, high byte
	clc 
	adc #1 
	sta clear_balls_sm4+2 	;offset+$180, high byte
	lda #0 
	tay
clear_balls_sm1
	sta $9a00,y 
clear_balls_sm2
	sta $9a80,y 
clear_balls_sm3
	sta $9b00,y 
clear_balls_sm4
	sta $9b80,y 
clear_balls_sm5
	sta $9c00,y 
	iny 
	bpl clear_balls_sm1
	rts 

;==========================================================
; Draw all balls in the current ball SM address
draw_balls
	lda cnt 
	sta ballssin1 
	ldx #balls
draw_balls1
	clc 
	lda ballssin1
	tay
draw_balls2
	adc #14
	sta ballssin1 
	lda sintab,y 
	ldy ballssin2 
	clc 
	adc sintab,y 
	ror 
	jsr draw_ball
	dex 
	bne draw_balls1 
	clc 
	lda ballssin2
	adc #2	;ball sin
	sta ballssin2 
	rts
	
;==========================================================
; Draw a ball at <A> in the current ball SM address
draw_ball
	pha
	and #$03 
	tay 
	lda ballsdrawlo,y
	sta draw_ball1+1
	lda ballsdrawhi,y
	sta draw_ball1+2
	pla
	lsr 
	lsr 
	clc 
	adc ballssmadr 
	sta ballsp1 
	lda ballssmadr+1 
	adc #0 
	sta ballsp1+1
draw_ball1
	jmp $ffff

;==========================================================
; Non VBI routine to fade out all balls to black and clears <ballsflag>

fadeballsycnt	.ds 1

fade_balls
	lda ballsxcnt
	bne fade_balls
	lda #ballsycntmax+1
	sta fadeballsycnt
	ldy ballsycnt
fade_balls1
	lda ballscolortab1,y
	jsr fadecolor
	sta ballscolortab1,y
	sta ballscolortab1+ballsycntmax,y
	lda ballscolortab2,y
	jsr fadecolor
	sta ballscolortab2,y
	sta ballscolortab2+ballsycntmax,y
	lda ballscolortab3,y
	jsr fadecolor
	sta ballscolortab3,y
	sta ballscolortab3+ballsycntmax,y
	lda #1
	jsr wait
	lda ballscolortab1,y
	ora ballscolortab2,y
	ora ballscolortab3,y
	bne fade_balls1

	iny
	cpy #ballsycntmax
	bne *+4
	ldy #0

	dec fadeballsycnt
	bne fade_balls1

	lda #0
	sta ballsflag
	rts

ballsend
