if DEBUG
	BOX_TL:		EQU	6 + 128
	BOX_TR:		EQU 3 + 128
	BOX_BL:		EQU	4 + 128
	BOX_BR:		EQU 5 + 128
	BOX_H:		EQU 1 + 128
	BOX_V:		EQU 2 + 128
else
	BOX_TL:		EQU	6
	BOX_TR:		EQU 3
	BOX_BL:		EQU	4
	BOX_BR:		EQU 5
	BOX_H:		EQU 1
	BOX_V:		EQU 2
endif

; Draw a box border
;   HL = base address
;   BC = height/with
DRAW_BORDER_AT:
	ld		IX,-10
	add		IX,SP

	; Save dimensions
	ld		(IX+0),C
	ld		(IX+1),B

	push	HL

	; Top left corner		
	ld		(HL),BOX_TL	
	inc		HL

	; Top edge
	ld		C,(IX+0)
	dec		C
	dec		C
	ld		B,0
	push	HL
	pop		DE
	inc		DE
	ld		(HL),BOX_H
	ldir

	; Top right corner
	ld		(HL),BOX_TR
	inc		HL

	; Right edge
	pop		HL
	push	HL
	ld		E,(IX+0)
	ld		D,0
	dec		E
	add		HL,DE				; Move to RHS
	ld		DE,SCREEN_WIDTH		; Move to second row
	add		HL,DE

	ld		B,(IX+1)			; Number of rows
	dec		B
	dec		B					; Exclude top/bottom
dba_l1:
	ld		(HL),BOX_V
	add		HL,DE
	djnz	dba_l1

	; Left edge
	pop		HL
	ld		DE,SCREEN_WIDTH
	add		HL,DE

	ld		B,(IX+1)			; Number of rows
	dec		B
	dec		B					; Exclude top/bottom
dba_l2:
	ld		(HL),BOX_V
	add		HL,DE
	djnz	dba_l2

	; Bottom left
	ld		(HL),BOX_BL
	inc		HL

	; Bottom edge
	ld		C,(IX+0)
	dec		C
	dec		C
	ld		B,0
	push	HL
	pop		DE
	inc		DE
	ld		(HL),BOX_H
	ldir

	; Bottom right corner
	ld		(HL),BOX_BR
	inc		HL

	ret

DRAW_BORDER_AT_END:

; Clear character ram
CLEAR_SCREEN:
	ld		HL,VCHAR_RAM
	ld		DE,VCHAR_RAM+1
	ld		BC,VBUFFER_SIZE-1
	ld		(HL),' '
	ldir
	ret
CLEAR_SCREEN_END:


; Clear color ram to color A
CLEAR_COLOR:
	COLOR_RAM_IN
	ld		HL,COLOR_RAM
	ld		DE,COLOR_RAM+1
	ld		BC,VBUFFER_SIZE-1
	ld		(HL),A
	ldir
	COLOR_RAM_OUT
	ret
CLEAR_COLOR_END:


		; print hex word in HL to DE
PRT_HEX_WORD:
		LD		A,H
		CALL	PRT_HEX_BYTE
		LD		A,L
		CALL	PRT_HEX_BYTE
		ret

		; print hex byte in A to DE
PRT_HEX_BYTE:
		PUSH	AF
		SRL		A
		SRL		A
		SRL		A
		SRL		A
		CALL	PRT_HEX_NIB
		POP		AF
		;; fall through


		; print low nibble of A to DE
PRT_HEX_NIB:
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
PRT_HEX_WORD_END:



; Multiply H by E, result in HL
MUL_H_E:

   ld	l, 0
   ld	d, l

   sla	h	
   jr	nc, $+3
   ld	l, e
   
   ld b, 7
mulhe_loop:
   add	hl, hl          
   jr	nc, $+3
   add	hl, de
   
   djnz	mulhe_loop
   
   ret
MUL_H_E_END:

; Divide AC by DE
; Returns quotient in AC and remainder in HL
;DIV_AC_DE:
;   ld	hl, 0
;   ld	b, 16
;
;div_ac_de_loop:
;   sll	c
;   rla
;   adc	hl, hl
;   sbc	hl, de
;   jr	nc, $+4
;   add	hl, de
;   dec	c
;   
;   djnz	div_ac_de_loop
;   
;   ret
;DIV_AC_DE_END:

