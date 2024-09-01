; 
; ABBUC 99 Intro - NetBalls
;
; ATASM source code format.
;
; This is the main file that defines the memory layout
; and contains all binary and source includes.
;
; The original version for ABBUC Magazin 99 was compiled on 2009-12-06.
; Fixed version with text and 240 scanlines text scroll compiled on 2010-06-19.

; Effect id
ballsid = 1

; Zero page addresses
ballszp = $80	;$66 bytes

; Zero page DLI colors for balls, must be at least 2*ballycntmax bytes
ballscolortab1	= ballszp+$06
ballscolortab2	= ballszp+$06+$20
ballscolortab3	= ballszp+$06+$40

; Effect id
textid = 2

; Zero page addresses
textzp = $80	;$66 bytes

; Zero page DLI colors and scroll positions for text, must be at least 2*textycntmax bytes
textcolortab1 = ballscolortab1
textscrolltab1 = ballscolortab2

; Zero page temporary pointers, not changed by VBI
p1	= $f0	;Common pointer 1
p2	= $f2	;Common pointer 2
p3	= $f4	;Common pointer 3
pt	= $f6	;Text pointer

; Zero page temporary variables, not changed by VBI
x1	= $f8
x2	= $f9

; Frame counter, changed by VBI
cnt	= $fa	;$00-$ff


; Use unused last page in sm area
sintab		= $4f00

; Sound routine, $800 bytes, uses $fc, $fd, $fe, $ff
sound		= $5000

; PM Graphics, $800 bytes
pm		= $5800

; Picture and mask have 15 lines *40 bytes = $258 = 600 bytes picture , will be overwritten
ballspic	= $6000
ballsmask	= $6300

; Bound sinus table, $C0 bytes
barsbouncetab	= $6f00

; Charset, $0400 bytes 
chr		= $8000

; Tune, $8400-$8890 = $491 bytes
tune		= $8400
sound_d200	= $8900

; Text horizontal sinus, $100 bytes
textsintab	= $9f00

; Start address for the 4 unrolled NetBall draw rountines
ballsdrawbase = $d800

; PM graphics source, $300 bytes
barpmsrc	= $e000
;==========================================================
; Standard includes

	.include "Macros.inc"

;==========================================================
; Pre-loader to fade the screen off

.bank 0
*	= $2000
init_loader
	jsr init_system
	jsr init_fade
	rts

; Check if this is PAL system and has 64k. 
; If not wait for a key and cold start.
init_system
	lda $d014
	and #2
	bne init_fail
	sei
	lda #0
	sta $d40e
	ldy #0
	lda $d301
	pha
	lda #$fe	;Disable OS ROM
	sta $d301
	ldx $e000	;Check if writeable
	inc $e000
	cpx $e000
	bne init_system1
	iny		;No
init_system1
	pla
	sta $d301
	lda #$40
	sta $d40e
	cli
	cpy #0
	bne init_fail
	rts

init_fail
	lda #14
	sta 708
	set $230,init_pal_dl
init_fail1
	lda $d40b
	clc
	adc 20
	sta $d40a
	sta $d01a
	lda $d20f
	and #12
	cmp #12
	beq init_fail1
	jmp $e474

	
init_pal_dl
	.byte $70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70
	.byte $46
	.word init_pal_sm
	.byte $70,$06
	.byte $70,$06
	.byte $41
	.word init_pal_dl

init_pal_sm
	.sbyte "REQUIRES PAL SYSTEM."
	.sbyte "  REQUIRES 64K RAM. "
	.sbyte "PRESS KEY TO REBOOT."

init_fade
	lda #0
	sta x2
	ldx #8
init_fade2
	lda 704,x
	pha
	and #$f0
	sta x1
	pla
	and #15
	beq init_fade3
	sec
	sbc #1
	ora x1
	sta x2
init_fade3
	sta 704,x
	dex
	bpl init_fade2
	lda 20
	clc
	adc #2
