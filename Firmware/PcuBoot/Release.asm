SCREEN_WIDTH:			EQU	32
SCREEN_HEIGHT:			EQU	16
VCHAR_RAM:				EQU	0xF000
COLOR_RAM:				EQU 0xF200
VBUFFER_SIZE:			EQU SCREEN_WIDTH * SCREEN_HEIGHT
HEAP_SIZE:				EQU	0x3800
ROM_PACK_LOAD_ADDR:		EQU	0x8000
COLOR_RAM_IN: macro
	endm
COLOR_RAM_OUT: macro
	endm

READ_KEY:
	push	HL
	push	DE
rk_loop:
	; Read's a single key from the keyboard, yielding back to 
	; the Microbee if none available
	in		A,(0x82)
	ld		E,A
	in		A,(0x83)
	bit		7,A			; bit 7 = 1 if key available
	jr		NZ,rk_1
	call	YIELD
	jr		rk_loop

rk_1:
	ld		D,0
	ld		HL,SCANCODE_TO_VK_TABLE 
	add		HL,DE
	add		HL,DE
	bit		0,A
	jr		Z,rk_not_extended
	inc		HL
rk_not_extended:
	ld		A,(HL)

	; F12 always toggles display
	cp		VK_F12
	jr		NZ,rk_have_key
	in		A,(0x81)
	xor		3
	out		(0x81),A
	jr		rk_loop

rk_have_key:
	pop		DE
	pop		HL
	ret

READ_KEY_END:


; Read block DEBC in to buffer at HL
DISK_READ:

	; Setup block number
	ld		A,C
	ld		C,0xC1
	out		(C),A
	out		(C),B
	out		(C),E
	out		(C),D

	; Initiate the read command
	ld			A,0
	out			(0xC7),A

	; Wait for read to finish
dr_wait:	
	in		A,(0xC7)
	and		0x80
	JR		NZ,dr_wait

	; Read it
	ld		BC,0x00C0
	inir
	inir

	; Done!
	ret
DISK_READ_END:

; Write block DEBC from SECTOR_BUFFER
DISK_WRITE:

	; Setup block number
	ld		A,C
	ld		C,0xC1
	out		(C),A
	out		(C),B
	out		(C),E
	out		(C),D

	; Initiate the write command
	ld			A,01h
	out			(0xC7),A

	; Read it
	ld		BC,0x00C0
	otir
	otir

	; Wait for write to finish
dw_wait:	
	in		A,(0xC7)
	and		0x80
	JR		NZ,dw_wait

	; Done!
	ret
DISK_WRITE_END:

