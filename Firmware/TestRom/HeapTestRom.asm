		ORG			08000h

RAM_BASE:			EQU		7000h
LIB_SCRATCH:		EQU		RAM_BASE

HEAP_FREE_CHAIN:		EQU	100h
HEAP_HI_WATER:			EQU	102h
HEAP_BASE_ADDRESS:		EQU 200h
HEAP_SIZE:				EQU	0x3800

P1: EQU		4000h
P2: EQU		4002h
P3: EQU		4004h
P4: EQU		4006h


	LD		SP,0x8000

	LD		HL,CRTC_Registers_64_16
	CALL	setup_crtc

	CALL	clear_screen
	LD		A,COLOR_YELLOW
	CALL	clear_color_buffer
	CALL	clear_attribute_buffer

	; Copy letters to RAM (testing)
	LD		DE,CHAR_RAM_BASE
	LD		HL,MSG
	LD		BC,MSG_END-MSG
	LDIR 

	call	HeapInit

	ld		BC,100
	call	HeapAlloc
	ld		(P1),HL

	ld		BC,200
	call	HeapAlloc
	ld		(P2),HL

	ld		BC,150
	call	HeapAlloc
	ld		(P3),HL

	ld		BC,250
	call	HeapAlloc
	ld		(P4),HL

	ld		HL,(P2)
	call	HeapFree
	ld		HL,(P3)
	call	HeapFree

	ld		BC,175
	call	HeapAlloc
	ld 		(P2),HL

	ld		BC,225
	call	HeapAlloc
	ld      (P3),HL

	jr $

MSG:
	DB	"Heap Testing"
MSG_END:


include "../PcuBoot/Heap.asm"
include "CommonDefs.asm"