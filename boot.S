.TEXT

; Memory:
;     - Interrupt vectors
; 00600 Beginning of usable RAM
; 07c00 Here we are now <--
; a0000 End of usable RAM
;     - Video RAM and BIOS


.GLOBAL _main
_main:

reset:
	mov ah,#0x0
	mov dl,#0x00	; Drive A:
	int #0x13
	jc reset

read:
	mov ah,#0x02	; Read sectors
	mov al,#0x01	; One sector
	mov ch,#0x00	; Track one
	mov cl,#0x02	; Sector two
	mov dh,#0x00	; Head zero
	mov dl,#0x00	; Drive A:
	mov bx,#0x0600	; Destination address
	int #0x13
	jc read

; This much was read
;	mov ah,#0x0e	; Output character
;	add al,#0x30
;	int #0x10

	mov cx,#5
print:
	mov ah,#0x0e	; Output character
	mov dx,#0x0605
	sub dx,cx
	push dx
	pop si
	mov al,[si]
	int #0x10
	loop print
;
;	mov al,0x7c03
;	mov al,0x7d00
;	int #0x10

lp:
	jmp lp

org 0x100
;.ascii "1"
.byte 0x31

; PC boot signature
org 0x1fe
.word 0xaa55
