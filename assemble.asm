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

asmstr ADC_A_n,          op_n, $CE
asmstr ADC_A_r,          lreg, $88
asmstr ADC_A_iHL,      opcode, $8E
asmstr ADC_A_iri,     ir_op_d, $8E
asmstr ADC_HL_rr,     ed_rreg, $4A
asmstr ADD_A_n,          op_n, $C6
asmstr ADD_A_r,          lreg, $80
asmstr ADD_A_iHL,      opcode, $86
asmstr ADD_A_iri,     ir_op_d, $86
asmstr ADD_HL_rr,        rreg, $09
asmstr ADD_IX_rx,     ix_rreg, $09
asmstr ADD_IY_ry,     iy_rreg, $09
asmstr AND_A_n,          op_n, $E6
asmstr AND_A_r,          lreg, $A0
asmstr AND_A_iHL,      opcode, $A6
asmstr AND_A_iri,     ir_op_d, $A6
asmstr BIT_b_r,   cb_bit_lreg, $40
asmstr BIT_b_iHL,      cb_bit, $46
asmstr BIT_b_iri, ir_cb_d_bit, $46
asmstr CALL_nn,         op_nn, $CD
asmstr CALL_cc_nn,      cc_nn, $C4
asmstr CCF_,           opcode, $3F
asmstr CP_A_n,           op_n, $FE
asmstr CP_A_r,           lreg, $B8
asmstr CP_A_iHL,       opcode, $BE
asmstr CP_A_iri,      ir_op_d, $BE
asmstr CPD_,            ed_op, $A9
asmstr CPDR_,           ed_op, $B9
asmstr CPI_,            ed_op, $A1
asmstr CPIR_,           ed_op, $B1
asmstr CPL_,           opcode, $2F
asmstr DAA_,           opcode, $27
asmstr DEC_r,            hreg, $05
asmstr DEC_iHL,        opcode, $35
asmstr DEC_iri,       ir_op_d, $35
asmstr DEC_rr,           rreg, $0B
asmstr DEC_ri,          ir_op, $2B
asmstr DI_,            opcode, $F3
asmstr DJNZ_,            op_d, $10
asmstr EI_,            opcode, $FB
asmstr EX_AF,          opcode, $08
asmstr EX_DE_HL,       opcode, $EB
asmstr EX_iSP_HL,      opcode, $E3
asmstr EX_iSP_ri,       ir_op, $E3

asmstr LD_r_n,         hreg_n, $06
asmstr LD_r_r,      hreg_lreg, $40
asmstr RET_,           opcode, $C9
asmstr SBC_A_r,          lreg, $98
asmstr SLA_r,         cb_lreg, $20
asmstr label,             lbl, $00

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
jentry opcode      ; just an opcode
jentry op_d        ; opcode followed by offset
jentry op_n        ; opcode followed by 1-byte constant
jentry op_nn       ; opcode followed by 2-byte constant
jentry hreg        ; hihg register encoding (bits 3-5)
jentry hreg_n      ; high register encoding followed by 1-byte constant
jentry hreg_lreg   ; both register encodings
jentry lreg        ; low register encoding (bits 0-2)
jentry rreg        ; 16-bit register encoding (bits 4-5)
jentry cb_lreg     ; $CB prefix, low register encoding
jentry ed_op       ; $ED prefix, single opcode
jentry ed_rreg     ; $ED prefix, 16-bit register encoding
jentry ix_rreg     ; $DD (IX) prefix, 16-bit reg encoding
jentry iy_rreg     ; $FD (IY) prefix, 16-bit reg encoding
jentry ir_op       ; $DD/$FD prefix, single opcode
jentry ir_op_d     ; $DD/$FD prefix, single opcode, offset
jentry cb_bit      ; $CB prefix, bit number
jentry cb_bit_lreg ; $CB prefix, bit number, low register
jentry ir_cb_d_bit ; $DD/$FD, $CB, displacement, bit number
jentry cc_nn       ; condition, 2-byte const
jentry lbl         ; label (no code generated)
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
skipname: ; name text only for display
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

