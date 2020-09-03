COLOR_RAM_BASE:		EQU	0xF800
PCG_RAM_BASE:		EQU 0xF800
CHAR_RAM_BASE:		EQU 0xF000
ATTR_RAM_BASE:		EQU 0F000h

COLOR_BLACK:		EQU 0
COLOR_DARK_RED:     EQU 1
COLOR_DARK_GREEN:   EQU 2
COLOR_BROWN:        EQU 3
COLOR_DARK_BLUE:    EQU 4
COLOR_DARK_MAGENTA: EQU 5
COLOR_DARK_CYAN:    EQU 6
COLOR_LIGHT_GREY:   EQU 7
COLOR_DARK_GREY:    EQU 8
COLOR_RED:          EQU 9
COLOR_GREEN:        EQU 10
COLOR_YELLOW:       EQU 11
COLOR_BLUE:         EQU 12
COLOR_MAGENTA:      EQU 13
COLOR_CYAN:         EQU 14
COLOR_WHITE:        EQU 15

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

KEY_LEFT:     EQU 59
KEY_RIGHT:    EQU 62
KEY_COMMA:    EQU 44
KEY_PERIOD:   EQU 46
KEY_SPACE:    EQU 55
KEY_ENTER:    EQU 52
KEY_1:        EQU 33
KEY_2:        EQU 34
KEY_ESCAPE:   EQU 48


; Various CRTC configurations

CRTC_Registers_64_16:  
	DB	0x6b,0x40,0x51,0x37,0x12,0x09,0x10,0x12
	DB  0x48,0x0F,0x2F,0x0F,0x00,0x00,0x00,0x00

CRTC_Registers_64_16_b:  
	DB	0x6b,0x40,0x51,0x37,0x12,0x09,0x10,0x12
	DB  0x48,0x0A,0x2F,0x0F,0x20,0x00,0x00,0x00

CRTC_Registers_64_17:  
	DB	0x6b,0x40,0x51,0x37,0x12,0x09,0x11,0x12
	DB  0x48,0x0F,0x2F,0x0F,0x00,0x00,0x00,0x00

CRTC_Registers_64_18:  
	DB	0x6b,0x40,0x51,0x37,0x12,0x09,0x12,0x12
	DB  0x48,0x0F,0x2F,0x0F,0x00,0x00,0x00,0x00

CRTC_Registers_40_25:
	DB	0x35,0x28,0x2D,0x24,0x1B,0x05,0x19,0x1A
	DB  0x48,0x0A,0x2A,0x0A,0x00,0x00,0x00,0x00

CRTC_Registers_80_16:
	DB	0x6B,0x50,0x59,0x37,0x12,0x09,0x10,0x12
	DB  0x48,0x0F,0x2F,0x0F,0x00,0x00,0x00,0x00

CRTC_Registers_80_24:
	DB	0x6B,0x50,0x58,0x37,0x1B,0x05,0x18,0x1A
	DB  0x48,0x0A,0x2A,0x0A,0x20,0x00,0x00,0x00

CRTC_Registers_80_25:
	DB	0x6B,0x50,0x58,0x37,0x1B,0x05,0x19,0x1A
	DB  0x48,0x0A,0x09,0x0A,0x20,0x00,0x00,0x00


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

is_key_down:  
		PUSH    BC
		LD      C,A
		LD      B,A
		LD      A,12h
		OUT     (0Ch),A
		LD      A,B
		RRCA
		RRCA
		RRCA
		RRCA
		AND     03h
		OUT     (0Dh),A
		LD      A,13h
		OUT     (0Ch),A
		LD      A,B
		RLCA
		RLCA
		RLCA
		RLCA
		OUT     (0Dh),A
		LD      A,01h
		OUT     (0Bh),A
		LD      A,10h
		OUT     (0Ch),A
		IN      A,(0Dh)
		LD      A,1Fh
		OUT     (0Ch),A
		OUT     (0Dh),A
L095D: 	IN      A,(0Ch)
		BIT     7,A
		JR      Z,L095D
		IN      A,(0Ch)
		CPL
		BIT     6,A
		LD      A,00h
		OUT     (0Bh),A
		LD      A,C
		POP     BC
		RET


;; Wait for space key
wait_key:
	LD		A,KEY_SPACE
	CALL	is_key_down
	JR		NZ,wait_key

L_wait2:
	LD		A,KEY_SPACE
	CALL	is_key_down
	JR		Z,L_wait2
	RET


		; print integer in HL to DE
prt_int_word:
		LD		A,'0'
		LD		(LIB_SCRATCH+0),A
		ld		bc,-10000
		call	Num1
		ld		bc,-1000
		call	Num1
		ld		bc,-100
		call	Num1
		ld		c,-10
		call	Num1
		ld		c,b
		XOR		A
		LD		(LIB_SCRATCH+0),A

Num1:		
		ld		a,'0'-1
Num2:	
		inc		a
		add		hl,bc
		jr		c,Num2
		sbc		hl,bc

		LD		C,A
		LD		A,(LIB_SCRATCH+0)
		cp		C
		ret		Z
		LD		A,C

		ld		(de),A
		inc		de
		XOR		A
		LD		(LIB_SCRATCH+0),A
		ret

		; print hex word in HL to DE
prt_hex_word:
		LD		A,H
		CALL	prt_hex_byte
		LD		A,L
		CALL	prt_hex_byte
		ret

		; print hex byte in A to DE
prt_hex_byte:
		PUSH	AF
		SRL		A
		SRL		A
		SRL		A
		SRL		A
		CALL	prt_hex_nib
		POP		AF
		;; fall through


		; print low nibble of A to DE
prt_hex_nib:
		and     0xF
		cp      0xA
		jr      c,lt10
		add		'A' - 0xA;
		ld		(de),a
		inc		de
		ret
lt10:
		add		'0'
		ld		(de),a
		inc		de
		ret;


