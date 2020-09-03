## SETTINGS FOR SYNTHESIS
DEVICE			= xc6slx16-2-csg324
PROJNAME		= FpgaBee_Nexys3
INTDIR			= ./build
T80DIR			= ../t80
FPGABEECOREDIR	= ../FPGABeeCore
SN76489DIR		= ../sn76489-1.0
HDL_FILES		= \
	FpgaBee_Nexys3.vhd \
	ClockCore.vhd \
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