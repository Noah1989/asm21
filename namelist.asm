; The assembler stores the source as bytecode.
; Each byte in the source corresponds to a single token.
; This list consists of entries that describe each possible bytecode token.
; These descriptions are used by the interactive source editor
; for printing and editing the source in a human-readable way.
; Not all bytecode tokens are valid source, some of them are placeholders
; for a choice among multiple possible tokens or an expression.

; The table starts at one, zero is not a valid bytecode token.
; Zero bytes in the source are ignored to allow fragmentation while editing.
last := 0

; This is a small hash table that allows skipping ahead in the list
debug_align $100
.align $100; for quick lookup
quicklist:
.db 0
.dw namelist
quicklist_next := $
.org quicklist + 48

namelist:
; Each entry consists of a name and a list of parameters
; The name is a variable length string
; The parameter list consists of references to other tokens.
; Entry format:
; - Byte 0, bit 0-3: name length
; - Byte 0, bit 4-7: parameter count
; - Name string
; - Parameter list (one byte each)
; Note that the total entry length can be derived from byte 0.
; A name length of zero implies the same name as the previous entry.
; Note that parameterless entries are just pascal-style strings.

; The interpretation of a parameter depends on the type of the described token
; as well as the type of the token referred to in the parameter.
; The token type can be derived from the token byte
; since all tokens are sorted by type:

; # Fixed tokens: fully specified by recursively traversing the parameter lists
; +-- Instructions:
; |     Parameter list contains instruction operands.
; |     Operands can be registers, indirect memory, flags, RST addresses
; |     as well as placeholders
; +-- Registers:
; |     No parameters
; +-- Indirect memory:
; |     Parameter specifies expression type if required.
; +-- Flags:
; |     No parameters.
; '-- RST addresses:
;       No parameters.

; # Placeholder tokens: require tokens to be consumed from source to specify
; +-- Choices:
; |     Fully specified using a single token consumed from source.
; |     Parameter list enumerates all valid tokens.
; '-- Expression placeholders
;       Fully specified using a variable length expression from source.
;       There are different expression placeholders depending on the
;       width and signedness of the required value.
;       No parameters.
;
; TODO: Lables, Comments, Indents...
;
; # Expression building blocks
; +-- Expression primitives:
; |     Are used to build expressions, might consume data from source.
; |     No parameters.
; '-- Data
;       16 tokens to encode 4 bits of data per byte

; ****************************************************************************
; *                                                                          *
; * Now prepare yourself for some serious macro abuse. You have been warned. *
; *                                                                          *
; ****************************************************************************

; This abomination is used to generate the list entries.
.macro entry, token, name, params
token equ last+1
head := $
.org head+1
start := $
db name
nlen := $-start
start := $
db params
plen := $-start
tail := $
.if nlen?>15
.error name too long at token
.endif
.if plen?>15
.error params too long at token
.endif
.org head
db nlen+plen*$10
.if nlen?>0
nlast := last
nhead := head
.endif
.if (token % 16) = 0
.org quicklist_next
.db nlast
.dw nhead
quicklist_next := $
.endif
.org tail
last := token
.endm

; Instructions:
; There is one token for each variant of each instruction.
; This syntax is more verbose than the official mnemonics.
; Operands are always specified,
; even if they are technically implied by the instruction itself.
instructions equ last+1

instr_ld8 equ last+1
entry LD_r_n,    "LD", {r_choice, n_const}
entry LD_r_r,      "", {r_choice, r_choice}
entry LD_r_iHL,    "", {r_choice, HL_ind}
entry LD_r_iri,    "", {r_choice, ri_ind_choice}
entry LD_A_inn,    "", {A_reg, nn_ind}
entry LD_A_iBC,    "", {A_reg, BC_ind}
entry LD_A_iDE,    "", {A_reg, DE_ind}
entry LD_A_I,      "", {A_reg, I_reg}
entry LD_A_R,      "", {A_reg, R_reg}
entry LD_iHL_n,    "", {HL_ind, n_const}
entry LD_iHL_r,    "", {HL_ind, r_choice}
entry LD_iri_n,    "", {ri_ind_choice, n_const}
entry LD_iri_r,    "", {ri_ind_choice, r_choice}
entry LD_inn_A,    "", {nn_ind, A_reg}
entry LD_iBC_A,    "", {BC_ind, A_reg}
entry LD_iDE_A,    "", {DE_ind, A_reg}
entry LD_I_A,      "", {I_reg, A_reg}
entry LD_R_A,      "", {R_reg, A_reg}

