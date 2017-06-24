/* Magnify Intro
**
** COMPILE: "c:\Program Files (x86)\MADS\mads.exe" -i:..\..\inc\a8\ -o:intro.xex intro.asm
**/
	icl "systemequates.20070530_bkw.inc"		; Don't forget the specify -i:<path to file> at compile time

	org $5100

	ins "intro-picture.dat"
pic_pg1 = $5100
pic_pg2 = $6000

    org $a800

.var	.byte	hss=7, count=0

init
	lda #0
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

main
	mwa #dli VDSLST
	mwa #dl SDLSTL

	lda #$32
	sta COLOR0
	lda #$38
	sta COLOR1
	lda #$3e
	sta COLOR2
	lda #$00
	sta COLOR4

	lda #7
	sta hss

	lda #0
	sta count

	lda #$c0
	sta NMIEN
	
	ldy #<vbi
	ldx #>vbi
	lda #6
	jsr SETVBV

wait
	lda CONSOL
	cmp #6			; Wait for START
	bne wait

	lda #0
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
// END: main

/*** Vertical Blank Interrupt ***/
vbi
	jsr scroll
	jmp SYSVBV

scroll
	lda hss
	sta HSCROL

	dec hss
	dec hss
	bpl ret

	lda #7
	sta hss

	inw p_text

	lda count
	cmp #$1e					; Is title in middle of the screen?
	bne tscroll

	lda p_dtitle
	cmp #$00
	bne cont

	lda #$80
	sta p_dtitle
	lda #$47
	sta p_dtitle2

	jmp cont					; Updated DL, skip the title scroller

tscroll
	inw p_title

	lda count
	cmp #$1e					; Is title in middle of the screen?
	beq cont
	
	inc count

cont
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

	sta WSYNC

	ldy bar3
	ldx #$0f

barloop	lda bar,x
	sta COLPF0
	lda bar2,x
	sta COLPF2
	sty COLPF3
	
	sta WSYNC

	dey
	dey
	dey
	dey

	dex
	bpl barloop

	inc bar3

	lda COLOR0
	sta COLPF0
	lda COLOR1
	sta COLPF1
	lda COLOR2
	sta COLPF2
	lda COLOR3
	sta COLPF3
	lda COLOR4
	sta COLBK

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

/*** Display List ***/
dl	dta DL_BLANK1
	dta DL_GR15 | DL_LMS, a(pic_pg1)								; $4e, $5100
:111	dta DL_GR15													; Create 8x13+7 lines of gr 15 (40 bytes/line)
	dta DL_GR15 | DL_LMS, a(pic_pg2)								; $4e, $6000
:47	dta DL_GR15														; Create 8x5+7 lines of gr 15 (40 bytes/line)
p_dtitle																; Pointer for title line (need to enable dli)
	dta DL_BLANK1													; $00
p_dtitle2																; Pointer for title line (need to disable dl_hscroll)
	dta DL_GR2 | DL_LMS | DL_VSCROLL								; $57 ($07 | $40 | $10)
p_title
	dta a(title)
	dta DL_BLANK7 | DL_DLI											; $70+$80
	dta DL_GR2 | DL_LMS | DL_VSCROLL								; $57 ($07 | $40 | $10)
p_text
	dta a(text)
	dta DL_JVB, a(dl)												; $51, (dl)

	org $8000

text
	dta d'                                                            ', \
	d'WELCOME TO THE INTRO OF THE', d' /magnify demo\'*, \
	d'                    ', \
	d'CREDITS OF THE MAGNFIY DEMO............ ', \
	d'GFX - '*, d'SENOR ROSSIE', \
	d'                    ', \
	d'MUSIC - '*, d'THE GATEKEEPER', \
	d'                    ', \
	d'CODING - '*, d'SENOR ROSSIE', \
	d'                    ', \
	d"(C)'94 BY:", d' B-WARE! '*, \
	d'                    ', \
	d'PRESS START TO LOAD ', d' /the magnify demo\ '*, \
	d'                    ', \
	d'GREETINX TO: HTT AND WRM-SOFT'
tend
	dta d'                                        '

title
	dta d'                              ', d' /the magnify demo\       '*

/*************************************/
	//ini init

	run main
