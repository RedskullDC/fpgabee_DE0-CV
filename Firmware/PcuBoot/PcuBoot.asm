DEBUG:				EQU 0

if DEBUG
RAM_LO:					EQU	0x100
RAM_HI:					EQU	0x4000
else
RAM_LO:					EQU	0x4000
RAM_HI:					EQU	0x8000
endif

; FBFS Config Sector
FBFS_SIG:			EQU		0
FBFS_VER:			EQU		FBFS_SIG + 4
FBFS_DIRBLK:		EQU		FBFS_VER + 2
FBFS_DIRCOUNT:		EQU		FBFS_DIRBLK + 4
FBFS_DI_SYSTEM:		EQU		FBFS_DIRCOUNT + 2
FBFS_DI_ROM_0:		EQU		FBFS_DI_SYSTEM + 2
FBFS_DI_ROM_1:		EQU		FBFS_DI_ROM_0 + 2
FBFS_DI_ROM_2:		EQU		FBFS_DI_ROM_1 + 2
FBFS_DI_DISK_0:		EQU		FBFS_DI_ROM_2 + 2
FBFS_DI_DISK_1:		EQU		FBFS_DI_DISK_0 + 2
FBFS_DI_DISK_2:		EQU		FBFS_DI_DISK_1 + 2
FBFS_DI_DISK_3:		EQU		FBFS_DI_DISK_2 + 2
FBFS_DI_DISK_4:		EQU		FBFS_DI_DISK_3 + 2
FBFS_DI_DISK_5:		EQU		FBFS_DI_DISK_4 + 2
FBFS_DI_DISK_6:		EQU		FBFS_DI_DISK_5 + 2
FBFS_CONFIG_SIZE:	EQU		FBFS_DI_DISK_6 + 2	

; FBFS Directory structure
DIR_BLOCK:			EQU		0
DIR_BLOCK_COUNT:	EQU		4
DIR_RESERVED:		EQU		6
DIR_FILENAME:		EQU		10
DIR_SIZE:			EQU		32

MAX_FILENAME:		EQU		22		; Maximum length of filename (including the NULL)

; Global Variables
ORG						RAM_LO
SECTOR_BUFFER:			DEFS	512
HEAP_FREE_CHAIN:		DW	0
HEAP_HI_WATER:			DW 	0
FBFS_CONFIG:			defs FBFS_CONFIG_SIZE, 0
PTR_DIRECTORY:			DW	0
TOTAL_DIR_ENTRIES:		DW	0
MENU_STR_HD1:			defs 32
MENU_STR_FD0:			defs 32
MENU_STR_FD1:			defs 32
MENU_STR_FD2:			defs 32
SCRATCH:				defs 8
if DEBUG
DEBUG_PREV_KEY:			DB	0
DEBUG_SCRATCH:			DEFS	128
else
SAVE_MBEE_SP:			DW	0
SAVE_PCU_SP:			DW	0
SAVE_MBEE_REGS:			DW	0,0,0,0,0,0
SAVE_MBEE_REGS_TOS:
endif
DEBUG_DATA:				defs	32
END_OF_STATIC_DATA:		
SEEK					0

HEAP_BASE_ADDRESS:		EQU END_OF_STATIC_DATA

; Startup setups entry point + NMI vector + yield implementation
include "Startup.asm"

; Debug/release mode
if DEBUG
	include "Debug.asm"
else
	include "Release.asm"
endif

; Library
include "Utils.asm"
include "ScanCodeTable.asm"
include "ListBox.asm"
include "Heap.asm"
include "ChooseFile.asm"


MSG:
	db		"FPGABee v2.0.1"
MSG_LEN:	EQU $-MSG

; Disk type constants
DISK_DS40: EQU 0
DISK_SS80: EQU 1
DISK_DS80: EQU 2
DISK_DS82: EQU 3
DISK_DS84: EQU 4
DISK_DS8B: EQU 5
DISK_HD0:  EQU 6
DISK_HD1:  EQU 7
DISK_NONE: EQU 8

MAIN_MENU:
	dw	MENU_STR_HD1
	dw	MENU_STR_FD0
	dw	MENU_STR_FD1
	dw	STR_SEP
	dw	STR_RESET
	dw	0

STR_DISK_EXTENSIONS:
	db "ds40",0
	db "ss80",0
	db "ds80",0
	db "ds82",0
	db "ds84",0
	db "ds8B",0
	db "hd0",0,0		; Pad to 5 chars
	db "hd1",0,0

STR_HD1:	db "HD1:",0
STR_FD0:	db "FD0:",0
STR_FD1:	db "FD1:",0
STR_FD2:	db "FD2:",0
STR_SEP:	db "-",0
STR_RESET:	db "Reset",0


