; 
; ABBUC 99 Intro - Text Init Include
;
; (c) 2009-11-29 by JAC!

; This initialization is located in the SM buffer and can
; be overwritten by the drawing of the texts

; Text line counter limits and counters for scrolling upwards, changed by VBI
textxcntmax	= $10		;Height of a text in scanlines
textxcnt	= textzp+$01	;Low, $00-$0f = textxcntmax-1
textycntmax	= $10		;Number of virtual text lines
textycnt	= textzp+$02	;High $00-$0f = textycntmax-1
textycntdli	= textzp+$03	;Initialized during VBI, incremented during DLI
textxpos	= textzp+$04
textxpostmp	= textzp+$05
; SM memory constats
textsmsize	= $280	;15*40 = 600 = $258

; Control characters
eof	= 255	;End of file
eop	= 254	;End of page
eol	= 253	;End of line
;==========================================================
; Initialize text scroll routines  
init_text
	set pt,text
	ldy #0
init_text1
	lda (pt),y
	cmp #eof
	beq init_textx
	cmp #eop
	beq init_text2
	cmp #eol
	beq init_text2
	sec
	sbc #32
init_text2
	sta (pt),y
	dic pt
	jmp init_text1
init_textx
	set pt,text
	rts
