CC = bcc
CFLAGS = -0 -Md -Ms -I
LD = ld86
LDFLAGS = -0 -d -M -t -m -T0x7c00
AS = as86
ASFLAGS = -0 -g
START = main.o

boot: boot.o
	$(LD) $(LDFLAGS) -o $@ $^

clean:
	-rm -f boot.o boot
