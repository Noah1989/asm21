.include rom.inc

gaddr_l .equ $B3
gaddr_h .equ $B4

.org $8000
fill $76, $1000

.org $9000

debug equ 1

; Aligning the code makes debugging easier.
.macro debug_align, %%1
.if debug
width := %%1
fill $76, ((width-($ % width)) % width)
.endif
.endm

; This leaves unreachable string marks all over the code.
; A stack trace can be constructed by looking at the hidden text.
.macro entrypoint, label
debug_align $10
label:
.if debug
jr label_code
.db "label"
fill " ", ((16-($ % 16)) % 16)
.endif
label_code:
.endm

code_start:
entrypoint asm21
.block
    CALL ROM_CLEAR_SCREEN
    XOR A
    LD E, 4
    LD D, 3
    LD HL, source_buffer
next_line:
    LD A, E
    OUT gaddr_l, A
    LD A, D
    OUT gaddr_h, A
next_token:
    PUSH DE
    CALL print_source_HL_return_count_C_trash_DE
    POP DE
    LD A, (HL)
    CP inlines
    JR NC, next_token
    INC D
    AND A
    JR NZ, next_line
wait:
    CALL ROM_GET_KEY
    JR Z, wait
    CALL ROM_CLEAR_SCREEN
    RET
.endblock

.include find.asm
.include print.asm
.include namelist.asm
.include assemble.asm

debug_align $1000
.if ($-code_start)?>$1000
.error size target exceeded
.endif

source_buffer:
.macro encode, char
.db (char+0) / 16 + dat_0
.db (char+0) % 16 + dat_0
.endm
.db ld_r_n, h_reg, hex_number, dat_1, dat_7
.db ld_r_n, e_reg, bin_number, dat_1, dat_1, dat_0, dat_1
.db call_nn, reference, dat_0
.db ld_r_r, b_reg, h_reg
.db ld_r_r, c_reg, l_reg
.db ret_
.db label, dat_0
encode "m"
encode "u"
encode "l"
encode "t"
encode "_"
encode "h"
encode "_"
encode "e"
.db ld_r_n, d_reg, dat_0
.db sla_r, h_reg
.db sbc_a_r, a_reg
.db and_a_r, e_reg
.db ld_r_r, l_reg, a_reg
.db ld_r_n, b_reg, dat_7
.db label, dat_1
encode "l"
encode "o"
encode "o"
encode "p"
.db add_hl_rr, hl_reg
.db jr_cr_d, nc_flag, reference, dat_2
.db add_hl_rr, de_reg
.db label, dat_2
encode "n"
encode "o"
encode "a"
encode "d"
encode "d"
.db djnz_, reference, dat_1
.db ret_
.db 0
