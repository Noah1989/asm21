entrypoint assemble_source_HL_output_DE_return_count_C
.block
retry:
    LD A, (HL)
    INC HL
    AND A
    JR Z, retry
    CP last_instruction+1
    JR NC, notimpl; not an instruction?!
    LD (DE), A; for later
    LD B, msb(stable)
    LD C, A
    LD A, (BC)
    AND A
    JR Z, notimpl; not implemented
    LD C, A
    LD A, (BC)
    PUSH AF
    DEC BC
    LD A, (BC)
    POP BC
    LD C, A
    PUSH BC; handler address
    LD A, (DE); stored from earlier
    LD B, msb(atable)
    LD C, A
    LD A, (BC); handler argument
    RET; jumps to handler
notimpl:
    LD A, $10
    RST $10
    LD A, 2
    RST $10
    LD A, "?"
    RST $10
    LD C, 0
    LD A, $10
    RST $10
    LD A, 0
    RST $10
    RET
.endblock

last := 0
.macro asmstr, instr, strat, arg
.if instr?<=last
    .error wrong order for instr
.endif
org stable + instr
.db strat
org atable + instr
.db arg
last := instr
.endm

debug_align $100
.align $100; for quick lookup
stable equ $
jtable equ stable+last_instruction+1
atable equ stable+$100

asmstr CALL_nn,  op_nn, $CD
asmstr DAA_,    opcode, $27
asmstr LD_r_n,   reg_n, $06
asmstr LD_r_r, reg_reg, $40
asmstr RET_,    opcode, $C9

last := last_instruction
.macro jentry, strat
strat equ last+2
.if strat?>$FF
.error strat too large
.endif
.dw strat_handler
last := strat
.endm

.org jtable
jentry opcode  ; just an opcode
jentry op_nn   ; opcode followed by 2-byte constant
jentry reg_n   ; register encoding followed by 1-byte constant
jentry reg_reg ; double register encoding
debug_align $100

.org atable+last_instruction+1

entrypoint opcode_handler
.block
    LD (DE), A
    INC DE
    LD C, 1
    RET
.endblock

entrypoint op_nn_handler
.block
    CALL opcode_handler
    CALL eval_expression_HL_write_DE
    LD C, 3
    RET
.endblock

entrypoint reg_handler
.block
    CALL encode_reg
    LD (DE), A
    INC DE
    LD C, 1
    RET
.endblock

entrypoint reg_n_handler
.block
    CALL encode_reg
    LD (DE), A
    INC DE
    CALL eval_expression_HL_write_DE
    DEC DE ; discard upper byte
    LD C, 2
    RET
.endblock

entrypoint reg_reg_handler
.block
    CALL encode_reg
    LD C, A
    LD A, (HL)
    INC HL
    SUB regs_8
    ADD A, C
    LD (DE), A
    INC DE
    LD C, 1
    RET
.endblock

entrypoint encode_reg
.block
    LD C, A
    LD  A, (HL)
    INC HL
    SUB regs_8
    RLCA
    RLCA
    RLCA
    ADD A, C
    RET
.endblock

entrypoint eval_expression_HL_write_DE
.block
    LD A, (HL)
    INC HL
    CP hex_number
    JR Z, eval_hex_number_HL_write_DE
    CP bin_number
    JR Z, eval_bin_number_HL_write_DE
    CP reference
    JR Z, dereference_HL_write_DE
    ; unexpected expression token
    LD (DE), A
    INC DE
    LD (DE), A
    INC DE
    DEC HL
    RET
.endblock
eval_hex_number_HL_write_DE:
.block
    XOR A
    LD (DE), A
    INC DE
    LD (DE), A
    DEC DE
    EX DE, HL; now: DE=*source HL=*result
loop:
    LD A, (DE)
    SUB dat_0
    JR C, done
    INC DE
    RLD
    INC HL
    RLD
    DEC HL
    JR loop
done:
    EX DE, HL
    INC DE
    INC DE
    RET
.endblock
eval_bin_number_HL_write_DE:
.block
    LD BC, 0
loop:
    LD A, (HL)
    SUB dat_0
    JR C, done
    INC HL
    RRA
    RL C
    RL B
    JR loop
done:
    LD A, C
    LD (DE), A
    INC DE
    LD A, B
    LD (DE), A
    INC DE
    RET
.endblock
dereference_HL_write_DE:
.block
    ;TODO
    JR eval_hex_number_HL_write_DE
.endblock