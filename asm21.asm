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
jr label
.db "label"
fill " ", ((16-($ % 16)) % 16)
.endif
label:
.endm

code_start:
entrypoint asm21
    LD HL, testcode
loop:
    CALL print_source_HL
.if platform = 2 ; zx spectrum
    LD B, A
    LD A, $0D ; return
    RST $10
    LD A, B
.endif
    LD A, (HL)
    AND A
    JR NZ, loop
    RET

debug_align $100
.macro encode, char
.db (char+0) / 16 + dat_0
.db (char+0) % 16 + dat_0
.endm
testcode:
.db ld_r_n, h_reg, dec_number, dat_1, dat_7
.db ld_r_n, e_reg, dec_number, dat_2, dat_3
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

debug_align $400
.include find.asm

debug_align $400
.include print.asm

debug_align $400
.include namelist.asm

debug_align $1000
.if ($-code_start)?>=$1000
.error size target exceeded
.endif