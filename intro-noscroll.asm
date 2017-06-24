/* Magnify Intro
**
**/
    org $a800

// Equates
col0	= $02c4
col1	= $02c5
col2	= $02c6
col3	= $02c7
col4	= $02c8		; Background col/lum
colpf0	= $d016
colpf1	= $d017
colpf2	= $d018
colpf3	= $d019
colbk	= $d01a
consol	= $d01f		; Function keys (Start/Select/Option)
pot1	= $d201
pot3	= $d203
pot5	= $d205
pot7	= $d207
irqst	= $d20e
portb	= $d301
antic	= $d400
hscrol	= $d404
wsync	= $d40a
nmie	= $d40e
setvbv	= $e45c		; Vector to set VBLANK parameters
sysvbv	= $e45f		; Vector to process Immediate VBLANK

/*** Main ***/
	lda #<dli
	sta $200
	lda #>dli
	sta $201

	lda #<dl
	sta $230
	lda #>dl
	sta $231

	lda #$32
	sta col0
	lda #$38
	sta col1
	lda #$3e
	sta col2
	lda #$00
	sta col4

	lda #$c0
	sta nmie
	
	ldy #<vbi
	ldx #>vbi
	lda #6
	jsr setvbv

	jmp *

/*** Vertical Blank Interrupt ***/
vbi	jmp sysvbv

/*** Display List ***/
dl	dta $00,$4e,a($5100)
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14

	dta $4e,a($6000)
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14,14
	dta 14,14,14,14,14,14,14
	dta $00+$80
	dta $57
	dta a(name)
	dta $70+$80
	dta $57
	dta a(txt)
	dta $41,a(dl)

/*** DLI ***/
dli	pha
	txa
	pha
	tya
	pha

	sta wsync

	ldy bar3
	ldx #$0f

barloop	lda bar,x
	sta colpf0
	lda bar2,x
	sta colpf2
	sty colpf3
	
	sta wsync

	dey
	dey
	dey
	dey

	dex
	bne barloop

	inc bar3

	lda col0
	sta colpf0
	lda col1
	sta colpf1
	lda col2
	sta colpf2
	lda col3
	sta colpf3
	lda col4
	sta colbk

	pla
	tay
	pla
	tax
	pla
	
	rti

bar	dta $76,$88,$78,$8a
	dta $7a,$8c,$7c,$8e
	dta $7e,$8c,$7c,$8a
	dta $7a,$88,$78,$86

bar2	dta $84,$86,$88,$8a
	dta $8c,$8e,$0c,$0e
	dta	$0e,$0c,$3e,$3c
	dta $3a,$38,$36,$34

bar3	dta 0

txt	dta d'WELCOME TO THE INTRO'
	
name dta ' /the magnify demo\ '*
	