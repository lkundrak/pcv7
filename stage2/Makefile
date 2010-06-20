# Dev86 setup
CC = bcc
CFLAGS = -0 -Md -Ms -I
LD = ld86
CFLAGS = -0
LDFLAGS = -0 -7 -M -t -m
AS = as86
ASFLAGS = -0 -g
START = main.o

all: stage2

stage2.o: stage2.c
stage2: stage2.o prf.o lo.o
	$(LD) $(LDFLAGS) -s -o $@ $^
	
clean:
	rm -f stage2 *.o
