; 
; ABBUC 99 Intro - Bars Main Include
;
; (c) 2009-11-29 by JAC!
;
; @com.wudsn.ide.asm.mainsourcefile=Abbuc99.asm


; Sets position and colors of the bars for next screen start
set_bars_top
	clc
bar1xpos
	lda #bar1x
	sta $d002
	adc #$08
	sta $d000
	adc #$08
	sta $d001
bar1color
	lda #14
	sta $d012
	sta $d013

bar3xpos
	lda #0
	sta $d007
	adc #$05
	sta $d003
	adc #$03
	sta $d006
	adc #$08
	sta $d005
	adc #$08
	sta $d004
bar3color
	lda #14
	sta $d015
	rts

;==========================================================
; Sets position and colors of the bars for next screen start
set_bars_middle
	lda $d40b
	cmp #$30
	bcc set_bars_middlex
	cmp #$40
	bcs set_bars_middlex

	lda #$3e
	cmp $d40b
	bcs *-5
	sta $d40a

bar2xpos
	lda #bar2x
	sta $d002
	adc #$08
	sta $d000
	adc #$08
	sta $d001
bar2color
	lda #14
	sta $d012
	sta $d013
bar4xpos
	lda #0
	sta $d007
	adc #$08
	sta $d003
	sta $d006
	adc #$08
	sta $d005
	adc #$08
	sta $d004
bar4color
	lda #14
	sta $d015
set_bars_middlex
	rts

;==========================================================

barscolors .dc 4 14

set_bars_flash
	lda barsflashflag
	beq set_bars_flashx
	lda cnt
	and #63
	cmp #16
	bcs set_bars_flashx
	and #15
	bne set_bars_flash2
set_bars_flash1
	lda $d20a
	and #3
	cmp barsflashbar
	beq set_bars_flash1
	sta barsflashbar
set_bars_flash2
	asl
	cmp #16
	bcc *+4
	eor #31
	eor #15
	ldx barsflashbar
	sta barscolors,x
set_bars_flashx
	lda barscolors+0
	sta bar1color+1
	lda barscolors+1
	sta bar2color+1
	lda barscolors+2
	sta bar3color+1
	lda barscolors+3
	sta bar4color+1
	rts

; Wait until flashing is over
wait_bars_flash
	lda #1
	jsr wait
	lda cnt
	and #63
	cmp #17
	bcc wait_bars_flash
	rts

;==========================================================

barsdelay = 40

barswait	.ds 4
barspos		.ds 4
barscnt		.ds 1

; Fading the bars on
bars_on
	lda #1
	sta ballsflag
	
	ldx #0
	ldy #0
bars_on0
	tya
	sta barswait,x
	clc
	adc #barsdelay
	tay
	lda #1
	sta barspos,x
	inx
	cpx #4
	bne bars_on0

	lda #0
	sta bar3xpos+1
	sta bar4xpos+1
	

bars_on2
	ldx #3
	stx barscnt
bars_on3
	ldx barscnt
	lda barswait,x
	beq bars_on4
	dec barswait,x
	jmp bars_onx
bars_on4
	lda barspos,x
	cmp #barsposmax
	beq bars_onx
	inc barspos,x
	tay
	cpx #0
	bne *+5+3
	jsr do_bar0
	jmp bars_onx
	cpx #1
	bne *+5+3
	jsr do_bar1
	jmp bars_onx
	cpx #2
	bne *+5+3
	jsr do_bar2
	jmp bars_onx
	jsr do_bar3
bars_onx
	dec barscnt
	bpl bars_on3

	lda #1
	jsr wait
	
	lda barspos
	bne bars_ony

bars_ony
	lda #barsposmax
	cmp barspos+0
	bne bars_on2
	cmp barspos+1
	bne bars_on2
	cmp barspos+2
	bne bars_on2
	cmp barspos+3
	bne bars_on2
	rts

	
;==========================================================
; Fading the bars off
bars_off
	ldx #0
	ldy #[3*barsdelay]
bars_off0
	tya
	sta barswait,x
	clc
	adc #barsdelay
	tay
	lda #barsposmax-1
	sta barspos,x
	inx
	cpx #4
	bne bars_off0

bars_off2
	ldx #3
	stx barscnt
bars_off3
	ldx barscnt
	lda barswait,x
	beq bars_off4
	dec barswait,x
	jmp bars_offx
