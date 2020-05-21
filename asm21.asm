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
	CALL	gui_editor_top
	CALL	gui_editor_frame
	CALL	gui_statusbar
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
	LD	HL, global_hints
	LD	(hint_pointer), HL
	LD	A, 1
	LD	(is_running), A
	LD	A, -1
	LD	(active_menu_entry), A
	LD	(active_submenu_entry), A
	RET
.endblock

entrypoint quit
.block
	XOR	A
	LD	(is_running), A
	RET
.endblock

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
.include clock.asm

debug_align $1000
.align $1000
;variables
input_table_pointer:
defs 2
is_running:
defs 1
active_menu_entry:
defs 1
active_submenu_entry:
defs 1
hint_pointer:
defs 2

debug_align $1000
.align $1000
source_buffer:
.db	ld_a_inn, digits, dat_F, dat_0, dat_0, dat_1
.db	ld_rr_nn, hl_reg, digits, dat_F, dat_0, dat_0, dat_2
.db	add_a_ihl
.db	ld_inn_a, digits, dat_F, dat_0, dat_0, dat_3
.db	ret_
.db	end_
