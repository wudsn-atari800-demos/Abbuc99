; 
; ABBUC 99 Intro - NetBalls Init Include
;
; (c) 2009-11-29 by JAC!

; This initialization is located in the SM buffer and can
; be overwritten by the drawing of the balls

; Total number of balls
balls	= 11

; Ball draw pointer zero page pointer
ballsp1	      = ballszp+$00

; Ball screen counter limit and counter for round robin, changed by VBI
ballssmcntmax = $2a		;$2a*$280
ballssmcnt    = ballszp+$02	;$00-$29 = ballssmcntmax-1

; Ball line counter limits and counters for scrolling upwards, changed by VBI
ballsxcntmax	= $20		;Height of a ball in scanlines
ballsxcnt	= ballszp+$03	;Low, $00-$1f = ballsxcntmax-1
ballsycntmax	= $0e		;Number of virtual ball lines
ballsycnt	= ballszp+$04	;High $00-$0d = ballsycntmax-1
ballsycntdli	= ballszp+$05	;Initialized during VBI, incremented during DLI

; SM memory constats
ballssmsize	= $280	;15*40 = 600 = $258

;==========================================================
; Generate the ball draw routines and store their address to ballsdrawlo and ballsdrawhi  
init_balls
	set p3,ballsdrawbase
	ldy #0		;0..3 shifted balls
	sty x1
	set p1,[ballspic+0*5]
	set p2,[ballsmask+0*5]
	jsr generate_ball
	set p1,[ballspic+1*5]
	set p2,[ballsmask+1*5]
	jsr generate_ball
	set p1,[ballspic+2*5]
	set p2,[ballsmask+2*5]
	jsr generate_ball
	set p1,[ballspic+3*5]
	set p2,[ballsmask+3*5]
	jsr generate_ball
	rts

; Generate the ball draw routine number <x1> based on (p1),y and (p2),y to (p3),y  
generate_ball
	ldx x1
	lda p3
	sta ballsdrawlo,x		;Store the routine address
	lda p3+1
	sta ballsdrawhi,x
	ldx #<[0*linewidth]
	jsr generate_ball_line
	ldx #<[1*linewidth]
	jsr generate_ball_line
	ldx #<[2*linewidth]
	jsr generate_ball_line
	ldx #<[3*linewidth]
	jsr generate_ball_line
	ldx #<[4*linewidth]
	jsr generate_ball_line
	ldx #<[5*linewidth]
	jsr generate_ball_line
	ldx #<[6*linewidth]
	jsr generate_ball_line
	lda #$e6	;"INC ballsp1+1"
	jsr generate_byte
	lda #<[ballsp1+1]
	jsr generate_byte
	ldx #<[7*linewidth]
	jsr generate_ball_line
	ldx #<[8*linewidth]
	jsr generate_ball_line
	ldx #<[9*linewidth]
	jsr generate_ball_line
	ldx #<[10*linewidth]
	jsr generate_ball_line
	ldx #<[11*linewidth]
	jsr generate_ball_line
	ldx #<[12*linewidth]
	jsr generate_ball_line
	lda #$e6	;"INC P1+1"
	jsr generate_byte
	lda #<[ballsp1+1]
	jsr generate_byte
	ldx #<[13*linewidth]
	jsr generate_ball_line
	ldx #<[14*linewidth]
	jsr generate_ball_line
	lda #$60	;"RTS"
	jsr generate_byte
	inc x1
	rts

;==========================================================
; Copy (and if required mask) the byte stored as (p1),y
; masked by the byte at (p2),y to (p3),x
generate_ball_line
	jsr generate_ball_line_byte
	inx
	jsr generate_ball_line_byte
	inx
	jsr generate_ball_line_byte
	inx
	jsr generate_ball_line_byte
	inx
	jsr generate_ball_line_byte
	add p1,[linewidth-5]
	add p2,[linewidth-5]
	rts

generate_ball_line_byte
	lda (p2),y
	cmp #$ff
	beq generate_ball_line_byte2;nothing to mask, so ignore
	cmp #$00
	bne generate_ball_line_byte1;complex mask
	jsr generate_ball_line_idx
	lda #$a9	;"LDA #$xx"
	jsr generate_byte
	lda (p1),y
	jsr generate_byte
	lda #$91	;"STA (ballsp1),Y"
	jsr generate_byte
	lda #<ballsp1
	jsr generate_byte
	jmp generate_ball_line_byte2
generate_ball_line_byte1
	lda #$a0	;"LDY #$xx"
	jsr generate_byte
	txa
	jsr generate_byte
	lda #$b1	;"LDA (ballsp1),Y"
	jsr generate_byte
	lda #<ballsp1
	jsr generate_byte
	lda #$29	;"AND #$xx"
	jsr generate_byte
	lda (p2),y
	jsr generate_byte
	lda #$09	;"ORA #$xx"
	jsr generate_byte
	lda (p1),y
	jsr generate_byte
	lda #$91	;"STA (ballsp1),Y"
	jsr generate_byte
	lda #<ballsp1
	jsr generate_byte
generate_ball_line_byte2
	dic p1
	dic p2
	rts

generate_ball_line_idx
	txa
	sec
	sbc x2
	cmp #1
	beq generate_ball_line_idx1
	lda #$a0	;"LDY #$xx"
	jsr generate_byte
	txa
	jmp generate_ball_line_idx2
generate_ball_line_idx1
	lda #$c8
generate_ball_line_idx2
	jsr generate_byte ;"INY"
	stx x2
	rts

; Store the byte in <A> to the current location pointed to by p3 and increment the pointer.
generate_byte
	sta (p3),y
	dic p3
	rts