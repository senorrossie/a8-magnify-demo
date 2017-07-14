/* Magnify Demo
**
** COMPILE:
** # Windows
** "c:\Program Files (x86)\MADS\mads.exe" -i:inc\ -o:xex\magnify.xex magnify.asm
**
** # Linux / OSX
** mads -i:inc/ -i:xex/ -o:xex/magnify.xex magnify.asm
**
** ### NOTE ###
** If you want to change the binary at compile time, use the -d:label=value
**  eg. to create a standalone binary (no intro):
** mads -d:STANDALONE=true -i:inc/ -i:xex/ -o:xex/magnify.xex magnify.asm
**  or to create a binary with into that ends in a loop:
** mads -d:SINGLE=true -i:inc/ -i:xex/ -o:xex/magnify.xex magnify.asm
**
** If you want to test 'The Magnify Demo' in Altirra, don't use the SINGLE label
*/

// If you don't want to specify the labels at compile time, uncomment the ones below
//.def STANDALONE			; Link intro if not defined
//.def SINGLE				; Waiting for start, then exit ('init' instead of 'run')

.ifdef STANDALONE
	icl "systemequates.20070530_bkw.inc"		; Don't forget the specify -i:<path to file> at compile time
.else
	icl "intro.asm"
.endif

	org $2300
magtab
	ins "demo-sinetable.dat"
font
	ins "demo-font.dat"
	
	org $5100
picture
	ins "demo-picture.dat"

	org $8000
fcb
	ins "demo-music.dat"

    org $a800

.zpvar	zp	.word = $e0
.zpvar	nsl	.word = $e2

.var	dl	.word = $2000
.var	.byte	hss=7, ypos=0, p_tab=0

// BEGIN: main
magnify
	mwa #dli VDSLST
	mwa #dl SDLSTL

	ldx p_tab		; Init magnify table (ypos) for first gendl run
	lda magtab, x
	sta ypos

	lda #7
	sta hss

	lda #0
	sta AUDCTL
	lda #3
	sta SKCTL

	jsr initdl

	lda #$c0
	sta NMIEN

	lda #7			; Deferred VBLank
	ldx #>vbi
	ldy #<vbi
	jsr SETVBV

.ifdef SINGLE
wait
	lda CONSOL
	cmp #6			; Wait for START
	bne wait

	lda #$40
	sta NMIEN

	lda #7			; Restore Deferred VBlank 
	ldx #$e4
	ldy #$62
	jsr SETVBV

	lda #0
	sta COLOR0
	sta COLOR1
	sta COLOR2
	sta COLBK
	sta AUDC1
	sta AUDC2
	sta AUDC3
	sta AUDC4
	sta IRQST
	sta DMACTL
	sta NMIEN
	lda #$ff
	sta PORTB

	rts
.else
endless
	jmp endless
.endif
// END: main

/*** Vertical Blank Interrupt ***/
vbi
	lda #$72
	sta COLPF0
	lda #$78
	sta COLPF1
	lda #$7E
	sta COLPF2
	lda #$00
	sta COLBK

	ldx p_tab
	lda magtab, x
	sta ypos
	inc p_tab

	jsr scroll
	jsr gendl

	ldy ypos

wait2
	dey
	sta WSYNC
	bne wait2

// Grey Line @start of magnify bar
	lda #5
	sta COLBK
	sta WSYNC

	lda #0
	sta COLBK
	sta WSYNC

	ldy #$1e

wait3 
	dey
	sta WSYNC
	bne wait3

// Grey Line @end of magnifier
	lda #5
	sta COLBK
	sta WSYNC

	lda #0
	sta COLBK
	sta WSYNC

	jsr fcb+1

	jmp XITVBV

// START: Display List generator
//  Initialize screen RAM
// 1. Magnify Image
initdl
	mwa #dl zp				; zp = dl memory location
	mwa #picture nsl		; nsl = picture memory location (Next Scan Line)

	ldy #0
	ldx ypos

iloop1
	lda #$4e				; LMS + GR. 15
	sta (zp),y
	jsr inczp
	lda nsl					; Image location Low Byte
	sta (zp),y
	jsr inczp
	lda nsl+1				; Image location High Byte
	sta (zp),y
	jsr inczp

	clc						; Calculate next Image location
	lda nsl
	adc #$28
	sta nsl
	lda nsl+1
	adc #0
	sta nsl+1

	dex
	bne iloop1

; 16 x GR7
	ldx #$10
iloop2
	lda #$4d
	sta (zp),y
	jsr inczp
	lda nsl
	sta (zp),y
	jsr inczp
	lda nsl+1
	sta (zp),y
	jsr inczp

	clc
	lda nsl
	adc #$28
	sta nsl
	lda nsl+1
	adc #0
	sta nsl+1

	dex
	bne iloop2

; (144 - ypos) x GR15
	sec
	lda #144
	sbc ypos
	tax

