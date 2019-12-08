asm21.36864.bin: asm21.bin
	tail -c+36865 asm21.bin | head -c4096 > asm21.36864.bin

asm21.bin:
	asm80 -m Z80 -t bin asm21.z80

.PHONY: clean
clean:
	rm -vf *.bin *.lst