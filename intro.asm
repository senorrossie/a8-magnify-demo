/* Magnify Intro
**
** COMPILE:
** # Windows
** "c:\Program Files (x86)\MADS\mads.exe" -i:inc\ -o:xex\intro.xex intro.asm
**
** # Linux / OSX
** mads -i:inc/ -o:xex/intro.xex intro.asm
*/

	icl "systemequates.20070530_bkw.inc"		; Don't forget the specify -i:<path to file> at compile time

	org $5100
pic_pg1
	ins "intro-picture.dat"
pic_pg2 = $6000

	org $a800
	
.var	.byte	ihss=7, icount=0

// MAIN
intro
	mwa #idli VDSLST
	mwa #idl SDLSTL

	lda #$32
	sta COLOR0
	lda #$38
	sta COLOR1
	lda #$3e
	sta COLOR2
	lda #$00
	sta COLOR4

	lda #0
	sta icount

	lda #7
	sta ihss

	lda #$c0
	sta NMIEN
	
	lda #6			; Immediate VBLank
	ldx #>ivbi
	ldy #<ivbi
	jsr SETVBV

iwait
	lda CONSOL
	cmp #6			; Wait for START
	bne iwait

	lda #$40
	sta NMIEN

	lda #6			; Restore Immediate VBlank 
	ldx #$e4
	ldy #$5f
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
// END: main

/*** Vertical Blank Interrupt ***/
ivbi
	jsr iscroll
	jmp SYSVBV

iscroll
	lda ihss
	sta HSCROL

	dec ihss
	dec ihss
	bpl iret

	lda #7
	sta ihss

	inw p_itext

	cpw p_itext #itend
	scc
	mwa #itext p_itext			; Loop scrolltext

	lda p_idtitle
	cmp #$00					; Is DLI enabled for the title?
	bne uhscrol

	lda icount
	cmp #$1d					; Is ititle in middle of the screen?
	bne tscroll

	lda #$80
	sta p_idtitle				; Enable DLI for the title
	lda #$47
	sta p_idtitle2				; Disable VSCROLL for title text

	inw p_ititle

	jmp uhscrol					; Updated DL, skip the ititle iscroller

tscroll
	inw p_ititle
	inc icount

uhscrol
	lda #9
	sta HSCROL

iret
	rts

/*** Display List Interrupt ***/
idli
	pha
	txa
	pha
	tya
	pha

	sta WSYNC

	ldy ibar3
	ldx #$0f

ibarloop
	lda ibar,x
	sta COLPF0
	lda ibar2,x
	sta COLPF2
	sty COLPF3
	
	sta WSYNC

	dey
	dey
	dey
	dey

	dex
	bpl ibarloop

	inc ibar3

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

ibar
	dta $76,$88,$78,$8a
	dta $7a,$8c,$7c,$8e
	dta $7e,$8c,$7c,$8a
	dta $7a,$88,$78,$86

ibar2
	dta $84,$86,$88,$8a
	dta $8c,$8e,$0c,$0e
	dta	$0e,$0c,$3e,$3c
	dta $3a,$38,$36,$34

ibar3
	dta 0

/*** Display List ***/
idl
	dta DL_BLANK1
	dta DL_GR15 | DL_LMS, a(pic_pg1)								; $4e, $5100
:111	dta DL_GR15													; Create 8x13+7 lines of gr 15 (40 bytes/line)
	dta DL_GR15 | DL_LMS, a(pic_pg2)								; $4e, $6000
:47	dta DL_GR15														; Create 8x5+7 lines of gr 15 (40 bytes/line)
p_idtitle															; Pointer for ititle line (need to enable idli)
	dta DL_BLANK1													; $00
p_idtitle2															; Pointer for ititle line (need to disable dl_hiscroll)
	dta DL_GR2 | DL_LMS | DL_VSCROLL								; $57 ($07 | $40 | $10)
p_ititle
	dta a(ititle)
	dta DL_BLANK7 | DL_DLI											; $70+$80
	dta DL_GR2 | DL_LMS | DL_VSCROLL								; $57 ($07 | $40 | $10)
p_itext
	dta a(itext)
	dta DL_JVB, a(idl)												; $51, (dl)

itext
	dta d'                                                            ', \
	d'WELCOME TO THE INTRO OF ', d' /the magnify demo\'*, \
	d'                    ', \
	d'CREDITS............ ', \
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
itend
	dta d'                                        '

ititle
	dta d'                              ', d' /the magnify demo\       '*

/*************************************/
	ini intro
/*************************************/
