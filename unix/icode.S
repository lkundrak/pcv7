.GLOBL _main
_main:
	mov cx,#10
pt:
	mov al,#0x61
	mov ah,#0x0e ; Output character
	int #0x10
	loop pt
lp:
	hlt
	jmp lp

