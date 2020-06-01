input_main:
.db	$01 ; F9
.dw	menu_activate
.db	$09 ; F10
.dw	quit
.db	$72 ; down arrow
.dw	editor_down;
.db	$75 ; up arrow
.dw	editor_up;
.db	$7A ; page down
.dw	editor_down_page;
.db	$7D ; page up
.dw	editor_up_page;
.db	$71 ; delete
.dw	editor_delete_after
.db	$66 ; backspace
.dw	editor_delete_before
.db	$5A ; enter
.dw	editor_insert_after
.db	$70 ; insert
.dw	editor_insert_before
.db	0

input_menu:
.db	$76 ; ESC
.dw	menu_abort
.db	$01 ; F9
.dw	menu_abort
.db	$09 ; F10
.dw	menu_abort
.db	$74 ; right arrow
.dw	menu_right
.db	$6B ; left arrow
.dw	menu_left;
.db	$72 ; down arrow
.dw	menu_down;
.db	$75 ; up arrow
.dw	menu_up;
.db	0

entrypoint input_handler
.block
	CALL	ROM_GET_KEY
	RET	Z
	LD	C, A
	LD	HL, (input_table_pointer)
loop:
	LD	A, (HL)
	INC	HL
	AND	A
	JR	Z, notfound
	CP	C
	JR	Z, found
	INC	HL
	INC	HL
	JR	loop
found:
	LD	E, (HL)
	INC	HL
	LD	D, (HL)
	EX	DE, HL
	JP	(HL)
notfound:
	LD	A, C
	LD	BC, 27
	LD	HL, input_az_end
	CPDR
	RET	NZ
	LD	HL, (input_az_pointer)
	JP	(HL)
.endblock

input_az:
.db	$76 ; ESC
.db	$1C ; A
.db	$32 ; B
.db	$21 ; C
.db	$23 ; D
.db	$24 ; E
.db	$2B ; F
.db	$34 ; G
.db	$33 ; H
.db	$43 ; I
.db	$3B ; J
.db	$42 ; K
.db	$4B ; L
.db	$3A ; M
.db	$31 ; N
.db	$44 ; O
.db	$4D ; P
.db	$15 ; Q
.db	$2D ; R
.db	$1B ; S
.db	$2C ; T
.db	$3C ; U
.db	$2A ; V
.db	$1D ; W
.db	$22 ; X
.db	$35 ; Y
input_az_end:
.db	$1A ; Z
