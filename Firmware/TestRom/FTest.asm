		ORG			0100h

RAM_BASE:			EQU		4000h
LIB_SCRATCH:		EQU		RAM_BASE + 20h

START:
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

	call 	FTEST 

	jr		$


hexdump:
    LD      A,(HL)
    CALL    prt_hex_byte
    INC     HL
    INC     DE
    DJNZ    hexdump
    RET


MSG:
	DB	"Disk Controller Format Testing"
MSG_END:

SECTOR_BUFFER:	defs		512

FTEST:
	; Setup sector buffer
	ld		HL,SECTOR_BUFFER
	ld		DE,SECTOR_BUFFER+1
	ld		BC,511
	ldir

	ld		A,2
	ld		(SECTOR_BUFFER+1),A
	ld		A,4
	ld		(SECTOR_BUFFER+3),A
	ld		A,6
	ld		(SECTOR_BUFFER+5),A

	; 3 Sectors	
	ld		A,3
	out		(0x42),A

	; Track 3
	ld		A,3
	out		(0x44),A
	ld		A,0
	out		(0x45),A

	; SDH
	ld		A,10111000b		; floppy 0 head 0
	out		(0x46),A
	ld		A,0
	out		(0x48),A

	; Invoke command
	ld		A,0x50
	out		(0x47),A

	; Write the buffer
	ld		HL,SECTOR_BUFFER
	ld		BC,0x0040
	otir
	otir

	; Wait
ftest_wait_loop:
	in		A,(0x47)
	and		80h
	jr		NZ,ftest_wait_loop



	; --------- second time with 48 set to 1

	; Setup sector buffer
	ld		HL,SECTOR_BUFFER
	ld		DE,SECTOR_BUFFER+1
	ld		BC,511
	ldir

	ld		A,2
	ld		(SECTOR_BUFFER+1),A
	ld		A,4
	ld		(SECTOR_BUFFER+3),A
	ld		A,6
	ld		(SECTOR_BUFFER+5),A

	; 3 Sectors	
	ld		A,3
	out		(0x42),A

	; Track 3
	ld		A,6
	out		(0x44),A
	ld		A,0
	out		(0x45),A

	; SDH
	ld		A,10111000b		; floppy 0 head 1
	out		(0x46),A
	ld		A,1
	out		(0x48),A

	; Invoke command
	ld		A,0x50
	out		(0x47),A

	; Write the buffer
	ld		HL,SECTOR_BUFFER
	ld		BC,0x0040
	otir
	otir

	; Wait
ftest_wait_loop_2:
	in		A,(0x47)
	and		80h
	jr		NZ,ftest_wait_loop_2

	ret
FTEST_END:


include "CommonDefs.asm"

