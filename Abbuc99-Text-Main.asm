; 
; ABBUC 99 Intro - Nettext Main Include
;
; (c) 2009-11-29 by JAC!
; (r) 2010-05-27 by JAC! scroll text type fixed, 240 scan lines used, thanks to Rybags tip siwtch off the DMA before the end of the last line


; This section must start on a page boundary
; A normal text line is one scan line high.
textdc	= $1f

;	18 bytes
	.macro define_text_dl_row
	.word 0
	.byte textdc,textdc,textdc,textdc,textdc,textdc,textdc
	.byte textdc,textdc,textdc,textdc,textdc,textdc,textdc,$80
	.byte $40+textdc
	.endm

textdl		.byte $40+textdc
textdllms1	define_text_dl_row
textdllms2	define_text_dl_row
textdllms3	define_text_dl_row
textdllms4	define_text_dl_row
textdllms5	define_text_dl_row
textdllms6	define_text_dl_row
textdllms7	define_text_dl_row
textdllms8	define_text_dl_row
textdllms9	define_text_dl_row
textdllmsa	define_text_dl_row
textdllmsb	define_text_dl_row
textdllmsc	define_text_dl_row
textdllmsd	define_text_dl_row
textdllmse	define_text_dl_row
textdllmsf	define_text_dl_row
textdllmsg	.word 0
		.byte textdc,textdc,textdc,textdc,textdc,textdc,textdc
		.byte textdc,textdc,textdc,textdc,textdc,textdc,textdc,$00

		.byte $00,$00,$00,$00
	
textdllmstmp	.word 0

; Pattern to fill the first section of the dl up to dllms1
textdlpattern	.byte $40+textdc
		define_text_dl_row

; Macro	6*$280 = $f00 bytes per $1000 block to pervent LMS overrun
	.macro define_text_sm_offset
	.word %1+textsmsize*$00,%1+textsmsize*$01,%1+textsmsize*$02,%1+textsmsize*$03,%1+textsmsize*$04,%1+textsmsize*$05
	.endm

; Macro	5*3 = 20 entries, each 2*$280 bytes
	.macro define_text_sm_offsets
	define_text_sm_offset $4000
	define_text_sm_offset $6000
	define_text_sm_offset $7000
	define_text_sm_offset $9000
	define_text_sm_offset $a000
	define_text_sm_offset $b000
;	define_text_sm_offset $c000
	.endm

textbuffer = $c000

; This one should not cross a page boundary	
textsmtab	
	define_text_sm_offsets
	define_text_sm_offsets

textsmadr
	.word $4000

; Used by macro "set_text_dllms". This one should not cross a page boundary
textlmsoffset
	.byte 0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60
	.byte 0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60	; roll-over copy

;==========================================================
; VBI sub routines before and after the counter increment

text_vbi_jsr1
	jsr set_text_dl
	jsr set_text_colors
	lda #$3d
	sta $d400 
	set [dli_jsr+1], text_dli_jsr
	rts

text_vbi_jsr2
	jsr animate_text 
	rts

;==========================================================
; DLI sub routine to set the text colors.

text_dli_jsr

set_text_colors
	ldx textycntdli
	lda textscrolltab1,x
	sta $d404
	lda textcolortab1,x
	sta $d017  
	inc textycntdli
	lda $d40b
	cmp #$74
	bcs set_text_colors2
	rts

set_text_colors2
	lda $d40b
	cmp #$7b
	bcc set_text_colors2
	sta $d40a
	nop
	nop
	nop
	nop
	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
	lda #$00	;Switch off DMA before and of last scanline
	sta $d400
	sta $d40a
	lda #$3d	;Restore old value 
	sta $d400
	rts
	
;==========================================================
; Macro to copy the LMS offsets into the actual DL instructions
; The current <textycnt> value is in <X>
	.macro set_text_dllms
	lda #<[[%1]*16+15]
	sec
	sbc textxcnt
	tay
	lda textsintab,y

	ldy [textlmsoffset],x
	lsr
	pha
	php
	lsr 
	lsr
	sta textxpos
	lda #20
	sec
	sbc textxpos
	clc
	adc textsmtab,y
	sta %2
	lda textsmtab+1,y
	sta %2+1
	plp
	bcc *+2+17
	add %2,textsmsize

	pla
	and #3
	sta textscrolltab1,x
	sta textscrolltab1+textycntmax,x
	inx
	.endm

; VBI routine to set LMS offsets into the actual DL instructions and $230
set_text_dl

;	Restore the first part of the DL for later modification
	ldx #17
set_text_dl1
	lda textdlpattern,x
	sta textdl,x
	sta textdllmsf-1,x
	sta textdllmsg-1,x
	dex
	bpl set_text_dl1
	
;	Prepare next DLI sequence
	ldx textycnt
	stx textycntdli

;	Copy the LMS points for first text line
	set_text_dllms 0,textdllmstmp
	
;	Compute additional LMS offset for first LMS command
	lda textxcnt
	and #$0f
	asl
	tax
	lda lineoffsettab,x
	clc
	adc textdllmstmp
	sta textdllmstmp
	lda lineoffsettab+1,x
	adc textdllmstmp+1
	sta textdllmstmp+1

;	Compute DL command for the first DL line
	ldx textxcnt
	lda #$40+textdc
	cpx #15
	bcc set_text_dlline0to14 ;lines 0-14
	ldx #17			 ;line 15 (index for blank)
	lda #$00		 ;line 15 (dc for one line blank)
	sta textdl,x
	inc textycntdli	;instead of DLI flag in blank lines
	jmp set_text_dllastline

set_text_dlline0to14
	sta textdl,x
	lda textdllmstmp
	sta textdllms1,x

	lda textdllmstmp+1
	sta textdllms1+1,x

;	Set the DL pointer early enought during VBI, otherwise vsync will fail
set_text_dllastline
	stx $d402 	;dlistl 
	lda #>textdl 
	sta $d403 	;dlisth

	
;	Copy the LMS points for all remaining text lines
	ldx textycnt
	inx
	set_text_dllms 1,textdllms2
	set_text_dllms 2,textdllms3
	set_text_dllms 3,textdllms4
	set_text_dllms 4,textdllms5
	set_text_dllms 5,textdllms6
	set_text_dllms 6,textdllms7
	set_text_dllms 7,textdllms8
	set_text_dllms 8,textdllms9
	set_text_dllms 9,textdllmsa
	set_text_dllms 10,textdllmsb
	set_text_dllms 11,textdllmsc
	set_text_dllms 12,textdllmsd
	set_text_dllms 13,textdllmse
	set_text_dllms 14,textdllmsf
	set_text_dllms 15,textdllmsg

;	The following lines are only required, if the display must be restricted to 239 lines
;	ldx textxcnt
;	cpx #2
;	bcc zero
;	inx
;	inx
;zero	lda #$41
;	sta textdllmsg-2,x
;	lda #<textdl
;	sta textdllmsg+1,x
;	lda #>textdl
;	sta textdllmsg+0,x
	rts

;==========================================================
; VBI routine to animate the text, i.e. count textxcnt and textycnt

animate_text
	inc textxcnt
	lda textxcnt
	cmp #textxcntmax
	bne animate_text2
	lda #0
	sta textxcnt

	inc textycnt
	lda textycnt
	cmp #textycntmax
	bne animate_text3
	lda #0
	sta textycnt
animate_text3
	clc
	adc #15
	cmp #textycntmax
	bcc *+4
	sbc #textycntmax
	sta text_next_index
	lda #1
	sta text_next_flag
animate_text2
	rts

text_next_flag	.byte 0
text_next_index	.byte 0

;==========================================================
; Main loop to print the text
print_text
	lda #textycntmax
	sta printfadelines

print_text_loop
	lda text_next_flag
	beq print_text_loop
	lda #0
	sta text_next_flag

; The first char is the color code or "eof" or "eop"
	ldy #0
print_text_first_byte1
	lda (pt),y
	dic pt
	cmp #eof
	bne print_text_first_byte2
	set pt,text
	bne print_text_first_byte1
print_text_first_byte2
	cmp #eop
	beq print_text_last_line

	ldx text_next_index
	sta textcolortab1,x
	sta textcolortab1+textycntmax,x

	jsr clear_text_buffer
	lda endflag
	bne print_text_last_char

	ldx #4+20
print_text_next_char
	ldy #0
print_text_next_char1
	lda (pt),y
