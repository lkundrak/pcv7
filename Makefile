BCOUNT=720
QEMUFLAGS = -monitor stdio
#QEMUFLAGS = -curses -monitor /dev/tty3
SUBDIRS=mkfs v7cat stage1 stage2

all: iboot2

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

# Create the image
image:
	dd if=/dev/zero bs=512 count=$(BCOUNT) of=$@

# Create filesystem
fs: image mkfs
	(echo $(BCOUNT); echo image) |mkfs/mkfs

# Install boot block
iboot1: image stage1
	dd if=stage1/boot of=image bs=512 conv=nocreat,notrunc

# Install secondary boot loader
iboot2: fs stage2
	-mkdir mnt
	-su -c 'umount mnt'
	su -c 'mount -o loop -t v7 image mnt'
	su -c 'cp stage2/stage2 mnt/boot'
	su -c 'umount mnt'

# Once the image is bootable, we can run it
run: iboot1 iboot2
	qemu -net none -fda image $(QEMUFLAGS)

clean:
	-for S in $(SUBDIRS); do $(MAKE) -C $$S $@; done
	-rm -f image
	-su -c 'umount mnt'
	-rmdir mnt

# It's not safe to dd to a mounted filesystem
.NOTPARALLEL:
