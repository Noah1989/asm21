global_hints:
.db	" &F&9-Menu  &F&1&0-Quit ", 0
menu_hints:
.db	" Use &A&R&R&O&W &K&E&Y&S to move,"
.db	" &E&N&T&E&R to select,"
.db	" &E&S&C to abort ", 0

program_name:
.db	" ASM&2&1 ", 0

editor_title:
.db	8, "Assembly", 0
tool_title_select:
.db	5, "Input", 0

entrypoint gui_menubar
.block
	XOR	A
	LD	E, A
	OUT	gaddr_l, A
	OUT	gaddr_h, A
	LD	B, 80
	LD	HL, main_menu
loop:
	LD	C, color_menubar
	LD	D, color_menubar_highlight
	LD	A, (active_menu_entry)
	CP	E
	JR	NZ, skip
	LD	C, color_menubar_active
	LD	D, color_menubar_active_hi
skip:
	INC	E
	CALL	gui_print_highlight_str_iHL_maxlen_B_colors_C_D
	INC	HL
	INC	HL
	INC	HL
	LD	A, (HL)
	AND	A
	JR	NZ, loop
	LD	C, color_menubar
	JP	gui_fill_space_len_B_color_C
.endblock

entrypoint gui_menu_dropdown
.block
	LD	DE, 0
	LD	HL, main_menu
loop:
	;	find position
	XOR	A
	LD	BC, $100
	CPIR
	LD	A, (active_menu_entry)
	CP	D
	JR	Z, found
	INC	D
	LD	A, -2
	ADD	A, E
	SUB	C
	LD	E, A
	INC	HL
	INC	HL
	JR	loop
found:
	LD	C, E ; left
	LD	E, (HL)
	INC	HL
	LD	D, (HL)
	EX	DE, HL ; submenu strings
	LD	D, (HL) ; width
	INC	HL
	LD	E, 1 ; top
	;	top
	LD	A, E
	OUT	gaddr_h, A
	LD	A, C
	OUT	gaddr_l, A
	PUSH	BC
	PUSH	HL
	LD	C, color_menu_dropdown
	LD	B, D
	LD	HL, chars_menu_dropdown_top
	INC	B
	INC	B
	CALL	gui_line_color_C_chars_iHL_len_B
	POP	HL
	POP	BC
loop2:
	;	body
	INC	E
	LD	A, E
	OUT	gaddr_h, A
	LD	A, C
	OUT	gaddr_l, A
	LD	A, color_menu_dropdown
	OUT	color_io, A
	LD	A, (chars_menu_dropdown_frame)
	OUT	chars_io, A
	LD	B, D
	PUSH	BC
	LD	C, color_menu_dropdown
	LD	D, color_menu_dropdown_hi
	LD	A, (active_submenu_entry)
	ADD	A, 2
	CP	E
	JR	NZ, skip
	LD	C, color_menu_dropdown_active
	LD	D, color_menu_dropdown_act_hi
skip:
	CALL	gui_print_highlight_str_iHL_maxlen_B_colors_C_D
	CALL	gui_fill_space_len_B_color_C
	POP	BC
	LD	D, B
	LD	A, color_menu_dropdown
	OUT	color_io, A
	LD	A, (chars_menu_dropdown_frame+2)
	OUT	chars_io, A
	LD	A, color_menu_dropdown_shadow
	OUT	color_inc, A
	OUT	color_inc, A
	INC	HL
	XOR	A
	CP	(HL)
	JR	NZ, loop2
	;	bottom
	INC	E
	LD	A, E
	OUT	gaddr_h, A
	LD	A, C
	OUT	gaddr_l, A
	PUSH	BC
	LD	C, color_menu_dropdown
	LD	B, D
	LD	HL, chars_menu_dropdown_bottom
	INC	B
	INC	B
	CALL	gui_line_color_C_chars_iHL_len_B
	POP	BC
	LD	A, color_menu_dropdown_shadow
	OUT	color_inc, A
	OUT	color_inc, A
	INC	E
	INC	C
	INC	C
	INC	D
	INC	D
	LD	A, E
	OUT	gaddr_h, A
	LD	A, C
	OUT	gaddr_l, A
	LD	B, D
	LD	A, color_menu_dropdown_shadow