print_text_next_char2
	dic pt
	cmp #eol
	beq print_text_last_char
	ldy #0
	sty p1+1
	asl
	rol p1+1
	asl
	rol p1+1
	asl
	rol p1+1
	sta p1
	clc
	lda p1+1
	adc #>chr
	sta p1+1

	jsr print_char
	jmp print_text_next_char

print_text_last_char
	ldx text_next_index
	ldy textlmsoffset,x
	lda textsmtab,y
	sta p1
	sta p2
	lda textsmtab+1,y
	sta p1+1
	sta p2+1
	add p2,textsmsize
	jsr copy_text_buffer
	lda endflag
	jeq print_text_loop
	dec printfadelines
	jne print_text_loop

print_text_last_line
	rts

printfadelines	.byte 0

;==========================================================
; Prints 8 lines of the 1x1 character at <(P1)> to <textbuffer,x> and increments <X>
print_char
	ldy #0
;	lda (p1),y
;	sta textbuffer+linewidth*0,x
;	iny
	lda (p1),y
	sta textbuffer+linewidth*1,x
	iny
	lda (p1),y
	sta textbuffer+linewidth*2,x
	iny
	lda (p1),y
	sta textbuffer+linewidth*3,x
	iny
	lda (p1),y
	sta textbuffer+linewidth*4,x
	iny
	lda (p1),y
	sta textbuffer+linewidth*5,x
	iny
	lda (p1),y
	sta textbuffer+linewidth*6,x
	iny
	lda (p1),y
	sta textbuffer+linewidth*7,x
	iny
	lda (p1),y
	sta textbuffer+linewidth*8,x
	inx
	rts

;==========================================================
; Clear $280 bytes of text memory starting at "textbuffer"
clear_text_buffer
	lda #0 
	tay
clear_text_buffer1
	sta textbuffer,y 
	sta textbuffer+$80,y 
	sta textbuffer+$100,y 
	sta textbuffer+$180,y 
	sta textbuffer+$200,y 
	iny 
	bpl clear_text_buffer1
	rts 

;==========================================================
; Shifts copy the text from "textbuffer" to (p1) and ror'ed once to (p2)
copy_text_buffer
	ldy #0
	clc
copy_text_buffer1
	lda textbuffer,y
	sta (p1),y
	ror
	sta (p2),y
	iny
	bne copy_text_buffer1
	inc p1+1
	inc p2+1
copy_text_buffer2
	lda textbuffer+$100,y
	sta (p1),y
	ror
	sta (p2),y
	iny
	bne copy_text_buffer2
	inc p1+1
	inc p2+1
copy_text_buffer3
	lda textbuffer+$200,y
	sta (p1),y
	ror
	sta (p2),y
	iny
	bpl copy_text_buffer3
	rts

;==========================================================
; Non VBI routine to fade out all text to black

;fadetextycnt	.ds 0
;
;fade_text
;	lda textxcnt
;	bne fade_text
;	lda #textycntmax
;	sta fadetextycnt
;	ldy textycnt
;fade_text1
;	lda textcolortab1,y
;	jsr fadecolor
;	sta textcolortab1,y
;	sta textcolortab1+textycntmax,y
;	lda #1
;	jsr wait
;	lda textcolortab1,y
;	bne fade_text1
;
;	iny
;	cpy #textycntmax
;	bne *+4
;	ldy #0
;
;	dec fadetextycnt
;	bne fade_text1
;
;	lda #0
;	sta textflag
;	rts



