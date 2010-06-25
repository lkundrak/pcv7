#dev/dhdm.o dev/du.o dev/kl.o dev/rp.o dev/mem.o dev/rf.o dev/partab.o dev/pk3.o 
#dev/dkleave.o dev/rl.o dev/sys.o dev/pk2.o dev/dz.o dev/ht.o dev/dsort.o 
#dev/dn.o dev/rk.o dev/dh.o dev/tc.o dev/pk1.o dev/hp.o dev/cat.o dev/tty.o 
#dev/pk0.o dev/dhfdm.o dev/vp.o dev/dc.o dev/tm.o dev/mx1.o dev/mx2.o dev/vs.o 
#dev/bio.o

find -name '*.o' -delete
find -name '*.c' -not -name mkconf.c -exec bcc -0 -c -I '{}' \;
as86 -0 -o pc.o pc.S

FILES="
conf/c.o sys/malloc.o sys/prim.o sys/pipe.o sys/acct.o sys/sys1.o 
sys/clock.o sys/prf.o sys/ureg.o sys/main.o sys/text.o sys/nami.o sys/subr.o 
sys/slp.o sys/sysent.o sys/machdep.o sys/rdwri.o sys/sig.o sys/sys3.o sys/fio.o 
sys/iget.o sys/fakemx.o sys/sys2.o sys/sys4.o sys/trap.o sys/alloc.o

dev/bio.o
dev/tty.o
dev/partab.o

pc.o
/usr/lib/bcc/libc.a
"

#ld86 -0 -7 -o unix $FILES
ld86 -0 -s -7 -i -o unix $FILES

# def
true <<EOF
undefined symbol: _putchar
	./dev/kl.c
EOF

# mch
true <<EOF
undefined symbol: _spl6
undefined symbol: _splx
undefined symbol: _u
undefined symbol: _fuword
undefined symbol: _suword
undefined symbol: _copyseg
undefined symbol: _fubyte
undefined symbol: _subyte
undefined symbol: _clearseg
undefined symbol: _spl1
undefined symbol: _spl5
undefined symbol: _spl7
undefined symbol: _display
undefined symbol: _waitloc
undefined symbol: _addupc
undefined symbol: _idle
undefined symbol: _copyout
undefined symbol: _save
undefined symbol: _suibyte
undefined symbol: _fuibyte
undefined symbol: _spl0
undefined symbol: _savfp
undefined symbol: _resume
undefined symbol: _fuiword
undefined symbol: _copyiout
undefined symbol: _copyin
undefined symbol: _copyiin
undefined symbol: _suiword
undefined symbol: _backup
undefined symbol: _restfp
undefined symbol: _stst
EOF
