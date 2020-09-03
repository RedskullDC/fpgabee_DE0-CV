		ORG			08000h

RAM_BASE:			EQU		7000h
LIB_SCRATCH:		EQU		RAM_BASE

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

	; --- setup each bank with signature ---
	LD		IX,CHAR_RAM_BASE+0x40
	LD		IY,0x1000

	LD		A,00000000b			;; Bank 0 Lower
	OUT		(50h),A
	LD		(IY+0),'a'

	LD		A,00000001b			;; Bank 0 Upper
	OUT		(50h),A
	LD		(IY+0),'A'

	LD		A,00000010b			;; Bank 1 Lower
	OUT		(50h),A
	LD		(IY+0),'b'

	LD		A,00000011b			;; Bank 1 Upper
	OUT		(50h),A
	LD		(IY+0),'B'

	; --- Now test ---
	LD		A,00000000b			;; Bank 0 Lower
	OUT		(50h),A
	LD		B,'a'
	CALL	CHECK

	LD		A,00000001b			;; Bank 0 Upper
	OUT		(50h),A
	LD		B,'A'
	CALL	CHECK

	LD		A,00000010b			;; Bank 1 Lower
	OUT		(50h),A
	LD		B,'b'
	CALL	CHECK

	LD		A,00000011b			;; Bank 1 Upper
	OUT		(50h),A
	LD		B,'B'
	CALL	CHECK

	INC		IX					;; Space

	LD		A,00000000b			;; Starting bank
	LD		B,00000110b			;; Target bank
	CALL	GET_HILOW_SIGS
	LD		H,'a'
	LD		L,'a'
	CALL	CHECK_HILOW_SIGS

	LD		A,00000001b			;; Starting bank
	LD		B,00000111b			;; Target bank
	CALL	GET_HILOW_SIGS
	LD		H,'a'
	LD		L,'A'
	CALL	CHECK_HILOW_SIGS

	LD		A,00000010b			;; Starting bank
	LD		B,00000100b			;; Target bank
	CALL	GET_HILOW_SIGS
	LD		H,'a'
	LD		L,'b'
	CALL	CHECK_HILOW_SIGS

	LD		A,00000011b			;; Starting bank
	LD		B,00000101b			;; Target bank
	CALL	GET_HILOW_SIGS
	LD		H,'a'
	LD		L,'B'
	CALL	CHECK_HILOW_SIGS

	INC		IX					;; Space
	LD		A,0
	OUT		(50h),a

	; Latch character ROM
	LD		A,1
	OUT		(0bh),A

	; Test read/write to charrom
	LD		A,'C'
	LD		(0xF006),A			;; write to character ram (should fail)
	LD		A,'P'
	LD		(0xF806),A			;; write to pcg ram (should succeed)
	LD		A,(0xF006)
	CP		0x41				;; Charrom found
	LD		A,0
	OUT		(0bh),a
	CALL	CHECK_Z

	; Latch character ROM
	LD		A,1
	OUT		(0bh),A

	LD		HL,PROXY_1
	LD		DE,0x7000
	LD		BC,PROXY_1_END - PROXY_1
	LDIR
	JP		0x7000

PROXY_1:
	; Switch to alternative video ram address
	LD		A,0x10
	OUT		(0x50),A
	LD		A,'C'
	LD		(0x8006),A
	LD		A,(0x8006)
	CP		0x41
	LD		A,0
	OUT		(50h),a
	OUT		(0bh),a
	JP		PROXY_1_END
PROXY_1_END:
	CALL	CHECK_Z

	INC		IX

	; Check that the byte at 0xF006 wasn't actually written
	; (should only be able to write to the pcg part of video ram)
	LD		A,(0xF006)
	CP		'C'
	CALL	CHECK_NZ

	LD		A,(0xF806)
	CP		'P'
	CALL	CHECK_Z

	LD		A,0
	OUT		(50h),A

	INC		IX

	; Write something to PCG RAM Beyond 16K
	LD		A,088h
	OUT		(0x1c),A

	LD		A,0c7h
	LD		(0xF800),A

	LD		A,(0xF800)
	CP		0c7h
	CALL	CHECK_NZ




        LD      DE,0xF0c0
        LD      HL,0x9000
        LD      B,16
        CALL	hexdump

        LD      DE,0xF100
        LD      HL,0xb100
        LD      B,16
        call	hexdump

        LD		A,0
        OUT		(50h),A
        LD		A,1
        OUT		(0Bh),A
        LD		HL,0xFC10
        LD		DE,0x3000
        LD		BC,16
        LDIR
        LD		A,0
        OUT		(0Bh),A

        LD		HL,0x3000
        LD		DE,0xF140
        LD		B,16
        call	hexdump

        JR      $

hexdump:
        LD      A,(HL)
        CALL    prt_hex_byte
        INC     HL
        INC     DE
        DJNZ    hexdump
        RET


CHECK_HILOW_SIGS:
	LD		A,D
	CP		H
	CALL	CHECK_Z
	LD		A,E
	CP		L
	CALL	CHECK_Z
	RET

CHAR_CHECK:	EQU	6
CHAR_CROSS:	EQU 5

CHECK:
	LD		A,(IY+0)
	CP		B
CHECK_Z:
	LD		A,CHAR_CHECK
	JR		Z,L_write
	LD		A,CHAR_CROSS
L_write:
	LD		(IX+0),A
	INC		IX
	RET

CHECK_NZ:
	LD		A,CHAR_CHECK
	JR		NZ,L_write
	LD		A,CHAR_CROSS
	JR		L_write


GET_HILOW_SIGS:
	POP		HL			; Move return address to the returning bank
	OUT		(50h),A
	PUSH	HL

	; Copy the routine to read hi ram to loram
	PUSH	BC
	LD		HL,GET_HILOW_SIGS_STUB
	LD		DE,0x2000
	LD		BC,GET_HILOW_SIGS_STUB_END - GET_HILOW_SIGS_STUB
	LDIR
	POP		BC
	CALL	0x2000
	RET

GET_HILOW_SIGS_STUB:
	; This routine will be moved to RAM to run

	; Switch to target bank layout
	LD		C,A
	LD		A,B
	OUT		(50h),A

	; Read hi/lo signatures
	LD		A,(0x9000)
	LD		D,A
	LD		A,(0x1000)
	LD		E,A

	; Switch back to starting bank
	LD		A,C
	OUT		(50h),A

	; Return 
	RET
GET_HILOW_SIGS_STUB_END:


MSG:
	DB	"Testing Memory Bank Switching"
MSG_END:



include "CommonDefs.asm"

seek 0x9000-0x8000
	db	0x01,0x02,0x03,0x04,0x05,0x06

seek 0xb100-0x8000
	db	0x11,0x12,0x13,0x14,0x15,0x16