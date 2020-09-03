if DEBUG

	ORG		8000h
	jp		PCU_MAIN

else

	ORG		0
	JP		PCU_MAIN	
	defs	0x66-$
NMI_VECTOR:
	JP		PCU_NMI
	defs	0x100-$

PCU_NMI:
	; Save Microbee state
	ld		(SAVE_MBEE_SP),SP
	ld		SP,SAVE_MBEE_REGS_TOS
	push	AF
	push	BC
	push	DE
	push	HL
	push	IX
	push	IY

	; Restore PCU state
	ld		SP,(SAVE_PCU_SP)
	pop		IY
	pop		IX
	pop		HL
	pop		DE
	pop		BC
	pop		AF

	; Carry on
	ret
PCU_NMI_END:

YIELD:
	; Save PCU state
	push	AF
	push	BC
	push	DE
	push	HL
	push	IX
	push	IY
	ld		(SAVE_PCU_SP),SP

	; Restore Microbee state
	ld		SP,SAVE_MBEE_REGS
	pop		IY
	pop		IX
	pop		HL
	pop		DE
	pop		BC
	pop		AF
	ld		SP,(SAVE_MBEE_SP)

	; Request PCU exit
	out		(0x80),A		
	retn
YIELD_END:

endif

