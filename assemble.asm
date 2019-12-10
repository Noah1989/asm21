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

asmstr AND_A_r,     lreg, $A0
asmstr CALL_nn,    op_nn, $CD
asmstr DAA_,      opcode, $27
asmstr LD_r_n,    hreg_n, $06
asmstr LD_r_r, hreg_lreg, $40
asmstr RET_,      opcode, $C9
asmstr SBC_A_r,     lreg, $98
asmstr SLA_r,    cb_lreg, $20
asmstr label,        lbl, $00

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
jentry opcode    ; just an opcode
jentry op_nn     ; opcode followed by 2-byte constant
jentry hreg_n    ; high register encoding followed by 1-byte constant
jentry hreg_lreg ; double register encoding
jentry lreg      ; low register encoding
jentry cb_lreg   ; $CB prefix, low register encoding
jentry lbl       ; label (no code generated)
debug_align $100

.org atable+last_instruction+1

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
    LD A, $10
    RST $10
    LD A, 0
    RST $10
    LD C, 0
    RET
.endblock

entrypoint lbl_handler
.block
    CALL eval_expression_HL_write_DE
    ; TODO: write result to symbol table
    DEC DE
    DEC DE
    LD C, 0
skipname:
    LD A, (HL)
    CP dat_0
    RET C
    INC HL
    JR skipname
.endblock

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

entrypoint hreg_handler
.block
    CALL encode_hreg
    LD (DE), A
    INC DE
    LD C, 1
    RET
.endblock

entrypoint hreg_n_handler
.block
    CALL encode_hreg
    LD (DE), A
    INC DE
    CALL eval_expression_HL_write_DE
    DEC DE ; discard upper byte
    LD C, 2
    RET
.endblock

entrypoint hreg_lreg_handler
.block
    CALL encode_hreg
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

entrypoint lreg_handler 
.block
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

entrypoint cb_lreg_handler
.block
    LD C, A
    LD A, $CB
    LD (DE), A
    INC DE
    LD A, (HL)
    INC HL
    SUB regs_8
    ADD A, C
    LD (DE), A
    INC DE
    LD C, 2
    RET
.endblock

entrypoint encode_hreg
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
    ; numbers 0-15 encoded as a single token without prefix
    CP dat_0
    JR C, unexpected
    SUB dat_0
    LD (DE), A
    INC DE
    XOR A
    LD (DE), A
    INC DE
    RET
unexpected:
    ; unexpected expression token, dump it for debugging
    LD (DE), A
    INC DE
    LD (DE), A
    INC DE
    DEC HL ; leave token unprocessed
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