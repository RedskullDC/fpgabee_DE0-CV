r_seed:		EQU		0xF000  	; prng seed byte (must not be zero)
stack_top:	EQU		0xF400


	org		0

	; Test write immediately on startup
	ld		A,0xA5
	ld		(0x8010),A
	ld		A,(0x8010)
	cp		0xA5
	jr		NZ,fail1

	; Setup 
	ld		SP,stack_top
	ld		A,1
	ld		(r_seed),A

	call	test1
	call	test2		; never returns!
	jr		$

fail1:
	ld		A,0xF1;
	out		(0xa0),A
	jr		$


; Simple test fills from 0x4000 -> 0xC000 with AA
; Reads it back and tests it's correct
test1:

	; Write
	ld		HL,0x4000
	ld		DE,0x4001
	ld		BC,0x7fff
	ld		(HL),0xAA
	ldir

	; Read, check
	ld		HL,0x4000
	ld		BC,0x8000
read_loop:
	ld		A,(HL)
	cp		0xAA
	jr		NZ,fail2
	inc		HL
	dec		BC
	ld		A,B
	or		C
	jr		NZ,read_loop

	ret

; More complex test:
; Fills from 0x4000 to 0xC000 with initial byte
; Main loop HL from 0x4000 to 0x8000
;  		Compares (HL) to (HL+0x4000)
; 		Write a random byte to (HL)
; 		Read it straight back and check it's correct
; 		Write same random byte to (HL+0x4000)
; 		Read it straight back and check it's correct
; 		Delay
;		Repeat main loop forever
test2:
	; Init memory
	ld		HL,0x4000
	ld		DE,0x4001
	ld		BC,0x7fff
	ld		(HL),0xBA
	ldir

	ld		HL,0x4000
	ld		BC,0
test2_l1:

	push	BC
	
	; Display the address
	ld		A,H
	out		(0xa2),A
	ld		A,L
	out		(0xa1),A

	; Compare two bytes
	ld		DE,0x4000
	ld		A,(HL)		; Get old byte
	add		HL,DE		; Go to pair address
	cp		(HL)		; Compare
	jr		NZ,fail3		; Quit if fail


	; Get a new random byte
	call	rand_8

	; Write it to lower half
	or		A
	sbc		HL,DE
	ld		(HL),A	
	ld		B,(HL)
	cp		B
	jr		NZ,fail4

	; Add 0x4000
	add		HL,DE

	; Display the address
	push	AF
	ld		A,H
	out		(0xa2),A
	ld		A,L
	out		(0xa1),A
	pop		AF


	; Write it to upper half
	ld		(HL),A
	ld		B,(HL)	
	cp		B
	jr		NZ,fail5

	inc		HL
	ld		A,H
	and		0x3F
	or		0x40
	ld		H,A

	pop		BC
	dec		BC
	ld		A,B
	or		C
	jr		NZ,test2_l1

	; Delay for a bit
	ld		BC,0
delay_loop:
	dec		BC
	ld		A,B
	or		C
	jr		NZ,delay_loop

	jr		test2_l1

fail2:
	ld		A,0xF2;
	out		(0xa0),A
	jr		$

fail3:
	ld		A,0xF3
	out		(0xa0),A
	jr		$

fail4:
	ld		A,0xF4
	out		(0xa0),A
	jr		$

fail5:
	ld		A,0xF5
	out		(0xa0),A
	jr		$


rand_8:
	LD	A,(r_seed)	; get seed
	AND	0xB8		; mask non feedback bits
	SCF				; set carry
	JP	PO,no_clr	; skip clear if odd
	CCF				; complement carry (clear it)
no_clr:
	LD	A,(r_seed)	; get seed back
	RLA				; rotate carry into byte
	LD	(r_seed),A	; save back for next prn
	RET				; done


