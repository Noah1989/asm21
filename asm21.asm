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
.db ":label:"
.endif
label_code:
.endm

code_start:
entrypoint asm21
.block
    CALL ROM_CLEAR_SCREEN
    LD E, 4
    LD D, 2
    LD B, 26
legend_loop:
    LD A, E
    OUT gaddr_l, A
    LD A, D
    OUT gaddr_h, A
    LD A, $07
    OUT (color_io), A
    LD A, 26 + "A"
    SUB B
    OUT (chars_io), A
    LD A, $07
    OUT (color_io), A
    LD A, ":"
    OUT (chars_io), A
    LD A, " "
    OUT (chars_io), A
    INC D
    DJNZ legend_loop
list_goups:
    LD E, 7
    LD D, 2
group_count equ group_table_end-group_table+1
    LD B, 26
    LD HL, group_names
next_line:
    LD A, E
    OUT gaddr_l, A
    LD A, D
    OUT gaddr_h, A
    LD C, (HL)
    XOR A
    CP C
    JR Z, emptyline
    CALL print_pstr_HL_trash_A
emptyline:
    CALL fill_right_30_txtlen_C_trash_A_C
    INC D
    DJNZ next_line
select_group:
    CALL input_key_az_result_C_zero_B
    LD A, C
    DEC A
    JP M, ROM_CLEAR_SCREEN
    CP group_count
    JR NC, select_group
    ADD A, lsb(group_table)
    LD L, A
    LD H, msb(group_table)
    LD B, (HL)
    INC L
    LD C, (HL)
    CALL list_instr_B_to_C
wait:
    CALL ROM_GET_KEY
    JR Z, wait
    JR list_goups

group_table:
    .db instr_ld8
    .db instr_ld16
    .db instr_arith8
    .db instr_arith16
    .db instr_decinc
    .db instr_logic
    .db instr_bits
    .db instr_rotate
    .db instr_shift
    .db instr_jump
    .db instr_block
    .db instr_io
group_table_end:
    .db instr_misc
    .db pseudo_instructions
.if msb(group_table) != msb(group_table_end)
.error "group_table must not cross 256-byte boudary"
.endif
group_names:
    .pstr "8-bit data move"
    .pstr "16-bit data move"
    .pstr "8-bit arithmetic"
    .pstr "16-bit arithmetic"
    .pstr "decrement/increment"
    .pstr "logic"
    .pstr "single bit operation"
    .pstr "bit rotation"
    .pstr "bit shift"
    .pstr "jump"
    .pstr "block operations"
    .pstr "input/output"
    .pstr "other"
    .db 0
.endblock

entrypoint list_instr_B_to_C
.block
    LD E, 7
    LD D, 2
next_line:
    LD A, D
    CP 2 + 26
    RET Z
    OUT gaddr_h, A
    LD A, E
    OUT gaddr_l, A
    LD A, B
    CP C
    PUSH BC
    PUSH DE
    LD C, 0
    CALL C, print_name_and_params_A_ret_len_C_trash_DE_HL_zero_B
    CALL fill_right_30_txtlen_C_trash_A_C
    POP DE
    POP BC
    INC B
    INC D
    JR next_line
.endblock

entrypoint test_print_source
.block
    LD E, 7
    LD D, 2
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
    RET
.endblock

.include namelist.asm
.include find.asm
.include input.asm
.include assemble.asm
.include print.asm

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
.db comment
encode "t"
encode "e"
encode "s"
encode "t"
.db 0
