timekeeper_hours   equ $7FFB
timekeeper_minutes equ $7FFA
timekeeper_seconds equ $7FF9

entrypoint clock
.block
	LD	A, 71
	OUT	gaddr_l, A
	LD	A, 29
	OUT	gaddr_h, A
	LD	A, (timekeeper_hours)
	CALL	ROM_PRINT_BYTE
	LD	A, ':'
	OUT	chars_io, A
	LD	A, (timekeeper_minutes)
	CALL	ROM_PRINT_BYTE
	LD	A, ':'
	OUT	chars_io, A
	LD	A, (timekeeper_seconds)
	CALL	ROM_PRINT_BYTE
	RET
.endblock
