.DATA

; proc[0]'s per-process data area copy
.GLOBL _u
_u:
	.SPACE 0x0400	; 1K, USIZE * 2 * 32
stack:	; Grows downwards from per-process data area
regstage:
	.SPACE 16	; 8 general purpose regs

; Current process address (KDSA6)
.GLOBL _cpaddr
_cpaddr:
	.SPACE 2

; Kernel stack pointer
savesp:
	.SPACE 2

.TEXT

.GLOBL _start
_start:
	; Set up stack
	mov sp,#stack

	; Set up current process
	mov ax,ds
	sub ax,#0x40	; Kernel process 0's U area
	shr ax,#1
	shr ax,#1
	mov _cpaddr,ax

	; Set up interrupts
	push si		; WTF? Otherwise main() would fail -- what does compiler use this for?
	push ds

	push #0		; IVT starts at segment 0
	pop ds

	xor di,di	; CPU interrupts and IRQs start here
	mov cx,#8	; 16 of them
	mov si,#intr0	; Start with first dispatch table entry
__instintr:
	mov [di],si	; Offset
	add di,#2	; Followed by...
	mov [di],cs	; Segment
	add di,#2	; Next IVT entry
	add si,#intr1	; Next dispatch table entry...
	sub si,#intr0	; ...all have the same length
	loop __instintr

	mov 0x3c4,#intrf1 ; A system call
	mov 0x3c6,cs

	push cs
	pop ds		; We now write into CS
	pop ax		; Saved DS
	mov kds,ax	; Store it for trap handler
	mov ds,ax	; and finally restore it back
	pop si

	; Kernel initialization
	call _main
	mov savesp,sp

	; Jump into user mode
	mov si,_u+0x50	; u.u_procp
	mov ax,0x10[si]	; p.p_addr
	shl ax,#1	; clicks to segment
	shl ax,#1
	add ax,#0x040	; skip over user area
	mov es,ax
	mov ds,ax
	mov ss,ax
	push ax
	push #0x0000
	retf

; Kernel data segment. Upon trap, CPU restores just CS,
; we need to restore the rest ourselves, thus this needs to
; reside in .TEXT
kds:
	.SPACE 2

; Interrupt dispatch table
intr0:	push #0
	jmp intrh
intr1:	push #0
	jmp intrh
intr2:	push #0
	jmp intrh
intr3:	push #0
	jmp intrh
intr4:	push #0
	jmp intrh
intr5:	push #0
	jmp intrh
intr6:	push #0
	jmp intrh
intr7:	push #0
	jmp intrh
intr8:	push #0
	jmp intrh
intr9:	push #0
	jmp intrh
intra:	push #0
	jmp intrh
intrb:	push #0
	jmp intrh
intrc:	push #0
	jmp intrh
intrd:	push #0
	jmp intrh
intre:	push #0
	jmp intrh
intrf:	push #0
	jmp intrh
; A system call
intrf1:	push #6
	jmp intrh

; Pass control to C trap handling routine
intrh:
	push ax
	push cx
	push dx
	push bx
	push sp		; This is different from pusha, which would
	push bp		; push sp before "pusha" instruction. We do not care
	push si
	push di

	; Arrange for stack switch
	mov dx,ss	; Old stack
	mov si,sp

	push cs		; Read data from .text
	pop ds

	mov bx,kds	; Switch to kernel .stack & .data (so that we can read savesp)
	mov ss,bx
	mov ds,bx
	mov sp,savesp	; New stack
	push dx		; Save for recovery of the old stack (userspace SS)
	push si		; userspace SP

	mov ds,dx	; Prepare for copying stuff from old stack

	; Construct C handler's arguments stack

	push #0 	; (sp) Not used, we can not grow stack

	xor ax,ax	; (ps) argument telling whether we came from user mode
	mov bx,ss
	cmp bx,dx
	je __kmode
	mov ax,#0170000	; UMODE
__kmode:
	push ax

	mov cx,#10	; 8 registers (r0-r7),
			; trap number (dev) and a return value (pc)
savess:			; Copy userspace stack onto ours
	lodsw
	push ax
	loop savess

	; Set up the rest of segment registers for kernel mode
	mov ds,bx
	mov es,bx

	; Dispatch to C coutine
	call _trap

	mov bp,sp
	mov di,24[bp]	; Recover old stack (userspace SS)
	mov dx,26[bp]	; userspace SP

	mov es,dx	; Prepare for copying stuff back to user stack
			; trap() could have modified the registers

	std		; ...copy backwards
	add di,#18	; Stand from the end and...
	mov cx,#10	; 8 registers (r0-r7),
			; trap number (dev) and a return value (pc)
