/* Magnify Demo
**
** COMPILE:
** # Windows
** "c:\Program Files (x86)\MADS\mads.exe" -i:inc\ -o:xex\magnify.xex magnify.asm
**
** # Linux / OSX
** mads -i:inc/ -i:xex/ -o:xex/magnify.xex magnify.asm
*/

.zpvar	zp	.word = $e0
.zpvar	nsl	.word = $e2

	//icl "systemequates.20070530_bkw.inc"		; Don't forget the specify -i:<path to file> at compile time
	icl "intro.asm"

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

.var	.byte	hss=7, count=0, ycoor=0, ypos=0, p_tab=0
.var	.word	dl=$2000

main	
	mwa #dli VDSLST
	mwa #dl SDLSTL

	ldx p_tab
	lda magtab, x
	sta ypos

	lda #7
	sta hss

	lda #0
	sta AUDCTL
	lda #3
	sta SKCTL

	jsr scroll
	jsr gendl

	lda #$c0
	sta NMIEN
	
	lda #7
	ldx #>vbi
	ldy #<vbi
	jsr SETVBV

wait
	lda CONSOL
	cmp #6			; Wait for START
	bne wait

endloop
	jmp endloop
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

	jsr scroll
	jsr gendl2
	jsr fcb+1

	ldx p_tab
	lda magtab, x
	sta ypos
	inc p_tab

	clc
	adc #$0c
	tay
	adc #32
	sta ycoor

wait2
	sta WSYNC
	dey
	bne wait2

// White Line @start of magnifier
	lda #5
	sta COLBK
	sta WSYNC

	lda #0
	sta COLBK

	ldy #29

wait3 
	sta WSYNC
	dey
	bpl wait3

// White Line @end of magnifier
	lda #5
	sta COLBK

noend
	sta WSYNC

	lda #0
	sta COLBK

	jmp XITVBV

// START: Display List generator
// 1. Magnify Image
gendl
	mwa #dl zp
	mwa #picture nsl

	ldy #0
	ldx ypos

loop1
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
	bne loop1

; 16 x GR7
	ldx #$10
loop2
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
	bpl loop2

; (144 - ypos) x GR15
	sec
	lda #144
	sbc ypos
	tax

loop3
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
	bne loop3
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
	
// START: Display List generator #2
// 1. Magnify Image
gendl2
	mwa #dl zp
	mwa #picture nsl

	ldy #0
	ldx ypos

bloop1
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
	bne bloop1

; 16 x GR7
	ldx #$10
bloop2
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
	bpl bloop2

; (144 - ypos) x GR15
	sec
	lda #144
	sbc ypos
	tax

bloop3
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
	bne bloop3
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
// END: Display List generator #2

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

	lda #<tend
	cmp p_text
	bne ret
	lda #>tend
	cmp p_text+1
	bne ret

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
	run main
/*************************************/
