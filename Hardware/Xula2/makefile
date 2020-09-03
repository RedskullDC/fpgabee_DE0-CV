## SETTINGS FOR SYNTHESIS
DEVICE			= xc6slx25-ftg256-2
PROJNAME		= FpgaBee_Xula2
INTDIR			= ./build
T80DIR			= ../t80
XULA2LIBDIR		= ../XuLA_lib
FPGABEECOREDIR	= ../FPGABeeCore
SN76489DIR		= ../sn76489-1.0
STARTUPCLK 		= JtagClk
HDL_FILES		= \
	FpgaBee_Xula2.vhd \
	Z80RamController.vhd \
	ClockCore.vhd \
	pcu_rom.vhd \
	$(XULA2LIBDIR)/Common.vhd \
	$(XULA2LIBDIR)/SdramCntl.vhd \
	$(FPGABEECOREDIR)/FpgaBeeCore.vhd \
	$(FPGABEECOREDIR)/Crtc6545.vhd \
	$(FPGABEECOREDIR)/FlashMemoryController.vhd \
	$(FPGABEECOREDIR)/KeyboardPort.vhd \
	$(FPGABEECOREDIR)/MicrobeeKeyboardDecoder.vhd \
	$(FPGABEECOREDIR)/ps2interface.vhd \
	$(FPGABEECOREDIR)/ScanCodeMapper.vhd \
	$(FPGABEECOREDIR)/ScanCodes.vhd \
	$(FPGABEECOREDIR)/DiskController.vhd \
	$(FPGABEECOREDIR)/DiskGeometry.vhd \
	$(FPGABEECOREDIR)/DiskConstants.vhd \
	$(FPGABEECOREDIR)/DiskControllerMultiplier.vhd \
	$(FPGABEECOREDIR)/PcuVideoController.vhd \
	$(FPGABEECOREDIR)/SDCardController.vhd \
	$(FPGABEECOREDIR)/seg7_addr_display.vhd \
	$(FPGABEECOREDIR)/seg7_decoder.vhd \
	$(FPGABEECOREDIR)/Utils.vhd \
	$(FPGABEECOREDIR)/vga_controller_800_60.vhd \
	$(FPGABEECOREDIR)/RamSinglePort.vhd \
	$(FPGABEECOREDIR)/RamDualPort.vhd \
	$(FPGABEECOREDIR)/RamTrueDualPort.vhd \
	$(FPGABEECOREDIR)/Fifo.vhd \
	$(FPGABEECOREDIR)/CharRom.vhd \
	$(FPGABEECOREDIR)/PcuCharRom.vhd \
	$(FPGABEECOREDIR)/StatusPanel.vhd \
	$(FPGABEECOREDIR)/StatusCharRom.vhd \
	$(FPGABEECOREDIR)/Dac.vhd \
	$(T80DIR)/T80.vhd \
	$(T80DIR)/T80_ALU.vhd \
	$(T80DIR)/T80_MCode.vhd \
	$(T80DIR)/T80_Pack.vhd \
	$(T80DIR)/T80_Reg.vhd \
	$(T80DIR)/T80se.vhd \
	$(SN76489DIR)/sn76489_comp_pack-p.vhd \
	$(SN76489DIR)/sn76489_top.vhd \
	$(SN76489DIR)/sn76489_latch_ctrl.vhd \
	$(SN76489DIR)/sn76489_clock_div.vhd \
	$(SN76489DIR)/sn76489_attenuator.vhd \
	$(SN76489DIR)/sn76489_tone.vhd \
	$(SN76489DIR)/sn76489_noise.vhd 


	

include ../../tools/xilinx.mk


#pcu_rom.vhd: ../xula2test/test_rom.asm
#	z80asm.exe -otest_rom.bin -ltest_rom.lst ../xula2test/test_rom.asm 
#	python ../../tools/bin2vhdlrom.py test_rom.bin pcu_rom.vhd --addrwidth:12 --clken

pcu_rom.vhd: ../../Firmware/PcuBoot/PcuBoot.bin
	python ../../tools/bin2vhdlrom.py ../../Firmware/PcuBoot/PcuBoot.bin pcu_rom.vhd --addrwidth:12 --clken

