#include "../h/param.h"
#include "../h/systm.h"
#include "../h/acct.h"
#include "../h/dir.h"
#include "../h/user.h"
#include "../h/inode.h"
#include "../h/proc.h"
#include "../h/seg.h"
#include "../h/map.h"
#include "../h/reg.h"
#include "../h/buf.h"

/*
 * Icode is the octal bootstrap
 * program executed in user mode
 * to bring up the system.
 */
#ifdef PDP11
int	icode[] =
{
	0104413,	/* sys exec; init; initp */
	0000014,
	0000010,
	0000777,	/* br . */
	0000014,	/* initp: init; 0 */
	0000000,
	0062457,	/* init: </etc/init\0> */
	0061564,
	0064457,
	0064556,
	0000164,
#else
char	icode[] =
{
#include "icode.h"
#endif
};
int	szicode = sizeof(icode);

/*
 * Machine-dependent startup code
 */
startup()
{
	register i;

	maxmem = memsize ();
	i = usermem ();

	/*
	 * zero and free all of core
	 */

	for(;;) {
		if(i == maxmem)
			break;
		clearseg(i);
		mfree (coremap, 1, i);
		i++;
	}

	printf("mem = %D\n", ctob((long)maxmem));
	if(MAXMEM < maxmem)
		maxmem = MAXMEM;
	mfree(swapmap, nswap, 1);
	swplo--;
}

/*
 * set up a physical address
 * into users virtual address space.
 */
sysphys()
{
panic("no sysphys()");
#ifdef PDP11
	register i, s, d;
	register struct a {
		int	segno;
		int	size;
		int	phys;
	} *uap;

	if(!suser())
		return;
	uap = (struct a *)u.u_ap;
	i = uap->segno;
	if(i < 0 || i >= 8)
		goto bad;
	s = uap->size;
	if(s < 0 || s > 128)
		goto bad;
	d = u.u_uisd[i+8];
	if(d != 0 && (d&ABS) == 0)
		goto bad;
	u.u_uisd[i+8] = 0;
	u.u_uisa[i+8] = 0;
	if(!u.u_sep) {
		u.u_uisd[i] = 0;
		u.u_uisa[i] = 0;
	}
	if(s) {
		u.u_uisd[i+8] = ((s-1)<<8) | RW|ABS;
		u.u_uisa[i+8] = uap->phys;
		if(!u.u_sep) {
			u.u_uisa[i] = u.u_uisa[i+8];
			u.u_uisd[i] = u.u_uisd[i+8];
		}
	}
	sureg();
	return;

bad:
	u.u_error = EINVAL;
#endif
}

/*
 * Determine which clock is attached, and start it.
 * panic: no clock found
 */
#if 0
#define	CLOCK1	((physadr)0177546)
#define	CLOCK2	((physadr)0172540)
#endif
clkstart()
{
	#if 0
	lks = CLOCK1;
	if(fuiword((caddr_t)lks) == -1) {
		lks = CLOCK2;
		if(fuiword((caddr_t)lks) == -1)
			panic("no clock");
	}
	lks->r[0] = 0115;
	#endif
}

/*
 * Let a process handle a signal by simulating an interrupt
 */
sendsig(p, signo)
caddr_t p;
{
	register unsigned n;

	n = u.u_ar0[R6] - 4;
	grow(n);
	suword((caddr_t)n+2, u.u_ar0[RPS]);
	suword((caddr_t)n, u.u_ar0[R7]);
	u.u_ar0[R6] = n;
	u.u_ar0[RPS] &= ~TBIT;
	u.u_ar0[R7] = (int)p;
}

/*
 * 11/70 routine to allocate the
 * UNIBUS map and initialize for
 * a unibus device.
 * The code here and in
 * rhstart assumes that an rh on an 11/70
 * is an rh70 and contains 22 bit addressing.
 */
int	maplock;

mapalloc(bp)
register struct buf *bp;
{
panic("no mapalloc()");
#ifdef PDP11
	register i, a;

	if(cputype != 70)
		return;
	spl6();
	while(maplock&B_BUSY) {
		maplock |= B_WANTED;
		sleep((caddr_t)&maplock, PSWP+1);
	}
	maplock |= B_BUSY;
	spl0();
	bp->b_flags |= B_MAP;
	a = bp->b_xmem;
	for(i=16; i<32; i+=2)
		UBMAP->r[i+1] = a;
	for(a++; i<48; i+=2)
		UBMAP->r[i+1] = a;
	bp->b_xmem = 1;
#endif
}

mapfree(bp)
struct buf *bp;
{

	bp->b_flags &= ~B_MAP;
	if(maplock&B_WANTED)
		wakeup((caddr_t)&maplock);
	maplock = 0;
}
