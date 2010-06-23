/* This file contains the BCC compiler helper functions */
/* (C) Copyright Bruce Evans */
/* Support for long arithmetic on little-endian (normal) longs 
 */

/* Function laddl */
! laddl.s

.GLOBAL	laddl
.GLOBAL	laddul

laddl:
laddul:
	add	ax,[di]
	adc	bx,2[di]
	ret

/* Function landl */
! landl.s

.GLOBAL	landl
.GLOBAL	landul

landl:
landul:
	and	ax,[di]
	and	bx,2[di]
	ret

/* Function lcmpl */
! lcmpl.s
! lcmpl, lcmpul don`t preserve bx

.GLOBAL	lcmpl
.GLOBAL	lcmpul

lcmpl:
lcmpul:
	sub	bx,2[di]	
	je	LCMP_NOT_SURE
	ret

.EVEN

LCMP_NOT_SURE:
	cmp	ax,[di]
	jb	LCMP_B_AND_LT
	jge	LCMP_EXIT
			
	inc	bx
LCMP_EXIT:
	ret

.EVEN

LCMP_B_AND_LT:
	dec	bx
	ret

/* Function lcoml */
! lcoml.s

.GLOBAL	lcoml
.GLOBAL	lcomul

lcoml:
lcomul:
	not	ax
	not	bx
	ret

/* Function ldecl */
! ldecl.s

.GLOBAL	ldecl
.GLOBAL	ldecul

ldecl:
ldecul:
	cmp	word ptr [bx],*0
	je	LDEC_BOTH
	dec	word ptr [bx]
	ret

.EVEN

LDEC_BOTH:
	dec	word ptr [bx]
	dec	word ptr 2[bx]
	ret

/* Function ldivl */
! ldivl.s
! bx:ax / 2(di):(di), quotient bx:ax, remainder di:cx, dx not preserved

.GLOBAL	ldivl

ldivl:
	mov	cx,[di]
	mov	di,2[di]
	call	ldivmod		
	xchg	ax,cx
	xchg	bx,di
	ret


/* Function ldivul */
! ldivul.s
! unsigned bx:ax / 2(di):(di), quotient bx:ax,remainder di:cx, dx not preserved

.GLOBAL	ldivul

ldivul:
	mov	cx,[di]
	mov	di,2[di]
	call	ludivmod	
	xchg	ax,cx
	xchg	bx,di
	ret

/* Function leorl */
! leorl.s

.GLOBAL	leorl
.GLOBAL	leorul

leorl:
leorul:
	xor	ax,[di]
	xor	bx,2[di]
	ret

/* Function lincl */
! lincl.s

.GLOBAL	lincl
.GLOBAL	lincul

lincl:
lincul:
	inc	word ptr [bx]
	je	LINC_HIGH_WORD
	ret

.EVEN

LINC_HIGH_WORD:
	inc	word ptr 2[bx]
	ret

/* Function lmodl */
! lmodl.s
! bx:ax % 2(di):(di), remainder bx:ax, quotient di:cx, dx not preserved

.GLOBAL	lmodl

lmodl:
	mov	cx,[di]
	mov	di,2[di]
	call	ldivmod
	ret	

/* Function lmodul */
! lmodul.s
! unsigned bx:ax / 2(di):(di), remainder bx:ax,quotient di:cx, dx not preserved

.GLOBAL	lmodul

lmodul:
	mov	cx,[di]
	mov	di,2[di]
	call	ludivmod
	ret

/* Function lmull */
! lmull.s
! lmull, lmulul don`t preserve cx, dx

.GLOBAL	lmull
.GLOBAL	lmulul

lmull:
lmulul:
	mov	cx,ax
	mul	word ptr 2[di]
	xchg	ax,bx
	mul	word ptr [di]
	add	bx,ax
	mov	ax,ptr [di]
	mul	cx
	add	bx,dx
	ret

/* Function lnegl */
! lnegl.s

.GLOBAL	lnegl
.GLOBAL	lnegul

lnegl:
lnegul:
	neg	bx
	neg	ax
	sbb	bx,*0
	ret

/* Function lorl */
! lorl.s

.GLOBAL	lorl
.GLOBAL	lorul

lorl:
lorul:
	or	ax,[di]
	or	bx,2[di]
	ret

