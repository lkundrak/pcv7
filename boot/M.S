; Segment where kernel resides
KERNEL=0x0100

; Copy a word to kernel memory space
.GLOBAL _mtpi
_mtpi:
	push bp
	mov bp,sp
	push di
	mov ax,0x4[bp]
	mov di,0x6[bp]
	push es

	mov bx,curseg
	add bx,#KERNEL
	push bx
	pop es

	stosw
	pop es
	pop di
	pop bp
	ret

; Zero an area in kernel memory space
.GLOBAL _clrseg
_clrseg:
	push bp
	mov bp,sp
	push di
	mov di,0x4[bp]	; From here
	mov cx,0x6[bp]	; This many bytes
	push es

	mov bx,curseg
	add bx,#KERNEL
	push bx
	pop es

	xor al,al	; Zero out
	rep
		stosb
	pop es
	pop di
	pop bp
	ret

; Set segment for separate I&D binaries
.GLOBAL _setseg
_setseg:
	push bp
	mov bp,sp
	mov ax,0x4[bp]
	; Value is given in 64B,
	; not 16B clicks
	shl ax,#1
	shl ax,#1
	mov curseg,ax
	pop bp
	ret

; Start executing the kernel
.GLOBAL _jumpunix
_jumpunix:
	; Data segment
	mov ax,#KERNEL
	; Text segment
	mov bx,curseg
	add bx,#KERNEL
	; Set the segmentation registers appropriately
        mov es,ax
        mov ds,ax
        mov ss,ax
	mov sp,#0xffff
	push bx
	xor ax,ax
	push ax	; Entry point hardcoded for now
	retf

.GLOBAL curseg
curseg:
	.WORD 0x0
