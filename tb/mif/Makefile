# --------------------------------------------------
#	Compile
# --------------------------------------------------
CC			= riscv64-unknown-linux-gnu-gcc
CFLAGS		= -mabi=ilp32 -march=rv32i
SRCS		= $(wildcard *.S)

# --------------------------------------------------
#	Linking
# --------------------------------------------------
LD			= riscv64-unknown-linux-gnu-ld
LDFLAGS		= -Tlink.ld -melf32lriscv
OBJS		= $(SRCS:.S=.o)

# --------------------------------------------------
#	OBJCOPY
# --------------------------------------------------
OBJCOPY		= riscv64-unknown-linux-gnu-objcopy
SRECCAT		= srec_cat
ELFS		= $(SRCS:.S=.elf)
BINS		= $(SRCS:.S=.text.bin) $(SRCS:.S=.data.bin)
MIFS		= $(SRCS:.S=.text.mif) $(SRCS:.S=.data.mif)

all: ${MIFS}

%.o: %.S test_macros.h riscv_test.h
	${CC} -c ${CFLAGS} -o $@ $<

%.elf: %.o 
	${LD} ${LDFLAGS} $< -o $@

%.text.bin: %.elf
	${OBJCOPY} -O binary $< $@ -j .text --change-addresses -0x400000

%.data.bin: %.elf
	${OBJCOPY} -O binary $< $@ -j .data --change-addresses -0x80000000

%.mif: %.bin
	${SRECCAT} $< -binary -byte-swap 4 -O $@ -VMem 32

clean:
	rm -f ${OBJS} ${ELFS} ${BINS} ${MIFS}
