scroll_lines equ 26
editor_width equ 58

entrypoint editor_redraw
.block
	CALL	gui_tools_top
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
	LD	HL, (line_active)
	INC	HL
	LD	(line_active), HL
	LD	DE, (line_listing_top)
	AND	A
	SBC	HL, DE
	LD	A, L
	CP	27
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
	JP	print_source
.endblock

entrypoint editor_up
.block
	LD	B, 1
	JR	go
@editor_up_page:
	LD	B, scroll_lines
go:
	LD	HL, (line_active)
	LD	A, H
	OR	L
	JR	Z, end2
	LD	HL, (active_line_pointer)
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
scroll_up:
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
end2:
	CALL	calc_scrollbar
	JP	print_source
@editor_scroll_up:
	LD	B, 1
	JR	scroll_up
.endblock

entrypoint editor_delete_after
.block
	LD	HL, (line_count)
	DEC	HL
	LD	A, H
	OR	L
	JR	NZ, start
	LD	HL, (active_line_pointer)
	LD	(HL), empty
	INC	HL
	LD	(HL), end_
	JP	print_source
start:
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
check:
	XOR	A
	LD	HL, (listing_top_pointer)
loop4:
	CP	(HL)
	JR	NZ, ok
	INC	HL
	JR	loop4
ok:
	LD	(listing_top_pointer), HL
	LD	HL, (active_line_pointer)
	LD	A, (HL)
	CP	end_
	JR	NZ, ok2
loop5:
	DEC	HL
	LD	A, (HL)
	AND	A
	JR	Z, loop5
	CP	inlines
	JR	NC, loop5
	LD	(active_line_pointer), HL
	LD	HL, (line_active)
	DEC	HL
	LD	(line_active), HL
ok2:
	LD	HL, (line_count)
	DEC	HL
	LD	(line_count), HL
	LD	A, H
	AND	A
	JR	NZ, go
	LD	A, L
	CP	27
	JR	C, skip
go:
	LD	DE, (line_listing_top)
	XOR	A ; clears carry
	SBC	HL, DE
	CP	H
	JR	NZ, skip
	LD	A, L
	CP	27
	JR	C, editor_scroll_up
skip:
	CALL	calc_scrollbar
	JP	print_source
@editor_delete_before:
	LD	HL, (line_active)
	LD	A, H
	OR	L
	RET	Z
	LD	HL, (active_line_pointer)
	LD	B, 0
loop3:
	DEC	HL
	LD	A, (HL)
	AND	A
	JR	Z, loop3
	LD	(HL), B
	CP	inlines
	JR	NC, loop3
	LD	HL, (line_listing_top)
	LD	DE, (line_active)
	AND	A ; clear carry
	SBC	HL, DE
	LD	HL, (line_count)
	DEC	DE ; no effect on on flags
	JR	NZ, skip2
	LD	(line_listing_top), DE
skip2:
	LD	(line_active), DE
	JR	check
.endblock

entrypoint editor_insert_after
.block
	LD	HL, (active_line_pointer)
retry:
	INC	HL
	LD	A, (HL)
	AND	A
	JR	Z, retry
	CP	inlines
	JR	NC, retry
	CALL	insert
	JP	editor_down
@editor_insert_before:
	LD	HL, (active_line_pointer)
	CALL	insert
	JP	print_source
insert:
	LD	C, empty
loop:
	LD	A, (HL)
	LD	(HL), C
	INC	HL
	AND	A
	JR	Z, done
	CP	end_
	JR	Z, end
	LD	C, A
	JR	loop
end:
	LD	(HL), A
done:
	LD	HL, (line_count)
	INC	HL
	LD	(line_count), HL
	JP	calc_scrollbar
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
	LD	A, 80-editor_width-2
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
	LD	A, editor_width
	CALL	fill_right_width_A_txtlen_C_trash_A_BC_DE
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
