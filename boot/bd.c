#
/*
 * BIOS disk driver
 */

#include <sys/param.h>
#include <sys/inode.h>
#include "saio.h"

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

bdstrategy(io, func)
register struct iob *io;
{
	struct chs xchs, chs;

	if (func != READ) {
		_stop ("Only READ operation supported");
	}

	/* Autodetect drive geometry type */
	if (!type) {
		int i = 0;
		do {
			type = &bdtypes[i++];
			if (type->cyl == 0) {
				_stop ("C/H/S autodetect failed.");
			}
		} while (bdread (io->i_unit, type->cyl-1, type->sec, type->head-1, io->i_buf));
	}

	/* Convert linear address to a 3D one */
	chs.cyl = io->i_bn/(type->head*type->sec);
	chs.sec = io->i_bn%(type->head*type->sec);
	chs.head = chs.sec/type->sec;
	chs.sec = chs.sec%type->sec+1;

	if (bdread (io->i_unit, chs.cyl, chs.sec, chs.head, io->i_ma)) {
		_stop ("Read error.");
	}

	return(io->i_cc);
}
