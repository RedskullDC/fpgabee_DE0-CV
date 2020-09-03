; Displays a list box/menu
; On entry:
;   PUSH ppStrings : (char**) to null terminated list of null terminated strings
;   PUSH pOrigin   : origin on screen to display the list
;   PUSH size	   : width in lobyte, height in hibyte
;   PUSH selection : zero based index of initial selection, 0xFFFF if none
;   PUSH colors    : normal color in lobyte, selected color in hibyte
;   PUSH callback  : callback to back called when return/esc pressed (HL=selected string pointer, DE=selected index)
; On exit:
;   DE             : zero based index of selection.  Z if selected, NZ if cancelled

LB_LOCAL_SPACE:		EQU		4
LB_STRINGS:			EQU		LB_LOCAL_SPACE + 12
LB_ORIGIN:  		EQU		LB_LOCAL_SPACE + 10
LB_SIZE:  			EQU		LB_LOCAL_SPACE + 8
LB_SEL:				EQU		LB_LOCAL_SPACE + 6
LB_COLORS:			EQU		LB_LOCAL_SPACE + 4
LB_CALLBACK:		EQU		LB_LOCAL_SPACE + 2
LB_TOP:				EQU		LB_LOCAL_SPACE - 2
LB_COUNT:			EQU		LB_LOCAL_SPACE - 4

LISTBOX:
	; Setup stack frame
	ld		IY,-LB_LOCAL_SPACE
	add		IY,SP
	ld		SP,IY

	; Count how many items
	ld		L,(IY+LB_STRINGS)
	ld		H,(IY+LB_STRINGS+1)
	ld		BC,0
lb_count_loop:
	ld		A,(HL)
	or		(HL)
	jr		Z,lb_counted
	inc		BC
	inc		HL
	inc		HL
	jr		lb_count_loop
lb_counted:
	ld		(IY+LB_COUNT),C
	ld		(IY+LB_COUNT+1),B

	; Setup top index
	xor		A
	ld		(IY+LB_TOP),A
	ld		(IY+LB_TOP+1),A

	; Setup colors for this area of the screen
	ld		C,(IY+LB_SIZE)
	ld		B,(IY+LB_SIZE+1)
	ld		L,(IY+LB_ORIGIN)
	ld		H,(IY+LB_ORIGIN+1)
	ld		A,(IY+LB_COLORS)
	ld		DE,COLOR_RAM
	add		HL,DE
	COLOR_RAM_IN
	call	CLEAR_SCREEN_AREA
	COLOR_RAM_OUT

lb_main_loop:
	; Check top/sel indicies
	call	lb_check_sel_range
	call	lb_check_sel_visible
	call	lb_check_top_range

	; Paint the screen
	call	lb_paint

	ld		A,(IY+LB_COLORS+1)
	call	lb_paint_sel

	; Wait for a key
	call	READ_KEY

	push	AF
	ld		A,(IY+LB_COLORS)
	call	lb_paint_sel
	pop		AF

	ld		E,(IY+LB_SEL)
	ld		D,(IY+LB_SEL+1)

	cp		'O'
	jr		NZ,$+5
	jp		lb_enter

	cp		VK_UP
	jr		z,lb_up
	cp		VK_DOWN
	jr		z,lb_down
	cp		VK_ENTER
	jr		nz,$+5
	jp		lb_enter
	cp		VK_ESCAPE
	jr		z,lb_escape
if DEBUG
	cp		'H'
	jr		Z,lb_home
	cp		'E'
	jr		z,lb_end
	cp		'N'
	jr		z,lb_pagedown
	cp		'P'
	jr		z,lb_pageup
else
	cp		VK_HOME
	jr		Z,lb_home
	cp		VK_END
	jr		z,lb_end
	cp		VK_NEXT
	jr		z,lb_pagedown
	cp		VK_PRIOR
	jr		z,lb_pageup
endif
	jr		lb_main_loop

lb_escape:
	ld		E,0xFF
	ld		D,E
	jp		lb_enter

