.include rom.inc

gaddr_l .equ $B3
gaddr_h .equ $B4

.org $8000
fill $FF, $1000

.org $9000

debug equ 1

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
jr label_code
.db ":label:"
.endif
label_code:
.endm

code_start:
entrypoint asm21
.block
	CALL ROM_CLEAR_SCREEN
	CALL gui_menubar
	CALL gui_editor_top
	CALL gui_editor_frame
	CALL gui_statusbar
	HALT
.endblock

.include namelist.asm
.include find.asm
.include input.asm
.include assemble.asm
.include print.asm
.include groups.asm
.include style.asm
.include gui.asm
.include editor.asm

debug_align $1000
.align $1000

source_buffer:
.db ld_a_inn, digits, dat_F, dat_0, dat_0, dat_1
.db ld_rr_nn, hl_reg, digits, dat_F, dat_0, dat_0, dat_2
.db add_a_ihl
.db ld_inn_a, digits, dat_F, dat_0, dat_0, dat_3
.db ret_
.db end_
