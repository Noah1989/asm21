entrypoint editor_redraw
.block
	CALL	gui_editor_top
	JP	print_source
.endblock

entrypoint editor_down
.block
	LD	HL, (active_line_pointer)
loop:
	INC	HL
	LD	A, (HL)
	CP	inlines
	JR	NC, loop
	CP	end_
	RET	Z
	LD	(active_line_pointer), HL
	JR	print_source
.endblock

entrypoint editor_up
.block
	LD	HL, (active_line_pointer)
	LD	DE, source_buffer
	AND	A ; clear carry
	SBC	HL, DE
	RET	Z
	ADD	HL, DE
loop:
	DEC	HL
	LD	A, (HL)
	CP	inlines
	JR	NC, loop
	LD	(active_line_pointer), HL
	JR	print_source
.endblock

entrypoint print_source
.block
	LD	D, 2
	LD	HL, (listing_top_pointer)
next_line:
	PUSH	DE
	PUSH	HL
	LD	DE, colors_editor
	LD	(code_colors_pointer), DE
	LD	DE, (active_line_pointer)
	AND	A; clear carry
	SBC	HL, DE
	JR	NZ, not_active
	LD	HL, colors_editor_active
	LD	(code_colors_pointer), HL
not_active:
	POP	HL
	POP	DE
	XOR	A
	OUT	gaddr_l, A
	LD	A, D
	OUT	gaddr_h, A
	LD	A, color_editor_left
	OUT	color_io, A
	LD	A, $B3
	OUT	chars_io, A
	LD	A, (HL)
	CP	end_
	PUSH	DE
	JR	Z, skip
	CALL	print_source_HL_return_count_C_trash_A_B_DE
skip:
	CALL	fill_right_78_txtlen_C_trash_A_BC_DE
	POP	DE
	;	scrollbar
	PUSH	HL
	LD	HL, chars_scrollbar
	LD	A, D
	CP	2
	JR	Z, scrollbar_ok
	INC	HL
	CP	28
	JR	Z, scrollbar_ok
	INC	HL
scrollbar_ok:
	LD	A, color_editor_scrollbar
	OUT	(color_io), A
	LD	A, (HL)
	OUT	(chars_io), A
	POP	HL

	INC	D
	LD	A, D
	CP	29
	JR	C, next_line
	RET
.endblock
