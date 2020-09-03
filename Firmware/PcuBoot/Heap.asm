; This is a _really_ simple heap manager, designed to work well enough for FPGABee's PCU
; Note the following:
;   - free blocks aren't split for smaller allocations - the first one that's big enough is
;      used
;   - free blocks aren't coalesced
;   - freeing the highest block will drop the hi-water mark.
; In other words:
;   - try to free blocks in the reverse order they're allocated
;   - try to allocate permanent/long living allocations first.

; Initialize the heap
HeapInit:
	ld		HL,0
	ld		(HEAP_FREE_CHAIN),HL
	ld		HL,HEAP_BASE_ADDRESS
	ld		(HEAP_HI_WATER),HL
	ret
HeapInitEnd:


; On entry
; 	BC = number of bytes
; On return
; 	HL = pointer
HeapAlloc:
	ld		IX,0
	add		IX,SP

	; BC must allocate at least 2 bytes
	ld		a,0
	or		b
	jr		nz,ha_big_enough
	ld		a,c
	cp		2
	jr		nc,ha_big_enough
	ld		c,2
ha_big_enough:

	; Previous chain pointer
	ld		(IX-10),0
	ld		(IX-9),0

	; Anything in the free chain?
	ld		HL,(HEAP_FREE_CHAIN)

heap_alloc_l1:
	ld		A,H
	or		L
	jr		Z,no_free_blocks

	; Get the size of this free block
	ld		E,(HL)
	inc		HL
	ld		D,(HL)
	inc		HL

	; Is it big enough?
	ld		A,E
	sub		C
	ld		A,D
	sbc		A,B
	jr		nc,found_free_block

	; Save previous pointer
	ld		(IX-10),L
	ld		(IX-9),H

	; Follow chain
	ld		E,(HL)
	inc		HL
	ld		D,(HL)
	inc		HL
	ex		DE,HL
	jr		heap_alloc_l1

found_free_block:
	; Save pointer to the memory block
	push	HL			

	; Unlink this block

	; Get address to next memory block
	ld		E,(HL)		
	inc		HL
	ld		D,(HL)
	inc		HL			; DE = pointer to next

	; Get address of previous memory block
	ld		L,(IX-10)
	ld		H,(IX-9)
	ld		A,L
	or		H
	jr		Z,ffb_1
	ld		(HL),E
	inc		HL
	ld		(HL),D
	jr		ffb_2

ffb_1:
	; Freed block is first in chain, update head pointer
	ex		DE,HL
	ld		(HEAP_FREE_CHAIN),HL

ffb_2:
	; Restore block pointer
	pop		HL			

	; Split block?

	ret

no_free_blocks:
	; Check have room in heap
	ld		HL,(HEAP_HI_WATER)
	add		HL,BC
	inc		HL
	inc		HL
	ld		DE,HEAP_BASE_ADDRESS + HEAP_SIZE

	; Compare HL > DE
	ld		A,E
	sub		L
	ld		A,D
	sbc		A,H
	jr		c,out_of_memory

	; Have room, adjust hi-water
	ld		HL,(HEAP_HI_WATER)
	ld		(HL),C
	inc		HL
	ld		(HL),B
	inc		HL
	push	HL
	add		HL,BC
	ld		(HEAP_HI_WATER),HL
	pop		HL
	ret

out_of_memory:
	ld		HL,0
	ret

HeapAllocEnd:

; On Entry
; 	HL = pointer
HeapFree:

	; Get the size of the allocated block
	dec		HL
	ld		B,(HL)
	dec		HL
	ld		C,(HL)		; BC = size of block

	; Is it the highest allocated block?
	push	HL
	add		HL,BC
	inc		HL
	inc		HL			; end of allocated block
	ex		DE,HL		
	ld		HL,(HEAP_HI_WATER)
	ld		A,D
	cp		H
	jr		NZ,add_to_free_chain
	ld		A,E
	cp		L
	jr		NZ,add_to_free_chain

	; Lower heap hi-water
	pop		HL
	ld		(HEAP_HI_WATER),HL
	ret

add_to_free_chain:
	pop		HL
	ld		DE,(HEAP_FREE_CHAIN)
	ld		(HEAP_FREE_CHAIN),HL
	inc		HL
	inc		HL
	ld		(HL),E
	inc		HL
	ld		(HL),D
	ret

HeapFreeEnd: