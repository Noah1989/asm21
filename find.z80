; Finds the description of the bytecode in A from namelist
; Returns pointer to the name in DE
;         pointer to the parameter list in HL
;         name length in C
;         parameter count in B
; Saves   AF
entrypoint find_descr_A_ret_name_C_DE_params_B_HL
.block
    PUSH AF
    
    LD C, A
    
    ; skip ahead using the quicklist
    AND $F0
    RRCA
    RRCA
    RRCA
    LD L, A
    RRCA
    ADD A, L
    LD L, A
    LD H, msb(quicklist)
    LD B, (HL)
    INC L
    LD E, (HL)
    INC L
    LD D, (HL)
    LD HL, DE
    
    LD A, C
    SUB B
    LD B, A
    
    
loop:
    ; extract name length into C
    LD A, (HL)
    AND $0F
    LD C, A
    ; keep the same name if length is zero
    JR Z, samename
newname:
      ; update name pointer in DE to current entry
      LD DE, HL
samename:
    ; extract parameter count into A
    LD A, (HL)
    RRA
    RRA
    RRA
    RRA
    AND $0F
    ; check if this is the entry we are looking for
    DJNZ notfound
found:
    ; find the parameter list
    ; since B is zero here, BC is just the name length of this entry
    INC HL ; skip the head
    ADD HL, BC ; skip the name
    ; B is used to return the parameter count, which is in A at this point
    LD B, A
    ; DE points to the entry containing the last name found
    ; extract its name length into C
    LD A, (DE)
    AND $0F
    LD C, A
    ; now skip the head byte to let DE point to the beginning of the name
    INC DE
    ; return the original value of A for further processing
    POP AF
    RET
notfound:
    ; calculate total entry length: parameter count + name length + 1
    SCF
    ADC A, C
    ; move the entry length from A into BC, rescuing B in A
    LD C, A
    LD A, B
    LD B, 0
    ; skip to the next entry
    ADD HL, BC
    ; restore B and continue search
    LD B, A
    JR loop
.endblock