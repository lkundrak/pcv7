# Dev86 setup
CC = bcc
CFLAGS = -0 -Md -Ms -I -I.
LD = ld86
LDFLAGS = -0 -7 #-M -t -m
AS = as86
ASFLAGS = -0 -g
START = main.o

all: boot

boot: boot.o prf.o SYS.o conf.o bcc.o l3.o atol.o lo.o bd.o
	$(LD) $(LDFLAGS) -s -o $@ $^

dump: clean boot
	dd if=boot bs=16 skip=1 of=pure
	objdump -m i8086 -b binary -M i8086 -D pure
	
clean:
	rm -f boot *.o pure
