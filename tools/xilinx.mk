all: $(INTDIR)/$(PROJNAME).bit

clean:
	rm -r $(INTDIR)

# DEFAULTS
INTDIR			?= ./build
STARTUPCLK 		?= CCLK
TOPMODULE 		?= $(PROJNAME)
LANGUAGE 		?= vhdl
UCFFILE 		?= $(PROJNAME).ucf
INTSTYLE 		?= ise
SIM_TIME		?= 1000 ns

XST_FLAGS 		?= 
NGDBUILD_FLAGS  ?= 
MAP_FLAGS 		?= -w -logic_opt off -register_duplication off -r 4 -global_opt off -ir off -pr off 
PAR_FLAGS 		?= -w -ol high -mt off
BITGEN_FLAGS	?= -w -g StartupClk:$(STARTUPCLK) -g CRC:Enable 

# Spartan 6 Default Build flags
ifeq (xc6s, $(findstring xc6s,$(DEVICE)))
	MAP_FLAGS 		+= -xt 0 -mt off -lc off -ol high -t 1 -power off
	BITGEN_FLAGS 	+= -g INIT_9K:Yes
endif

# Xula2
ifeq (xc6slx25, $(findstring xc6slx25,$(DEVICE)))
	BITGEN_FLAGS += -g ConfigRate:10
endif

# Spartan 3 Default Build flags
ifeq (xc3s, $(findstring xc3s,$(DEVICE)))
	BITGEN_FLAGS 	+= -g UnusedPin:PullNone
endif


# TOOL CHAIN
XILINXDIR ?= /cygdrive/c/Xilinx/14.1
XILINXISE ?= $(XILINXDIR)/ISE_DS/ISE
XILINXBIN ?= $(XILINXISE)/bin/nt64
XST ?= $(XILINXBIN)/xst.exe
NGDBUILD ?= $(XILINXBIN)/ngdbuild.exe
MAP ?= $(XILINXBIN)/map.exe
PAR ?= $(XILINXBIN)/par.exe
BITGEN ?= $(XILINXBIN)/bitgen.exe

SRCDIR = $(shell cygpath -w $(CURDIR))
XILINX = $(shell cygpath -w $(XILINXISE))

# XST
$(INTDIR)/$(PROJNAME).ngc: $(HDL_FILES) $(INTDIR)/$(PROJNAME).xst $(INTDIR)/$(PROJNAME).prj
	cd $(INTDIR); $(XST) -intstyle $(INTSTYLE) $(XST_FLAGS) -ifn $(PROJNAME).xst -ofn $(PROJNAME).syr

# NGDBUILD
$(INTDIR)/$(PROJNAME).ngd: $(INTDIR)/$(PROJNAME).ngc $(UCFFILE)
	cd $(INTDIR); $(NGDBUILD) -intstyle $(INTSTYLE) $(NGDBUILD_FLAGS) -uc "$(SRCDIR)/$(UCFFILE)" -dd . -sd ipcore_dir -p $(DEVICE) $(PROJNAME).ngc $(PROJNAME).ngd

# MAP
$(INTDIR)/$(PROJNAME)_map.ncd: $(INTDIR)/$(PROJNAME).ngd $(UCFFILE)
	cd $(INTDIR); $(MAP) -intstyle $(INTSTYLE) $(MAP_FLAGS) -p $(DEVICE) -o $(PROJNAME)_map.ncd $(PROJNAME).ngd $(PROJNAME).pcf

# PAR
$(INTDIR)/$(PROJNAME).ncd: $(INTDIR)/$(PROJNAME)_map.ncd $(INTDIR)/$(PROJNAME).pcf
	cd $(INTDIR); $(PAR) -intstyle $(INTSTYLE) $(PAR_FLAGS) $(PROJNAME)_map.ncd $(PROJNAME).ncd $(PROJNAME).pcf

# BITGEN
$(INTDIR)/$(PROJNAME).bit: $(INTDIR)/$(PROJNAME).ncd $(INTDIR)/$(PROJNAME).pcf
	cd $(INTDIR); $(BITGEN) -intstyle $(INTSTYLE) $(BITGEN_FLAGS)  $(PROJNAME).ncd $(PROJNAME).bit $(PROJNAME).pcf


# Create the intermediate directory
$(INTDIR):
	mkdir $@

# Generate project for synthesis
$(INTDIR)/$(PROJNAME).prj: $(HDL_FILES) | $(INTDIR)
	for f in $^; do echo work "$(SRCDIR)"/$$f >> $@; done

# Generate xst command file
$(INTDIR)/$(PROJNAME).xst: makefile | $(INTDIR)
	@echo set -tmpdir . 					> $(INTDIR)/$(PROJNAME).xst
	@echo set -xsthdpdir "xst" 				>> $(INTDIR)/$(PROJNAME).xst
	@echo run 								>> $(INTDIR)/$(PROJNAME).xst
	@echo -ifn "$(PROJNAME).prj" 			>> $(INTDIR)/$(PROJNAME).xst
	@echo -ifmt $(LANGUAGE) 				>> $(INTDIR)/$(PROJNAME).xst
	@echo -ofn "$(PROJNAME)" 				>> $(INTDIR)/$(PROJNAME).xst
	@echo -ofmt NGC 						>> $(INTDIR)/$(PROJNAME).xst
	@echo -top $(TOPMODULE) 				>> $(INTDIR)/$(PROJNAME).xst
	@echo -p $(DEVICE) 						>> $(INTDIR)/$(PROJNAME).xst
	@echo -opt_mode Speed 					>> $(INTDIR)/$(PROJNAME).xst
	@echo -opt_level 1 						>> $(INTDIR)/$(PROJNAME).xst

#$(SIM_TOP)_sim.prj: makefile
#
#$(SIM_TOP)_sim.exe: $(SIM_HDL_FILES) makefile
#	makefile_utils makeprj $(SIM_TOP)_sim.prj $(LANGUAGE) $(SIM_HDL_FILES)
#	fuse -prj $(SIM_TOP)_sim.prj $(SIM_TOP) -o $(SIM_TOP)_sim.exe
#
#run: $(SIM_TOP)_sim.exe
#	@echo onerror {resume} 		> $(INTDIR)/$(SIM_TOP)_isim.cmd
#	@echo wave add /				>> $(INTDIR)/$(SIM_TOP)_isim.cmd
#	@echo run $(SIM_TIME)        >> $(INTDIR)/$(SIM_TOP)_isim.cmd
#	set XILINX=$(XILINX)
#	$(SIM_TOP)_sim.exe -gui -tclbatch $(INTDIR)/$(SIM_TOP)_isim.cmd 

