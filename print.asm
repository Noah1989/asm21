color_io equ $B9 ; GPU color table
chars_io equ $BC ; GPU name table with auto increment

; Finds and prints the name of the bytecode token in A.
; Returns number of characters printed in C
;         parameter count in B
;         pointer to parameter list in HL
; Trashes DE
entrypoint print_name_A_ret_len_C_params_B_HL_trash_DE
.block
    CALL find_descr_A_ret_name_C_DE_params_B_HL
    PUSH BC
    EX DE, HL ; result: HL *name, DE *params
    LD B, C ; name length
    LD C, chars_io
loop:
        CALL print_color_A
        OUTI ; (C) <= (HL); DEC B; INC HL
        JR NZ, loop
    EX DE, HL ; result: HL *params, DE trash
    POP BC
    RET
.endblock

; Finds and prints the name of the bytecode in A
; followed by the names of its parameters.
; Name and parameters are separated by a space
; Parameter names are separated from each other by comma and space
; Returns number of characters printed in C
;         B set to zero
; Trashes DE and HL
; Saves   AF
entrypoint print_name_and_params_A_ret_len_C_trash_DE_HL_zero_B
.block
    PUSH AF
    CALL print_name_A_ret_len_C_params_B_HL_trash_DE
    ; check if no params
    XOR A
    OR B
    JR Z, done
    ; separator
    LD A, " "
    OUT (chars_io), A
    INC C
    JR first
loop:
        ; print comma and space
        LD A, ","
        OUT (chars_io), A
        INC C
        LD A, " "
        OUT (chars_io), A
        INC C
first:
        ; print parameter name
        LD A, (HL)
        PUSH HL
        PUSH BC
        CALL print_name_A_ret_len_C_params_B_HL_trash_DE
        ; tally the number of characters printed
        LD A, C
        POP BC
        ADD A, C
        LD C, A
        ; next param
        POP HL
        INC HL
        DJNZ loop
done:
    POP AF
    RET
.endblock

; Prints a piece of source from the address pointed to by HL.
; HL will be moved forward for every token consumed.
entrypoint print_source_HL_return_count_C_trash_DE
.block
retry:
    LD A, (HL)
    INC HL
    OR A
    JR Z, retry
    PUSH HL
    CALL print_name_A_ret_len_C_params_B_HL_trash_DE
    POP DE ; source pointer
    EX DE, HL ; result: DE = *params, HL = *source
    ; check if no params
    INC B
    DJNZ hasparams
    RET
hasparams:
    CP nospace
    JR NC, first
    ; separator
    LD A, " "
    OUT (chars_io), A
    INC C
    JR first
loop:
        ; print comma and space
        LD A, ","
        OUT (chars_io), A
        INC C
        LD A, " "
        OUT (chars_io), A
        INC C
first:
        ; process parameter
        LD A, (DE)
        PUSH DE
        PUSH BC
switch:
        CP placeholders
        JR NC, switch_1
            ; not a placeholder, just print the name
            PUSH HL
            CALL print_name_A_ret_len_C_params_B_HL_trash_DE
            POP HL
            JR switch_break
switch_1:
            ; handle placeholers that use multiple data bytes
            LD DE, switch_break
            PUSH DE ; return address
            CP text
            JP Z, print_text_HL
            CP digits
            JP Z, print_digits_HL
            ; generic placeholder, print single token from source
            JR print_source_HL_return_count_C_trash_DE
switch_break:
        ; tally the number of characters printed
        LD A, C
        POP BC
        ADD A, C
        LD C, A
        ; next param
        POP DE
        INC DE
        DJNZ loop
done:
    RET
.endblock

entrypoint print_text_HL
.block
        LD C, 0
loop:
        LD A, (HL)
        SUB dat_0
        RET C
        INC HL
        RLCA
        RLCA
        RLCA
        RLCA
        LD B, A
        LD A, (HL)
        SUB dat_0
        JR C, halfbyte
        INC HL
        ADD A, B
        out (chars_io), A
        INC C
        JR loop
halfbyte:
        DEC HL
        RET
.endblock

entrypoint print_digits_HL
.block
        LD C, 0
loop:
        LD A, (HL)
        SUB dat_0
        RET C
        INC HL
        ADD A, $90
        DAA
        ADC A, $40
        DAA
        OUT (chars_io), A
        INC C
        JR loop
.endblock

; Sets the color of the next character to be printed according to the
; type of the bytecode token in A
entrypoint print_color_A
.block
    PUSH AF
    ;TODO: actually choose different colors
    LD A, $0A
    OUT (color_io), A
    POP AF
    RET
.endblock