; Main entry point
PCU_MAIN:
	; Setup stack
	ld		SP,RAM_HI

if DEBUG
	call	DebugInit
endif

	call	HeapInit

	; Clear screen and draw border
	LD		A,0
	call	CLEAR_COLOR
	call	CLEAR_SCREEN

	; Wait for SD startup
wait_sd_card:
	IN		A,(0xC7)
	AND		0x40
	JR		NZ,wait_sd_card

	; Read the config sector and directory
	call	READ_CONFIG
	call	READ_DIRECTORY
	call	INSERT_DISKS
	call	LOAD_ROMS

	ld		HL,STR_HD1
	ld		DE,MENU_STR_HD1
	ld		BC,(FBFS_CONFIG + FBFS_DI_DISK_1)
	call	SETUP_MENU_SELECTION

	ld		HL,STR_FD0
	ld		DE,MENU_STR_FD0
	ld		BC,(FBFS_CONFIG + FBFS_DI_DISK_3)
	call	SETUP_MENU_SELECTION

	ld		HL,STR_FD1
	ld		DE,MENU_STR_FD1
	ld		BC,(FBFS_CONFIG + FBFS_DI_DISK_4)
	call	SETUP_MENU_SELECTION

	; Clear color
	ld		HL,COLOR_RAM
	ld		BC,0x0720
	ld		A,0xCF
	COLOR_RAM_IN
	call	CLEAR_SCREEN_AREA
	COLOR_RAM_OUT

	ld		HL,VCHAR_RAM
	ld		BC,0x0720
	call	DRAW_BORDER_AT

	; Display a message
	ld		HL,MSG
	ld		DE,0xF000 + (SCREEN_WIDTH-MSG_LEN)/2
	ld		BC,MSG_LEN
	ldir

	; Display the main menu
	ld		HL,MAIN_MENU			; Strings
	push	HL
	ld		HL,0x0021				; Position
	push	HL
	ld		HL,0x051e				; Size
	push	HL
	ld		HL,0					; Selection
	push	HL
	ld		HL,0xB0CF				; Colours
	push	HL
	ld		HL,MAIN_MENU_SELECTED	; Callback
	push	HL
	call	LISTBOX

	; Should never get here
	jr		$

PCU_MAIN_END:

hexdump:
        LD      A,(HL)
        CALL    PRT_HEX_BYTE
        INC     HL
        INC     DE
        DJNZ    hexdump
        RET


MAIN_MENU_SELECTED:
	ld		A,D
	and		80h
	jr		nz,hide_menu
	ld		A,E
	cp		0
	jr		Z,choose_hd1
	cp		1
	jr		Z,choose_fd0
	cp		2
	jr		Z,choose_fd1
	cp		4
	jr		Z,invoke_reset
	or		1
	ret

invoke_reset:
	ld		A,0
	out		(0x81),A
	out		(0xFF),A
	or		1					; shouldn't get to here...
	ret

hide_menu:
	ld		A,0
	out		(0x81),A
	or		1
	ret

choose_hd1:
	ld		HL,(FBFS_CONFIG + FBFS_DI_DISK_1)
	ld		DE,FILTER_HDD_IMAGES
	ld		A,1
	call	CHOOSE_FILE
	ld		HL,MENU_STR_HD1 + 5
	ld		C,1
	jr		insert_disk

choose_fd0:
	ld		HL,(FBFS_CONFIG + FBFS_DI_DISK_3)
	ld		DE,FILTER_FDD_IMAGES
	ld		A,1
	call	CHOOSE_FILE
	ld		HL,MENU_STR_FD0 + 5
	ld		C,3
	jr		insert_disk

choose_fd1:
	ld		HL,(FBFS_CONFIG + FBFS_DI_DISK_4)
	ld		DE,FILTER_FDD_IMAGES
	ld		A,1
	call	CHOOSE_FILE
	ld		HL,MENU_STR_FD1 + 5
	ld		C,4
	jr		insert_disk

insert_disk:
	; DE = -1 if cancelled, -2 if eject, else directory index
	; HL = menu string to be updated
	; C = drive number
	ld		A,D
	and		0x80
	jr		Z,have_new_disk
	ld		A,E
	cp		0xFE
	jr		Z,eject_disk
	or		1
	ret

eject_disk:
	; Reset the menu string
	ld		(HL),'-'
	inc		HL
	ld		(HL),0
	ld		DE,0xFFFF
	jr		apply_new_disk

have_new_disk:
	; Update the menu string
	push	DE
	push	HL
	ex		DE,HL
	add		HL,HL		; * 2
	add		HL,HL		; * 4
	add		HL,HL		; * 8
	add		HL,HL		; * 16
	add		HL,HL		; * 32
	ld		DE,(PTR_DIRECTORY)
	add		HL,DE
	ld		DE,DIR_FILENAME
	add		HL,DE
	pop		DE
	call	STRCPY
	pop		DE

