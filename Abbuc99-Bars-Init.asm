; 
; ABBUC 99 Intro - Bars Init Include
;
; (c) 2009-11-29 by JAC!

; This initialization is located in the SM buffer and can
; be overwritten by the drawing of the balls


; PM bar colors, heights, x and y positions
bar12c	= $b8
bar12h	= $60+$18
bar1x	= $30+$10
bar1y	= $08
bar2x	= $b0-$10
bar2y	= $80

bar34c	= $38
bar34h	= $1f
bar3x	= $b0+8
bar3y	= $22
bar4x	= $30-8
bar4y	= [$20+$c0-bar34h]

barsposmax = $c0 ;Number of user bytes in the barbouncetab

;==========================================================
init_bars
	lda #0
	tax
init_bars_clrpm
	sta pm+$300,x
	sta pm+$400,x
	sta pm+$500,x
	sta pm+$600,x
	sta pm+$700,x
	inx
	bne init_bars_clrpm

	lda #>pm
	sta $d407
	lda #3
	sta $d01d
	lda #$11		;5th player
	sta $d01b

; Compute PM source graphics, 3 pages to be stored at pm+$400 later
	ldx #0
	ldy #0
init_bars_fillpm1	
	lda pmabbuc,y
	sta barpmsrc+$000+bar1y,x	;bar1 text
	lda pmabbuc+1,y
	sta barpmsrc+$100+bar1y,x	

	lda #$7e
	cpx #bar12h-1
	bcc *+4
	lda #0
	sta barpmsrc+$200+bar1y,x	;bar1 background

	lda pmissue,y		;bar2 text
	sta barpmsrc+$000+bar2y,x
	lda pmissue+1,y
	sta barpmsrc+$100+bar2y,x
	lda #$7e
	cpx #1
	bcs *+4
	lda #0
	sta barpmsrc+$200+bar2y,x	;bar2 background

	iny
	iny

	inx
	cpx #bar12h
	bne init_bars_fillpm1

;	bar1 and bar2 text
	lda #14
	sta $d012	;COLP0
	sta $d013	;COLP1
	lda #0
	sta $d008	;SIZEP0
	sta $d009	;SIZEP1

;	bar1 and bar2 background
	lda #bar12c
	sta $d014	;COLP2
	lda #$ff
	sta $d00a	;SIZEP2

	ldx #0
init_bars_fillpm2
	lda #$ff
	sta pm+$300+bar3y,x	;bar3 background
	sta pm+$300+bar4y,x	;bar4 background

	inx
	cpx #bar34h
	bne init_bars_fillpm2

	lda #0
	jsr set_issue
		
;	bar3 and bar4 text
	lda #14			;COLP3
	sta $d015
	lda #1
	sta $d00b		;SIZEP3
	
;	bar3 and bar4 background
	lda #bar34c
	sta $d019		;COLPF3
	lda #$ff
	sta $d00c		;SIZEM

	rts