instr_ld16 equ last+1
entry LD_rr_nn,    "", {rr_choice, nn_const}
entry LD_rr_inn,   "", {rr_choice, nn_ind}
entry LD_ri_nn,    "", {ri_choice, nn_const}
entry LD_ri_inn,   "", {ri_choice, nn_ind}
entry LD_SP_HL,    "", {SP_reg, HL_reg}
entry LD_SP_ri,    "", {SP_reg, ri_choice}
entry LD_inn_rr,   "", {nn_ind, rr_choice}
entry LD_inn_ri,   "", {nn_ind, ri_choice}
entry POP_rp,   "POP", {rp_choice}
entry POP_ri,      "", {ri_choice}
entry PUSH_rp, "PUSH", {rp_choice}
entry PUSH_ri,     "", {ri_choice}
entry EX_AF,     "EX", {AF_reg, AF_alt}
entry EX_DE_HL,    "", {DE_reg, HL_reg}
entry EX_iSP_HL,   "", {SP_ind, HL_reg}
entry EX_iSP_ri,   "", {SP_ind, ri_choice}
entry EXX_,     "EXX", {BC_reg, DE_reg, HL_reg, BC_alt, DE_alt, HL_alt}

instr_arith8 equ last+1
entry ADD_A_n,  "ADD", {A_reg, n_const}
entry ADD_A_r,     "", {A_reg, r_choice}
entry ADD_A_iHL,   "", {A_reg, HL_ind}
entry ADD_A_iri,   "", {A_reg, ri_ind_choice}
entry ADC_A_n,  "ADC", {A_reg, n_const}
entry ADC_A_r,     "", {A_reg, r_choice}
entry ADC_A_iHL,   "", {A_reg, HL_ind}
entry ADC_A_iri,   "", {A_reg, ri_ind_choice}
entry SUB_A_n,  "SUB", {A_reg, n_const}
entry SUB_A_r,     "", {A_reg, r_choice}
entry SUB_A_iHL,   "", {A_reg, HL_ind}
entry SUB_A_iri,   "", {A_reg, ri_ind_choice}
entry SBC_A_n,  "SBC", {A_reg, n_const}
entry SBC_A_r,     "", {A_reg, r_choice}
entry SBC_A_iHL,   "", {A_reg, HL_ind}
entry SBC_A_iri,   "", {A_reg, ri_ind_choice}
entry CP_A_n,    "CP", {A_reg, n_const}
entry CP_A_r,      "", {A_reg, r_choice}
entry CP_A_iHL,    "", {A_reg, HL_ind}
entry CP_A_iri,    "", {A_reg, ri_ind_choice}
entry NEG_,     "NEG", {A_reg}
entry DAA_,     "DAA", {A_reg}

instr_arith16 equ last+1
entry ADD_HL_rr,"ADD", {HL_reg, rr_choice}
entry ADD_IX_rx,   "", {IX_reg, rx_choice}
entry ADD_IY_ry,   "", {IY_reg, ry_choice}
entry ADC_HL_rr,"ADC", {HL_reg, rr_choice}
entry SBC_HL_rr,"SBC", {HL_reg, rr_choice}

instr_decinc equ last+1
entry DEC_r,    "DEC", {r_choice}
entry DEC_iHl,     "", {HL_ind}
entry DEC_iri,     "", {ri_ind_choice}
entry DEC_rr,      "", {rr_choice}
entry DEC_ri,      "", {ri_choice}
entry INC_r,    "INC", {r_choice}
entry INC_iHL,     "", {HL_ind}
entry INC_iri,     "", {ri_ind_choice}
entry INC_rr,      "", {rr_choice}
entry INC_ri,      "", {ri_choice}

