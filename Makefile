#objdump -m i8086 -b binary -M i8086 -D --adjust-vma=0x100 boot

# Dev86 setup
CC = bcc
CFLAGS = -0 -Md -Ms -I
#-A-O
LD = ld86
LDFLAGS = -0 -d -M -t -m -T0x7c00
AS = as86
ASFLAGS = -0 -g
START = main.o
EXT = 
CPPFLAGS = -DDEBUG

run: image
	#hexdump -C image
	qemu -net none -fda $^ -monitor stdio

payload:
	echo "Hello! " >payload

image: boot payload
	cat boot payload /dev/zero |dd bs=512 count=2880 of=$@

boot$(EXT): boot.o
	$(LD) $(LDFLAGS) -o $@ $^
