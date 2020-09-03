	org		0

	ld		SP,0xC000

;	; Setup seed
;	ld		A,0xFE
;	ld		(r_seed),A
;
;	ld		C,1
;
;	ld		HL,0xC000
;loop:
;	ld		A,C
;	xor		0x3
;	ld		C,A
;	out		(0),A
;
;	; Generate a random address at (0xC000-0xFFFF)
;	call	rand_8
;	out		(1),A
;	ld		L,A
;	call	rand_8
;	or		0xC0
;	out		(2),A
;	ld		H,A
;
;	xor		L
;	ld		(HL),A
;
;	ld		B,A
;	ld		A,(HL)
;
;	cp		B
;	jr		Z,loop
;
;	; Failed!
;	ld		A,4
;	out		(0),A
;
;	jr		$


	ld		E,0x3
loop:
	ld		A,E
	out		(0),A
	rlca
	ld		E,A
	call	delay_loop
	jr		loop

delay:
	ld		BC,12000
delay_loop:
	dec		BC
	ld		A,B
	or		C
	jr		NZ,delay_loop
	ret

; returns pseudo random 8 bit number in A. Only affects A.
; (r_seed) is the byte from which the number is generated and MUST be	
; initialised to a non zero value or this function will always return
; zero. Also r_seed must be in RAM, you can see why......

rand_8:
	LD	A,(r_seed)	; get seed
	AND	0xB8		; mask non feedback bits
	SCF			; set carry
	JP	PO,no_clr	; skip clear if odd
	CCF			; complement carry (clear it)
no_clr:
	LD	A,(r_seed)	; get seed back
	RLA			; rotate carry into byte
	LD	(r_seed),A	; save back for next prn
	RET			; done

r_seed:	EQU		0x8001  	; prng seed byte (must not be zero)