; Divide HL by C
; Returns quotient in HL, remainder in A
DIV_HL_C:
   xor	a
   ld	b, 16

div_hl_c_loop:
   add	hl, hl
   rla
   cp	c
   jr	c, $+4
   sub	c
   inc	l
   
   djnz	div_hl_c_loop
   
   ret
 DIV_HL_C_END:
 

; HL = pointer to screen buffer
; B = number of rows
; C = number of columns
; A = fill with
CLEAR_SCREEN_AREA:

csa_fill:
	push	BC				; Save number of rows/cols
	push	HL				; Save current row pointer

	ld		(HL),A			; Set fill character
	push	HL				
	pop		DE
	inc		DE				; DE = HL + 1
	ld		B,0				; Number of columns in BC
	dec		C
	ldir					; memset

	pop		HL				; Restore row pointer
	pop		BC				; Restore row/col count
	ld		DE,SCREEN_WIDTH
	add		HL,DE			; Next line
	djnz	csa_fill
	ret
CLEAR_SCREEN_AREA_END:

; Save a copy of a screen area
; 	HL = offset from start of color/char buffer
; 	B = number of rows
; 	C = number of columns
; Returns ptr to malloced saved screen
SAVE_SCREEN_AREA:

	; Save params
	push	HL
	push	BC

	; Work out how much room required to store character
	; and color buffers
	ld		H,B
	ld		E,C
	call	MUL_H_E			; HL = b*c
	add		HL,HL			; HL = 2*b*c (chars+color)
	ld		DE,4
	add		HL,DE			; HL = 4 + 2*b*c

	; Allocate a block from the heap
	push	HL
	pop		BC
	call	HeapAlloc
	push	HL
	pop		IX				; IX = Allocated block

	; Restore params
	pop		BC
	pop		DE

	; Save params to allocated block
	ld		(IX+0),E
	ld		(IX+1),D
	ld		(IX+2),C
	ld		(IX+3),B

	; Setup DE as destination for the copy
	ld		DE,4
	add		HL,DE
	ex		DE,HL			; DE - allocation + 4 bytes

	; Copy colors
	ld		C,(IX+0)
	ld		B,(IX+1)
	ld		HL,COLOR_RAM	
	add		HL,BC			; HL = source
	COLOR_RAM_IN
	call	psa_copy		; Copy it
	COLOR_RAM_OUT

	; Copy characters
	ld		C,(IX+0)
	ld		B,(IX+1)
	ld		HL,VCHAR_RAM
	add		HL,BC
	call 	psa_copy

	push	IX
	pop		HL
	ret

psa_copy:
	ld		B,(IX+3)
ssa_l1:
	push	BC
	push	HL				; Save current row pointer

	ld		B,0				; Number of columns in BC
	ld		C,(IX+2)
	ldir					; copy it

	pop		HL				; Restore row pointer

	ld		BC,SCREEN_WIDTH
	add		HL,BC			; Next line

	pop		BC

	djnz	ssa_l1		; Repeat B times
	ret

SAVE_SCREEN_AREA_END:


; Restore a previously pushed copy of a screen area from the stack
;  HL - Saved block
RESTORE_SCREEN_AREA:

	push	HL
	pop		IX

	; Calculate destination ptr
	ld		HL,COLOR_RAM
	ld		E,(IX+0)
	ld		D,(IX+1)
	add		HL,DE
	ex		DE,HL

	; Calculate source ptr
	ld		BC,4
	push	IX
	pop		HL
	add		HL,BC

	; Copy region
	COLOR_RAM_IN
	call 	rsa_copy
	COLOR_RAM_OUT

	; Calculate destination ptr
	push	HL
	ld		HL,VCHAR_RAM
	ld		E,(IX+0)
	ld		D,(IX+1)
	add		HL,DE
	ex		DE,HL
	pop		HL

	; Copy region
	call 	rsa_copy

	push	IX
	pop		HL
	call	HeapFree

	; Done!
	ret