/* Function lsll */
! lsll.s
! lsll, lslul don`t preserve cx

.GLOBAL	lsll
.GLOBAL	lslul

lsll:
lslul:
	mov	cx,di
	jcxz	LSL_EXIT
	cmp	cx,*32
	jae	LSL_ZERO
LSL_LOOP:
	shl	ax,*1
	rcl	bx,*1
	loop	LSL_LOOP
LSL_EXIT:
	ret

.EVEN

LSL_ZERO:
	xor	ax,ax
	mov	bx,ax
	ret

/* Function lsrl */
! lsrl.s
! lsrl doesn`t preserve cx

.GLOBAL	lsrl

lsrl:
	mov	cx,di
	jcxz	LSR_EXIT
	cmp	cx,*32
	jae	LSR_SIGNBIT
LSR_LOOP:
	sar	bx,*1
	rcr	ax,*1
	loop	LSR_LOOP
LSR_EXIT:
	ret

.EVEN

LSR_SIGNBIT:
	mov	cx,*32	
	j	LSR_LOOP

/* Function lsrul */
! lsrul.s
! lsrul doesn`t preserve cx

.GLOBAL	lsrul

lsrul:
	mov	cx,di
	jcxz	LSRU_EXIT
	cmp	cx,*32
	jae	LSRU_ZERO
LSRU_LOOP:
	shr	bx,*1
	rcr	ax,*1
	loop	LSRU_LOOP
LSRU_EXIT:
	ret

.EVEN

LSRU_ZERO:
	xor	ax,ax
	mov	bx,ax
	ret

/* Function lsubl */
! lsubl.s

.GLOBAL	lsubl
.GLOBAL	lsubul

lsubl:
lsubul:
	sub	ax,[di]
	sbb	bx,2[di]
	ret

/* Function ltstl */
! ltstl.s
! ltstl, ltstul don`t preserve bx

.GLOBAL	ltstl
.GLOBAL	ltstul

ltstl:
ltstul:
	test	bx,bx
	je	LTST_NOT_SURE
	ret

.EVEN

LTST_NOT_SURE:
	test	ax,ax
	js	LTST_FIX_SIGN
	ret

.EVEN

LTST_FIX_SIGN:
	inc	bx
	ret

/* This file contains the BCC compiler helper functions */
/* (C) Copyright Bruce Evans */
/* Function ldivmod */


! ldivmod.s - 32 over 32 to 32 bit division and remainder for 8086

! ldivmod( dividend bx:ax, divisor di:cx )  [ signed quot di:cx, rem bx:ax ]
! ludivmod( dividend bx:ax, divisor di:cx ) [ unsigned quot di:cx, rem bx:ax ]

! dx is not preserved


! NB negatives are handled correctly, unlike by the processor
! divison by zero does not trap


! let dividend = a, divisor = b, quotient = q, remainder = r
!	a = b * q + r  mod 2**32
! where:

! if b = 0, q = 0 and r = a

! otherwise, q and r are uniquely determined by the requirements:
! r has the same sign as b and absolute value smaller than that of b, i.e.
!	if b > 0, then 0 <= r < b
!	if b < 0, then 0 >= r > b
! (the absoulute value and its comparison depend on signed/unsigned)

! the rule for the sign of r means that the quotient is truncated towards
! negative infinity in the usual case of a positive divisor

! if the divisor is negative, the division is done by negating a and b,
! doing the division, then negating q and r


.GLOBAL	ldivmod

ldivmod:
	mov	dx,di		! sign byte of b in dh
	mov	dl,bh		! sign byte of a in dl
	test	di,di
	jns	set_asign
	neg	di
	neg	cx
	sbb	di,*0
set_asign:
	test	bx,bx
	jns	got_signs	! leave r = a positive
	neg	bx
	neg	ax
	sbb	bx,*0
	j	got_signs

.GLOBAL	ludivmod
.EVEN

ludivmod:
	xor	dx,dx		! both sign bytes 0
got_signs:
	push	bp
	push	si
	mov	bp,sp
	push	di		! remember b
	push	cx
b0	=	-4
b16	=	-2

	test	di,di
	jne	divlarge
	test	cx,cx
	je	divzero
	cmp	bx,cx
	jae	divlarge	! would overflow
	xchg	dx,bx		! a in dx:ax, signs in bx
	div	cx
	xchg	cx,ax		! q in di:cx, junk in ax
	xchg	ax,bx		! signs in ax, junk in bx
	xchg	ax,dx		! r in ax, signs back in dx
	mov	bx,di		! r in bx:ax
	j	zdivu1

divzero:			! return q = 0 and r = a
	test	dl,dl
	jns	return
	j	negr		! a initially minus, restore it

