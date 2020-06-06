entrypoint print_groups
.block
	LD	E, 2
	LD	B, 26
	LD	HL, group_names
	LD	A, (colors_editor+7)
	LD	C, A
next_line:
	XOR	A
	OUT	gaddr_l, A
	LD	A, E
	OUT	gaddr_h, A
	LD	A, color_editor_left
	OUT	color_io, A
	LD	A, $B3
	OUT	(chars_io), A
	LD	B, 80-editor_width-3
	LD	A, (HL)
	AND	A
	JR	Z, emptyline
	CP	9
	JR	Z, hint
	LD	A, color_tool_key
	OUT	color_io, A
	LD	A, E
	ADD	A, "A"-2
	OUT	chars_io, A
	DEC	B
	LD	A, color_tool_text
	OUT	color_io, A
	LD	A, "-"
	OUT	chars_io, A
	DEC	B
	JR	nohint
hint:
	INC	HL
	LD	D, 34-editor_width/2
hint_loop:
	LD	A, C
	OUT	color_io, A
	LD	A, " "
	OUT	chars_io, A
	DEC	B
	DEC	D
	JR	NZ, hint_loop
	LD	D, color_tool_hint_highlight
nohint:
	CALL	gui_print_highlight_str_iHL_maxlen_B_colors_C_D
	INC	HL
emptyline:
	LD	A, C
	OUT	color_io, A
	LD	A, " "
	OUT	chars_io, A
	DJNZ	emptyline
	INC	E
	LD	A, E
	CP	19
	JR	NZ, skip
	LD	C, color_tool_hint
	LD	HL, tool_hint_select
skip:
	CP	29
	JR	C, next_line
	RET
.endblock

entrypoint group_select
.block
	; A: keycode, C: Letter (0=ESC)
	LD	E, A
	LD	A, C
	AND	A
	RET	Z
	CP	14
	RET	NC
	INC	A
	OUT	gaddr_h, A
	LD	A, 1
	OUT	gaddr_l, A
	LD	A, color_tool_key_active
	OUT	color_inc, A
	AND	$F0
	LD	D, A
	LD	B, 80-editor_width-4
loop1:
	IN	A, color_io
	AND	$0F
	OR	D
	OUT	color_inc, A
	DJNZ	loop1
wait:
	CALL	ROM_GET_KEY
	JR	NZ, wait ; waiting for keyup
	CP	E
	JR	NZ, wait
	LD	HL, group_table
	LD	B, 0
	ADD	HL, BC
	LD	A, (HL)
	LD	(instruction_select_end), A
	DEC	HL
	LD	A, (HL)
	LD	(instruction_select_begin), A
	LD	D, A
	LD	HL, instruction_select
	LD	(input_az_pointer), HL
	LD	E, 2
next_line:
	LD	A, E
	CP	29
	RET	NC
	PUSH	DE
	OUT	gaddr_h, A
	LD	A, 1
	OUT	gaddr_l, A
	LD	A, E
	CP	26
	JR	Z, hint
	LD	C, 0
	LD	A, D
	LD	HL, instruction_select_end
	CP	(HL)
	LD	A, 80-editor_width-3
	JR	NC, emptyline
	LD	A, color_tool_key
	OUT	color_io, A
	LD	A, 'A'-2
	ADD	A, E
	OUT	chars_io, A
	LD	A, color_tool_text
	OUT	color_io, A
	LD	A, '-'
	OUT	chars_io, A
	LD	A, D
	CALL	print_name_and_params_A_ret_len_C_trash_DE_HL_zero_B
	LD	A, 80-editor_width-5
emptyline:
	CALL	fill_right_width_A_txtlen_C_trash_A_BC_DE
resume:
	POP	DE
	INC	E
	INC	D
	JR next_line
hint:
	LD	C, color_tool_hint
	LD	D, color_tool_hint_highlight
	LD	B, 80-editor_width-3
	LD	HL, tool_hint_back
	CALL	gui_print_highlight_str_iHL_maxlen_B_colors_C_D
hint_fill2:
	LD	A, C
	OUT	color_io, A
	LD	A, " "
	OUT	chars_io, A
	DJNZ	hint_fill2
	JR	resume
.endblock


entrypoint instruction_select
.block
	; A: keycode, C: Letter (0=ESC)
	CP	$76
	JR	Z, back
	RET
back:
	LD	HL, group_select
	LD	(input_az_pointer), HL
	JP	print_groups
.endblock


group_table:
	.db instr_ld8
	.db instr_ld16
	.db instr_arith8
	.db instr_arith16
	.db instr_decinc
	.db instr_logic
	.db instr_bits
	.db instr_rotate
	.db instr_shift
	.db instr_jump
	.db instr_block
	.db instr_io
group_table_end:
	.db instr_misc
	.db pseudo_instructions

group_names:
	.db "8-bit data move", 0
	.db "16-bit data move", 0
	.db "8-bit arithmetic", 0
	.db "16-bit arithmetic", 0
	.db "decrement/increment", 0
	.db "logic", 0
	.db "single bit operation", 0
	.db "bit rotation", 0
	.db "bit shift", 0
	.db "jump", 0
	.db "block operations", 0
	.db "input/output", 0
	.db "other", 0
	.db 0
group_count equ group_table_end-group_table+1
