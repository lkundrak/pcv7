# Dev86 setup
CC = bcc
CFLAGS = -0 -Md -Ms -I -I.
LD = ld86
LDFLAGS = -0 -s -i -7 #-M -t -m
AS = as86
ASFLAGS = -0 -g
START = main.o

FILES = conf/c.o pc.o
FILES += sys/malloc.o sys/prim.o sys/pipe.o sys/acct.o sys/sys1.o 
FILES += sys/clock.o sys/prf.o sys/ureg.o sys/main.o sys/text.o sys/nami.o 
FILES += sys/subr.o sys/slp.o sys/sysent.o sys/machdep.o sys/rdwri.o 
FILES += sys/sig.o sys/sys3.o sys/fio.o sys/iget.o sys/fakemx.o sys/sys2.o 
FILES += sys/sys4.o sys/trap.o sys/alloc.o
FILES += dev/bio.o dev/tty.o dev/partab.o
FILES += /home/lkundrak/src/dev86/libc/bcc/bcc_int.o /home/lkundrak/src/dev86/libc/bcc/bcc_long.o
#FILES += libc.a
#dev/dhdm.o dev/du.o dev/kl.o dev/rp.o dev/mem.o dev/rf.o dev/partab.o dev/pk3.o 
#dev/dkleave.o dev/rl.o dev/sys.o dev/pk2.o dev/dz.o dev/ht.o dev/dsort.o 
#dev/dn.o dev/rk.o dev/dh.o dev/tc.o dev/pk1.o dev/hp.o dev/cat.o dev/tty.o 
#dev/pk0.o dev/dhfdm.o dev/vp.o dev/dc.o dev/tm.o dev/mx1.o dev/mx2.o dev/vs.o 
#dev/bio.o

all: unix

libc.a: /usr/lib/bcc/libc.a
	cp $< $@

unix: $(FILES)
	$(LD) $(LDFLAGS) -s -o $@ $^

dump: clean unix
	dd if=unix bs=16 skip=1 of=pure
	objdump -m i8086 -b binary -M i8086 -D pure
	
clean:
	rm -f unix pure $(FILES)

# DO NOT DELETE This line, or makedepend will be very angry

