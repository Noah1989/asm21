asm21.hex: *.asm
	asm80 -m Z80 -t hex asm21.asm

asm21.36864.bin: asm21.bin
	tail -c+36865 asm21.bin | head -c4096 > asm21.36864.bin

asm21.bin: *.asm
	asm80 -m Z80 -t bin asm21.asm

.PHONY: clean
clean:
	rm -vf *.bin *.lst *.hex