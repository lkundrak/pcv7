.GLOBL _main
_main:

	mov cx,#10
pt:
	mov al,#0x61
	mov ah,#0x0e ; Output character
	int #0x10
	loop pt

	mov cx,#10
sc:
	mov ax,#0x666
	mov bx,#0x777
	mov cx,#0x888
	mov dx,#0x999
	int #0xf1
	mov ax,#0x1234
	loop sc

lp:
	hlt
	jmp lp
