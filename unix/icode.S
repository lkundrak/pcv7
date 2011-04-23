.GLOBL _main
_main:

	mov cx,#10
pt:
	mov al,#0x61
	mov ah,#0x0e	; BIOS output character
	int #0x10
	loop pt

	mov si,#20	; Getpid
	int #0xf1
	mov si,#0	; Getpid
	int #0xf1

lp:
	hlt
	jmp lp