instr_logic equ last+1
entry AND_A_n,  "AND", {A_reg, n_const}
entry AND_A_r,     "", {A_reg, r_choice}
entry AND_A_iHL,   "", {A_reg, HL_ind}
entry AND_A_iri,   "", {A_reg, ri_ind_choice}
entry OR_A_n,    "OR", {A_reg, n_const}
entry OR_A_r,      "", {A_reg, r_choice}
entry OR_A_iHL,    "", {A_reg, HL_ind}
entry OR_A_iri,    "", {A_reg, ri_ind_choice}
entry XOR_A_n,  "XOR", {A_reg, n_const}
entry XOR_A_r,     "", {A_reg, r_choice}
entry XOR_A_iHL,   "", {A_reg, HL_ind}
entry XOR_A_iri,   "", {A_reg, ri_ind_choice}
entry CPL_,     "CPL", {A_reg}

instr_bits equ last+1
entry BIT_b_r,  "BIT", {b_const, r_choice}
entry BIT_b_iHL,   "", {b_const, HL_ind}
entry BIT_b_iri,   "", {b_const, ri_ind_choice}
entry RES_b_r,  "RES", {b_const, r_choice}
entry RES_b_iHL,   "", {b_const, HL_ind}
entry RES_b_iri,   "", {b_const, ri_ind_choice}
entry SET_b_r,  "SET", {b_const, r_choice}
entry SET_b_iHL,   "", {b_const, HL_ind}
entry SET_b_iri,   "", {b_const, ri_ind_choice}

instr_rotate equ last+1
entry RL_r,      "RL", {r_choice}
entry RL_iHL,      "", {HL_ind}
entry RL_iri,      "", {ri_ind_choice}
entry RLA_,     "RLA", {A_reg}
entry RLC_r,    "RLC", {r_choice}
entry RLC_iHL,     "", {HL_ind}
entry RLC_iri,     "", {ri_ind_choice}
entry RLCA_,   "RLCA", {A_reg}
entry RLD_,     "RLD", {A_reg, HL_ind}
entry RR_r,      "RR", {r_choice}
entry RR_iHL,      "", {HL_ind}
entry RR_iri,      "", {ri_ind_choice}
entry RRA_,     "RRA", {A_reg}
entry RRC_r,    "RRC", {r_choice}
entry RRC_iHL,     "", {HL_ind}
entry RRC_iri,     "", {ri_ind_choice}
entry RRCA_,   "RRCA", {A_reg}
entry RRD_,     "RRD", {A_reg, HL_ind}

instr_shift equ last+1
entry SLA_r,    "SLA", {r_choice}
entry SLA_iHL,     "", {HL_ind}
entry SLA_iri,     "", {ri_ind_choice}
entry SRA_r,    "SRA", {r_choice}
entry SRA_iHL,     "", {HL_ind}
entry SRA_iri,     "", {ri_ind_choice}
entry SRL_r,    "SRL", {r_choice}
entry SRL_iHL,     "", {HL_ind}
entry SRL_iri,     "", {ri_ind_choice}

instr_jump equ last+1
entry JR_d,      "JR", {d_const}
entry JR_cr_d,     "", {cr_choice, d_const}
entry DJNZ_,   "DJNZ", {B_reg, d_const}
entry JP_nn,     "JP", {nn_const}
entry JP_cc_nn,    "", {cc_choice, nn_const}
entry JP_HL,       "", {HL_reg}
entry JP_ri,       "", {ri_choice}
entry CALL_nn, "CALL", {nn_const}
entry CALL_cc_nn,  "", {cc_choice, nn_const}
entry RET_,     "RET", {}
entry RET_cc,      "", {cc_choice}
entry RETI_,   "RETI", {}
entry RETN_,   "RETN", {}
entry RST_,     "RST", {p_choice}

