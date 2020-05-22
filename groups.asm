entrypoint menu_groups
.block
	LD E, 7
	LD D, 2
	LD B, 26
	LD HL, group_names
next_line:
	LD A, E
	OUT gaddr_l, A
	LD A, D
	OUT gaddr_h, A
	LD C, (HL)
	XOR A
	CP C
	JR Z, emptyline
	CALL print_pstr_HL_trash_A
emptyline:
	;CALL fill_right_30_txtlen_C_trash_A_C
	INC D
	DJNZ next_line
	RET
.endblock

entrypoint list_instr_B_to_C
.block
	LD E, 7
	LD D, 2
next_line:
	LD A, D
	CP 2 + 26
	RET Z
	OUT gaddr_h, A
	LD A, E
	OUT gaddr_l, A
	LD A, B
	CP C
	PUSH BC
	PUSH DE
	LD C, 0
	CALL C, print_name_and_params_A_ret_len_C_trash_DE_HL_zero_B
	;CALL fill_right_30_txtlen_C_trash_A_C
	POP DE
	POP BC
	INC B
	INC D
	JR next_line
	RET
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
.if msb(group_table) != msb(group_table_end)
.error "group_table must not cross 256-byte boudary"
.endif
group_names:
	.pstr "8-bit data move"
	.pstr "16-bit data move"
	.pstr "8-bit arithmetic"
	.pstr "16-bit arithmetic"
	.pstr "decrement/increment"
	.pstr "logic"
	.pstr "single bit operation"
	.pstr "bit rotation"
	.pstr "bit shift"
	.pstr "jump"
	.pstr "block operations"
	.pstr "input/output"
	.pstr "other"
	.db 0
group_count equ group_table_end-group_table+1
