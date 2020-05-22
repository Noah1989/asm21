color_io  equ $B9 ; GPU color table
chars_io  equ $BC ; GPU name table with auto increment
color_inc equ $BD ; GPU color table with auto increment

; Finds and prints the name of the bytecode token in A.
; Returns number of characters printed in C
;         parameter count in B
;         pointer to parameter list in HL
; Trashes DE
entrypoint print_name_A_ret_len_C_params_B_HL_trash_DE
.block
	CALL	find_descr_A_ret_name_C_DE_params_B_HL
@print_descr_A_name_C_DE_trash_DE:
	PUSH	BC
	EX	DE, HL ; result: HL *name, DE *params
	LD	B, C ; name length
	LD	C, chars_io
loop:
	CALL	print_color_A
	OUTI	; (C) <= (HL); DEC B; INC HL
	JR	NZ, loop
	EX	DE, HL ; result: HL *params, DE trash
	POP	BC
	RET
.endblock

; Finds and prints the name of the bytecode in A
; followed by the names of its parameters.
; Name and parameters are separated by a space
; Parameter names are separated from each other by comma and space
; Returns number of characters printed in C
;         B set to zero
; Trashes DE and HL
; Saves   AF
entrypoint print_name_and_params_A_ret_len_C_trash_DE_HL_zero_B
.block
	PUSH	AF
	CALL	print_name_A_ret_len_C_params_B_HL_trash_DE
	;	check if no params
	XOR	A
	OR	B
	JR	Z, done
	;	separator
	LD	DE, (code_colors_pointer)
	LD	A, (DE)
	OUT	(color_io), A
	LD	A, " "
	OUT	(chars_io), A
	INC	C
	JR	first
loop:
	;	print comma and space
	LD	DE, (code_colors_pointer)
	LD	A, (DE)
	OUT	(color_io), A
	LD	A, ","
	OUT	(chars_io), A
	INC	C
	LD	A, (DE)
	OUT	(color_io), A
	LD	A, " "
	OUT	(chars_io), A
	INC	C
first:
	;	print parameter name
	LD	A, (HL)
	PUSH	HL
	PUSH	BC
	CALL	print_name_A_ret_len_C_params_B_HL_trash_DE
	;	tally the number of characters printed
	LD	A, C
	POP	BC
	ADD	A, C
	LD	C, A
	;	next param
	POP	HL
	INC	HL
	DJNZ	loop
done:
	POP	AF
	RET
.endblock

; Prints a piece of source from the address pointed to by HL.
; HL will be moved forward for every token consumed.
entrypoint print_source_HL_return_count_C_trash_A_B_DE
.block
retry:
	LD	A, (HL)
	INC	HL
	OR	A
	JR	Z, retry
	CP	alignment
	JR	nz, noalign
align:
	LD	A, (HL)
	INC	HL
	SUB	dat_0
	PUSH	AF
	LD	B, A
align_loop:
	LD	DE, (code_colors_pointer)
	LD	A, (DE)
	OUT	color_io, A
	LD	A, ' '
	OUT	chars_io, A
	DJNZ	align_loop
	CALL	print_source_HL_return_count_C_trash_A_B_DE
	POP	AF
	ADD	A, C
	LD	C, A
	RET
noalign:
	PUSH	HL
	CALL	print_name_A_ret_len_C_params_B_HL_trash_DE
	POP	DE ; source pointer
	EX	DE, HL ; result: DE = *params, HL = *source
	;	check if no params
	INC	B
	DJNZ	hasparams
	RET
hasparams:
	CP	nospace
	JR	NC, first
	;	separator
	PUSH	DE
	LD	DE, (code_colors_pointer)
	LD	A, (DE)
	POP	DE
	OUT	(color_io), A
	LD	A, " "
	OUT	(chars_io), A
	INC	C
	JR	first
loop:
	;	print comma and space
	PUSH	DE
	LD	DE, (code_colors_pointer)
	LD	A, (DE)
	OUT	(color_io), A
	LD	A, ","
	OUT	(chars_io), A
	INC	C
	LD	A, (DE)
	POP	DE
	OUT	(color_io), A
	LD	A, " "
	OUT	(chars_io), A
	INC	C
first:
	;	process parameter
	LD	A, (DE)
	PUSH	DE
	PUSH	BC