init_fade4
	cmp 20
	bne init_fade4
	lda x2
	bne init_fade
	rts

	.byte 0,155,10,13
	.byte "ABBUC 99 Intro by JAC!/Peter Dell. "
	.byte "Original version for ABBUC Magazin 99 compiled on 2009-12-06. "
	.byte "Fixed version for ABBUC Magazin 99 compiled on 2010-06-19. " 
	.byte 0,155,10,13
.bank 1
*	= $2e2
	.word init_loader

;==========================================================
; Main Intro
.bank
 
*	= $4000
init	cld 
	sei
	lda #$00 	
	sta $d40e ;nmien 
	sta $d20e ;irqen 
	tax 
init1	sta $d400,x ;dmactl
	sta $d000,x ;hposp0
	inx 
	bne init1

	lda #$fe 
	sta $d301 ;portb 
	set $fffa,nmi

	jsr init_bars
	jsr init_balls
	jsr init_text
	
	lda #0
	sta cnt
	rts

	.include "Abbuc99-Bars-Init.asm"
	.include "Abbuc99-Bars-PM.asm"
	.include "Abbuc99-NetBalls-Init.asm"
	.include "Abbuc99-Text-Init.asm"

;==========================================================
*	= $2000
	.include "Abbuc99-NetBalls-Main.asm"	; Must be at page boundary

; Common tables
linewidth	= 40
lineoffsettab
	.word $00*linewidth,$01*linewidth,$02*linewidth,$03*linewidth,$04*linewidth,$05*linewidth,$06*linewidth,$07*linewidth
	.word $08*linewidth,$09*linewidth,$0a*linewidth,$0b*linewidth,$0c*linewidth,$0d*linewidth,$0e*linewidth,$0f*linewidth

; Animation flags and counters
waitskip	.byte 0 ;$00 to keep waits, $01 to skip waits
waitcnt 	.byte 0	;Frame delay counter
effect		.byte 0	;Effect id, $00 is balls, $01 is text
barsflashflag	.byte 0	;$00 is flash is off, $01 is flash is on 
barsflashbar 	.byte 0	;0-3
ballsflag 	.byte 0	;$00 is balls are fading off, $01 balls are fading in
endflag		.byte 0	;$00 demo is running, $01 demo is ending


*	= $2500
	.include "Abbuc99-Text-Main.asm"	; Must be at page boundary

	.include "Abbuc99-Bars-Main.asm"

;==========================================================
; Main routine
start
	jsr init
	jsr sound_start

	jsr effects
	
	lda #25
	jsr wait
	jsr sound_fadeout
	lda #25
	jsr wait
	jsr sound_stop
	
	lda #0
	sta $d40e
	sta $d20e
	sta $d400
	lda #$ff
	sta $d301
	jmp $e474

;==========================================================
effects
	lda #ballsid
	jsr set_effect_first
	jsr wait_sync

	lda #$c0 
	sta $d40e ;NMIEN 

	jsr bars_on

	lda #75
	jsr wait	;TODO

	lda #0
effect_next_issue
	pha
	jsr set_issue
	
	lda #2
	jsr wait
	pla
	sed
	clc
	adc #1
	cld
	bcc effect_next_issue

	jsr wait_bars_flash
	lda #1
	sta barsflashflag

	set effectcnt,150

	set effectcnt,1		;TODO
	jsr effect_balls_loop
	lda endflag
	bne effect_any_end
	
effect_main_loop
	jsr effect_text
	
	jmp effect_main_loop	;TODO
	
	lda endflag
	bne effect_any_end
	jsr effect_balls
	lda endflag
	bne effect_any_end
	jmp effect_main_loop

effect_any_end
	jsr wait_bars_flash
	lda #0
	sta barsflashflag
	jsr bars_off
	rts

;==========================================================
; Counts down the work value in <effectcnt> once per frame until zero, returns 1 in case count down is over
effect_count_down
	lda #1
	jsr wait
	lda effectcnt
	ora effectcnt+1
	beq effect_count_down2	;zero reached
	dec effectcnt
	lda effectcnt
	cmp #$ff
	bne effect_count_down1
	dec effectcnt+1
effect_count_down1
	lda #0
	rts
