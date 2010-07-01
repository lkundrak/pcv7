.TEXT

.GLOBL _spl6
_spl6:

.GLOBL _splx
_splx:

.GLOBL _u
_u:

.GLOBL _fuword
_fuword:

.GLOBL _suword
_suword:

.GLOBL _copyseg
_copyseg:

.GLOBL _fubyte
_fubyte:

.GLOBL _subyte
_subyte:

.GLOBL _spl1
_spl1:

.GLOBL _spl5
_spl5:

.GLOBL _spl7
_spl7:

.GLOBL _display
_display:

.GLOBL _waitloc
_waitloc:

.GLOBL _addupc
_addupc:

.GLOBL _copyout
_copyout:

.GLOBL _save
_save:

.GLOBL _suibyte
_suibyte:

.GLOBL _fuibyte
_fuibyte:

.GLOBL _spl0
_spl0:

.GLOBL _savfp
_savfp:

.GLOBL _resume
_resume:

.GLOBL _fuiword
_fuiword:

.GLOBL _copyiout
_copyiout:

.GLOBL _copyin
_copyin:

.GLOBL _copyiin
_copyiin:

.GLOBL _suiword
_suiword:

.GLOBL _backup
_backup:

.GLOBL _restfp
_restfp:

.GLOBL _stst
_stst:

	push #eimpl
	call _panic
	ret

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
	mov ah,#0x0e	; Output character
	int #0x10
	cmp al,#0xa
	pop bp
	ret

.GLOBL _idle
_idle:
	hlt
	ret

; Clear a single 64B click
.GLOBL _clearseg
_clearseg:
	push bp
	mov bp,sp
	mov ax,0x4[bp]
	shl ax,#2	; Convert to a segment
	push es
	push ax
	pop es
	xor al,al	; Zero out
	mov cx,#64	; 64 bytes
	rep
		stosb
	pop es
	pop bp
	ret


; Supplementary

; maxmem
.GLOBAL _memsize
_memsize:
	int #0x12
	; Kbytes to 64B clicks
	shl ax,#4
	ret

; First 64B click not occupied by kernel
.GLOBAL _usermem
_usermem:
	mov ax,cs
	add ax,#0x1000
	add ax,#0x3
	shr ax,#2
	ret

.DATA

; Not used by PC
.GLOBAL _cputype
_cputype:
	.WORD 0x0

; Supplementary
.GLOBAL eimpl
eimpl:
	.ASCII "Not implemented"
	.WORD 0x0
