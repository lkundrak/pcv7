# Dev86 setup
CC = bcc
CFLAGS = -0 -Md -Ms -I -I.
LD = ld86
LDFLAGS = -0 -7 -M -t -m
AS = as86
ASFLAGS = -0 -g
START = main.o

all: boot

boot: stage2.o prf.o lo.o
	$(LD) $(LDFLAGS) -s -o $@ $^
	
clean:
	rm -f boot *.o pure
