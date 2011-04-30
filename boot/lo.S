; Console I/O

.GLOBAL _putchar
_putchar:
	push bp
	mov bp,sp

	; CRLF conversion
	cmp 4[bp],#0xa
	jne __putchar
	mov ax,#0xd
	push ax
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

; Disk input

.GLOBAL _bdread
_bdread:
	push bp
	mov bp,sp

        mov ah,#0x02    ; Read sectors
        mov al,#0x01    ; One sector
	mov dl,4[bp]	; Unit number
	mov ch,6[bp]	; Track
	mov cl,8[bp]	; Sector
	mov dh,10[bp]	; Head
        mov bx,12[bp]	; Destination address

	int #0x13

	jc __bdread	; Short read?
	xor ax,ax
	pop bp
	ret
__bdread:
	mov ax,#1
	pop bp
	ret

; Utility

.GLOBAL __rtt
__rtt:
	hlt
	jmp __rtt
