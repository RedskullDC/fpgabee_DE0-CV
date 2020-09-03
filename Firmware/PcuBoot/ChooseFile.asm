CF_LOCAL_SPACE:		EQU	12
CF_STRINGS:			EQU CF_LOCAL_SPACE-2
CF_SAVE_SCREEN:		EQU CF_LOCAL_SPACE-4
CF_FILTER:			EQU CF_LOCAL_SPACE-6
CF_CURR_FILE:		EQU	CF_LOCAL_SPACE-8
CF_SEL_INDEX:		EQU	CF_LOCAL_SPACE-10
CF_CAN_EJECT:		EQU	CF_LOCAL_SPACE-12


CHOOSE_FILE_ORIGIN:	EQU	0x0042
CHOOSE_FILE_SIZE:	EQU	0x0C1C

CF_STR_NONE:		DB "<eject>",0

; Choose a file 
; 	DE = filter string
; 	HL = dir id of the currently selected image
; 	A = 1 to include an option for "eject"
; Returns DE = directory number of selected image
;            = 0xFFFF (-1) if cancelled
;            = 0xFFFE (-2) if selected <eject>
CHOOSE_FILE:

	; Setup stack frame
	ld		IY,-CF_LOCAL_SPACE
	add		IY,SP
	ld		SP,IY

	ld		(IY+CF_CAN_EJECT),A

	; Save the filter string
	ld		(IY+CF_FILTER),E
	ld		(IY+CF_FILTER+1),D

	; Set the default initial selection to -1
	ld		A,0xFF
	ld		(IY+CF_SEL_INDEX),A
	ld		(IY+CF_SEL_INDEX+1),A

	; Convert the currently selected directory index to 
	; a pointer to the filename for that directory entry
	ld		A,H
	and		0x80
	jr		nz,cf_no_prev_sel
	add		HL,HL		;*2
	add		HL,HL		;*4
	add		HL,HL		;*8
	add		HL,HL		;*16
	add		HL,HL		;*32
	ex		DE,HL
	ld		HL,(PTR_DIRECTORY)
	add		HL,DE
	ld		DE,DIR_FILENAME
	add		HL,DE
cf_no_prev_sel:
	ld		(IY+CF_CURR_FILE),L
	ld		(IY+CF_CURR_FILE+1),H

	; Save the screen area
	ld		HL,CHOOSE_FILE_ORIGIN
	ld		BC,CHOOSE_FILE_SIZE
	call	SAVE_SCREEN_AREA
	ld		(IY+CF_SAVE_SCREEN),L
	ld		(IY+CF_SAVE_SCREEN+1),H

	; Setup colours
	ld		HL,COLOR_RAM + CHOOSE_FILE_ORIGIN
	ld		BC,CHOOSE_FILE_SIZE
	ld		A,0xCF
	COLOR_RAM_IN
	call	CLEAR_SCREEN_AREA
	COLOR_RAM_OUT

	; Draw border
	ld		HL,VCHAR_RAM + CHOOSE_FILE_ORIGIN
	ld		BC,CHOOSE_FILE_SIZE
	call	DRAW_BORDER_AT

	; Allocate enough room for a pointer to every possible file name
	ld		HL,(TOTAL_DIR_ENTRIES)
	add		HL,HL
	inc		HL			; add 2 for the terminator
	inc		HL
	inc		HL			; and 2 for the "eject" entry
	inc		HL
	push	HL
	pop		BC
	call	HeapAlloc
	ld		(IY+CF_STRINGS),L
	ld		(IY+CF_STRINGS+1),H

	; IX is destination string pointer
	push	HL
	pop		IX

	ld		A,(IY+CF_CAN_EJECT)
	or		A
	jr		Z,cf_no_eject

	ld		HL,CF_STR_NONE
	ld		(IX+0),L
	ld		(IX+1),H
	inc		IX
	inc		IX

cf_no_eject:

	; Calculate pointer to file name of first directory entry
	ld		HL,(PTR_DIRECTORY)
	ld		DE,DIR_FILENAME
	add		HL,DE

	ld		BC,(TOTAL_DIR_ENTRIES)
