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
	RET	Z
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
.endblock