iloop3
	lda #$4e
	sta (zp),y
	jsr inczp
	lda nsl
	sta (zp),y
	jsr inczp
	lda nsl+1
	sta (zp),y
	jsr inczp

	clc
	lda nsl
	adc #$28
	sta nsl
	lda nsl+1
	adc #0
	sta nsl+1

	dex
	bne iloop3
// END: 1. Magnify Image

	lda #$70
	sta (zp),y
	jsr inczp
	lda #$70+$80
	sta (zp),y
	jsr inczp

// GR2 text
	lda #$57
	sta (zp),y
	jsr inczp
	lda p_text
	sta (zp),y
	jsr inczp
	lda p_text+1
	sta (zp),y
	jsr inczp

	lda #$41
	sta (zp),y
	jsr inczp
	lda #<dl
	sta (zp),y
	jsr inczp
	lda #>dl
	sta (zp),y
	jsr inczp

	rts
// END: Display list

// START: Display List generator
// 1. Magnify Image
gendl
	mwa #dl zp
	mwa #picture nsl

	ldy #0
	ldx ypos

gloop1
	lda #$4e
	sta (zp),y

	lda zp
	clc
	adc #3
	sta zp
	lda zp+1
	adc #0
	sta zp+1

	dex
	bne gloop1

; 16 x GR7
	ldx #$10
gloop2
	lda #$4d
	sta (zp),y

	lda zp
	clc
	adc #3
	sta zp
	lda zp+1
	adc #0
	sta zp+1

	dex
	bne gloop2

; (144 - ypos) x GR15
	sec
	lda #144
	sbc ypos
	tax

gloop3
	lda #$4e
	sta (zp),y

	lda zp
	clc
	adc #3
	sta zp
	lda zp+1
	adc #0
	sta zp+1

	dex
	bne gloop3
// END: 1. Magnify Image

	lda #$70
	sta (zp),y
	jsr inczp
	lda #$70+$80
	sta (zp),y
	jsr inczp

// GR2 text
	lda #$57
	sta (zp),y
	jsr inczp
	lda p_text
	sta (zp),y
	jsr inczp
	lda p_text+1
	sta (zp),y
	jsr inczp

	lda #$41
	sta (zp),y
	jsr inczp
	lda #<dl
	sta (zp),y
	jsr inczp
	lda #>dl
	sta (zp),y
	jsr inczp

	rts
// END: Display List generator
	
inczp
	inc zp
	bne no1
	inc zp+1

no1
	rts
	
/*************************************/
scroll
	lda hss
	sta HSCROL

	dec hss
	bpl ret

	lda #8
	sta hss

	inw p_text

	lda #9
	sta HSCROL

	cpw p_text #tend
	scc
	mwa #text p_text

ret
	rts


/*** Display List Interrupt ***/
dli	pha
	txa
	pha
	tya
	pha

	lda #$24
	sta CHBASE

	sta WSYNC
	
	ldy #$0f

barloop
	clc
	lda bar,y
	sta COLPF2
	adc #$30
	sta COLPF0
	adc #$20
	sta COLPF1
	sta WSYNC
	dey
	bpl barloop

	lda #05
	sta CHACTL

	lda #$a4
	sta COLPF0
	sta COLPF1
	sta COLPF2
	sta COLPF3

	pla
	tay
	pla
	tax
	pla
	
	rti

bar	dta $00,$02,$04,$06,$08,$0a
	dta $0c,$0e,$0e,$0c,$0a,$08
	dta $06,$04,$02,$00

/*************************************/
p_text	dta a(text)

text
	dta d'                                        ', \
	d'B-WARE'*, d',THE NEW NAME ON THE 8-BIT ATARIS.        ',\
	d'WE ARE PROUD TO PRESENT TO YOU...   the magnify demo  ', \
	d'ANOTHER PART OF OUR mega demo CALLED ', d'THE ILLUSION'*, \
	d'. THIS DEMO WAS WRITTEN BY: ', d'SENOR ROSSIE'*, \
	d'.                       NOTE FROM THE AUTHOR......... ', \
	d'I HOPE YOU ENJOYED MY FIRST DEMOS FOR OUR LITTLE ATARIS, ', \
	d'BUT I THINK YOU WILL LIKE THIS ONE EVEN BETTER. THE MUSIC ', \
	d'IS PART OF A TRACK BY ', d'2 HYPED BROTHERS AND A DOG '*, \
	d'CALLED ', d'DOO DOO BROWN '*, d'AND WAS CONVERTED TO A ', \
	d'FUTURE COMPOSER FILE BY the gatekeeper (IT IS A DIRTY ', \
	d'JOB, BUT SOMEONE HAS TO DO IT !). EVERYTHING ELSE WAS ', \
	d'DONE BY ME. watch the scroll in my next part for greetinx ', \
	d'and the address to write to. SIGNING OFF, ', \
	d'SENOR ROSSIE'*, d'.                   '
tend
	dta d'                                        '

/*************************************/
.ifdef SINGLE
	ini magnify
.else
	run magnify
.endif
/*************************************/
