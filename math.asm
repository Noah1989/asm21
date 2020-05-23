;https://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Multiplication#16.2A8_multiplication
entrypoint mult_A_DE_result_AHL_trash_BC
.block
	LD	C, 0
	LD	H, C
	LD	L, H
	;	optimized 1st iteration
	ADD	A, A
	JR	NC, $+4
	LD	H, D
	LD	L, E
skip:
	LD	B, 7
loop:
	ADD	HL, HL
	RLA
	JR	NC, skip2
	ADD	HL, DE
	;	yes this is actually adc a, 0 but since c is free we set it to
	;	zero so we can save 1 byte and up to 3 T-states per iteration
	ADC	A, C
skip2:
	DJNZ	loop
	RET
.endblock

;http://www.cpcwiki.eu/index.php/Programming:Integer_Division#24bit_division
entrypoint div_ABC_DE_result_HL_remainder_DE_trash_AF_BC_IX_IYL
	;	IX <- divisor
.db	$dd
	LD	L, E
.db	$dd
	LD	H, D
	;	EBC <- dividend (counter)
	LD	E, A
	;	avoid dividing by zero
.db	$dd
	LD	A, L
.db	$dd
	OR	H
	RET	Z
	;	DHL = result
	LD	HL, 0
	LD	D, L
	;	IYL = counter
.db	$fd
	LD	L, 24
loop:
	RL	C
	RL	B
	RL	E
	RL	L
	RL	H
	RL	D
	;	DHL <- DHL-IX
	LD	A, L
.db	$dd
	SUB	L
	LD	L, A
	LD	A, H
.db	$dd
	SBC	A, H
	LD	H, A
	LD	A, D
	SBC	A, 0
	LD	D, A
	JR	NC, skip
	;	DHL <- DHL+IX
	LD	A, L
.db	$dd
	ADD	A, L
	LD	L, A
	LD	A, H
.db	$dd
	ADC	A, H
	LD	H, A
	LD	A, D
	ADC	A, 0
	LD	D, A
	SCF
skip:
	CCF
.db	$fd
	DEC	L
	JR	NZ, loop
	;	DE <- remainder
	EX	DE, HL
	;	HL <- quotient
	RL	C
	RL	B
	LD	L, C
	LD	H, B
	RET
