SCREEN_WIDTH:			EQU	32
SCREEN_HEIGHT:			EQU	16
VCHAR_RAM:				EQU	0xF000	
COLOR_RAM:				EQU 0xF800
VBUFFER_SIZE:			EQU SCREEN_WIDTH * SCREEN_HEIGHT
HEAP_SIZE:				EQU	0x3800
ROM_PACK_LOAD_ADDR:		EQU	0x4000
COLOR_RAM_IN: macro
	PUSH	AF
	LD		A, COLOR_RAM_ENABLE
	OUT     (PORT_COLOR_RAM),A
	POP		AF
	endm
COLOR_RAM_OUT: macro
	PUSH	AF
	LD		A, COLOR_RAM_DISABLE
	OUT     (PORT_COLOR_RAM),A
	POP		AF
	endm




COLOR_RAM_BASE:		EQU	0xF800
PCG_RAM_BASE:		EQU 0xF800
CHAR_RAM_BASE:		EQU 0xF000
ATTR_RAM_BASE:		EQU 0F000h

; Color RAM support
PORT_COLOR_RAM:				EQU 08h
COLOR_RAM_DISABLE:			EQU 00h
COLOR_RAM_ENABLE:			EQU 40h

; Video Memory Latch
PORT_VIDEO_MEMORY_LATCH:	EQU	1Ch
VML_BANK_SELECT_MASK:		EQU 0Fh
VML_CHARACTER_RAM_ENABLE:	EQU 00h
VML_ATTRIBUTE_RAM_ENABLE:	EQU 10h
VML_EXTENDED_GRAPHICS:		EQU 80h

; Attributes
ATTR_PCG_BANK_SELECT_MASK:	EQU 0Fh


DebugInit:
	ld	HL,CRTC_Registers_64_16
	call	setup_crtc
	CALL	clear_screen
	LD		A,11
	CALL	clear_color_buffer
	CALL	clear_attribute_buffer

    ; Setup box draw characters
    ld      HL,BOX_DRAW_CHARS
    ld      DE,0xf800
    ld      BC,BOX_DRAW_CHARS_END-BOX_DRAW_CHARS
    ldir       
	ret
DebugInitEnd:

; Clear the screen
clear_screen:
		LD		A,' '
		LD		HL,CHAR_RAM_BASE
		LD		DE,CHAR_RAM_BASE+1
		LD		BC,0x800-1
		LD      (HL),A
		LDIR
		RET

; Clear attribute RAM
clear_attribute_buffer:
		LD		A,VML_ATTRIBUTE_RAM_ENABLE
		OUT		(PORT_VIDEO_MEMORY_LATCH),A
		LD		A,0
		LD		HL,ATTR_RAM_BASE
		LD		DE,ATTR_RAM_BASE+1
		LD		BC,0x800-1
		LD      (HL),A
		LDIR
		LD		A,VML_CHARACTER_RAM_ENABLE
		OUT		(PORT_VIDEO_MEMORY_LATCH),A
		RET

; Fill colour buffer with A
clear_color_buffer:	
		PUSH	AF
		LD		A, COLOR_RAM_ENABLE
		OUT     (PORT_COLOR_RAM),A
		LD		HL,COLOR_RAM_BASE
		LD		DE,COLOR_RAM_BASE+1
		LD		BC,0x800-1
		POP		AF
		LD		(HL),A
		LDIR
		LD		A,COLOR_RAM_DISABLE
		OUT		(PORT_COLOR_RAM),A
		RET


; Helper to load CRTC with register values pointed to by HL
setup_crtc:
		LD		C,0
		LD		B,16
L1:
		LD		A,C
		OUT		(0CH),A
		LD		A,(HL)
		OUT		(0DH),A
		INC		C
		INC		HL
		DJNZ	L1
		RET
setup_crtc_end:

CRTC_Registers_64_16:  
	DB	0x6b,0x20,0x51,0x37,0x12,0x09,0x10,0x12
	DB      0x48,0x0A,0x2F,0x0F,0x20,0x00,0x00,0x00