cf_scan_dir:

	; Is the file name zero length?
	ld		A,(HL)
	or		A
	jr		Z,cf_skip_file

	ld		E,(IY+CF_FILTER)
	ld		D,(IY+CF_FILTER+1)
	push	HL
	call	IS_EXTENSION_ONE_OF
	pop		HL
	jr		NZ,cf_skip_file

	; Check this file is the currently selected file
	ld		A,(IY+CF_CURR_FILE)
	cp		L
	jr		NZ,cf_not_curr_file
	ld		A,(IY+CF_CURR_FILE+1)
	cp		H
	jr		NZ,cf_not_curr_file

	; This is the current file, work out it's index
	;  (IX-pStrings)/2
	push	HL
	push	IX
	pop		HL
	ld		E,(IY+CF_STRINGS)
	ld		D,(IY+CF_STRINGS+1)
	or		A
	sbc		HL,DE
	SRL		H		; Shift HL right by one
	RR		L
	ld		(IY+CF_SEL_INDEX),L
	ld		(IY+CF_SEL_INDEX+1),H
	pop		HL

cf_not_curr_file:

	; Store the file name pointer in list strings
	ld		(IX+0),L
	ld		(IX+1),H
	inc		IX
	inc		IX


cf_skip_file:
	ld		DE,DIR_SIZE
	add		HL,DE
	dec		BC
	ld		A,B
	or		C
	jr		nz,cf_scan_dir

	; Null terminate the list of strings
	xor		A
	ld		(IX+0),A
	ld		(IX+1),A

	; Show the list box	
	push	IY
	ld		L,(IY+CF_STRINGS)
	ld		H,(IY+CF_STRINGS+1)
	push	HL			; Strings
	ld		HL,CHOOSE_FILE_ORIGIN+SCREEN_WIDTH+1		; Origin
	push	HL			
	ld		HL,CHOOSE_FILE_SIZE-0x0202	; Size
	push	HL
	ld		L,(IY+CF_SEL_INDEX)
	ld		H,(IY+CF_SEL_INDEX+1)
	push	HL
	ld		HL,0xB0CF	; Colours
	push	HL
	ld		HL,0		; Callback
	push	HL
	call 	LISTBOX
	ld		IY,12
	add		IY,SP
	ld		SP,IY
	pop		IY

	ld		A,D
	and		0x80
	jr		NZ,cf_cancelled

	ld		A,(IY+CF_CAN_EJECT)
	or		A
	jr		Z,cf_select_image

	ld		A,D
	or		E
	jr		Z,cf_eject

cf_select_image:
	; Convert the selected index back into directory entry number
	ld		L,(IY+CF_STRINGS)
	ld		H,(IY+CF_STRINGS+1)
	add		HL,DE
	add		HL,DE
	ld		E,(HL)
	inc		HL
	ld		D,(HL)						; DE = pointer to file name
	ex		DE,HL
	ld		DE,DIR_FILENAME
	or		A
	sbc		HL,DE						; HL = pointer to directory entry
	ld		DE,(PTR_DIRECTORY)
	or		A
	sbc		HL,DE						; HL = offset from directory memory to directory entry

	SRL		H							; /2
	RR		L
	SRL		H							; /4
	RR		L
	SRL		H							; /8
	RR		L
	SRL		H							; /16
	RR		L
	SRL		H							; /32
	RR		L

	ex		DE,HL						; DE = directory index

	jr		cf_finished

cf_eject:
	ld		DE,0xFFFE					; -2 = eject disk

cf_cancelled:
cf_finished:
	push	DE
	; Free memory
	ld		L,(IY+CF_STRINGS)
	ld		H,(IY+CF_STRINGS+1)
	call	HeapFree

	; Restore the screen area
	ld		L,(IY+CF_SAVE_SCREEN)
	ld		H,(IY+CF_SAVE_SCREEN+1)
	call	RESTORE_SCREEN_AREA

	pop		DE

	; Clean up local stack frame
	ld		IY,CF_LOCAL_SPACE
	add		IY,SP
	ld		SP,IY
	ret

CHOOSE_FILE_END:

; Given a filename in HL
; and a double NULL terminated string (without the dot) in DE
; eg: db "hd0",0,"hd1",0,0.  Pass DE=NULL to match all files
; Return Z if one matches
IS_EXTENSION_ONE_OF:
	
	ld		A,D
	or		E
	ret		Z

	; Find the file's extension
	call	FIND_EXTENSION
	ld		A,H
	or		L
	jr		nz,ix_has_extension

	; No extension, no match
	or		1
	ret

ix_has_extension:
	inc		HL

ix_loop:
	; HL = filename extension (after dot)
 	; DE = next extension to match
	push	HL
	call	STRICMP
	pop		HL
	ret		Z

	; Find the next extension
ix_loop2:
	ld		A,(DE)
	or		A
	inc		DE
	jr		NZ,ix_loop2

	; End of the list?
	ld		A,(DE)
	or		A
	jr		NZ,ix_loop

	; Doesn't match any extension
	or		1
	ret

IS_EXTENSION_ONE_OF_END: