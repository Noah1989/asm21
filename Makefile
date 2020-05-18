program: asm21.hex
	python3 -u ~/Documents/GitHub/memload/loader.py asm21.hex

asm21.hex: *.asm
	asm80 -m Z80 -t hex asm21.asm

clean:
	rm -vf *.bin *.lst *.hex

.PHONY: clean program