instr_block equ last+1
entry LDD_,     "LDD", {DE_ind, HL_ind, BC_reg}
entry LDDR_,   "LDDR", {DE_ind, HL_ind, BC_reg}
entry LDI_,     "LDI", {DE_ind, HL_ind, BC_reg}
entry LDIR_,   "LDIR", {DE_ind, HL_ind, BC_reg}
entry CPD_,     "CPD", {A_reg, HL_ind, BC_reg}
entry CPDR_,   "CPDR", {A_reg, HL_ind, BC_reg}
entry CPI_,     "CPI", {A_reg, HL_ind, BC_reg}
entry CPIR_,   "CPIR", {A_reg, HL_ind, BC_reg}
entry IND_,     "IND", {HL_ind, C_reg, B_reg}
entry INDR_,   "INDR", {HL_ind, C_reg, B_reg}
entry INI_,     "INI", {HL_ind, C_reg, B_reg}
entry INIR_,   "INIR", {HL_ind, C_reg, B_reg}
entry OUTD_,   "OUTD", {C_reg, HL_ind, B_reg}
entry OTDR_,   "OTDR", {C_reg, HL_ind, B_reg}
entry OUTI_,   "OUTI", {C_reg, HL_ind, B_reg}
entry OTIR_,   "OTIR", {C_reg, HL_ind, B_reg}

instr_io equ last+1
entry IN_A_n,    "IN", {A_reg, n_const}
entry IN_r_C,      "", {r_choice, C_reg}
entry OUT_n_A,  "OUT", {n_const, A_reg}
entry OUT_C_r,     "", {C_reg, r_choice}

instr_misc equ last+1
entry HALT_,   "HALT", {}
entry NOP_,     "NOP", {}
entry SCF_,     "SCF", {}
entry CCF_,     "CCF", {}
entry DI_,       "DI", {}
entry EI_,       "EI", {}
entry IM_0,      "IM", {dat_0}
entry IM_1,        "", {dat_1}
entry IM_2,        "", {dat_2}

last_instruction equ last

; tokens below do not need a space after the name when printing
nospace equ last+1

; pseudo-instructions
pseudo_instructions equ last+1
entry origin,    "@", {nn_const}
entry label,     ".", {n_const, text}
entry define,    ":", {n_const, text, expr}
entry data,      "'", {expr}
entry comment,   "!", {text}
entry empty,     " ", {}
entry end_,       "", {}

; All tokens above introduce a new line in the source listing, tokens below do not.
inlines equ last+1

; 8-bit registers:
; The order is chosen in such a way that the machine code encoding
; can be calculated by subtracting 8bit_regs and taking the last three bits.
regs_8 equ last+1
entry B_reg, "B", {} ; 000
entry C_reg, "C", {} ; 001
entry D_reg, "D", {} ; 010
entry E_reg, "E", {} ; 011
entry H_reg, "H", {} ; 100
entry L_reg, "L", {} ; 101
entry I_reg, "I", {} ;(110)
entry A_reg, "A", {} ; 111
entry R_reg, "R", {} ;(000)

; 16-bit registers:
; The order is chosen in such a way that the machine code encoding
; can be calculated by subtracting 16bit_regs and taking the last two bits.
regs_16 equ last+1
entry BC_reg, "BC",  {} ; 00
entry DE_reg, "DE",  {} ; 01
entry HL_reg, "HL",  {} ; 10
entry SP_reg, "SP",  {} ; 11
entry BC_alt, "BC'", {} ;(00)
entry DE_alt, "DE'", {} ;(01)
entry IX_reg, "IX",  {} ; 10
entry AF_reg, "AF",  {} ; 11
entry AF_alt, "AF'", {} ;(00)
entry HL_alt, "HL'", {} ;(01)
entry IY_reg, "IY",  {} ; 10

; Indirect memory access:
entry BC_ind, "(BC)", {}
entry DE_ind, "(DE)", {}
entry HL_ind, "(HL)", {}
entry SP_ind, "(SP)", {}
entry IX_ind, "(IX+d)", {d_const}
entry IY_ind, "(IY+d)", {d_const}
entry nn_ind, "(nn)", {nn_const}

