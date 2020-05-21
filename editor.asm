entrypoint editor_redraw
.block
	CALL	gui_editor_top
	JP	gui_editor_frame
.endblock

entrypoint print_source
.block
	LD E, 40
	LD D, 2
	LD HL, source_buffer
next_line:
	LD A, E
	OUT gaddr_l, A
	LD A, D
	OUT gaddr_h, A
next_token:
	PUSH DE
	CALL print_source_HL_return_count_C_trash_A_B_DE
	POP DE
	CALL fill_right_30_txtlen_C_trash_A_C
	INC D
	LD A, (HL)
	CP end_
	JR NZ, next_line
	RET
.endblock
