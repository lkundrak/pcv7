.TEXT

.GLOBL _start
_start:
	mov sp,#stack
	; Kernel initialization
	call _main
	; Jump into user mode
	mov ax,ss
	mov es,ax
	mov ds,ax
	mov ss,ax
	mov fs,ax
	mov gs,ax
	push ax
	push #0x0400
	retf

; Not implemented

.GLOBL _fuword
_fuword:
	mov ax,#2
	jmp ni

.GLOBL _suword
_suword:
	mov ax,#3
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
	mov ax,0x4[bp]	; Destination click
	shl ax,#2	; Convert to a segment
	push es
	push ax
	pop es
	xor di,di
	xor al,al	; Zero out
	mov cx,#64	; 64 bytes
	rep
		stosb
	pop es
	pop bp
	ret

; Copy into a single single 64B click
; from current data segment
.GLOBL _copyseg
_copyseg:
	push bp
	mov bp,sp
	pusha		; Save status (we need ax & cx)
	push ds
	push es

	mov ax,0x4[bp]	; Source
	shl ax,#2	; Convert to a segment
	push ax
	pop ds

	mov ax,0x6[bp]	; Destination
	shl ax,#2	; Convert to a segment
	push ax
	pop es

	xor di,di	; Start at zero
	xor si,si
	mov cx,#64	; 64 bytes
__copy:			; Copy
	lodsb
	stosb
	loop __copy

	pop es		; Resume status
	pop ds
	popa
	pop bp
	ret

; Save general purpose registers (context), all of them word-wide:
; AX, CX, DX, BX, SP, BP, SI and DI (in this "pusha" order)
; IP is saved in AX, which is the non-zero return value upon resume()
.GLOBL _save
_save:
	cli
	pop ax		; Return value
	push bx		; Save BX
	push di		; Save DI, we use it do index target
	push bp		; Save BP, used to index argument
	mov bp,sp
	mov di,0x6[bp]	; Address to save to
	mov 0x0[di],ax	; AX, A non-zero return value upon resume()
	mov 0x2[di],cx
	mov 0x4[di],dx
	mov 0x6[di],bx
	add bp,#0x06	; Original SP (w/o return value)
	mov 0x8[di],bp
	pop bp		; Saved BP
	mov 0xa[di],bp
	mov 0xc[di],si
	pop bx		; Saved DI
	mov 0xe[di],bx
	mov di,0xe[di]	; Restore DI
	pop bx		; Restore BX
	push ax		; Return address
	xor ax,ax	; Return value in saving process
	ret

; Restore general purpose registers (context), all of them word-wide:
; AX, CX, DX, BX, SP, BP, SI and DI (in this "popa" order)
.GLOBL _resume
_resume:
	pop ax		; Throw away return address, we're not returning
	pop bx		; Process address (clicks)
	mov bp,sp
	mov di,[bp]
	shl bx,#2	; Convert to a segment
	mov ss,bx	; Switch to a new stack
	mov ax,0x0[di]
	mov cx,0x2[di]
	mov dx,0x4[di]
	mov bx,0x6[di]
	mov sp,0x8[di]
	mov bp,0xa[di]
	mov si,0xc[di]
	mov di,0xe[di]
	jmp ax

; Copy into current process' .data
.GLOBL _copyout
_copyout:
	push bp
	mov bp,sp
	push es
	pusha

	mov ax,ss
	mov es,ax

	mov si,0x4[bp]	; Source
	mov di,0x6[bp]	; Destination
	mov cx,0x8[bp]	; Size

__copyout:		; Copy
	lodsb
	stosb
	loop __copyout

	popa
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

; Beginning of current D space in clicks
.GLOBAL _curseg
_curseg:
	mov ax,ds
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

; proc[0]'s per-process data area copy
.GLOBAL u
u:
	.SPACE 0x0400	; 1K, USIZE * 2 * 32
stack:	; Grows downwards from per-process data area

; Not used by PC
.GLOBAL _cputype
_cputype:
	.WORD 0x0

; Supplementary
.GLOBAL eimpl
eimpl:
	.ASCII "Not implemented"
	.WORD 0x0
