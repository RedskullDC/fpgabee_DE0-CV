		ORG			08000h

RAM_BASE:			EQU		7000h
LIB_SCRATCH:		EQU		RAM_BASE + 20h
CYL:				EQU		RAM_BASE

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

	; ;- setup each bank with signature ;-
	LD		IX,CHAR_RAM_BASE+0x40

	; Select HDD controller
	LD		A,1
	OUT		(0x58),A

	; Read-write to port 0x40 should return different data
	LD		A,0xA0
	OUT		(0x40),A
	XOR		A
	IN		A,(0x40)
	CP		0xA0
	CALL	CHECK_NZ

	; Read-write to port 0x41 should return different data
	LD		A,0xA9
	OUT		(0x41),A
	XOR		A
	IN		A,(0x41)
	CP		0xA9
	CALL	CHECK_NZ

	; Read-write to port 0x42 should return same data (sector count)
	LD		A,0xAA
	OUT		(0x42),A
	XOR		A
	IN		A,(0x42)
	CP		0xAA
	CALL	CHECK_Z

	; Read-write to port 0x43 should return same data (sector number)
	LD		A,0xAB
	OUT		(0x43),A
	XOR		A
	IN		A,(0x43)
	CP		0xAB
	CALL	CHECK_Z

	; Read-write to port 0x44 should return same data (track low)
	LD		A,0xAC
	OUT		(0x44),A
	XOR		A
	IN		A,(0x44)
	CP		0xAC
	CALL	CHECK_Z

	; Read-write to port 0x45 should return same data (track hi)
	LD		A,0xAD
	OUT		(0x45),A
	XOR		A
	IN		A,(0x45)
	CP		0xAD
	CALL	CHECK_Z

	; Read-write to port 0x46 should return same data (SDH)
	LD		A,0xAE
	OUT		(0x46),A
	XOR		A
	IN		A,(0x46)
	CP		0xAE
	CALL	CHECK_Z

	; Read-write to port 0x47 should return different data (CMD)
	LD		A,0x90
	OUT		(0x47),A
	XOR		A
	IN		A,(0x47)
	CP		0x90
	CALL	CHECK_NZ

	INC		IX

	call	wait_key

	LD		A,0
	LD		(CYL),A

read_test:

	LD		A,(CYL)
	LD		L,A
	LD		H,0
	LD		DE,0xf020
	CALL	prt_int_word

	; Setup task file
 	LD		A,1				; Sector 1
	OUT		(0x43),A
	LD		A,(CYL)			; Track lo
	OUT		(0x44),A
	LD		A,0				; Track high
	OUT		(0x45),A
	LD		A,10101000b		; SIZE=512,HDD=1,HEAD=0
	OUT		(0x46),A
	LD		A,1				; Sector count
	OUT		(0x42),A
	LD		A,0x20			; Read
	OUT		(0x47),A

wait_read:
	IN		A,(0x47)
	AND		0x80
	JR		NZ,wait_read

;	LD		BC,4000
;wait_read:
;	DEC		BC
;	LD		A,B
;	OR		C
;	JR		NZ,wait_read

	LD		HL,0x3000
	LD		DE,0x3001
	LD		BC,0x3f
	LD		(HL),0xFA
	LDIR


	LD		HL,0x3000
	LD		BC,0x0040
	INIR
	INIR

;	; Write the data
;	LD		BC,512
;	LD		DE,0x3000
;read_loop:
;	IN		A,(40h)
;	LD		(DE),A
;	INC		DE
;	DEC		BC
;	LD		A,B
;	OR		C
;	JR		NZ,read_loop

	LD		HL,0x3000
	LD		B,16
	LD		DE,0xF080
	CALL	hexdump

	call	wait_key

	LD		A,(CYL)
	INC		A
	LD		(CYL),A

	jp		read_test


hexdump:
        LD      A,(HL)
        CALL    prt_hex_byte
        INC     HL
        INC     DE
        DJNZ    hexdump
        RET