rsa_copy:
	ld		B,(IX+3)
rsa_l1:
	push	BC
	push	DE
	ld		B,0				; Number of columns in BC
	ld		C,(IX+2)
	ldir					; copy it
	pop		DE

	push	HL
	ld		HL,SCREEN_WIDTH
	add		HL,DE
	ex		DE,HL
	pop		HL

	pop		BC

	djnz	rsa_l1			; Repeat B times
	ret
RESTORE_SCREEN_AREA_END:

; Probably don't need this (doesn't work anyway)
; HL = Start address
; BC = Height/Width
;SCROLL_SCREEN_DOWN:
;
;	dec		B				; Height - 1
;	push	BC
;
;	; Work out width * (height-1)
;	push	HL
;	ld		E,C
;	ld		H,SCREEN_WIDTH
;	call	MUL_H_E
;	ex		DE,HL
;	pop		HL
;	add		HL,DE			; DEST = origin + width * (height-1) (ie: bottom row)
;
;	; Work out destination ptr (DEST - SCREEN_WIDTH)
;	push	HL
;	ld		DE,-SCREEN_WIDTH
;	add		HL,DE			; HL = SRC = DEST - SCREEN_WIDTH
;	pop		DE				; DE = DEST
;
;	pop		BC
;
;ssd_loop:
;	push	BC
;
;	push	HL				; Save source pointer
;	push	HL
;
;	ld		B,0				; BC = area width
;	ldir					; Move it
;
;	pop		HL
;	ld		DE,-SCREEN_WIDTH
;	add		HL,DE			; old source - SCREEN_WIDTH
;	pop		DE				; DE = old source
;
;	pop		BC
;	djnz	ssd_loop
;
;	ret

SCROLL_SCREEN_DOWN_END:

; HL = zero terminated string
; DE = screen buffer
; C = buffer width (will be space padded)
PRINT_LINE:

	; Copy the string
pl_loop1:
	ld		A,(HL)
	or		A
	jr		Z,pl_end_of_string
	ld		(DE),A
	inc		HL
	inc		DE
	dec		C
	ld		A,C
	or		A
	jr		nz,pl_loop1

	; Destination buffer full
	ret

pl_end_of_string:
	ex		DE,HL
	ld		A,B
	ld		B,C
pl_loop2:
	ld		(HL),' '
	inc		HL
	djnz	pl_loop2
	ld		B,A

	ret

PRINT_LINE_END:

; Copy null terminated string from HL to DE
STRCPY:
	ld		A,(HL)
	ld		(DE),A
	inc		HL
	inc		DE
	or		A
	jr		nz,STRCPY
	ret
STRCPY_END:

; Given a NULL terminated string in HL, find the last '.'
; Returns found pointer in HL, or NULL if not found
FIND_EXTENSION:
	push	DE
	ld		DE,0				; Pointer to last found dot

fe_l1:
	ld		A,(HL)
	or		A
	jr		z,fe_eos			; End of string?
	cp		'.'
	jr		nz,fe_not_a_dot
	push	HL					; Save position of the dot
	pop		DE

fe_not_a_dot:
	inc		HL					; Next character
	jr		fe_l1

fe_eos:
	ex		DE,HL				; Return the found position
	pop		DE
	ret
FIND_EXTENSION_END:

; Compare to strings case insensitively
; HL = string 1
; DE = string 2
; Returns Z if strings match
STRICMP:
	push	BC
sic_loop:
	ld		A,(HL)
	or		A
	jr		Z,sic_eos
	call	TOUPPER
	ld		C,A
	ld		A,(DE)
	call	TOUPPER
	cp		C
	jr		NZ,sic_exit
	inc		HL
	inc		DE
	jr		sic_loop
sic_exit:
	pop		BC
	ret
sic_eos:
	ld		C,A
	ld		A,(DE)
	cp		C
	jr		sic_exit
STRICMP_END:


; Make character A uppercase
TOUPPER:
	cp      'a'             ; Nothing to do if not lower case
	ret     c
	cp      'z' + 1         ; > 'z'?
	ret     nc              ; Nothing to do, either
	and     0x5f            ; Convert to upper case
	ret
TOUPPER_END: