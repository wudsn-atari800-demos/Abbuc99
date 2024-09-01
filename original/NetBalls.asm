;	>>> NetBalls <<<
;
;	The original implementation that was later
;	used in the ABBUC Magazine 99 intro.
;
;	(c) by JAC of WUDSN ursel on 07-07-1991.
;	(r) by JAC on 12-02-2009 from binary.

irqa	= $00
irqx	= $01
dliup	= $03

p1	= $80
p2	= $82
p3	= $84

x1	= $e0
x2	= $e1
x3	= $e2

cnt	= $fe	;$00-$ff
smcnt	= $ff	;$00-smmax


sintab	= $2000
netpic	= $2100
netmask	= $2600
chr	= $2c00

smbase	= $6000	; up to $beff
smsize	= $280	;15*40 = 600 = $258
smmax	= $24	;$24*$280 = $5a00

balls	= 11


*	= $4000
dl	.byte $70,$70,$80
	.byte $4e
lms1	.word 0
	.byte $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$8e,$00
	.byte $4e
lms2	.word 0
	.byte $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$8e,$00
	.byte $4e
lms3	.word 0
	.byte $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$8e,$00
	.byte $4e
lms4	.word 0
	.byte $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$8e,$00
	.byte $4e
lms5	.word 0
	.byte $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$8e,$00
	.byte $4e
lms6	.word 0
	.byte $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$8e,$00
	.byte $4e
lms7	.word 0
	.byte $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$8e,$00
	.byte $4e
lms8	.word 0
	.byte $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$8e,$00
	.byte $70,$70,$70,$70,$70,$70,$70
	.byte $42
	.word text
	.byte $70,$02,$30,$02
	.byte $41
	.word dl
text
	.byte "            ", 34, "NetBalls 1.1", 34, "              "
	.byte "(c) by JAC of WUDSN ursel on 07-07-1991."
	.byte "(r) by JAC on 12-02-2009 from binary.   "

smoffsettab	; 36 entries, each $280 bytes, 6*%280 = $f00 bytes per $1000 block to pervent LMS overrun
	.word $0000+smsize*$00,$0000+smsize*$01,$0000+smsize*$02,$0000+smsize*$03,$0000+smsize*$04,$0000+smsize*$05
	.word $1000+smsize*$00,$1000+smsize*$01,$1000+smsize*$02,$1000+smsize*$03,$1000+smsize*$04,$1000+smsize*$05
	.word $2000+smsize*$00,$2000+smsize*$01,$2000+smsize*$02,$2000+smsize*$03,$2000+smsize*$04,$2000+smsize*$05
	.word $3000+smsize*$00,$3000+smsize*$01,$3000+smsize*$02,$3000+smsize*$03,$3000+smsize*$04,$3000+smsize*$05
	.word $4000+smsize*$00,$4000+smsize*$01,$4000+smsize*$02,$4000+smsize*$03,$4000+smsize*$04,$4000+smsize*$05
	.word $5000+smsize*$00,$5000+smsize*$01,$5000+smsize*$02,$5000+smsize*$03,$5000+smsize*$04,$5000+smsize*$05

xoffsettab
	.byte $00,$05,$0a,$0f	;low byte offet for shifted balls (0 to 3 pixel)
	
colortab
	.byte $34,$24,$e4,$c4,$a4,$84,$64,$44
nmi
	sta irqa 
	stx irqx 
	bit $d40f ;nmist 
	bmi dli 
	lda #$00 
	sta dliup 
nmiend	ldx irqx 
	lda irqa 
	rti
 
dli	ldx dliup 
	cpx #$08 
	beq dli2 
	lda colortab,x 
	clc
	sta $d40a
	sta $d018 ;colpf2 
	adc #$04 
	sta $d017 ;colpf1 
	adc #$04 
	sta $d016 ;colpf0 
	inc dliup
	jmp nmiend
 
dli2	lda cnt 
	and #$1f 
	cmp #$10 
	bcc *+4 
	eor #$1f 
	sta $d017 ;colpf1 
	lda #0 
	sta $d018 ;colpf2 
	jmp nmiend 

start
	cld 
	sei 
	lda #$00 	
	sta $d40e ;nmien 
	sta $d20e ;irqen 
	tax 
init1	sta $d400,x ;dmactl
	sta $d000,x ;hposp0
	inx 
	bne init1 
	lda #$ff 
	sta $d301 ;portb 
init2	lda #$00 
	sta chr,x 
	lda $e000,x 
	sta chr+$100,x 
	lda $e100,x 
	sta chr+$200,x 
	lda $e300,x 
	sta chr+$300,x 
	inx 
	bne init2 
	lda #$fe 
	sta $d301 ;portb 
	lda #<dl 
	sta $d402 ;dlistl 
	lda #>dl 
	sta $d403 ;dlisth 
	lda #<nmi 
	sta $fffa 
	lda #>nmi
	sta $fffb 
	lda #>chr
	sta $d409 ;chbase 
	lda #$22 
	sta $d400 ;dmactl 
	lda #$c0 
	sta $d40e ;nmien 

	lda #0 
	sta cnt 
	sta smcnt
main
	lda $d20a
	sta $d01a
	lda #$5a
	cmp $d40b ;vcount 
	bne main
	lda #$34 
	sta $d40a ;wsync 
	lda #$00 
	sta $d40a ;wsync
	lda #$32
	sta $d01a
	jsr setlms 
	lda #$44
	sta $d01a
	jsr clearsm 
	lda #$02
	sta $d01a
	jsr drawballs
	jsr count 
	lda #0
	sta $d40a ;wsync 
	lda #0
	sta $d40a ;wsync 
	jmp main

	.macro setlm
	lda smoffsettab,x 
	clc 
	adc #<smbase
	sta %1 
	lda smoffsettab+1,x 
	adc #>smbase
	sta %1+1 
	inx 
	inx 
	inx 
	inx 
	inx 
	inx 
	inx 
	inx 
	cpx #[2*smmax] 
	bcc *+7
	txa 
	sec 
	sbc #[2*smmax]  
	tax 
	.endm

setlms	lda smcnt 
	asl 
	tax

	setlm lms1
	setlm lms2
	setlm lms3
	setlm lms4
	setlm lms5
	setlm lms6
	setlm lms7
	setlm lms8
	setlm smadr 
	rts 

smadr	.word 0

count
	inc cnt

	inc smcnt 
	lda smcnt
	cmp #smmax 
	bne *+4 
	lda #0 
	sta smcnt
	rts

; Clear $280 bytes starting at "smadr"
clearsm
	lda $d20f ;skstat 
	and #$0c 
	cmp #$0c 
	beq *+3 
	rts
	
	lda smadr 
	sta clearsm1+1
	sta clearsm3+1
	sta clearsm5+1
	ldx smadr+1
	stx clearsm1+2 
	inx 
	stx clearsm3+2 
	inx 
	stx clearsm5+2

	clc 
	lda smadr 
	adc #$80 
	sta clearsm2+1
	sta clearsm4+1
	lda smadr+1 
	adc #0 
	sta clearsm2+2 
	clc 
	adc #1 
	sta clearsm4+2 
	lda #0 
	tay 

clearsm1
	sta $9a00,y 
clearsm2
	sta $9a80,y 
clearsm3
	sta $9b00,y 
clearsm4
	sta $9b80,y 
clearsm5
	sta $9c00,y 
	iny 
	bpl clearsm1
	rts 

	.macro copyline
	ldy #<[%1*40]
	lda (p3),y
	and (p2),y 
	ora (p1),y 
	sta (p3),y
	iny 
	lda (p3),y
	and (p2),y 
	ora (p1),y 
	sta (p3),y
	iny 
	lda (p3),y
	and (p2),y 
	ora (p1),y 
	sta (p3),y
	iny 
	lda (p3),y
	and (p2),y 
	ora (p1),y 
	sta (p3),y
	iny 
	lda (p3),y
	and (p2),y 
	ora (p1),y 
	sta (p3),y
	.endm


drawball
	lda x1 
	and #$03 
	tay 
	lda xoffsettab,y 
	sta p1 
	sta p2 
	lda #>netpic
	sta p1+1 
	lda #>netmask
	sta p2+1 
	lda x1 
	lsr 
	lsr 
	clc 
	adc smadr 
	sta p3 
	lda smadr+1 
	adc #0 
	sta p3+1 

	copyline 0
	copyline 1
	copyline 2
	copyline 3
	copyline 4
	copyline 5
	copyline 6

	inc p1+1 
	inc p2+1 
	inc p3+1
	
	copyline 7
	copyline 8
	copyline 9
	copyline 10
	copyline 11
	copyline 12
	inc p1+1 
	inc p2+1 
	inc p3+1

	copyline 13
	copyline 14
	rts 

drawballs
	lda cnt 
	sta x2 
	ldx #balls
drawballs1
	ldy x2
	lda sintab,y 
	ldy x3 
	clc 
	adc sintab,y 
	ror 
	sta x1 
	clc 
	lda x2 
	adc #$0e 
	sta x2 
	jsr drawball
	dex 
	bne drawballs1 
	clc 
	lda x3 
	adc #$02 
	sta x3 
	rts
	
*	= sintab
	.incbin "NetBalls.sin"	;Sinus256.sin

*	= netpic
	.incbin "NetBalls.pic"	;15 lines *40 bytes = 600 bytes picture 

*	= netmask
	.incbin "NetBalls.mask"	;15 lines *40 bytes = 600 bytes picture 


*	= $2e0 
	.word start