apply_new_disk:
	; DE = directory number
	; C = drive number

	; Update the config record
	push	BC
	ld		HL,FBFS_CONFIG + FBFS_DI_DISK_0
	ld		B,0
	add		HL,BC
	add		HL,BC
	ld		(HL),E
	inc		HL
	ld		(HL),D
	pop		BC

	; Update the disk controller
	ld		A,C			
	call	INSERT_DISK

	; Save the config
	call	WRITE_CONFIG

	or		1
	ret
MAIN_MENU_SELECTED_END:

FILTER_HDD_IMAGES:	db "hd0",0,"hd1",0,0
FILTER_FDD_IMAGES:  db "ds40",0,"ss80",0,"ds80",0,"ds82",0,"ds84",0,"ds8b",0,0

; Read the config record
READ_CONFIG:
	; Read the config sector
	ld		DE,0
	ld		BC,0
	ld		HL,SECTOR_BUFFER
	call	DISK_READ
	ld		HL,SECTOR_BUFFER
	ld		DE,FBFS_CONFIG
	ld		BC,FBFS_CONFIG_SIZE
	ldir
	ret
READ_CONFIG_END:

; Write the config record
WRITE_CONFIG:
	ld		HL,FBFS_CONFIG
	ld		DE,SECTOR_BUFFER
	ld		BC,FBFS_CONFIG_SIZE
	ldir
	ld		DE,0
	ld		BC,0
	ld		HL,SECTOR_BUFFER
	call	DISK_WRITE
	ret
WRITE_CONFIG_END:

; Allocate a block of memory, store it at (PTR_DIRECTORY) and read all
; the directory clusters in.
READ_DIRECTORY:
	; Work out total directory size (DIRCOUNT * 512)
	ld		A,(FBFS_CONFIG + FBFS_DIRCOUNT)
	sla		A
	ld		B,A
	ld		C,0

	; Allocate memory
	call 	HeapAlloc
	ld		(PTR_DIRECTORY),HL

	; Get the first block number (32 bit argh!)
	ld		BC,(FBFS_CONFIG + FBFS_DIRBLK)
	ld		DE,(FBFS_CONFIG + FBFS_DIRBLK + 2)

	ld		A,(FBFS_CONFIG + FBFS_DIRCOUNT)

dir_load_loop:
	push	AF
	; Save block number
	push	BC
	push	DE

	; Read a block
	call	DISK_READ

	; Restore block number
	pop		DE
	pop		BC

	; Increment block number
	push	HL
	ld		HL,1
	add		HL,BC
	push	HL
	pop		BC
	ld		HL,0
	adc		HL,DE
	ex		DE,HL
	pop		HL

	; Loop counter
	pop		AF
	sub		1
	jr		nz,dir_load_loop

	; Now work out how many directory entries were actually used
	ld		IX,(PTR_DIRECTORY)
	ld		BC,0
	ld		DE,DIR_SIZE
dir_load_count_loop:
	ld		A,(IX+0)
	or		(IX+1)
	or		(IX+2)
	or		(IX+3)
	jr		z,dir_end_found
	add		IX,DE
	inc		BC
	jr		dir_load_count_loop

dir_end_found:
	ld		(TOTAL_DIR_ENTRIES),BC
	ret

READ_DIRECTORY_END:

SETUP_MENU_SELECTION:

	; Copy the menu item name
	call 	STRCPY

	; Overwrite the NULL terminator
	ex		DE,HL
	dec		HL
	ld		(HL),' '
	inc		HL

	; Is a file selected?
	ld		A,B
	and		0x80
	jr		z,sms_setup_filename

	; No, n/a
	ld		(HL),'-'
	inc		HL
	ld		(HL),0
	ret

sms_setup_filename:
	ex		DE,HL
	push	BC
	pop		HL
	add		HL,HL		; * 2
	add		HL,HL		; * 4
	add		HL,HL		; * 8
	add		HL,HL		; * 16
	add		HL,HL		; * 32
	ld		BC,DIR_FILENAME
	add		HL,BC		; Pointer to file name
	ld		BC,(PTR_DIRECTORY)
	add		HL,BC
	call	STRCPY

	ret
SETUP_MENU_SELECTION_END:

; DE = directory index
; A = drive number (0-6)
INSERT_DISK:

	; Save registers
	push	HL
	push	BC

	; Save drive number 
	push	AF

	; Check for "eject" (DE==-1)
	ld		A,D
	and		80h
	jr		z,id_has_disk

	; Clear the block number
	ld		A,0
	out		(0xc1),A
	out		(0xc1),A
	out		(0xc1),A
	out		(0xc1),A

	; No disk
	ld		A,DISK_NONE
	jr		id_have_disk_type