GEO_TESTS:

	CALL	wait_key

	; Test calculation of cluster number
	LD		A,2				; Sector 2
	OUT		(0x43),A
	LD		A,2				; Track low
	OUT		(0x44),A
	LD		A,0				; Track high
	OUT		(0x45),A
	LD		A,00001000b		; SDH (drive 1/head 0)  HD0
	OUT		(0x46),A
	LD		A,0x90			; Invoke 
	OUT		(0x47),A	
	CALL 	wait_key		;; Should show 0x89

	; Test calculation of cluster number
	LD		A,2				; Sector 2
	OUT		(0x43),A
	LD		A,2				; Track low
	OUT		(0x44),A
	LD		A,0				; Track high
	OUT		(0x45),A
	LD		A,00001010b		; SDH (drive 1/head 0)  HD0
	OUT		(0x46),A
	LD		A,0x90			; Invoke 
	OUT		(0x47),A	
	CALL 	wait_key		;; Should show 0xAB

	; Test calculation of cluster number
	LD		A,2				; Sector 2
	OUT		(0x43),A
	LD		A,0x33			; Track low
	OUT		(0x44),A
	LD		A,0x01			; Track high
	OUT		(0x45),A
	LD		A,00001011b		; SDH (drive 1/head 0)  HD0
	OUT		(0x46),A
	LD		A,0x90			; Invoke 
	OUT		(0x47),A	
	CALL 	wait_key		;; Should show error (ubee512 doesn't though as relies on OS eof check)

	; Test calculation of cluster number
	LD		A,2				; Sector 2
	OUT		(0x43),A
	LD		A,2				; Track low
	OUT		(0x44),A
	LD		A,1				; Track high
	OUT		(0x45),A
	LD		A,00001011b		; SDH (drive 1/head 0)  HD0
	OUT		(0x46),A
	LD		A,0x90			; Invoke 
	OUT		(0x47),A	
	CALL 	wait_key		;; Should show 44bc

	; Test calculation of cluster number
	LD		A,23			; Sector 23
	OUT		(0x43),A
	LD		A,2				; Track low
	OUT		(0x44),A
	LD		A,0				; Track high
	OUT		(0x45),A
	LD		A,00011000b		; SDH (fdd 1/head 0)   DS80
	OUT		(0x46),A
	LD		A,0x90			; Invoke 
	OUT		(0x47),A	
	CALL 	wait_key		; Should show 0x2a


	; Test calculation of cluster number
	LD		A,2				; Sector 2
	OUT		(0x43),A
	LD		A,2				; Track low
	OUT		(0x44),A
	LD		A,0				; Track high
	OUT		(0x45),A
	LD		A,00011000b		; SDH (fdd 1/head 0)   DS80
	OUT		(0x46),A
	LD		A,0x90			; Invoke 
	OUT		(0x47),A	
	CALL 	wait_key		; Should show error


	; Test calculation of cluster number
	LD		A,2				; Sector 2
	OUT		(0x43),A
	LD		A,1				; Track low
	OUT		(0x44),A
	LD		A,0				; Track high
	OUT		(0x45),A
	LD		A,00011000b		; SDH (fdd 1/head 0)   DS80
	OUT		(0x46),A
	LD		A,0x90			; Invoke 
	OUT		(0x47),A	
	CALL 	wait_key		; Should show 0x15

	RET

CHECK_Z:
	LD		A,6
	JR		Z,L_write
	LD		A,5
L_write:
	LD		(IX+0),A
	INC		IX
	RET

CHECK_NZ:
	LD		A,6
	JR		NZ,L_write
	LD		A,5
	JR		L_write


WRITE_TEST:
	; Setup task file
 	LD		A,1				; Sector 1
	OUT		(0x43),A
	LD		A,28			; Track Low
	OUT		(0x44),A
	LD		A,0				; Track High
	OUT		(0x45),A
	LD		A,00101000b		; SIZE=512,HDD=1,HEAD=0
	OUT		(0x46),A
	LD		A,0x30			; Invoke Write Common
	OUT		(0x47),A

	; Write the data
	LD		BC,512
write_loop:
	LD		A,6
	OUT		(40h),A
	DEC		BC
	LD		A,B
	OR		C
	JR		NZ,write_loop

	LD		HL,0
wait_write:
	IN		A,(0x47)
	AND		0x80
	INC		HL
	JR		NZ,wait_write

	LD		DE,0xF028
	CALL 	prt_int_word
	RET




MSG:
	DB	"Disk Controller Testing"
;	DB	"Disk Test: -- 89 AB -- 44bc 2A -- 15 "
MSG_END:



include "CommonDefs.asm"

