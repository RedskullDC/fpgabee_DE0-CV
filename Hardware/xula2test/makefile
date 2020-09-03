## SETTINGS FOR SYNTHESIS
DEVICE			= xc6slx25-ftg256-2
PROJNAME		= xula2test
INTDIR			= ./build
T80DIR			= ../t80
XULALIBDIR		= ../XuLA_lib
HDL_FILES		= \
	xula2test.vhd \
	test_rom.vhd \
	../Xula2/Z80RamController.vhd \
	../Xula2/ClockCore.vhd \
	../FPGABeeCore/vga_controller_800_60.vhd \
	../FPGABeeCore/ps2interface.vhd \
	../FPGABeeCore/KeyboardPort.vhd \
	../FPGABeeCore/StatusPanel.vhd \
	../FPGABeeCore/StatusCharRom.vhd \
	../FPGABeeCore/RamSinglePort.vhd \
	$(XULALIBDIR)/Common.vhd \
	$(XULALIBDIR)/SdramCntl.vhd \
	$(T80DIR)/T80.vhd \
	$(T80DIR)/T80_ALU.vhd \
	$(T80DIR)/T80_MCode.vhd \
	$(T80DIR)/T80_Pack.vhd \
	$(T80DIR)/T80_Reg.vhd \
	$(T80DIR)/T80se.vhd

STARTUPCLK 		= JtagClk

include ../../tools/xilinx.mk


test_rom.vhd: test_rom.asm
	z80asm.exe -otest_rom.bin -ltest_rom.lst test_rom.asm
	python ../../tools/bin2vhdlrom.py test_rom.bin test_rom.vhd --addrwidth:8 --clken
	
