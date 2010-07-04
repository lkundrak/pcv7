.TEXT

.GLOBL _fuword
_fuword:
	mov ax,#2
	jmp ni

.GLOBL _suword
_suword:
	mov ax,#3
	jmp ni

.GLOBL _copyseg
_copyseg:
	mov ax,#4
	jmp ni

.GLOBL _fubyte
_fubyte:
	mov ax,#5
	jmp ni

.GLOBL _subyte
_subyte:
	mov ax,#6
	jmp ni

.GLOBL _display
_display:
	mov ax,#7
	jmp ni

.GLOBL _waitloc
_waitloc:
	mov ax,#8
	jmp ni

.GLOBL _addupc
_addupc:
	mov ax,#9
	jmp ni

.GLOBL _copyout
_copyout:
	mov ax,#10
	jmp ni

.GLOBL _save
_save:
	mov ax,#11
	jmp ni

.GLOBL _suibyte
_suibyte:
	mov ax,#12
	jmp ni

.GLOBL _fuibyte
_fuibyte:
	mov ax,#13
	jmp ni

.GLOBL _savfp
_savfp:
	mov ax,#14
	jmp ni

.GLOBL _resume
_resume:
	mov ax,#15
	jmp ni

.GLOBL _fuiword
_fuiword:
	mov ax,#16
	jmp ni

.GLOBL _copyiout
_copyiout:
	mov ax,#17
	jmp ni

.GLOBL _copyin
_copyin:
	mov ax,#18
	jmp ni

.GLOBL _copyiin
_copyiin:
	mov ax,#19
	jmp ni

.GLOBL _suiword
_suiword:
	mov ax,#20
	jmp ni

.GLOBL _backup
_backup:
	mov ax,#21
	jmp ni

.GLOBL _restfp
_restfp:
	mov ax,#22
	jmp ni

.GLOBL _stst
_stst:
	mov ax,#23
	jmp ni

ni:
	push #10
	push #0
	push ax
	call _printn
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

; No interrupt levels on PC, halt all
.GLOBL _spl1
_spl1:

.GLOBL _spl5
_spl5:

.GLOBL _spl7
_spl7:

.GLOBL _spl6
_spl6:
	cli
	ret

; Basically, always called with no-zero (verify!),
; and we don't have interrupt levels on PC
.GLOBL _splx
_splx:

.GLOBL _spl0
_spl0:

	sti
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

; Disk input

.GLOBAL _bddread
_bddread:
	push bp
	mov bp,sp

	mov ah,#0x02	; Read sectors
	mov al,#0x01	; One sector
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