divlarge:
	push	dx		! remember sign bytes
	mov	si,di		! w in si:dx, initially b from di:cx
	mov	dx,cx
	xor	cx,cx		! q in di:cx, initially 0
	mov	di,cx
				! r in bx:ax, initially a
				! use di:cx rather than dx:cx in order to
				! have dx free for a byte pair later
	cmp	si,bx
	jb	loop1
	ja	zdivu		! finished if b > r
	cmp	dx,ax
	ja	zdivu

! rotate w (= b) to greatest dyadic multiple of b <= r

loop1:
	shl	dx,*1		! w = 2*w
	rcl	si,*1
	jc	loop1_exit	! w was > r counting overflow (unsigned)
	cmp	si,bx		! while w <= r (unsigned)
	jb	loop1
	ja	loop1_exit
	cmp	dx,ax
	jbe	loop1		! else exit with carry clear for rcr
loop1_exit:
	rcr	si,*1
	rcr	dx,*1
loop2:
	shl	cx,*1		! q = 2*q
	rcl	di,*1
	cmp	si,bx		! if w <= r
	jb	loop2_over
	ja	loop2_test
	cmp	dx,ax
	ja	loop2_test
loop2_over:
	add	cx,*1		! q++
	adc	di,*0
	sub	ax,dx		! r = r-w
	sbb	bx,si
loop2_test:
	shr	si,*1		! w = w/2
	rcr	dx,*1
	cmp	si,b16[bp]	! while w >= b
	ja	loop2
	jb	zdivu
	cmp	dx,b0[bp]
	jae	loop2

zdivu:
	pop	dx		! sign bytes
zdivu1:
	test	dh,dh
	js	zbminus
	test	dl,dl
	jns	return		! else a initially minus, b plus
	mov	dx,ax		! -a = b * q + r ==> a = b * (-q) + (-r)
	or	dx,bx
	je	negq		! use if r = 0
	sub	ax,b0[bp]	! use a = b * (-1 - q) + (b - r)
	sbb	bx,b16[bp]
	not	cx		! q = -1 - q (same as complement)
	not	di
negr:
	neg	bx
	neg	ax
	sbb	bx,*0
return:
	mov	sp,bp
	pop	si
	pop	bp
	ret

.EVEN

zbminus:
	test	dl,dl		! (-a) = (-b) * q + r ==> a = b * q + (-r)
	js	negr		! use if initial a was minus
	mov	dx,ax		! a = (-b) * q + r ==> a = b * (-q) + r
	or	dx,bx
	je	negq		! use if r = 0
	sub	ax,b0[bp]	! use a = b * (-1 - q) + (b + r) (b is now -b)
	sbb	bx,b16[bp]
	not	cx
	not	di
	mov	sp,bp
	pop	si
	pop	bp
	ret

.EVEN

negq:
	neg	di
	neg	cx
	sbb	di,*0
	mov	sp,bp
	pop	si
	pop	bp
	ret

/* Function idiv */
! idiv.s
! idiv_ doesn`t preserve dx (returns remainder in it)

.GLOBAL idiv_

idiv_:
	cwd
	idiv	bx
	ret

/* Function idivu */
! idivu.s
! idiv_u doesn`t preserve dx (returns remainder in it)

.GLOBAL idiv_u

idiv_u:
	xor	dx,dx
	div	bx
	ret

/* Function imod */
! imod.s
! imod doesn`t preserve dx (returns quotient in it)

.GLOBAL imod

imod:
	cwd
	idiv	bx
	mov	ax,dx	
	ret

/* Function imodu */
! imodu.s
! imodu doesn`t preserve dx (returns quotient in it)

.GLOBAL imodu

imodu:
	xor	dx,dx
	div	bx
	mov	ax,dx		! instruction queue full so xchg slower
	ret

/* Function imul */
! imul.s
! imul_, imul_u don`t preserve dx

.GLOBAL imul_
.GLOBAL imul_u

imul_:
imul_u:
	imul	bx
	ret

/* Function isl */
! isl.s
! isl, islu don`t preserve cl

.GLOBAL isl
.GLOBAL islu

isl:
islu:
	mov	cl,bl
	shl	ax,cl
	ret

/* Function isr */
! isr.s
! isr doesn`t preserve cl

.GLOBAL isr

isr:
	mov	cl,bl
	sar	ax,cl
	ret

/* Function isru */
! isru.s
! isru doesn`t preserve cl

.GLOBAL isru

isru:
	mov	cl,bl
	shr	ax,cl
	ret

