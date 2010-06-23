; Console I/O

.GLOBAL _putchar
_putchar:
	push bp
	mov bp,sp

	; CRLF conversion
	cmp 4[bp],#0xa
	jne __putchar
	push #0xd
	call _putchar
	add sp,#2
__putchar:

	; BIOS Teletype output
	mov al,4[bp]
        mov ah,#0x0e    ; Output character
        int #0x10
	cmp al,#0xa
	pop bp
	ret


.GLOBAL _getchar
_getchar:
	mov ah,#0x00	; Read key
	int #0x16
	xor ah,ah	; Ignore scan code
	cmp ax,#0xd	; Convert CR into \n
	jne __getchar
	mov ax,#0xa
__getchar:
	push ax
	call _putchar	; Echo
	pop ax
	ret
