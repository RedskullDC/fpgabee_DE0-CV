## SETTINGS FOR SYNTHESIS
DEVICE			= xc3s200a-4-vq100
PROJNAME		= xulatest
INTDIR			= ./build
T80DIR			= ../t80
XULALIBDIR		= ../XuLA_lib
HDL_FILES		= \
	xulatest.vhd \
	test_rom.vhd \
	Z80RamController.vhd \
	../FPGABeeCore/vga_controller_800_60.vhd \
	../FPGABeeCore/ps2interface.vhd \
	../FPGABeeCore/KeyboardPort.vhd \
	../FPGABeeCore/StatusPanel.vhd \
	../FPGABeeCore/StatusCharRom.vhd \
	$(XULALIBDIR)/Common.vhd \
	$(XULALIBDIR)/SdramCntl.vhd \
	$(T80DIR)/T80.vhd \
	$(T80DIR)/T80_ALU.vhd \
	$(T80DIR)/T80_MCode.vhd \
	$(T80DIR)/T80_Pack.vhd \
	$(T80DIR)/T80_Reg.vhd \
	$(T80DIR)/T80se.vhd

#STARTUPCLK 		= JtagClk

include ../../tools/xilinx.mk


test_rom.vhd: test_rom.asm
	z80asm.exe -otest_rom.bin -ltest_rom.lst test_rom.asm
	python ../../tools/bin2vhdlrom.py test_rom.bin test_rom.vhd
	