entrypoint op_d_handler
.block
    LD (DE), A
    INC DE
    CALL eval_expression_HL_write_DE
    DEC DE ; TODO: calculate offset
    LD C, 2
    RET
.endblock

entrypoint op_n_handler
.block
    LD (DE), A
    INC DE
    CALL eval_expression_HL_write_DE
    DEC DE
    LD C, 2
    RET
.endblock

entrypoint op_nn_handler
.block
    LD (DE), A
    INC DE
    CALL eval_expression_HL_write_DE
    LD C, 3
    RET
.endblock

entrypoint ed_op_handler
.block
    LD C, A
    LD A, $ED
    LD (DE), A
    INC DE
    LD A, C
    LD (DE), A
    INC DE
    LD C, 2
    RET
.endblock

entrypoint ir_op_handler
.block
    LD C, A
    CALL encode_ir_prefix
    LD (DE), A
    INC DE
    LD A, C
    LD (DE), A
    INC DE
    LD C, 2
    RET
.endblock

entrypoint ir_op_d_handler
.block
    LD C, A
    CALL encode_ir_prefix
    LD (DE), A
    INC DE
    LD A, C
    LD (DE), A
    INC DE
    CALL eval_expression_HL_write_DE
    DEC DE
    LD C, 3
    RET
.endblock

entrypoint encode_ir_prefix
.block
    LD A, (HL)
    INC HL
    CP IX_ind
    JR NZ, is_iy
is_ix:
    LD A, $DD
    RET
is_iy:
    LD A, $FD
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

entrypoint cb_bit_handler
.block
    PUSH AF
    LD A, $CB
    LD (DE), A
    INC DE
    CALL encode_bit
    POP BC
    ADD A, B
    LD (DE), A
    INC DE
    LD C, 2
    RET
.endblock

entrypoint cb_bit_lreg_handler
.block
    PUSH AF
    LD A, $CB
    LD (DE), A
    INC DE
    CALL encode_bit
    POP BC
    ADD A, B
    LD C, A
    LD A, (HL)
    SUB regs_8
    ADD A, C
    LD (DE), A
    INC DE
    LD C, 2
    RET
.endblock

entrypoint ir_cb_d_bit_handler
.block
    PUSH AF
    CALL encode_ir_prefix
    LD (DE), A
    INC DE
    LD A, $CB
    LD (DE), A
    INC DE
    CALL eval_expression_HL_write_DE
    DEC DE
    CALL encode_bit
    POP BC
    ADD A, B
    LD (DE), A
    INC DE
    LD C, 4
    RET
.endblock

entrypoint encode_bit
.block
    CALL eval_expression_HL_write_DE
    DEC DE
    DEC DE
    LD A, (DE)
    RLCA
    RLCA
    RLCA
    RET
.endblock

entrypoint rreg_handler
.block
    CALL encode_rreg
    LD (DE), A
    INC DE
    LD C, 1
    RET
.endblock

entrypoint ix_rreg_handler
.block
    LD C, A
    LD A, $DD
    JR common_prefix_rreg_handler
.endblock

entrypoint iy_rreg_handler
.block
    LD C, A
    LD A, $FD
    jr common_prefix_rreg_handler
.endblock

entrypoint ed_rreg_handler
.block
    LD C, A
    LD A, $ED
@common_prefix_rreg_handler:
    LD (DE), A
    INC DE
    LD A, C
    CALL encode_rreg
    LD (DE), A
    INC DE
    LD C, 2
    RET
.endblock

entrypoint cc_nn_handler
.block
    LD C, A
    LD A, (HL)
    INC HL
    SUB NZ_flag
    RLCA
    RLCA
    RLCA
    ADD A, C
    LD (DE), A
    INC DE
    CALL eval_expression_HL_write_DE
    LD C, 3
    RET
.endblock

entrypoint encode_hreg
.block
    LD C, A
    LD A, (HL)
    INC HL
    SUB regs_8
    RLCA
    RLCA
    RLCA
    ADD A, C
    RET
.endblock

entrypoint encode_rreg
.block
    LD C, A
    LD A, (HL)
    INC HL
    SUB regs_16
    AND $03
    RLCA
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