MBEE_TO_PS2_SCAN_CODE:
        db      VK_BACKTICK        
        db      "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        db      VK_LSQUARE
        db      VK_BACKSLASH
        db      VK_RSQUARE
        db      0               ; caret/tilda?
        db      VK_DELETE
        db      "0123456789"
        db      0               ; colon/asterisk
        db      VK_SEMICOLON
        db      VK_COMMA
        db      VK_HYPHEN
        db      VK_PERIOD
        db      VK_SLASH
        db      VK_ESCAPE
        db      VK_BACKSPACE
        db      VK_TAB
        db      0               ; line feed
        db      VK_ENTER
        db      0               ; lock
        db      0               ; break
        db      VK_SPACE
        db      VK_UP
        db      VK_LCTRL
        db      VK_DOWN
        db      VK_LEFT
        db      0               ; unused
        db      0               ; unused
        db      VK_RIGHT
        db      VK_LSHIFT




BOX_DRAW_CHARS:
        db      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 
        db      0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 
        db      0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00 
        db      0x00, 0x00, 0x00, 0x00, 0x00, 0xf0, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00 
        db      0x10, 0x10, 0x10, 0x10, 0x10, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 
        db      0x10, 0x10, 0x10, 0x10, 0x10, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 
        db      0x00, 0x00, 0x00, 0x00, 0x00, 0x1f, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00 
BOX_DRAW_CHARS_END:


; Convert block number to cyclinder/head/sector  (assuming fbfs image setup as --hdd1=fbfs.hd0)
; DEBC = 32 bit block number
;  track = block_number / 68
;  head = (block_number % 68) / 17
;  sector = block_number % 17 + 1
SELECT_DISK_BLOCK:

	push		HL
	push		BC
	pop			HL

	; Don't support 32 bit block numbers
	ld			A,D
	or			E
	jr			z,sdb_ok

	; Bad block number, quit
	jr			$

sdb_ok:

	push		HL

	; Setup sector number (block%17+1)
	ld			C,17
	call		DIV_HL_C
	inc			A
	out			(0x43),A

	pop			HL

	; Setup track number (block/68)
	ld			C,68
	call		DIV_HL_C
	ld			C,0x44
	out			(C),L
	ld			C,0x45
	out			(C),H

	; Setup head (block%68)/17
	ld			L,A				; A=block%68 (from above div)
	ld			H,0
	ld			C,17
	call		DIV_HL_C
	ld			A,10101000b		; Size = 512bytes (01), Drive=1   (ESSDDHHH)
	or			L				; Head = L
	out			(0x46),A

	pop			HL

	ret

SELECT_DISK_BLOCK_END:

; Read block DEBC in to buffer at HL
DISK_READ:

	; Setup disk controller sector/head/track
	call		SELECT_DISK_BLOCK

	; Initiate the read command
	ld			A,20h
	out			(0x47),A

	; Wait for read to finish
dr_wait:	
	in		A,(0x47)
	and		0x80
	JR		NZ,dr_wait

	; Read it
	ld		BC,0x0040
	inir
	inir

	; Done!
	ret
DISK_READ_END:

; Write block DEBC from buffer at BC
DISK_WRITE:

	; Setup disk controller sector/head/track
	call		SELECT_DISK_BLOCK

	; Initiate the write command
	ld			A,30h
	out			(0x47),A

	; Read it
	ld		BC,0x0040
	otir
	otir

	; Wait for write to finish
dw_wait:	
	in		A,(0x47)
	and		0x80
	JR		NZ,dw_wait

	; Done!
	ret
DISK_WRITE_END:



READ_KEY:

    ld      a,10h
    out     (0ch),a
    in      a,(0dh)
    ld      a,11h
    out     (0ch),a
    in      a,(0dh)


	; Wait for next key to be pressed
rk_loop2:
	in		A,(0x0C)
	and		01000000b
	jr		nz,rk_pressed
	xor		A
	ld		(DEBUG_PREV_KEY),A
	jr		rk_loop2


rk_pressed:

    ld      a,10h
    out     (0ch),a
    in      a,(0dh)
    ld      h,a
    ld      a,11h
    out     (0ch),a
    in      a,(0dh)
    ld      l,a
    add     hl,hl
    add     hl,hl
    add     hl,hl
    add     hl,hl
    ld      a,h
    and     3fh

    ld		HL,MBEE_TO_PS2_SCAN_CODE
    ld		E,A
    ld		D,0
    add		HL,DE

    ld		A,(DEBUG_PREV_KEY)
    ld		B,A
    ld		A,(HL)
    cp		B
    jr		Z,READ_KEY

    ld		(DEBUG_PREV_KEY),A

	ret

READ_KEY_END:


