key_hints:
	.db " &F&1&0-Menu", 0

program_name:
	.db " ASM&2&1 ", 0

main_menu:
	.db " &File ", 0
	.dw file_menu
	.db " &Test1 ", 0
	.dw test_menu
	.db " T&est2 ", 0
	.dw test_menu
	.db 0

file_menu:
	.db "&Quit", 0

test_menu:
	.db "&This is", 0
	.db "&Just a", 0
	.db "&Test", 0
	.db 0

entrypoint gui_menubar
.block
	XOR A
	OUT gaddr_l, A
	OUT gaddr_h, A
	LD B, 80
	LD C, color_menubar
	LD D, color_menubar_hightlight
	LD HL, main_menu
loop:
	CALL gui_print_highlight_str_iHL_maxlen_B_colors_C_D
	INC HL
	INC HL
	INC HL
	LD A, (HL)
	AND A
	JR NZ, loop
loop2:
	LD A, color_menubar
	OUT color_io, A
	LD A, ' '
	OUT chars_io, A
	DJNZ loop2
	RET
.endblock

entrypoint gui_editor_top
.block
	XOR A
	OUT gaddr_l, A
	INC A
	OUT gaddr_h, A
	LD C, color_editor
	LD HL, chars_editor_top
	JR gui_line_color_C_chars_iHL
.endblock

entrypoint gui_editor_frame
.block
	LD D, 2
loop:
	XOR A
	OUT gaddr_l, A
	LD A, D
	OUT gaddr_h, A
	LD C, color_editor
	LD HL, chars_editor_frame
	CALL gui_line_color_C_chars_iHL
	INC D
	LD A, D
	CP 29
	JR C, loop
	RET
.endblock

entrypoint gui_statusbar
.block
	XOR A
	OUT gaddr_l, A
	LD A, 29
	OUT gaddr_h, A
	LD HL, key_hints
	LD B, 72
	LD C, color_statusbar
	LD D, color_statusbar_highlight
	CALL gui_print_highlight_str_iHL_maxlen_B_colors_C_D
loop:
	LD A, C
	OUT color_io, A
	LD A, ' '
	OUT chars_io, A
	DJNZ loop
	LD C, color_statusbar_info
	LD D, color_statusbar_info2
	LD A, C
	OUT color_io, A
	LD A, $B3
	OUT chars_io, A
	LD HL, program_name
	LD B, 7
	JR gui_print_highlight_str_iHL_maxlen_B_colors_C_D
.endblock

entrypoint gui_line_color_C_chars_iHL
.block
	LD A, C
	OUT color_io, A
	LD A, (HL)
	OUT chars_io, A
	INC HL
	LD B, 78
loop:
	LD A, C
	OUT color_io, A
	LD A, (HL)
	OUT chars_io, A
	DJNZ loop
	INC HL
	LD A, C
	OUT color_io, A
	LD A, (HL)
	OUT chars_io, A
	RET
.endblock

entrypoint gui_print_highlight_str_iHL_maxlen_B_colors_C_D
.block
loop:
	LD A, (HL)
	AND A
	RET Z
elif:
	CP '&'
	JR NZ, else
	LD A, D
	INC HL
	JR endif
else:
	LD A, C
endif:
	OUT color_io, A
	LD A, (HL)
	OUT chars_io, A
	INC HL
	DJNZ loop
	RET
.endblock