restoress:		; Copy our space into userspace one
	pop ax
	stosw
	loop restoress
	cld
	add di,#2

	mov ax,di	; Resume user stack pointer
	mov sp,ax

	mov bx,es	; Resume user segments
	mov ss,bx
	mov ds,bx

	pop di
	pop si
	pop bp
	pop sp
	pop bx
	pop dx
	pop cx
	pop ax
	add sp,#2	; Chuck trap number
	iret

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
	shl ax,#1	; Convert to a segment
	shl ax,#1
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
; from one segment to another
.GLOBL _copyseg
_copyseg:
	push bp
	mov bp,sp
	push ax	; Do we need to save all these?
	push cx
	push bx
	push di
	push si
	push ds
	push es

	; It's possible that we're copying from the current U
	; area, swap current one away just in case we need it
	mov bx,_cpaddr
	shl bx,#1	; clicks to segment
	shl bx,#1
	mov es,bx
	xor di,di	; Destination at zero
	mov si,#_u	; Source U area
	mov cx,#1024	; Size
__cuout:		; Copy
	lodsb
	stosb
	loop __cuout
	push ds
	pop es

	mov ax,0x4[bp]	; Source
	shl ax,#1	; Convert to a segment
	shl ax,#1
	;push ax
	;pop ds
	mov ds,ax

	mov ax,0x6[bp]	; Destination
	shl ax,#1	; Convert to a segment
	shl ax,#1
	;push ax
	;pop es
	mov es,ax

	xor di,di	; Start at zero
	xor si,si
	mov cx,#64	; 64 bytes
__copy:			; Copy
	lodsb
	stosb
	loop __copy

	pop es		; Resume status
	pop ds
	pop si
	pop di
	pop bx
	pop cx
	pop ax
	pop bp
	ret

; Save general purpose registers (context), all of them word-wide:
; AX, CX, DX, BX, SP, BP, SI and DI (in this "pusha" order)
; IP is saved in AX, which is the non-zero return value upon resume()
.GLOBL _save
_save:
	pop ax		; Return address
	push bx		; Save BX
	push di		; Save DI, we use it do index target
	push bp		; Save BP, used to index argument
	mov bp,sp
	mov di,0x6[bp]	; Address to save to
	mov 0x0[di],ax	; AX, A non-zero return value upon resume()
	mov 0x2[di],cx
	mov 0x4[di],dx
	add bp,#0x06	; Original SP (w/o return value)
	mov 0x8[di],bp
	pop bp		; Saved BP
	mov 0xa[di],bp
	mov 0xc[di],si
	pop bx		; Saved DI
	mov 0xe[di],bx
	pop bx		; Restore BX
	mov 0x6[di],bx
	mov di,0xe[di]	; Restore DI
	push ax		; Return address
	xor ax,ax	; Return value in saving process
	ret

; Restore general purpose registers (context), all of them word-wide:
; AX, CX, DX, BX, SP, BP, SI and DI (in this "popa" order)
.GLOBL _resume
_resume:
	pop ax		; Throw away return address, we're not returning
	pop bx		; Process address (clicks)
	pop di		; Context

	mov _cpaddr,bx
	mov ax,0x0[di]
	mov cx,0x2[di]
	mov dx,0x4[di]
	mov bx,0x6[di]
	mov sp,0x8[di]
	mov bp,0xa[di]
	mov si,0xc[di]
	mov di,0xe[di]

	jmp ax

; We potentially switch the stack here, which is the reason
; this is implemented in assembly here.
.GLOBL _sureg
_sureg:
	pop bp

	; Currently loaded process
	mov si,_u+0x50	; u.u_procp
	mov bx,0x10[si]	; p.p_addr
	shl bx,#1	; click into segment
	shl bx,#1

	; A process that should be current
	mov dx,_cpaddr
	shl dx,#1	; click into segment
	shl dx,#1

	; Not switching a process?
	cmp bx,dx
	je __nosw

	; Swap out the U area
	mov es,bx
	xor di,di	; Destination at zero
	mov si,#_u	; Source U area
	mov cx,#1024	; Size
__uout:			; Copy
	lodsb
	stosb
	loop __uout
	push ds
	pop es

	; Swap in the new U area
	mov ds,dx
	xor si,si	; Source at zero
	mov di,#_u	; Destination U area
	mov cx,#1024	; Size
__uin:			; Copy
	lodsb
	stosb
	loop __uin
	push es
	pop ds

__nosw:
	jmp bp

; Copy into current process' .data
.GLOBL _copyout
_copyout:
	push bp
	mov bp,sp
	push es
	push ax
	push cx
	push si

	; Process' data
	mov si,_u+0x50	; u.u_procp
	mov ax,0x10[si]	; p.p_addr
	shl ax,#1	; clicks to segment
	shl ax,#1
	add ax,#0x40	; skip through the U area
	mov es,ax

	mov si,0x4[bp]	; Source
	mov di,0x6[bp]	; Destination
	mov cx,0x8[bp]	; Size

__copyout:		; Copy
	lodsb
	stosb
	loop __copyout

	pop si
	pop cx
	pop ax
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
	shl ax,#1
	shl ax,#1
	shl ax,#1
	shl ax,#1
	ret

; First 64B click not occupied by kernel
.GLOBAL _usermem
_usermem:
	mov ax,cs
	add ax,#0x1000
	add ax,#0x3
	shr ax,#1
	shr ax,#1
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
