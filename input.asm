entrypoint input_key_az_result_C_zero_B
.block
loop:
	CALL ROM_GET_KEY
	JR Z, loop
	LD BC, 27
	LD HL, keys_table_end
	CPDR
	JR NZ, loop
	RET
keys_table:
	.db $76 ;ESC
	.db $1C ;A
	.db $32 ;B
	.db $21 ;C
	.db $23 ;D
	.db $24 ;E
	.db $2B ;F
	.db $34 ;G
	.db $33 ;H
	.db $43 ;I
	.db $3B ;J
	.db $42 ;K
	.db $4B ;L
	.db $3A ;M
	.db $31 ;N
	.db $44 ;O
	.db $4D ;P
	.db $15 ;Q
	.db $2D ;R
	.db $1B ;S
	.db $2C ;T
	.db $3C ;U
	.db $2A ;V
	.db $1D ;W
	.db $22 ;X
	.db $35 ;Y
keys_table_end:
	.db $1A ;Z
.endblock