lb_move_sel:
	; DE should be new selection;
	; BC should be which direction to go it lands on a separator
	ld		A,D
	and		80h
	jr		z,lb_sel_is_positive
	ld		DE,0
lb_sel_is_positive:
	ld		L,(IY+LB_COUNT)
	ld		H,(IY+LB_COUNT+1)
	or		A
	sbc		HL,DE
	jr		nc,lb_sel_is_less_than_count
	ld		E,(IY+LB_COUNT)
	ld		D,(IY+LB_COUNT+1)
	dec		DE

lb_sel_is_less_than_count:
	ld		L,(IY+LB_STRINGS)
	ld		H,(IY+LB_STRINGS+1)
	add		HL,DE
	add		HL,DE
	push	DE
	ld		E,(HL)
	inc		HL
	ld		D,(HL)
	ex		DE,HL
	pop		DE

	ld		A,(HL)
	cp		'-'
	jr		nz,lb_not_a_sep
	ex		DE,HL
	add		HL,BC
	ex		DE,HL

lb_not_a_sep:
	ld		(IY+LB_SEL),E
	ld		(IY+LB_SEL+1),D
	jp		lb_main_loop

lb_up:
	dec		DE
	ld		BC,-1
	jr		lb_move_sel

lb_down:
	inc		DE
	ld		BC,1
	jr		lb_move_sel

lb_home:
	ld		DE,0
	ld		BC,1
	jr		lb_move_sel

lb_end:
	ld		E,(IY+LB_COUNT)
	ld		D,(IY+LB_COUNT+1)
	dec		DE
	ld		BC,-1
	jr		lb_move_sel

lb_pagedown:
	ld		L,(IY+LB_SIZE+1)
	ld		H,0
	add		HL,DE
	ex		DE,HL
	ld		BC,1
	jr		lb_move_sel

lb_pageup:
	ld		L,(IY+LB_SIZE+1)
	ld		H,0
	ex		DE,HL
	or		A
	sbc		HL,De
	ex		DE,HL
	ld		BC,-1
	jr		lb_move_sel

lb_enter:
	; Setup IX = callback
	ld		L,(IY+LB_CALLBACK)	
	ld		H,(IY+LB_CALLBACK+1)
	ld		A,L
	or		H
	jr		z,lb_return
	push	HL
	pop		IX

	; Setup HL = selected string pointer (or NULL if negative sel)
	ld		A,D
	and		80h
	jr		z,lb_get_string_pointer
	ld		HL,0
	jr		lb_cont
lb_get_string_pointer:
	ld		L,(IY+LB_STRINGS)	
	ld		H,(IY+LB_STRINGS+1)
	add		HL,DE
	add		HL,DE
lb_cont:

	; Leave DE = selected index

	; Call callback
	push	IY
	call	__call_indirect_ix
	pop		IY
	jr		z,lb_return
	jp		lb_main_loop


lb_return:
	; Clean up local stack frame
	ld		IY,LB_LOCAL_SPACE
	add		IY,SP
	ld		SP,IY
	ret

__call_indirect_ix:
	jp 		(ix)

lb_check_sel_range:
	ld		L,(IY+LB_SEL)
	ld		H,(IY+LB_SEL+1)
	ld		A,H
	and		80h			; Is the selection negative?
	jr		Z,lb_sel_not_negative
	ld		(IY+LB_SEL),0
	ld		(IY+LB_SEL+1),0
	ret
lb_sel_not_negative:
	ex		DE,HL		; DE = selection
	ld		L,(IY+LB_COUNT)	
	ld		H,(IY+LB_COUNT+1)
	dec		HL			; HL = count - 1
	or		A			; clear carry
	sbc		HL,DE		; Compare
	ret		nc			; within range

	; selection is past the end, clamp to count-1
	ld		L,(IY+LB_COUNT)	
	ld		H,(IY+LB_COUNT+1)
	dec		HL			; HL = count - 1
	ld		(IY+LB_SEL),L	
	ld		(IY+LB_SEL+1),H

	ret

