main_menu:
.db	" &File ", 0
.dw	file_menu
.db	0
main_menu_count equ 1

file_menu:
.db	6
.db	" &Quit ", 0
.db	0

entrypoint menu_activate
.block
	LD	HL, input_menu
	LD	(input_table_pointer), HL
	LD	HL, (input_az_pointer)
	LD	(menu_az_save), HL
	LD	HL, menu_az
	LD	(input_az_pointer), HL
	LD	HL, menu_hints
	LD	(hint_pointer), HL
	CALL	gui_statusbar
	LD	A, (active_menu_entry)
	CPL
	LD	(active_menu_entry), A
	CALL	gui_menubar
	LD	A, (active_submenu_entry)
	AND	A
	RET	M
	JP	gui_menu_dropdown
.endblock

entrypoint menu_az
.block
	RET
.endblock

entrypoint menu_abort
.block
	LD	HL, input_main
	LD	(input_table_pointer), HL
	LD	HL, global_hints
	LD	(hint_pointer), HL
	CALL	gui_statusbar
	LD	A, (active_menu_entry)
	CPL
	LD	(active_menu_entry), A
	CALL	gui_menubar
	LD	HL, (menu_az_save)
	LD	(input_az_pointer), HL
	JP	editor_redraw
.endblock

entrypoint menu_right
.block
	LD	A, (active_menu_entry)
	INC	A
	CP	main_menu_count
	RET	NC
	JR	menu_left_right_common
.endblock
entrypoint menu_left
.block
	LD	A, (active_menu_entry)
	DEC	A
	RET	M
@menu_left_right_common:
	LD	DE, (active_menu_entry)
	LD	D, 0
	LD	HL, active_submenu_store
	ADD	HL, DE
	LD	(active_menu_entry), A
	LD	A, (active_submenu_entry)
	LD	(HL), A
	AND	A
	CALL	P, editor_redraw
	CALL	gui_menubar
	LD	DE, (active_menu_entry)
	LD	D, 0
	LD	HL, active_submenu_store
	ADD	HL, DE
	LD	A, (HL)
	LD	(active_submenu_entry), A
	AND	A
	RET	M
	JP	gui_menu_dropdown
.endblock

entrypoint menu_down
.block
	LD	A, (active_submenu_entry)
	INC	A
	LD	HL, submenu_count
	CP	(HL)
	RET	NC
	LD	(active_submenu_entry), A
	JP	gui_menu_dropdown
.endblock

entrypoint menu_up
.block
	LD	A, (active_submenu_entry)
	AND	A
	JP	M, menu_abort
	DEC	A
	LD	(active_submenu_entry), A
	JP	M, editor_redraw
	JP	gui_menu_dropdown
.endblock
