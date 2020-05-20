keys_esc:
	.db $76 ;ESC
keys_a:
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
keys_z:
	.db $1A ;Z
keys_up:
	.db $75 ;up
keys_down:
	.db $72 ;down

input_handlers:
	.db 27
	.dw keys_z
	.dw 0; TODO menu_input
	.db 2
	.dw keys_down
	.dw 0; TODO cursor_updown
	.db 0