id_has_disk:
	ex		DE,HL
	add		HL,HL		; *2
	add		HL,HL		; *4
	add		HL,HL		; *8
	add		HL,HL		; *16
	add		HL,HL		; *32
	ld		DE,(PTR_DIRECTORY)
	add		HL,DE

	; Write the base block number
	push	HL
	ld		BC,0x04c1
	otir
	pop		HL

	; Work out the disk type from the file's extension
	ld		DE,DIR_FILENAME
	add		HL,DE
	call	IMAGE_TYPE_FROM_EXTENSION


id_have_disk_type:
	sla		A
	sla		A
	sla		A
	ld		B,A

	; Get drive number back
	pop		AF

	; Adjust floppy drive number to match what disk controller expects
	cp		3
	jr		C,id_no_inc
	inc		A
id_no_inc:

	; Compose the final command and send it
	or		80h			; Command
	or		B			; Disk type
	out		(0xC7),A	; Invoke the command

	; Restore registers
	pop		BC
	pop		HL
	ret

INSERT_DISK_END:

INSERT_DISKS:

	ld		HL,FBFS_CONFIG + FBFS_DI_DISK_0
	ld		B,7

id_loop:
	; Get the directory entry
	ld		E,(HL)
	inc		HL
	ld		D,(HL)
	inc		HL

	; Calculate drive number
	ld		A,7
	sub		B

	; Insert it
	call	INSERT_DISK

	djnz	id_loop

	ret

INSERT_DISKS_END:

; DE = directory index
; A = ROM Pack number
LOAD_ROM:

	; Map in Microbee's ROM pack RAM
	or		0x80
	out		(0xD0),A

	; Clear old ROM data
	push	DE
	ld		HL,ROM_PACK_LOAD_ADDR
	ld		DE,ROM_PACK_LOAD_ADDR+1
	ld		BC,0x3fff
	ld		(HL),0
	ldir
	pop		DE

	; Check for "no rom"
	ld		A,D
	and		80h
	jr		NZ,lr_exit

	; Find the directory entry
	ex		DE,HL
	add		HL,HL		; * 2
	add		HL,HL		; * 4
	add		HL,HL		; * 8
	add		HL,HL		; * 16
	add		HL,HL		; * 32
	ld		DE,(PTR_DIRECTORY)
	add		HL,DE

	; HL is pointer to directory entry for the ROM, read the block number

	; Copy the block number to scratch
	ld		DE,SCRATCH
	ld		BC,4
	ldir

	; Load the number of blocks and limit to 32
	ld		A,(HL);
	dec		A
	and		0x1f
	inc		A
	ld		B,A

	ld		HL,ROM_PACK_LOAD_ADDR

lr_read_loop:
	push	BC

	; Read the block
	ld		BC,(SCRATCH)
	ld		DE,(SCRATCH+2)
	call	DISK_READ

	; Increment the block number
	ex		DE,HL
	ld		HL,(SCRATCH)
	ld		BC,1
	add		HL,BC
	ld		(SCRATCH),HL
	ld		HL,(SCRATCH+2)
	ld		BC,0
	adc		HL,BC
	ld		(SCRATCH+2),HL
	ex		DE,HL

	; Loop
	pop		BC
	djnz	lr_read_loop

lr_exit:
	; Unmap ROM pack RAM
	xor		A
	out		(0xD0),A

	ret
lr_has_rom:

LOAD_ROM_END:

	
LOAD_ROMS:

	ld		HL,FBFS_CONFIG + FBFS_DI_ROM_0
	ld		B,3

lrs_loop:
	ld		E,(HL)
	inc		HL
	ld		D,(HL)
	inc		HL

	ld		A,3
	sub		B

	push	BC
	push	HL
	call	LOAD_ROM
	pop		HL
	pop		BC

	djnz	lrs_loop

	ret
LOAD_ROMS_END:

; Work out the image type of a file by looking at it's extension
; HL should point to the file name
IMAGE_TYPE_FROM_EXTENSION:
	
	call	FIND_EXTENSION
	ld		A,H
	or		L
	jr		nz,itfe_has_extension
	ld		A,DISK_NONE
	ret
itfe_has_extension:

	inc		HL
	ld		B,8
	ld		DE,STR_DISK_EXTENSIONS
	ex		DE,HL
itfe_loop:
	push	HL
	push	DE
	call	STRICMP
	pop		DE
	pop		HL
	jr		z,itfe_found
	push	BC
	ld		BC,5
	add		HL,BC
	pop		BC	
	djnz	itfe_loop
itfe_found:
	ld		A,DISK_NONE
	sub		B
	ret

IMAGE_TYPE_FROM_EXTENSION_END:

