; Starts and stops the sound.

sound_init	= $5003
sound_replay	= $5006

soundvol .ds 1
soundmix .ds 1

;==========================================================
; Start the sound

sound_start
	ldx #8
	lda #0
sound_start1
	sta $d200,x
	dex
	bpl sound_start1
	lda #3
	sta $d20f
	lda #0
	sta soundvol

	lda #>sound_d200
;	sta sound+$5ff	;Patch CMC replayed to store sound data at "sound_d200"
	sta sound+$614

	lda #$70	;Set tune address
	ldx #<tune	;Tune address low byte
	ldy #>tune	;Tune address high byte
	jsr sound_init
	lda #0		;Set default tune
	ldx #0		;Default tune #0
	jsr sound_init
	rts

;==========================================================
; Plays sound per frame including volume control

sound_play
	jsr sound_replay
	ldy #0
sound_play1
	iny
	lda sound_d200,y
	and #$f0
	sta soundmix
	lda sound_d200,y
	and #15
	sec
	sbc soundvol
	bcs *+4
	lda #0
	ora soundmix
	sta $d200,y
	iny
	cpy #8
	bne sound_play1
	rts

;==========================================================
; Fades the current sound out to silence
sound_fadeout
	ldx #0
sound_fadeout1
	stx soundvol
	lda #4
	jsr wait
	inx
	cpx #16
	bne sound_fadeout1
	rts

;==========================================================
; Stops the current sound.

sound_stop
	lda #0
	ldx #0
	jsr sound_init
	rts
