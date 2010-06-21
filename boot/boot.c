#include <sys/param.h>
#include <sys/ino.h>
#include <sys/inode.h>
#include <sys/filsys.h>
#include <sys/dir.h>
#include <saio.h>


char line[100];

main()
{
int i;
	segflag = 2;


	printf("Boot\n");
	do {
		printf(": "); gets(line);
		i = open(line,0);
	} while (i < 0);


	copyunix(i);

}


copyunix(io)
register io;
{
register addr,s;
long phys;
unsigned	txtsiz,datsiz,bsssiz;
int	magic;


	lseek(io, (off_t)0, 0);
	magic = getw(io);
	txtsiz = getw(io);
	datsiz = getw(io);
	bsssiz = getw(io);


	switch (magic) {
	case 0411:
#ifdef PDP11
		setseg(0);
#endif
		lseek(io, (long)(020+txtsiz), 0);

		for(addr=0; addr!=datsiz; addr+=2)  {
#ifdef PDP11
			mtpi(getw(io),addr);
#endif
		}

#ifdef PDP11
		clrseg(addr,bsssiz);
#endif

		phys = (long)datsiz + (long)bsssiz + 63L;
		phys =/ 64;
#ifdef PDP11
		setseg((int)phys);
#endif

		lseek(io, 020L, 0);

		for(addr=0; addr!=txtsiz; addr+=2) {
#ifdef PDP11
			mtpi(getw(io),addr);
#endif
		}
		return;
	case 0407:
#ifdef PDP11
		setseg(0);
#endif
		/*
		 * space over the header. We do this instead of seeking
		 * because the input might be a tape which doesn't know 
		 * how to seek.
		 */
		getw(io); getw(io); getw(io); getw(io);
		phys = txtsiz+datsiz;
#ifdef PDP11
		for (addr = 0; addr != phys; addr += 2)
			mtpi(getw(io),addr);
#endif
#ifdef PDP11
		clrseg(addr, bsssiz);
#endif
		return;
	default:
		printf("Can't load %o files\n", magic);
		exit(1);
	}
}