conf/c.o: h/param.h h/systm.h h/buf.h h/tty.h h/conf.h h/proc.h h/text.h
conf/c.o: h/dir.h h/user.h h/file.h h/inode.h h/acct.h
dev/kl.o: h/param.h h/conf.h h/dir.h h/user.h h/tty.h h/systm.h
dev/rl.o: h/param.h h/buf.h h/dir.h h/user.h h/systm.h
dev/vs.o: h/types.h h/tty.h
dev/dkleave.o: h/param.h h/buf.h
dev/vp.o: h/param.h h/dir.h h/user.h h/buf.h h/systm.h
dev/dc.o: h/param.h h/conf.h h/dir.h h/user.h h/tty.h h/systm.h
dev/rf.o: h/param.h h/systm.h h/buf.h h/conf.h h/dir.h h/user.h
dev/mx2.o: h/param.h h/systm.h h/dir.h h/user.h h/proc.h h/tty.h h/inode.h
dev/mx2.o: h/mx.h h/file.h h/conf.h h/buf.h
dev/pk1.o: h/pk.p h/param.h h/dir.h h/user.h h/pk.h h/tty.h h/buf.h h/proc.h
dev/pk0.o: h/pk.p h/param.h h/dir.h h/user.h h/pk.h h/tty.h h/buf.h h/proc.h
dev/dz.o: h/param.h h/dir.h h/user.h h/tty.h
dev/rk.o: h/param.h h/systm.h h/buf.h h/conf.h h/dir.h h/user.h
dev/dhfdm.o: h/param.h h/tty.h h/conf.h
dev/hp.o: h/param.h h/systm.h h/buf.h h/conf.h h/dir.h h/user.h
dev/tty.o: h/param.h h/systm.h h/dir.h h/user.h h/tty.h h/proc.h h/mx.h
dev/tty.o: h/inode.h h/file.h h/reg.h h/conf.h
dev/dsort.o: h/param.h h/systm.h h/buf.h
dev/cat.o: h/param.h h/dir.h h/user.h h/tty.h
dev/pk3.o: h/param.h h/systm.h h/conf.h h/buf.h
dev/mem.o: h/param.h h/dir.h h/user.h h/conf.h h/seg.h
dev/ht.o: h/param.h h/systm.h h/buf.h h/conf.h h/dir.h h/file.h h/user.h
dev/dn.o: h/param.h h/dir.h h/user.h
dev/pk2.o: h/pk.p h/param.h h/dir.h h/user.h h/pk.h h/tty.h h/buf.h h/proc.h
dev/sys.o: h/param.h h/conf.h h/dir.h h/user.h h/tty.h h/proc.h
dev/dhdm.o: h/param.h h/tty.h h/conf.h
dev/mx1.o: h/param.h h/systm.h h/dir.h h/user.h h/reg.h h/proc.h h/tty.h
dev/mx1.o: h/inode.h h/mx.h h/file.h h/conf.h
dev/tc.o: h/param.h h/conf.h h/buf.h h/dir.h h/user.h
dev/dh.o: h/param.h h/conf.h h/dir.h h/user.h h/tty.h
dev/bio.o: h/param.h h/systm.h h/dir.h h/user.h h/buf.h h/conf.h h/proc.h
dev/bio.o: h/seg.h
dev/du.o: h/param.h h/systm.h h/dir.h h/user.h h/buf.h
dev/tm.o: h/param.h h/buf.h h/dir.h h/conf.h h/file.h h/user.h
dev/rp.o: h/param.h h/systm.h h/buf.h h/dir.h h/conf.h h/user.h
sys/pipe.o: h/param.h h/systm.h h/dir.h h/user.h h/inode.h h/file.h h/reg.h
sys/iget.o: h/param.h h/systm.h h/mount.h h/dir.h h/user.h h/inode.h h/ino.h
sys/iget.o: h/filsys.h h/conf.h h/buf.h
sys/malloc.o: h/param.h h/systm.h h/map.h
sys/fakemx.o: h/param.h h/dir.h h/user.h h/tty.h h/inode.h h/mx.h
sys/sys4.o: h/param.h h/systm.h h/dir.h h/user.h h/reg.h h/inode.h h/proc.h
sys/sys4.o: h/timeb.h
sys/trap.o: h/param.h h/systm.h h/dir.h h/user.h h/proc.h h/reg.h h/seg.h
sys/prim.o: h/param.h h/tty.h h/systm.h h/conf.h h/buf.h
sys/sig.o: h/param.h h/systm.h h/dir.h h/user.h h/proc.h h/inode.h h/reg.h
sys/sig.o: h/text.h h/seg.h
sys/ureg.o: h/param.h h/systm.h h/dir.h h/user.h h/proc.h h/text.h h/seg.h
sys/prf.o: h/param.h h/systm.h h/seg.h h/buf.h h/conf.h
sys/text.o: h/param.h h/systm.h h/map.h h/dir.h h/user.h h/proc.h h/text.h
sys/text.o: h/inode.h h/buf.h h/seg.h
sys/acct.o: h/param.h h/systm.h h/acct.h h/dir.h h/user.h h/inode.h h/proc.h
sys/acct.o: h/seg.h
sys/machdep.o: h/param.h h/systm.h h/acct.h h/dir.h h/user.h h/inode.h
sys/machdep.o: h/proc.h h/seg.h h/map.h h/reg.h h/buf.h
sys/slp.o: h/param.h h/systm.h h/dir.h h/user.h h/proc.h h/text.h h/map.h
sys/slp.o: h/file.h h/inode.h h/buf.h
sys/sysent.o: h/param.h h/systm.h
sys/sys1.o: h/param.h h/systm.h h/map.h h/dir.h h/user.h h/proc.h h/buf.h
sys/sys1.o: h/reg.h h/inode.h h/seg.h h/acct.h
sys/sys2.o: h/param.h h/systm.h h/dir.h h/user.h h/reg.h h/file.h h/inode.h
sys/fio.o: h/param.h h/systm.h h/dir.h h/user.h h/filsys.h h/file.h h/conf.h
sys/fio.o: h/inode.h h/reg.h h/acct.h
sys/alloc.o: h/param.h h/systm.h h/mount.h h/filsys.h h/fblk.h h/conf.h
sys/alloc.o: h/buf.h h/inode.h h/ino.h h/dir.h h/user.h
sys/rdwri.o: h/param.h h/systm.h h/inode.h h/dir.h h/user.h h/buf.h h/conf.h
sys/clock.o: h/param.h h/systm.h h/callo.h h/seg.h h/dir.h h/user.h h/proc.h
sys/clock.o: h/reg.h
sys/subr.o: h/param.h h/systm.h h/conf.h h/inode.h h/dir.h h/user.h h/buf.h
sys/nami.o: h/param.h h/systm.h h/inode.h h/mount.h h/dir.h h/user.h h/buf.h
sys/main.o: h/param.h h/systm.h h/dir.h h/user.h h/filsys.h h/mount.h h/map.h
sys/main.o: h/proc.h h/inode.h h/seg.h h/conf.h h/buf.h
sys/sys3.o: h/param.h h/systm.h h/mount.h h/ino.h h/reg.h h/buf.h h/filsys.h
sys/sys3.o: h/dir.h h/user.h h/inode.h h/file.h h/conf.h h/stat.h