switch:
	CP	placeholders
	JR	NC, switch_1
	;	not placeholder, just print the name
	PUSH	HL
	;	check if the name itself has a parameter (such as "IX+d")
	CALL	find_descr_A_ret_name_C_DE_params_B_HL
	DJNZ	name_has_no_param
name_has_param:
	DEC	C ; remove ")"
	LD	B, A ; original bytecode token
	;	get the parameter itself
	LD	A, (HL)
	PUSH	BC
	PUSH	DE
	CALL	find_descr_A_ret_name_C_DE_params_B_HL
	LD	A, C
	POP	DE
	POP	BC
	NEG	; subtract param name length, "(ix+d" -> "(ix+"
	ADD	A, C
	LD	C, A
	LD	A, B ; restore original bytecode token
	CALL	print_descr_A_name_C_DE_trash_DE
	POP	HL
	PUSH	AF
	PUSH	BC
	CALL	print_source_HL_return_count_C_trash_A_B_DE
	POP	DE
	LD	A, C
	ADD	A, E
	LD	C, A
	POP	AF
	CALL	print_color_A
	LD	A, ")"
	OUT	(chars_io), A
	INC	C
	JR	switch_break
name_has_no_param:
	CALL	print_descr_A_name_C_DE_trash_DE
	POP	HL
	JR	switch_break
switch_1:
	;	handle placeholers that use multiple data bytes
	LD	DE, switch_break
	PUSH	DE ; return address
	CP	text
	JP	Z, print_text_HL_return_len_C_trash_A_B_DE
	CP	digits
	JP	Z, print_digits_HL_return_len_C_trash_A_DE
	;	generic placeholder, print single token from source
	JP	print_source_HL_return_count_C_trash_A_B_DE
switch_break:
	;	tally the number of characters printed
	LD	A, C
	POP	BC
	ADD	A, C
	LD	C, A
	;	next param
	POP	DE
	INC	DE
	DJNZ	loop
done:
	RET
.endblock

entrypoint print_text_HL_return_len_C_trash_A_B_DE
.block
	LD	C, 0
	LD	DE, (code_colors_pointer)
	INC	DE
loop:
	LD	A, (DE)
	OUT	(color_io), A
	LD	A, (HL)
	SUB	dat_0
	RET	C
	INC	HL
	RLCA
	RLCA
	RLCA
	RLCA
	LD	B, A
	LD	A, (HL)
	SUB	dat_0
	JR	C, halfbyte
	INC	HL
	ADD	A, B
	OUT	(chars_io), A
	INC	C
	JR	loop
halfbyte:
	DEC	HL
	RET
.endblock

entrypoint print_digits_HL_return_len_C_trash_A_DE
.block
	LD	C, 0
	LD	DE, (code_colors_pointer)
	INC	DE
	INC	DE
loop:
	LD	A, (DE)
	OUT	(color_io), A
	LD	A, (HL)
	CP	terminator
	JR	Z, terminated
	SUB	dat_0
	RET	C
	INC	HL
	ADD	A, $90
	DAA
	ADC	A, $40
	DAA
	OUT	(chars_io), A
	INC	C
	JR	loop
terminated:
	INC	HL
	RET
.endblock

; Sets the color of the next character to be printed according to the
; type of the bytecode token in A
entrypoint print_color_A
.block
	PUSH	AF
	PUSH	DE
	PUSH	HL
	LD	HL, table
	LD	DE, (code_colors_pointer)
	INC	DE
loop:
	INC	DE
	CP	(HL)
	INC	HL
	JR	C, loop
	LD	A, (DE)
	OUT	(color_io), A
	POP	HL
	POP	DE
	POP	AF
	RET
table:
.db	dat_nibbles
.db	expression_primitives
.db	flags
.db	regs_8
.db	pseudo_instructions
.db	0
.endblock

entrypoint print_pstr_HL_trash_A
.block
	PUSH	BC
	LD	B, (HL)
	INC	HL
next_char:
	LD	A, $1A
	OUT	(color_io),A
	LD	A, (HL)
	INC	HL
	OUT	(chars_io), A
	DJNZ	next_char
	POP	BC
	RET
.endblock

entrypoint fill_right_78_txtlen_C_trash_A_BC_DE
.block
	LD	A, 78
	SUB	C
	LD	C, B
	LD	B, A
	LD	DE, (code_colors_pointer)
loop:
	LD	A, (DE)
	OUT	(color_io), A
	LD	A, " "
	OUT	(chars_io), A
	DJNZ	loop
	LD	B, C
	RET
.endblock