bars_off4
	lda barspos,x
	beq bars_offx
	dec barspos,x
	tay
	cpx #0
	bne *+5+3
	jsr do_bar0
	jmp bars_offx
	cpx #1
	bne *+5+3
	jsr do_bar1
	jmp bars_offx
	cpx #2
	bne *+5+3
	jsr do_bar2
	jmp bars_offx
	jsr do_bar3
bars_offx
	dec barscnt
	bpl bars_off3

	lda #1
	jsr wait
	lda barspos
	ora barspos+1
	ora barspos+2
	ora barspos+3
	bne bars_off2
	rts

;==========================================================
; Do the "ABBUC" bar
do_bar0
	lda barsbouncetab,y
	tay
	ldx #0
do_bar01
	cpy #$80
	bcs do_bar02

	lda barpmsrc+$000,y
	sta pm+$400,x
	lda barpmsrc+$100,y
	sta pm+$500,x
	lda barpmsrc+$200,y
	sta pm+$600,x
	iny
	jmp do_bar03
do_bar02
	lda #0
	sta pm+$400,x
	sta pm+$500,x
	sta pm+$600,x
do_bar03
	inx
	cpx #$80
	bne do_bar01
	rts

; Do the "ISSUE" bar
do_bar1	lda #$81
	clc
	adc barsbouncetab,y
	bcc *+4
	lda #$ff
	sta do_bar11+1
	ldy #0
	ldx #$80
do_bar11
	cpx #$ff
	bcc do_bar12

	lda barpmsrc+$081,y
	sta pm+$400,x
	lda barpmsrc+$181,y
	sta pm+$500,x
	lda barpmsrc+$281,y
	sta pm+$600,x
	iny
	jmp do_bar13
do_bar12
	lda #0
	sta pm+$400,x
	sta pm+$500,x
	sta pm+$600,x
do_bar13
	inx
	bne do_bar11
	rts

; Do the "99" bar on the upper right
do_bar2
	lda #bar3x
	sec
	sbc barsbouncetab,y
	bcs *+4
	lda #0
	sta bar3xpos+1
	rts

; Do the "99" bar on the lower left
do_bar3
	lda #bar4x
	clc
	adc barsbouncetab,y
	bcc *+4
	lda #0
	sta bar4xpos+1
	rts

;==========================================================
; Prints the issue number as PM graphics.
; <A> contains the number to be printed in BCD format.

issuedigitheight = 7

issuedigit
	.ds issuedigitheight

issuedigitpattern
	.byte $7,$5,$5,$5,$5,$5,$7,0	;0
	.byte $1,$1,$1,$1,$1,$1,$1,0	;1
	.byte $7,$1,$1,$7,$4,$4,$7,0	;2
	.byte $7,$1,$1,$7,$1,$1,$7,0	;3
	.byte $5,$5,$5,$7,$1,$1,$1,0	;4
	.byte $7,$4,$4,$7,$1,$1,$7,0	;5
	.byte $7,$4,$4,$7,$5,$5,$7,0	;6
	.byte $7,$1,$1,$1,$1,$1,$1,0	;7
	.byte $7,$5,$5,$7,$5,$5,$7,0	;8
	.byte $7,$5,$5,$7,$1,$1,$7,0	;9

set_issue
	pha
	and #$0f	;Compute lower digit offset.
	asl
	asl
	asl
	tax
	ldy #0		;Copy pattern for lower digit.
set_issue1
	lda issuedigitpattern,x
	sta issuedigit,y
	inx
	iny
	cpy #issuedigitheight
	bne set_issue1
	
	pla		;Compute upper digit offset.
	and #$f0
	lsr
	tax
	ldy #0		;Compute pattern for lower digit.
set_issue2
	lda issuedigitpattern,x
	asl
	asl
	asl
	asl
	ora issuedigit,y
	sta issuedigit,y
	inx
	iny
	cpy #issuedigitheight
	bne set_issue2
	
	ldx #0
	ldy #0
set_issue3
	lda issuedigit,y
	jsr set_issue4
	jsr set_issue4
	jsr set_issue4
	iny
	cpy #issuedigitheight
	bne set_issue3
	rts
	
set_issue4
	sta pm+$700+bar3y+5,x
	sta pm+$700+bar4y+5,x
	inx
	rts

