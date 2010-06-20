# Dev86 setup
CC = bcc
CFLAGS = -0 -Md -Ms -I
LD = ld86
#LDFLAGS = -0 -d -M -t -m -T0x7c00
CFLAGS=-0
LDFLAGS=-0 -7
AS = as86
ASFLAGS = -0 -g
START = main.o

all: stage2

stage2.o: stage2.c
stage2: stage2.o
	$(LD) $(LDFLAGS) -s -o $@ $<
	
clean:
	rm -f stage2 *.o