lb_check_sel_visible:
	ld		L,(IY+LB_SEL)
	ld		H,(IY+LB_SEL+1)
	ld		E,(IY+LB_TOP)
	ld		D,(IY+LB_TOP+1)
	push	HL
	push	DE
	or		A			; clear carry
	sbc		HL,DE
	pop		DE
	pop		HL
	jr		nc,lb_sel_not_off_top

	; Select is off the top, set top to selection
	ld		(IY+LB_TOP),L
	ld		(IY+LB_TOP+1),H
	ret

lb_sel_not_off_top:
	ld		C,(IY+LB_SIZE+1)
	ld		B,0
	dec		C
	ex		DE,HL
	add		HL,BC
	ex		DE,HL		; DE is now the index of the last visible item, HL is the current sel

	or		A			; clear carry
	sbc		HL,DE
	ret		C
	ret		Z

	ld		E,(IY+LB_TOP)
	ld		D,(IY+LB_TOP+1)
	add		HL,De
	ld		(IY+LB_TOP),L
	ld		(IY+LB_TOP+1),H
	ret


lb_check_top_range:
	ret

lb_paint_sel:
	; Work out number of lines from top 
	ld		L,(IY+LB_SEL)
	ld		H,(IY+LB_SEL+1)
	ld		E,(IY+LB_TOP)
	ld		D,(IY+LB_TOP+1)
	or		A
	sbc		HL,DE

	; Work out offset to selected line
	ld		E,L
	ld		H,SCREEN_WIDTH
	call	MUL_H_E
	ld		DE,COLOR_RAM
	add		HL,DE				
	ld		E,(IY+LB_ORIGIN)
	ld		D,(IY+LB_ORIGIN+1)
	add		HL,DE				; HL = color buf pointed for selected line
	push	HL
	pop		DE
	inc		DE

	ld		B,0
	ld		C,(IY+LB_SIZE)		
	dec		C					; Width of listbox

	; Fill color buffer
	COLOR_RAM_IN
	ld		(HL),A
	ldir
	COLOR_RAM_OUT
	ret


lb_paint:
	; Print the menu
	ld		HL,VCHAR_RAM
	ld		E,(IY+LB_ORIGIN)
	ld		D,(IY+LB_ORIGIN+1)
	add		HL,DE
	ex		DE,HL		; DE = screen pointer
	ld		L,(IY+LB_STRINGS)
	ld		H,(IY+LB_STRINGS+1)	
	ld		C,(IY+LB_TOP)	; Top index
	ld		B,(IY+LB_TOP+1)
	add		HL,BC		; Add to source strings array pointer
	add		HL,BC
	push	HL
	pop		IX			; IX = strings array pointer

	ld		B,(IY+LB_SIZE+1)
paint_loop:
	ld		L,(IX+0)
	ld		H,(IX+1)	; HL = string pointer
	ld		A,L
	or		H
	jr		Z,paint_loop_not_enough_strings

	ld		A,(HL)
	cp 		'-'			; Separator?
	jr		nz,paint_loop_not_a_sep

	push	DE
	push	DE
	pop		HL
	inc		DE
	push	BC
	ld		C,(IY+LB_SIZE)
	dec		C
	ld		B,0
	ld		(HL),BOX_H
	ldir
	pop		BC
	pop		DE
	jr		paint_loop_cont

paint_loop_not_enough_strings:
	ld		HL,NULL_STRING
	dec		IX			; Stop IX from incrementing
	dec		IX

paint_loop_not_a_sep:
	push	DE
	ld		C,(IY+LB_SIZE)
	call	PRINT_LINE
	pop		DE

paint_loop_cont:
	ld		HL,SCREEN_WIDTH
	add		HL,DE
	ex		DE,HL		; DE = next line

	inc		IX
	inc		IX			; IX = next string
	djnz	paint_loop
paint_loop_finished:

	; Done!
	ret

NULL_STRING:
	db		0

END_LISTBOX:


