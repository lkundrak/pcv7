; Library functions

.GLOBAL _putchar
_putchar:
	push bp
	mov bp,sp
	mov al,4[bp]
        mov ah,#0x0e    ; Output character
        int #0x10
	pop bp
	ret

