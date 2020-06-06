.include rom.inc

gaddr_l .equ $B3
gaddr_h .equ $B4

.org $9000

debug equ 0

; Aligning the code makes debugging easier.
.macro debug_align, %%1
.if debug
width := %%1
fill $FF, ((width-($ % width)) % width)
.endif
.endm

; This leaves unreachable string marks all over the code.
; A stack trace can be constructed by looking at the hidden text.
.macro entrypoint, label
debug_align $10
label:
.if debug
	JR	label_code
.db ":label:"
.endif
label_code:
.endm

code_start:
entrypoint asm21
.block
	CALL	ROM_CLEAR_SCREEN
	CALL	init
	CALL	gui_menubar
	CALL	gui_statusbar
	CALL	count_lines
	CALL	calc_scrollbar
	CALL	editor_redraw
loop:
	CALL	input_handler
	CALL	clock
	LD	A, (is_running)
	AND	A
	JR	NZ, loop
	CALL	ROM_CLEAR_SCREEN
	RET
.endblock

entrypoint init
.block
	LD	HL, input_main
	LD	(input_table_pointer), HL

	LD	HL, group_select
	LD	(input_az_pointer), HL

	LD	HL, global_hints
	LD	(hint_pointer), HL

	LD	HL, tool_title_select
	LD	(tool_title_pointer), HL

	LD	HL, source_buffer
	XOR	A
loop1:
	CP	(HL)
	JR	NZ, done
	INC	HL
	JR	loop1
done:
	LD	(listing_top_pointer), HL
	LD	(active_line_pointer), HL

	LD	HL, 0
	LD	(line_listing_top), HL
	LD	(line_active), HL

	LD	A, 1
	LD	(is_running), A

	LD	A, -1
	LD	(active_menu_entry), A
	LD	(active_submenu_entry), A

	LD	HL, active_submenu_store
	LD	B, main_menu_count
loop2:
	LD	(HL), A
	INC	HL
	DJNZ	loop2

	RET
.endblock

entrypoint count_lines
.block
	LD	HL, source_buffer
	LD	DE, 0
retry:
	LD	A, (HL)
	AND	A
	JR	NZ, loop
	INC	HL
	JR	retry
loop:
	CP	end_
	JR	Z, end
	INC	DE
loop2:
	INC	HL
	LD	A, (HL)
	AND	A
	JR	Z, loop2
	CP	inlines
	JR	NC, loop2
	JR	loop
end:
	LD	(line_count), DE
	RET
.endblock

entrypoint quit
.block
	XOR	A
	LD	(is_running), A
	RET
.endblock

.include math.asm
.include namelist.asm
.include find.asm
.include input.asm
.include assemble.asm
.include print.asm
.include groups.asm
.include style.asm
.include gui.asm
.include menu.asm
.include editor.asm
.include tools.asm
.include clock.asm

debug_align $1000
.align $1000
;variables
input_table_pointer:
defs 2
input_az_pointer:
defs 2
is_running:
defs 1
active_menu_entry:
defs 1
active_submenu_entry:
defs 1
active_submenu_store:
defs main_menu_count
submenu_count:
defs 1
hint_pointer:
defs 2
listing_top_pointer:
defs 2
active_line_pointer:
defs 2
code_colors_pointer:
defs 2
line_count:
defs 2
line_listing_top:
defs 2
line_active:
defs 2
scrollbar_top:
defs 1
scrollbar_bottom:
defs 1
tool_title_pointer:
defs 2
instruction_select_begin:
defs 1
instruction_select_end:
defs 1
expression_buffer:
defs 8