; RST program addresses
entry p00, "$00", {}
entry p08, "$08", {}
entry p10, "$10", {}
entry p18, "$18", {}
entry p20, "$20", {}
entry p28, "$28", {}
entry p30, "$30", {}
entry p38, "$38", {}

; Flags for jump conditions
flags equ last+1
entry NZ_flag, "NZ", {} ; 000 / 00
entry  Z_flag,  "Z", {} ; 001 / 01
entry NC_flag, "NC", {} ; 010 / 10
entry  C_flag,  "C", {} ; 011 / 11
entry PO_flag, "PO", {} ; 100
entry PE_flag, "PE", {} ; 101
entry  P_flag,  "P", {} ; 110
entry  M_flag,  "M", {} ; 111

; Expression primitives:
expression_primitives equ last+1
entry math_op1,   "m", {h_const, expr}
entry math_op2,   "M", {h_const, expr, expr}
entry dec_number, "#", {digits}
entry bin_number, "%", {digits}
entry reference,  "*", {n_const} ; resolve label/define
entry terminator, ";", {}
entry alignment,  $1A, {h_const}

placeholders equ last+1

; Choice placeholders:
; These mark a place where a token needs to be provided from the source.
; The parameters specify which token types are valid.
entry r_choice,             "r", {A_reg, B_reg, C_reg, D_reg, E_reg, H_reg, L_reg}
entry rr_choice,           "rr", {BC_reg, DE_reg, HL_reg, SP_reg}
entry rx_choice,             "", {BC_reg, DE_reg, IX_reg, SP_reg}
entry ry_choice,             "", {BC_reg, DE_reg, IY_reg, SP_reg}
entry rp_choice,             "", {AF_reg, BC_reg, DE_reg, HL_reg}
entry ri_choice,         "IX/Y", {IX_reg, IY_reg}
entry ri_ind_choice, "(IX/Y+d)", {IX_ind, IY_ind}
entry cc_choice,           "cc", {NZ_flag, Z_flag, NC_flag, C_flag, PO_flag, PE_flag, P_Flag, M_Flag}
entry cr_choice,             "", {NZ_flag, Z_flag, NC_flag, C_flag}
entry p_choice,             "p", {p00, p08, p10, p18, p20, p28, p30, p38}

; Expression placeholders:
; These mark a place where an expression needs to be provided from the source,
; and how it will be interpreted.
entry expr,      "e", {b_const, h_const, d_const, n_const, nn_const, text, digits}
entry b_const,   "b", {} ; bit number, truncate to 0..7
entry h_const,   "h", {} ; half byte, truncate to $0..$F
; placeholders below require multiple data bytes from source
entry d_const,   "d", {} ; displacement, truncate to -128..+127 for index registers, calculate relative address for jumps
entry n_const,   "n", {} ; 8-bit const, truncate to $00..$FF
entry nn_const, "nn", {} ; 16-bit const, truncate to $0000..$FFFF
; these even have variable data length
entry text,       34, {text} ; even number of data tokens
entry digits,    "$", {digits} ; hex number if not specified otherwise
hex_number equ digits

; These tokens encode data.
; - as part of expressions in the source:
;   - hexadecimal numbers use one byte $F0..$FF per digit
;   - decimal numbers use one byte $F0..$F9 per digit
;   - binary numbers use one byte $F0/$F1 per digit
;   - strings use two bytes $F0..$FF per character
;   - one byte is used to encode the operator type for math
; - comments are encoded like expression strings
dat_nibbles equ last+1
entry dat_0, "0", {}
entry dat_1, "1", {}
entry dat_2, "2", {}
entry dat_3, "3", {}
entry dat_4, "4", {}
entry dat_5, "5", {}
entry dat_6, "6", {}
entry dat_7, "7", {}
entry dat_8, "8", {}
entry dat_9, "9", {}
entry dat_A, "A", {}
entry dat_B, "B", {}
entry dat_C, "C", {}
entry dat_D, "D", {}
entry dat_E, "E", {}
entry dat_F, "F", {}


.if last?<$FF
.error not enough entries
.endif
.if last?>$FF
.error too many entries
.endif
