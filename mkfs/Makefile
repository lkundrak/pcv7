CPPFLAGS = -I. -DSTANDALONE
MKFS_H = sys/filsys.h sys/inode.h sys/param.h sys/ino.h
MKFS_H += sys/fblk.h sys/dir.h

all: mkfs

mkfs.o: mkfs.c $(MKFS_H)

clean:
	-rm -rf mkfs *.o
