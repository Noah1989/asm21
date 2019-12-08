.org $9000

debug equ 1
color equ 0
platform equ 2 ; 1 = micro21, 2 = zx spectrum

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
.if debug
debug_align $80
label:
jr label_code
.db "label"
fill " ", ((16-($ % 16)) % 16)
.endif
label_code:
.endm

code_start:
entrypoint asm21
.block
    LD DE, $8000
    LD HL, testcode
loop:
    PUSH DE
    PUSH HL
    CALL print_source_HL_return_count_C
    LD A, 16
    SUB C
    LD B, A
    LD A, $10
    RST $10
    LD A, 6
    RST $10
spaces:
    LD A, "_"
    RST $10
    DJNZ spaces
    LD A, $10
    RST $10
    LD A, 0
    RST $10
    POP HL
    POP DE
    CALL assemble_source_HL_output_DE_return_count_C
    XOR A
    OR  C
    JR Z, next
    LD B, 0
    EX DE, HL
    SBC HL, BC
    EX DE, HL
    LD B, C
    JR print_result
print_result_loop:
    LD A, " "
    RST $10
print_result:
    LD A, (DE)
    INC DE
    CALL print_byte_A
    DJNZ print_result_loop

next:
    LD A, $0D ; newline
    RST $10
    LD A, (HL)
    AND A
    JR NZ, loop
    RET
.endblock

print_byte_A:
    PUSH AF
    RRA
    RRA
    RRA
    RRA
    CALL print_nibble_A
    POP AF
print_nibble_A:
    AND $0F
    ADD A, $90
    DAA
    ADC A, $40
    DAA
    RST $10
    RET

debug_align $100
.macro encode, char
.db (char+0) / 16 + dat_0
.db (char+0) % 16 + dat_0
.endm
testcode:
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
testcode_end:
.db 0

.include find.asm
.include print.asm
.include namelist.asm
.include assemble.asm

debug_align $1000
.if ($-code_start)?>$1000
.error size target exceeded
.endif