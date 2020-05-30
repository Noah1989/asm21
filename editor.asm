scroll_lines equ 26

entrypoint editor_redraw
.block
	CALL	gui_editor_top
	JP	print_source
.endblock

entrypoint editor_down
.block
	LD	B, 1
	JR	go
@editor_down_page:
	LD	B, scroll_lines
go:
	LD	HL, (active_line_pointer)
loop:
	INC	HL
	LD	A, (HL)
	AND	A
	JR	Z, loop
	CP	inlines
	JR	NC, loop
	CP	end_
	JR	Z, end
	LD	(active_line_pointer), HL
	LD	DE, (line_active)
	INC	DE
	LD	(line_active), DE
	LD	DE, (listing_bottom_pointer)
	AND	A
	SBC	HL, DE
	JR	C, end
	;	scroll down
	LD	HL, (listing_top_pointer)
loop2:
	INC	HL
	LD	A, (HL)
	AND	A
	JR	Z, loop2
	CP	inlines
	JR	NC, loop2
	LD	(listing_top_pointer), HL
	LD	DE, (line_listing_top)
	INC	DE
	LD	(line_listing_top), DE
end:
	DJNZ	go
	CALL	calc_scrollbar
	JR	print_source
.endblock

entrypoint editor_up
.block
	LD	B, 1
	JR	go
@editor_up_page:
	LD	B, scroll_lines
go:
	LD	HL, (active_line_pointer)
	LD	DE, source_buffer
	AND	A ; clear carry
	SBC	HL, DE
	JR	Z, end
	ADD	HL, DE
loop:
	DEC	HL
	LD	A, (HL)
	AND	A
	JR	Z, loop
	CP	inlines
	JR	NC, loop
	LD	(active_line_pointer), HL
	LD	DE, (line_active)
	DEC	DE
	LD	(line_active), DE
	LD	DE, (listing_top_pointer)
	AND	A
	SBC	HL, DE
	JR	NC, end
	;	scroll up
	LD	HL, (listing_top_pointer)
loop2:
	DEC	HL
	LD	A, (HL)
	AND	A
	JR	Z, loop2
	CP	inlines
	JR	NC, loop2
	LD	(listing_top_pointer), HL
	LD	DE, (line_listing_top)
	DEC	DE
	LD	(line_listing_top), DE
end:
	DJNZ	go
	CALL	calc_scrollbar
	JR	print_source
.endblock

entrypoint editor_delete_after
.block
	LD	HL, (active_line_pointer)
	LD	B, 0
loop:
	LD	(HL), B
loop2:
	INC	HL
	LD	A, (HL)
	AND	A
	JR	Z, loop2
	CP	inlines
	JR	NC, loop
	LD	(active_line_pointer), HL
	JR	print_source
.endblock

entrypoint editor_delete_before
.block
	LD	HL, (active_line_pointer)
	LD	B, 0
loop:
	DEC	HL
	LD	A, (HL)
	AND	A
	JR	Z, loop
	LD	(HL), B
	CP	inlines
	JR	NC, loop
	JR	print_source
.endblock

entrypoint print_source
.block
	LD	D, 2
	LD	HL, (listing_top_pointer)
	DEC	HL
retry:
	INC	HL
next_line:
	LD	A, (HL)
	AND	A
	JR	Z, retry
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
	LD	A, (scrollbar_top)
	DEC	A
	CP	D
	JR	NC, scrollbar_ok
	INC	HL
	LD	A, (scrollbar_bottom)
	CP	D
	JR	NC, scrollbar_ok
	DEC	HL
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
	LD	(listing_bottom_pointer), HL
	RET
.endblock

entrypoint calc_scrollbar
.block
	LD	A, (line_count+1)
	AND	A
	JR	NZ, go
	LD	A, (line_count)
	CP	27
	JR	NC, go
	;	no scrolling
	XOR	A
	LD	(scrollbar_top), A
	LD	(scrollbar_bottom), A
	RET
go:
	LD	DE, (line_listing_top)
	CALL	calc
	ADD	A, 3
	LD	(scrollbar_top), A
	LD	HL, (line_count)
	LD	DE, -27
	ADD	HL, DE
	EX	DE, HL
	CALL	calc
	SUB	24
	NEG
	LD	HL, scrollbar_top
	ADD	A, (HL)
	LD	(scrollbar_bottom), A
	RET
calc:
	LD	A, 24
	CALL	mult_A_DE_result_AHL_trash_BC
	LD	C, L
	LD	B, H
	LD	DE, (line_count)
	DEC	DE
	CALL	div_ABC_DE_result_HL_remainder_DE_trash_AF_BC_IX_IYL
	;	round up
	LD	A, D
	OR	E
	ADD	A, $FF
	LD	A, L
	ADC	A, 0
	RET
.endblock
