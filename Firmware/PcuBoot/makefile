
ifeq ($(OSTYPE),cygwin)
UBEE512_PATH=/cygdrive/z/retro/ubee512
UBEE512_EXE=$(UBEE512_PATH)/ubee512.exe
ZZ=z80asm.exe
else
UBEE512_PATH=~/.ubee512
UBEE512_EXE=gnome-terminal -x gdb --args ~/Projects/ubee512/src/build/ubee512
ZZ=z80asm
endif

all: PcuBoot.bin

PcuBoot.bin: PcuBoot.asm Startup.asm Utils.asm ScanCodeTable.asm ListBox.asm Heap.asm Debug.asm Release.asm ChooseFile.asm
	$(ZZ) -lPcuBoot.lst -oPcuBoot.bin PcuBoot.asm
	cp PcuBoot.bin $(UBEE512_PATH)/roms/

run: PcuBoot.bin
	$(UBEE512_EXE) hdd --hdd1=fbfs.hd0 --hdd3=blank.ds40 --rom1=PcuBoot.bin  --conio --exit-check=off --debug=on --modio=+hdd --aspect=1 --bpr=0,0x8d89