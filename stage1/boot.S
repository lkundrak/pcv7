; First stage boot loader for PC that loads an OMAGIC "impure a.out"
; second stage boot from a floppy with little-endian Seventh Edition UNIX
; filesystem.

; DISCLAIMER: This is the first piece of 8086 assembly longer than a fours
; lines inline in C I've written; I beg your pardon if it's ugly.
; I attempted to comments parts that would not be obvious to me heavily,
; so that I could read it myself in a week or so. Consequently, the whole
; source is commented.

; Written by Lubomir Rintel <lkundrak@v3.sk>

; Memory:
;     - Interrupt vectors
; 00600 inode (second stage loads kernel here)
; 00800 (Single) indirect block
; 00a00 file data blocks
; 07c00 This boot sector code
; 0ffff Top of our stack
; 10600 We'l relocate the second stage bootstrap here
; 205ff Top of second stage stack
; a0000 End of usable RAM
;     - Video RAM and BIOS

STAGE2=0x1060

.GLOBAL _main
_main:
	mov sp,#0xffff

reset:
	mov ah,#0x0
	mov dl,#0x00	; Drive A:
	int #0x13
	jc reset

; Detect floppy type,
; Make fdtype pointer into 3-byte entry in fdtable array

	mov si,#fdtable
fddetect:
	mov ah,#0x02	; Read sectors
	mov al,#0x01	; One sector
	mov dl,#0x00	; Drive A:
	mov bx,#0x0600	; Destination address
	mov ch,[si]	; Track
	mov cl,1[si]	; Sector
	inc cl
	mov dh,2[si]	; Head
	int #0x13
	jnc done
	add si,#3	; Next fdtable entry
	cmp si,#fdtend	; Last one?
	je error	; Error out
	jmp fddetect
done:
	mov fdtype,si

; Read /
	mov ax,#2
	call readfile

; Find a 'boot' directory entry
	; Directory needs to be a multiply 16-byte long
	and bl,#0xf0
	; Beginning of directory
	mov si,#0x0a00
direntry:
	cmp bx,#0x00	; Last block?
	je error	; ENOENT
	cmp [si],#0x0000 ; Unused entry
	je dirnext

;	cmp 2[si],#0x4f43 ; 'C'
;	je dirfound

;	cmp 2[si],#0x6e75 ; 'nu'
	cmp 2[si],#0x6f62 ; 'ob'
	jne dirnext
;	cmp 4[si],#0x7869 ; 'xi'
	cmp 4[si],#0x746f ; 'to'
	jne dirnext
	cmp 6[si],#0x00
	jne dirnext
	jmp dirfound
dirnext:
	add si,#0x10
	sub bx,#0x10
	jmp direntry	; Next block
dirfound:

; Read /boot
	mov ax,[si]	; Inode number
	call readfile

; Relocate it
	mov cx,bx	; This many bytes
	sub cx,#0x10	; Sans the header
	mov si,#0x0a10	; From here
	mov di,#0x0
	mov ax,#STAGE2	; To here
	mov es,ax
copyboot:
	lodsb
	stosb
	loop copyboot

; Entry point
	mov bx,0x0a0a
; Pass control to the newly loaded loaded kernel
	mov ax,#0x00a1
	mov ds,ax
	mov ax,#STAGE2
	mov ds,ax
	mov fs,ax
	mov gs,ax
	mov ss,ax
	push ax
	push bx
	retf

; Error
error:
	mov ah,#0x0e	; Output character
	mov al,#0x21
	int #0x10

; Stop the CPU
lp:
	hlt
	jmp lp


; Given inode number, read the contents
; of the file

readfile:
; AX <= inode
; BX => file size
; 0xa00 => read file
	call iread	; Load the inode and indirect block
	mov cx,bx	; File length in bytes
	cmp cx,#0
	je empty	; Zero-length file
	dec cx
	shr cx,#9	; Translate bytes to blocks
	inc cx		; This many blocks

	xor dx,dx	; Start from block zero
blk:
	call rmblk
	inc dx
	loop blk	; Next block
empty:
	ret

; Read a single file block

; AX <= inode offset
; DX <= block number
; AX => preserved
; CX => preserved
; 0x0a00 + DX * 512 => read block
rmblk:
	pusha

	; Inode block map
	mov si,#0x060c
	add si,ax

	; XXX: temporarily shield against overwriting ourselves when reading big files
	; 0x7c00 - 0x0a00 = 57
	cmp dx,#57
	jl sizeok
	mov dx,#57
sizeok:
	; Save the absolute block number, before possible
	; indirection. Later popped into di
	push dx

	; Only single indirection is supported,
	; no more than 179 blocks can be addressed
	cmp dx,#179
	jg error

	; Direct block
	cmp dx,#10
	jl direct

	; Single indirection
	mov si,#0x0800	; Block offset is relative to indirect block now
	sub dx,#10
	; four-byte entries in indirect block!?
	add si,dx

direct:	
	; A three-byte address (?)
	add si,dx
	add si,dx
	add si,dx
	mov ax,[si]

	; Destination address
	pop di
	shl di,#0x09
	add di,#0x0a00

	; Do the read
	call lbaread
	popa
	ret

; Read file metadata -- the inode
; and a single indirect block if necessary

; AX <= inode number
; AX => offset from dest
; BX => file length
; dest => 0x600
iread:
	; Skip through boot record and super block
	; (skip this much inode-sized 64-byte chunks)
	add ax,#0x0f
	push ax
	; Block number
	shr ax,3

	mov di,#0x0600
	call lbaread

	; Inode offset from start of block
	pop ax
	and ax,#0x7
	shl ax,#6

	; File length
	mov si,#0x0608
	add si,ax
	mov bx,[si]

	; File without indirect blocks
	cmp bx,#1400
	jle short

	; Single indirection
	pusha
	add di,ax
	mov ax,42[di]	; 10th 3-byte address in inode
	mov di,#0x0800	; Indirect block is loaded here
	call lbaread
	popa

short:
	ret

; Translate LBA address to CHS coordinates and read the
; block from disk into memoty.

; AX <= logical block number
; dest => di
lbaread:
	mov si, fdtype

	; Calculate the CHS address
	mov dl,1[si]	; Sectors per track
	inc dl
	div dl
	mov cl,ah	; Sector
        inc cl          ; Numbered from 1
	xor ah,ah
	mov dl,2[si]	; Heads
	inc dl
	div dl
	mov ch,al	; Track
	mov dh,ah	; Head

read:
	mov ah,#0x02	; Read sectors
	mov al,#0x01	; One sector
	mov dl,#0x00	; Drive A:
	mov bx,di	; Destination address

	int #0x13
	jc read		; Retry

	ret

; Floppy type autodetection
; Pre-XT BIOSes were not able to tell us geometry of a floppy, since
; INT 0x13/0x08 was only provided by the hard drive BIOS. We, who use LBA
; are doomed to guess here. Only a handful of formats is supported, so that
; we do not waste space. Maybe an installboot program could fill an entry
; here. A good reference of floppy formats:
; http://support.microsoft.com/kb/75131

; From biggest to smallest
;	Maximum track number
;	Maximum sector number
;	Maximum head number
fdtype: .byte 0
fdtable:
; 3.5" 1,44M
.byte 79
.byte 17
.byte 1
; 5.25" 360K
.byte 39
.byte 8
.byte 1
fdtend:

; PC boot signature
org 0x1fe
.word 0xaa55