loop3:
	OUT	color_inc, A
	DJNZ	loop3
	LD	A, E
	SUB	3
	LD	(submenu_count), A
	RET
.endblock

entrypoint gui_topbar_width_A_title_iHL_style_iDE
.block
	SUB	(HL)
	SRL	A
	PUSH	AF
	ADC	A, 0
	LD	B, A
	EX	DE, HL
	LD	C, color_editor_top
	CALL	gui_line_color_C_chars_iHL_len_B
	EX	DE, HL
	LD	C, color_editor_title
	LD	B, (HL)
	INC	HL
	CALL	gui_print_highlight_str_iHL_maxlen_B_colors_C_D
	POP	AF
	LD	B, A
	EX	DE, HL
	LD	C, color_editor_top
	JP	gui_line_color_C_chars_iHL_len_B
.endblock

entrypoint gui_editor_top
.block
	LD	A, 80-editor_width-2
	OUT	gaddr_l, A
	LD	A, 1
	OUT	gaddr_h, A
	LD	A, editor_width+2
	LD	DE, chars_editor_top
	LD	HL, editor_title
	JP	gui_topbar_width_A_title_iHL_style_iDE
.endblock

entrypoint gui_tools_top
.block
	XOR	A
	OUT	gaddr_l, A
	INC	A
	OUT	gaddr_h, A
	LD	A, 80-editor_width-2
	LD	DE, chars_tools_top
	LD	HL, (tool_title_pointer)
	JP	gui_topbar_width_A_title_iHL_style_iDE
.endblock

entrypoint gui_statusbar
.block
	XOR	A
	OUT	gaddr_l, A
	LD	A, 29
	OUT	gaddr_h, A
	LD	HL, (hint_pointer)
	LD	B, 63
	LD	C, color_statusbar
	LD	D, color_statusbar_highlight
	CALL	gui_print_highlight_str_iHL_maxlen_B_colors_C_D
loop1:
	CALL	gui_fill_space_len_B_color_C
	LD	C, color_statusbar_info
	LD	D, color_statusbar_info2
	LD	A, C
	OUT	color_io, A
	LD	A, $B3
	OUT	chars_io, A
	LD	HL, program_name
	LD	B, 16
	CALL	gui_print_highlight_str_iHL_maxlen_B_colors_C_D
	LD	A, C
loop2:
	OUT	color_inc, A
	DJNZ	loop2
	RET
.endblock

entrypoint gui_fill_space_len_B_color_C
.block
	XOR	A
	CP	B
	RET	Z
loop:
	LD	A, C
	OUT	color_io, A
	LD	A, ' '
	OUT	chars_io, A
	DJNZ	loop
	RET
.endblock

entrypoint gui_line_color_C_chars_iHL_len_B
.block
	LD	A, C
	OUT	color_io, A
	LD	A, (HL)
	OUT	chars_io, A
	INC	HL
	DJNZ	skip
	RET
skip:
	DJNZ	loop
	INC	HL
	JR	end
loop:
	LD	A, C
	OUT	color_io, A
	LD	A, (HL)
	OUT	chars_io, A
	DJNZ	loop
end:
	INC	HL
	LD	A, C
	OUT	color_io, A
	LD	A, (HL)
	OUT	chars_io, A
	RET
.endblock

entrypoint gui_print_highlight_str_iHL_maxlen_B_colors_C_D
.block
loop:
	LD	A, (HL)
	AND	A
	RET	Z
elif:
	CP	'&'
	JR	NZ, else
	LD	A, D
	INC	HL
	JR	endif
else:
	LD	A, C
endif:
	OUT	color_io, A
	LD	A, (HL)
	OUT	chars_io, A
	INC	HL
	DJNZ	loop
	RET
.endblock