effect_count_down2
	lda #1
	rts

effectcnt .word 0

;==========================================================
; Runs the balls effect
effect_balls
	lda #ballsid
	jsr set_effect

	lda #1
	sta ballsflag

	set effectcnt,600	;12 seconds

effect_balls_loop
	jsr effect_count_down
	bne effect_balls_end

	lda endflag
	beq effect_balls_loop
effect_balls_end
	jsr fade_balls
	rts

;==========================================================
; Runs the text effect

effect_text
	lda #textid
	jsr set_effect

	jmp print_text

;==========================================================
; Fades the color in <A>

fadecolor
	cmp #0
	beq fadecolorx
	pha
	and #$f0
	sta fadecolortmp
	pla
	and #15
	beq fadecolorx
	sec
	sbc #1
	ora fadecolortmp
fadecolorx
	rts

fadecolortmp
	.byte 0

;==========================================================
; Set effect in <A> and activate VBI and DLI subroutines

set_effect
	pha
	lda #1
	jsr wait
	set [vbi_jsr1+1], blank_vbi_jsr1
	set [vbi_jsr2+1], blank_vbi_jsr2
	lda #1
	jsr wait
	pla

; Set effect in <A> without waiting for a VBI
set_effect_first
	sta effect
	cmp #ballsid
	beq set_effect_balls
	cmp #textid
	beq set_effect_text
	jmp *

set_effect_balls
; Clear zero page and tables
	lda #0
	sta ballsxcnt
	sta ballsycnt
	sta ballsycntdli
	sta ballssmcnt
	ldx #[ballsycntmax*2-1]
set_effect_balls1
	sta ballscolortab1,x
	sta ballscolortab2,x
	sta ballscolortab3,x
	dex
	bpl set_effect_balls1

;	Set random ball sinus speed
	lda $d20a
	and #7
	clc
	adc #13
	sta draw_balls2+1

	jsr wait_sync
	set [vbi_jsr1+1], balls_vbi_jsr1
	set [vbi_jsr2+1], balls_vbi_jsr2
	rts

set_effect_text
; Clear zero page and tables
	lda #0
	sta textxcnt
	sta textycnt
	sta textycntdli
	ldx #[textycntmax*2-1]
set_effect_text1
	sta textcolortab1,x
	sta textscrolltab1,x
	dex
	bpl set_effect_text1

; Clear all SMs, 2*$280 bytes each
	ldx #0
set_effect_text2
	lda textsmtab,x
	sta p1
	inx
	lda textsmtab,x
	sta p1+1
	inx
	lda #0
	tay
set_effect_text_clear1
	sta (p1),y
	iny
	bne set_effect_text_clear1
	inc p1+1
set_effect_text_clear2
	sta (p1),y
	iny
	bne set_effect_text_clear2
	inc p1+1
set_effect_text_clear3
	sta (p1),y
	iny
	bpl set_effect_text_clear3
	cpx #[2*2*textycntmax]
	bne set_effect_text2

	jsr wait_sync
	set [vbi_jsr1+1], text_vbi_jsr1
	set [vbi_jsr2+1], text_vbi_jsr2
	rts


;==========================================================
blank_vbi_jsr1
	set $d402,blank_dl
	set [dli_jsr+1],blank_dli_jsr
	lda #$3e
	sta $d400
blank_vbi_jsr2
blank_dli_jsr
	rts

blank_dl
	.byte $70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$80,$41
	.word blank_dl

;==========================================================
; Main NMI routine

nmi_jsr_none
	rts

nmi	bit $d40f ;NMIST 
	bpl vbi

;==========================================================
dli	pha
	txa
	pha
dli_jsr	jsr nmi_jsr_none
	jsr set_bars_middle
	pla
	tax
	pla
	rti

;==========================================================
; VBI routine

vbi	pha
	txa
	pha
	tya
	pha
	cld

vbi_jsr1
	jsr nmi_jsr_none
	jsr set_bars_top

vbi_jsr2
	jsr nmi_jsr_none

;	Next frame
	inc cnt
	jsr sound_play
	jsr readkeys
	jsr set_bars_flash

	pla
	tay
	pla
	tax
	pla 
	rti

;==========================================================
; Wait for a VSYNC
wait_sync
	lda $d40b
	bne *-3
	lda $d40b
	beq *-3
	rts

;==========================================================
; Wait <A> frames

wait	sta waitcnt
	lda waitskip
	cmp #1
	beq waitx
wait1	lda cnt
wait2	cmp cnt
	beq wait2
	dec waitcnt
	bne wait1
waitx	rts

;==========================================================
; Read the keys (console, trigger, SPACE) to compute the end flag.
readkeys
	lda #8
	sta $d01f
	lda $d01f
	cmp #7
	bne readkeys1
	lda $d010
	and $d011
	beq readkeys1
	lda $d20f
	and #12
	cmp #12
	beq readkeys2
readkeys1
	lda #1
	sta endflag
readkeys2
	rts

;==========================================================
	.include "Abbuc99-Sound.asm"

*	= ballspic
	.incbin "Abbuc99-NetBalls.pic"

*	= ballsmask
	.incbin "Abbuc99-NetBalls.mask"	;15 lines *40 bytes = $258 = 600 bytes picture 

*	= sintab
	.incbin "Abbuc99-NetBalls.sin"	;Sinus256.sin

*	= barsbouncetab
	.byte 254,253,252,251,250,249,247,245,243,241,239,236,234,231,228,224,221,217,213,209,205,201,196,191,187,181,176,171,165,159,153,147,140,134,127,120,113,105,98,90,82,74,66,57,49,40,31,22,12,3,6,11,16,20,25,29,33,37,40,44,47,50,53,56
	.byte 59,61,63,65,67,69,70,71,72,73,74,75,75,75,75,75,74,74,73,72,71,70,68,66,65,63,60,58,55,52,49,46,43,39,36,32,28,23,19,14,9,4,0,3,5,7,10,11,13,15,16,17,18,19,20,20,21,21,21,21,20,19,19,18
	.byte 16,15,13,12,10,8,5,3,0,2,3,4,6,7,7,8,8,9,9,8,8,8,7,6,5,4,2,1,0,1,2,3,3,3,3,3,3,2,2,1,0,0,1,2,2,2,2,2,1,1,0,0,1,1,1,1,1,1,0,0,0,0,0,0

*	= sound
	.incbin "Abbuc99-CmcSnd$5000.snd"

*	= chr
	.incbin "Abbuc99.chr"

*	= tune
	.incbin "Abbuc99-Faxen$8400.cmc"

*	= textsintab

	.byte 31,34,38,41,44,47,51,54,57,60,64,67,70,73,76,
	.byte 78,81,84,86,88,90,93,94,96,98,99,100,102,103,103,104,105,105,105,105,105,105,105,104,104,103,103,102,101,100,99,98,
	.byte 97,96,95,94,93,92,91,90,89,88,87,87,86,85,85,84,84,84,84,84,84,84,84,85,85,86,87,87,88,89,90,92,
	.byte 93,94,96,97,98,100,101,103,104,106,107,109,110,112,113,114,116,117,118,119,119,120,121,121,121,121,121,121,121,120,119,119,
	.byte 118,116,115,113,112,110,108,106,103,101,98,96,93,90,87,84,80,77,74,70,67,64,60,57,53,50,46,43,40,37,34,31,
	.byte 28,25,22,20,17,15,13,11,9,7,6,5,3,2,2,1,1,0,0,1,1,1,2,3,3,4,6,7,8,10,11,13,
	.byte 15,16,18,20,22,24,26,28,30,32,33,35,37,39,40,42,43,45,46,47,48,49,50,51,52,52,53,53,53,53,53,53,
	.byte 53,53,52,52,52,51,50,50,49,48,47,46,46,45,44,43,43,42,41,41,40,40,39,39,39,39,39,39,40,40,41,41,
	.byte 42,43,44,46,47,49,50,52,54,56,59,61,63,66,69,71
textsintabend


*	= $2e0 
	.word start
