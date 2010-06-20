#ifdef __BCC__

; Compiler generates references to these

.GLOBAL imodu
imodu:
        xor dx,dx
        div bx
        mov ax,dx
        ret

.GLOBAL idiv_u
idiv_u:
        xor dx,dx
        div bx
        ret

#endif /* __BCC__ */

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

