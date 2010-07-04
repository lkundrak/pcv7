/*
 * BIOS disk driver
 */

#include "../h/param.h"
#include "../h/systm.h"
#include "../h/buf.h"
#include "../h/conf.h"
#include "../h/dir.h"
#include "../h/user.h"

struct	buf	rbdbuf;
struct	buf	bdtab;

struct chs {
	int cyl;	/* Number of tracks */
	int sec;	/* Number of sectors per track */
	int head;	/* Number of heads per track */
};

struct chs *type = NULL;
struct chs bdtypes[] = {
	/* Ordered from biggest to smallest */
	{ 80, 18, 2 },	/* 3.5" 1.44M */
	{ 40, 9, 2 },	/* 5.25" 360K */
	{ 0, 0, 0 }
};

bdstrategy(bp)
register struct buf *bp;
{
	struct chs xchs, chs;
	static int async;

	if (!(bp->b_flags & B_READ)) {
		printf ("Only READ operation supported\n");
		bp->b_flags |= B_ERROR;
		iodone (bp);
		return;
	}

	if (bp->b_flags & B_ASYNC) {
		if (!async++)
			printf ("No async READ operation supported\n");
	}

	/* XXX: could this happen at all? */
	if (bp->b_bcount != 512) {
		printf ("bcount=%d\n", bp->b_bcount);
		panic ("bad bcount");
	}

	/* Autodetect drive geometry type */
	if (!type) {
		int i = 0;
		do {
			type = &bdtypes[i++];
			if (type->cyl == 0) {
				printf ("C/H/S autodetect failed.");
				bp->b_flags |= B_ERROR;
				iodone (bp);
				return;
			}
		} while (bddread (minor(bp->b_dev), type->cyl-1,
			type->sec, type->head-1, bp->b_un.b_addr));
	}

	/* Convert linear address to a 3D one */
	chs.cyl = bp->b_blkno/(type->head*type->sec);
	chs.sec = bp->b_blkno%(type->head*type->sec);
	chs.head = chs.sec/type->sec;
	chs.sec = chs.sec%type->sec+1;

	if (bddread (minor(bp->b_dev), chs.cyl, chs.sec,
		chs.head, bp->b_un.b_addr)) {
		prdev ("Read error", bp->b_dev);
		bp->b_flags |= B_ERROR;
	}
	iodone (bp);
}

bdintr()
{
}

bdread(dev)
dev_t dev;
{
	physio(bdstrategy, &rbdbuf, dev, B_READ);
}

bbdwrite(dev)
dev_t dev;
{

	physio(bdstrategy, &rbdbuf, dev, B_WRITE);
}

/* XXX: These are useless, replace them with nulldev in bdevsw */

bdopen(dev)
dev_t dev;
{
	return nulldev (dev);
}

bdclose(dev)
dev_t dev;
{
	return nulldev (dev);
}