debug_align $1000
.align $1000
source_buffer:
.db	define, digits, dat_0, dat_0, terminator, dat_6, dat_7, dat_7, dat_3, dat_6, dat_5, dat_7, dat_4, dat_3, dat_2, digits, dat_b, dat_2
.db	empty
.db	define, digits, dat_0, dat_1, terminator, dat_6, dat_7, dat_6, dat_1, dat_6, dat_4, dat_6, dat_4, dat_7, dat_2, dat_5, dat_f, dat_6, dat_c, digits, dat_b, dat_3
.db	define, digits, dat_0, dat_2, terminator, dat_6, dat_7, dat_6, dat_1, dat_6, dat_4, dat_6, dat_4, dat_7, dat_2, dat_5, dat_f, dat_6, dat_8, digits, dat_b, dat_4
.db	empty
.db	define, digits, dat_0, dat_3, terminator, dat_6, dat_e, dat_6, dat_1, dat_6, dat_d, dat_6, dat_5, alignment, dat_3, digits, dat_b, dat_8
.db	define, digits, dat_0, dat_4, terminator, dat_6, dat_3, dat_6, dat_f, dat_6, dat_c, dat_6, dat_f, dat_7, dat_2, alignment, dat_2, digits, dat_b, dat_9
.db	define, digits, dat_0, dat_5, terminator, dat_7, dat_0, dat_6, dat_1, dat_7, dat_4, dat_7, dat_4, dat_6, dat_5, dat_7, dat_2, dat_6, dat_e, digits, dat_b, dat_a
.db	define, digits, dat_0, dat_6, terminator, dat_7, dat_0, dat_6, dat_1, dat_6, dat_c, dat_6, dat_5, dat_7, dat_4, dat_7, dat_4, dat_6, dat_5, digits, dat_b, dat_b
.db	empty
.db	define, digits, dat_0, dat_7, terminator, dat_6, dat_e, dat_6, dat_1, dat_6, dat_d, dat_6, dat_5, dat_5, dat_f, dat_6, dat_9, dat_6, dat_e, dat_6, dat_3, alignment, dat_3, digits, dat_b, dat_8
.db	define, digits, dat_0, dat_8, terminator, dat_6, dat_3, dat_6, dat_f, dat_6, dat_c, dat_6, dat_f, dat_7, dat_2, dat_5, dat_f, dat_6, dat_9, dat_6, dat_e, dat_6, dat_3, alignment, dat_2, digits, dat_b, dat_9
.db	define, digits, dat_0, dat_9, terminator, dat_7, dat_0, dat_6, dat_1, dat_7, dat_4, dat_7, dat_4, dat_6, dat_5, dat_7, dat_2, dat_6, dat_e, dat_5, dat_f, dat_6, dat_9, dat_6, dat_e, dat_6, dat_3, digits, dat_b, dat_a
.db	define, digits, dat_0, dat_a, terminator, dat_7, dat_0, dat_6, dat_1, dat_6, dat_c, dat_6, dat_5, dat_7, dat_4, dat_7, dat_4, dat_6, dat_5, dat_5, dat_f, dat_6, dat_9, dat_6, dat_e, dat_6, dat_3, digits, dat_b, dat_b
.db	empty
.db	define, digits, dat_0, dat_b, terminator, dat_6, dat_9, dat_6, dat_e, dat_6, dat_9, dat_7, dat_4, dat_5, dat_f, dat_6, dat_7, dat_7, dat_2, dat_6, dat_1, dat_7, dat_0, dat_6, dat_8, dat_6, dat_9, dat_6, dat_3, dat_7, dat_3, alignment, dat_3, digits, dat_0, dat_0, dat_d, dat_0
.db	define, digits, dat_0, dat_c, terminator, dat_6, dat_c, dat_6, dat_f, dat_6, dat_1, dat_6, dat_4, dat_5, dat_f, dat_7, dat_0, dat_6, dat_1, dat_6, dat_c, dat_6, dat_5, dat_7, dat_4, dat_7, dat_4, dat_6, dat_5, alignment, dat_4, digits, dat_0, dat_0, dat_f, dat_0
.db	define, digits, dat_0, dat_d, terminator, dat_6, dat_c, dat_6, dat_f, dat_6, dat_1, dat_6, dat_4, dat_5, dat_f, dat_6, dat_3, dat_6, dat_8, dat_6, dat_1, dat_7, dat_2, dat_7, dat_3, alignment, dat_6, digits, dat_0, dat_1, dat_5, dat_0
.db	define, digits, dat_0, dat_e, terminator, dat_6, dat_3, dat_6, dat_c, dat_6, dat_5, dat_6, dat_1, dat_7, dat_2, dat_5, dat_f, dat_7, dat_3, dat_6, dat_3, dat_7, dat_2, dat_6, dat_5, dat_6, dat_5, dat_6, dat_e, alignment, dat_4, digits, dat_0, dat_1, dat_b, dat_0
.db	define, digits, dat_0, dat_f, terminator, dat_6, dat_3, dat_6, dat_c, dat_6, dat_5, dat_6, dat_1, dat_7, dat_2, dat_5, dat_f, dat_7, dat_3, dat_6, dat_3, dat_7, dat_2, dat_6, dat_5, dat_6, dat_5, dat_6, dat_e, dat_5, dat_f, dat_6, dat_3, dat_6, dat_f, dat_6, dat_c, digits, dat_0, dat_1, dat_c, dat_2
.db	define, digits, dat_1, dat_0, terminator, dat_7, dat_0, dat_7, dat_2, dat_6, dat_9, dat_6, dat_e, dat_7, dat_4, dat_5, dat_f, dat_6, dat_2, dat_7, dat_9, dat_7, dat_4, dat_6, dat_5, alignment, dat_6, digits, dat_0, dat_3, dat_5, dat_0
.db	define, digits, dat_1, dat_1, terminator, dat_6, dat_7, dat_6, dat_5, dat_7, dat_4, dat_5, dat_f, dat_6, dat_b, dat_6, dat_5, dat_7, dat_9, alignment, dat_9, digits, dat_0, dat_2, dat_0, dat_0
.db	empty
.db	origin, digits, dat_8, dat_0, dat_0, dat_0
.db	empty
.db	call_nn, reference, digits, dat_0, dat_f
.db	empty
.db	comment, dat_6, dat_4, dat_6, dat_9, dat_7, dat_3, dat_6, dat_1, dat_6, dat_2, dat_6, dat_c, dat_6, dat_5, dat_2, dat_0, dat_6, dat_8, dat_6, dat_9, dat_6, dat_7, dat_6, dat_8, dat_6, dat_3, dat_6, dat_8, dat_6, dat_1, dat_7, dat_2, dat_7, dat_3, dat_2, dat_0, dat_6, dat_d, dat_6, dat_f, dat_6, dat_4, dat_6, dat_5
.db	ld_r_n, a_reg, bin_number, dat_0, dat_0, dat_1, dat_1, dat_0, dat_0, dat_1, dat_1
.db	out_n_a, reference, digits, dat_0, dat_0
.db	empty
.db	comment, dat_6, dat_6, dat_6, dat_9, dat_6, dat_c, dat_6, dat_c, dat_2, dat_0, dat_7, dat_0, dat_6, dat_1, dat_7, dat_4, dat_7, dat_4, dat_6, dat_5, dat_7, dat_2, dat_6, dat_e, dat_7, dat_3, dat_2, dat_0, dat_2, dat_4, dat_3, dat_0, dat_3, dat_0, dat_2, dat_e, dat_2, dat_e, dat_2, dat_4, dat_3, dat_0, dat_6, dat_6, dat_2, dat_0, dat_7, dat_7, dat_6, dat_9, dat_7, dat_4, dat_6, dat_8, dat_2, dat_0, dat_7, dat_3, dat_6, dat_9, dat_6, dat_e, dat_6, dat_7, dat_6, dat_c, dat_6, dat_5, dat_2, dat_0, dat_6, dat_3, dat_6, dat_f, dat_6, dat_c, dat_6, dat_f, dat_7, dat_2
.db	xor_a_r, a_reg
.db	out_n_a, reference, digits, dat_0, dat_1
.db	out_n_a, reference, digits, dat_0, dat_2
.db	label, digits, dat_1, dat_2, terminator, dat_7, dat_0, dat_6, dat_1, dat_7, dat_4, dat_5, dat_f, dat_6, dat_2, dat_6, dat_9, dat_6, dat_7, dat_6, dat_c, dat_6, dat_f, dat_6, dat_f, dat_7, dat_0
.db	ld_r_n, b_reg, dec_number, dat_3, dat_2
.db	label, digits, dat_1, dat_3, terminator, dat_7, dat_0, dat_6, dat_1, dat_7, dat_4, dat_5, dat_f, dat_6, dat_c, dat_6, dat_f, dat_6, dat_f, dat_7, dat_0
.db	out_n_a, reference, digits, dat_0, dat_9
.db	djnz_, reference, digits, dat_1, dat_3
.db	add_a_n, digits, dat_1, dat_1
.db	jr_cr_d, nc_flag, reference, digits, dat_1, dat_2
.db	empty
.db	comment, dat_6, dat_6, dat_6, dat_9, dat_6, dat_c, dat_6, dat_c, dat_2, dat_0, dat_7, dat_0, dat_6, dat_1, dat_6, dat_c, dat_6, dat_5, dat_7, dat_4, dat_7, dat_4, dat_6, dat_5, dat_7, dat_3, dat_2, dat_0, dat_2, dat_4, dat_3, dat_0, dat_3, dat_0, dat_2, dat_e, dat_2, dat_e, dat_2, dat_4, dat_3, dat_0, dat_6, dat_6, dat_2, dat_0, dat_7, dat_7, dat_6, dat_9, dat_7, dat_4, dat_6, dat_8, dat_2, dat_0, dat_6, dat_1, dat_6, dat_c, dat_6, dat_c, dat_2, dat_0, dat_7, dat_0, dat_6, dat_f, dat_7, dat_3, dat_7, dat_3, dat_6, dat_9, dat_6, dat_2, dat_6, dat_c, dat_6, dat_5, dat_2, dat_0, dat_6, dat_3, dat_6, dat_f, dat_6, dat_c, dat_6, dat_f, dat_7, dat_2, dat_7, dat_3
.db	xor_a_r, a_reg
.db	out_n_a, reference, digits, dat_0, dat_1
.db	out_n_a, reference, digits, dat_0, dat_2
.db	label, digits, dat_1, dat_4, terminator, dat_7, dat_0, dat_6, dat_1, dat_6, dat_c, dat_5, dat_f, dat_6, dat_c, dat_6, dat_f, dat_6, dat_f, dat_7, dat_0
.db	out_n_a, reference, digits, dat_0, dat_a
.db	inc_r, a_reg
.db	jr_cr_d, nz_flag, reference, digits, dat_1, dat_4
.db	empty
.db	comment, dat_7, dat_0, dat_6, dat_1, dat_6, dat_c, dat_6, dat_5, dat_7, dat_4, dat_7, dat_4, dat_6, dat_5, dat_2, dat_0, dat_2, dat_4, dat_3, dat_1, dat_3, dat_0, dat_2, dat_0, dat_6, dat_6, dat_6, dat_f, dat_7, dat_2, dat_2, dat_0, dat_7, dat_4, dat_6, dat_f, dat_7, dat_0, dat_2, dat_0, dat_6, dat_8, dat_6, dat_1, dat_6, dat_c, dat_6, dat_6, dat_2, dat_0, dat_6, dat_f, dat_6, dat_6, dat_2, dat_0, dat_6, dat_3, dat_6, dat_8, dat_6, dat_1, dat_7, dat_2, dat_6, dat_1, dat_6, dat_3, dat_7, dat_4, dat_6, dat_5, dat_7, dat_2, dat_7, dat_3
.db	ld_r_n, b_reg, dat_8
.db	label, digits, dat_1, dat_5, terminator, dat_7, dat_0, dat_6, dat_1, dat_6, dat_c, dat_5, dat_f, dat_7, dat_4, dat_6, dat_f, dat_7, dat_0, dat_5, dat_f, dat_6, dat_c, dat_6, dat_f, dat_6, dat_f, dat_7, dat_0

.db	empty
.db	end_
