		ORG			08000h

RAM_BASE:			EQU		7000h
LIB_SCRATCH:		EQU		RAM_BASE

START:
	LD		SP,0x8000

	LD		DE,1500
	LD		BC,500

	LD		A,E
	SUB		C
	LD		E,A
	LD		A,D
	SBC		A,B
	LD		D,A



	LD		HL,CRTC_Registers_80_25
	CALL	setup_crtc

	CALL	clear_screen
	LD		A,0Fh
	CALL	clear_color_buffer
	CALL	clear_attribute_buffer

	LD		HL,0xf000
	LD		B,0
	LD		A,0
l1:
	LD		(HL),A
	INC		A
	INC		HL
	DJNZ	l1

	jr	$

include "CommonDefs.asm"