text	.byte $0e," ABBUC MAGAZIN  ",eol 
	.byte $0e,"    ISSUE 99    ",eol
	.byte $06,"  DECEMBER 2009 ",eol
	.byte $0a,"  WWW.ABBUC.DE  ",eol
	.rept 4
	.byte 0,eol
	.endr
	.byte $0e," CODE: JAC/WUDSN",eol
	.byte $0e,"   PETER DELL   ",eol
	.byte $06,"8 BIT ARE ENOUGH",eol
	.byte $0a,"  WWW.WUDSN.COM ",eol
	.rept 4
	.byte 0,eol
	.endr
	.byte $0e,"   MSX: 505/CP  ",eol
	.byte $0e,"   NILS FESKE   ",eol
	.byte $06,"FINE ATARI TUNES",eol
	.byte $0a,"  505.ATARI.ORG ",eol
	.rept textycntmax
	.byte 0,eol
	.endr
	.byte eop
	
	.byte $0e,"   THANKS TO:   ",eol
	.byte 0,eol
	.byte $0e,"    PATRICIA    ",eol
	.byte $0a,"   FOR ALL HER  ",eol
	.byte $06,"  PATIENCE AND  ",eol
	.byte $06," MORAL SUPPORT  ",eol
	.byte 0,eol
	.byte $0e,"     HELENA     ",eol
	.byte $0a,"  FOR SAYING    ",eol
	.byte $06," HEY DAD I LIKE ",eol
	.byte $06,"  THOSE MOVING  ",eol
	.byte $06,"     MARBELS    ",eol

	.rept textycntmax
	.byte 0,eol
	.endr
	.byte eop
	
	.byte $0e," GREETINGS TO: ",eol
	.byte $06,"     505       ",eol
	.byte $08," ABBUC MEMBERS ",eol
	.byte $0a,"   ABBUC RAF   ",eol
	.byte $0c,"ALL ATARIAGERS ",eol
	.byte $0e,"     ERU       ",eol
	.byte $0c,"    FANDAL     ",eol
	.byte $0a," FLASHJAZZCAT  ",eol
	.byte $08,"     FOX       ",eol
	.byte $06,"    HEAVEN     ",eol
	.byte $08," HOMECON TEAM  ",eol
	.byte $0a," LARESISTANCE  ",eol
	.byte $0c,"   MAD TEAM    ",eol
	.byte $0e,"     MAPA      ",eol
	.byte $0c,"     MEC       ",eol
	.byte $0a,"    RASTER     ",eol
	.byte $08,"    SPOOKT     ",eol
	.byte $06,"     TOXI      ",eol
	.byte $08,"     TWH       ",eol
	.byte $0a,"   TIGERDUCK   ",eol
	.byte $0c,"     XXL       ",eol
	.byte 0,eol
	.byte 0,eol
	.byte 0,eol
	.byte $08,"AND ALL THOSE  ",eol
	.byte $0a," CRAZY ACTIVE  ",eol
	.byte $0e," ATARI LOVERS  ",eol
	.byte $0a," I FORGOT TO   ",eol
	.byte $08,"   MENTION     ",eol
	.rept textycntmax
	.byte 0,eol
	.endr
	.byte eop

	.byte $0e,"TECHNICAL INF0:",eol
	.byte $00,eol
	.byte $08," IT'S ISSUE 99 ",eol
	.byte $0a," SO I CREATED  ",eol
	.byte $0a," 99 ONE FRAMED ",eol
	.byte $0c," SOFTSPRITES   ",eol
	.byte $00,eol
	.byte $00,eol
	.byte $0e,"       ...     ",eol
	.byte $00,eol
	.byte $00,eol
	.byte $06," OF COURSE NOT ",eol
	.byte $08,"REALLY BUT HEY ",eol
	.byte $0a," THERE ARE 99  ",eol
	.byte $0c,"   BALLS AND   ",eol
	.byte $0e,"THEY LOOK NICE!",eol
	.byte $00,eol
	.byte $00,eol
	.byte $08,"  EVEN THOUGH  ",eol
	.byte $0a,"THERE IS ALSO A",eol
	.byte $0e,"  REAL RECORD: ",eol
	.byte $0a," THE BALLS RUN ",eol
	.byte $0e,"  WITH FULL    ",eol
	.byte $0e," 240 SCANLINES!",eol
	.byte $00,eol
	.byte $08,"NORMALLY THERE ",eol
	.byte $0a,"  CAN ONLY BE  ",eol
	.byte $0c," 239 SCANLINES ",eol
	.byte $0a,"DISPLAYED ON A ",eol
	.byte $08,"   PAL ATARI   ",eol
	.byte $00,eol
	.byte $08,"SO WE ARE AGAIN",eol
	.byte $0a,"ONE STEP CLOSER",eol
	.byte $0c," TO FULL HD TV ",eol
	.byte $0a,"ON THE ATARI ;)",eol
	.byte $00,eol
	.byte $08,"PRESS ANY KEY ",eol
	.byte $0a,"OR TRIGGER TO ",eol
	.byte $0c,"     EXIT     ",eol
	.rept textycntmax
	.byte 0,eol
	.endr
	.byte eop


	.byte eof
	



