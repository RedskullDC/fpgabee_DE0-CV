ifeq ($(OSTYPE),cygwin)
UBEE512_PATH=/cygdrive/z/retro/ubee512
UBEE512_EXE=$(UBEE512_PATH)/ubee512.exe
ZZ=z80asm.exe
else
UBEE512_PATH=~/.ubee512
UBEE512_EXE=gnome-terminal -x gdb --args ~/Projects/ubee512/src/build/ubee512
ZZ=z80asm
endif

all: DiskTestRom.bin MemTestRom.bin DiskTestRom.bin HddBoot.bin HeapTestRom.bin FTest.com

CrtcTestRom.bin: CrtcTestRom.asm CommonDefs.asm
	$(ZZ) -lCrtcTestRom.lst -oCrtcTestRom.bin CrtcTestRom.asm
	cp CrtcTestRom.bin $(UBEE512_PATH)/roms/

CharRomTestRom.bin: CharRomTestRom.asm CommonDefs.asm
	$(ZZ) -lCharRomTestRom.lst -oCharRomTestRom.bin CharRomTestRom.asm
	cp CharRomTestRom.bin $(UBEE512_PATH)/roms/

MemTestRom.bin: MemTestRom.asm CommonDefs.asm
	$(ZZ) -lMemTestRom.lst -oMemTestRom.bin MemTestRom.asm
	cp MemTestRom.bin $(UBEE512_PATH)/roms/

HeapTestRom.bin: HeapTestRom.asm CommonDefs.asm ../PcuBoot/Heap.asm
	$(ZZ) -lHeapTestRom.lst -oHeapTestRom.bin HeapTestRom.asm
	cp HeapTestRom.bin $(UBEE512_PATH)/roms/

DiskTestRom.bin: DiskTestRom.asm CommonDefs.asm
	$(ZZ) -lDiskTestRom.lst -oDiskTestRom.bin DiskTestRom.asm
	cp DiskTestRom.bin $(UBEE512_PATH)/roms/

HddBoot.bin: HddBoot.asm CommonDefs.asm
	$(ZZ) -lHddBoot.lst -oHddBoot.bin HddBoot.asm
	cp HddBoot.bin $(UBEE512_PATH)/roms/

FTest.com: FTest.asm CommonDefs.asm
	$(ZZ) -lFTest.lst -oFTest.com FTest.asm

run: MemTestRom.bin CrtcTestRom.bin DiskTestRom.bin HddBoot.bin CharRomTestRom.bin HeapTestRom.bin
	$(UBEE512_EXE) hdd --rom1=HeapTestRom.bin  --conio --exit-check=off --debug=on --hdd3=tmp.ds80.temp --bp=0x8025 --aspect=1

