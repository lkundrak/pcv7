; Segment where kernel resides
KERNEL=0x0060

; Copy a word to kernel memory space
.GLOBAL _mtpi
_mtpi:
	push bp
	mov bp,sp
	push di
	mov ax,0x4[bp]
	mov di,0x6[bp]
	push es
	push #KERNEL
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
	push #KERNEL
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
	cmp 0x4[bp],#0
	je goodseg
	push #badseg
	call __stop
goodseg:
	pop bp
	ret

; Start executing the kernel
.GLOBAL _jumpunix
_jumpunix:
	mov ax,#KERNEL
        mov es,ax
        mov ds,ax
        mov fs,ax
        mov gs,ax
        mov ss,ax
	mov di,#0
	mov ax,[di]
	mov sp,#0xffff
	push #KERNEL
	push #0x0	; Entry point hardcoded for now
	retf

.DATA
badseg:
	.ASCII "Separate I&D not supported"
	.WORD 0x0
