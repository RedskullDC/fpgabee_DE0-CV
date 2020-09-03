-- FpgaBee
--
-- Copyright (C) 2012-2013 Topten Software.
-- All Rights Reserved
-- 
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this 
-- product except in compliance with the License. You may obtain a copy of the License at
-- 
-- http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software distributed under 
-- the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
-- ANY KIND, either express or implied. See the License for the specific language governing 
-- permissions and limitations under the License.

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity FpgaBeeCore is
Port 
( 
	-- Clocks
	clock_100_000 : in std_logic;		-- 100Mhz clock drives fake vertical retrace, ps2 and sd card
	clock_40_000 : in std_logic;		-- Video Pixel Clock

	-- CPU clock
	clktb_3_375 : in std_logic;			-- CLocK Time Base, any freq
	clken_3_375 : in std_logic;			-- CLocK ENable, when applied to clktb should produce 3.375Mhz

	-- Buttons
	reset : in std_logic;
	monitor_key : in std_logic;			-- 1 to fake 'M' key
	show_status_panel : in std_logic;	-- 1 to show debug status panel

	-- Access to 256K of off-chip RAM
	-- 
	-- 0x00000 - 0x1FFFF = 128K Main Microbee Memory (4 x 32K banks)
	-- 0x20000 - 0x23FFF - 16K Rom Pack 0 (maps to Microbee Z80 addr 0x8000)
	-- 0x24000 - 0x27FFF - 16K Rom Pack 1 (maps to Microbee Z80 addr 0xC000)
	-- 0x28000 - 0x2BFFF - 16K Rom Pack 2 (maps to Microbee Z80 addr 0xC000)
	-- 0x2C000 - 0x2FFFF - Unused
	-- 0x30000 - 0x3FFFF - 64K PCU ROM/RAM (maps to Microbee Z80 addr 0x0000 when in pcu_mode)
	-- 
	-- NB: 
	-- 1) ROM packs are loaded by PCU startup code from SD card, but could be mapped to board 
	--		flash/ROM if preferred. 
	-- 2) The CPU starts execution from Z80 address 0x0000 in PCU mode (ie:0x30000 in above 
	--		memory map).  At 0x30000 needs to be either:
	--			a) the PCU firmware in flash/ROM
	--			b) a boot ROM to load the PCU firmware from SD card.
	--	  The Nexys-3 port currently uses approach (a).  The XuLA will need to use (b) since 
	--    there's no onboard parallel flash.
	ram_addr : out std_logic_vector(17 downto 0);
	ram_rd_data : in std_logic_vector(7 downto 0);
	ram_wr_data : out std_logic_vector(7 downto 0);
	ram_wr : out std_logic;
	ram_rd : out std_logic;
	ram_wait : in std_logic;

	-- VGA
	vga_red: out std_logic_vector(1 downto 0);
	vga_green: out std_logic_vector(1 downto 0);
	vga_blue: out std_logic_vector(1 downto 0);
	vga_hsync: out std_logic;
	vga_vsync: out std_logic;
	vga_pixel_x : out std_logic_vector(10 downto 0);		-- Optional, use to externally generate overlaid video
	vga_pixel_y : out std_logic_vector(10 downto 0);

	-- SD Card
	sd_sclk : out std_logic;
	sd_mosi : out std_logic;
	sd_miso : in std_logic;
	sd_ss_n : out std_logic;

	-- Keyboard
	ps2_keyboard_data : inout std_logic;
	ps2_keyboard_clock : inout std_logic;

	-- Audio
	speaker : out std_logic
);
end FpgaBeeCore;

architecture Behavioral of FpgaBeeCore is

    signal boot_scan : std_logic := '1';
	signal output_clock : std_logic;
	signal z80_dout : std_logic_vector(7 downto 0);
	signal z80_din : std_logic_vector(7 downto 0);
	signal z80_addr : std_logic_vector(15 downto 0);
	signal z80_mreq_n : std_logic;
	signal z80_iorq_n : std_logic;
	signal z80_rd_n : std_logic;
	signal z80_wr_n : std_logic;
	signal z80_m1_n : std_logic;
	signal z80_wait_n : std_logic;
	signal z80_nmi_n : std_logic;
	signal char_ram_wea : std_logic;
	signal char_ram_dout : std_logic_vector(7 downto 0);
	signal pcgram_wea : std_logic;
	signal pcgram_dout : std_logic_vector(7 downto 0);
	signal charrom_dout : std_logic_vector(7 downto 0);
	signal seg7_wea : std_logic;
	signal led_reg : std_logic_vector(7 downto 0);
	signal hex_reg : std_logic_vector(15 downto 0);
	signal mem_rd : std_logic;
	signal mem_wr : std_logic;
	signal port_rd : std_logic;
	signal port_wr : std_logic;
	signal ram_range : std_logic;
	signal ram_range_ro : std_logic;			-- '1' when accessing ROM's loaded into RAM
	signal char_ram_range : std_logic;
	signal attr_ram_range : std_logic;
	signal charrom_range : std_logic;
	signal pcg_ram_range : std_logic;
	signal color_ram_range : std_logic;
	signal latch_rom : std_logic;
	signal small_char_set_selected : std_logic;
	signal charrom_addr_b : std_logic_vector(11 downto 0);
	signal charrom_dout_b : std_logic_vector(7 downto 0);
	signal char_ram_addr_b : std_logic_vector(10 downto 0);
	signal char_ram_dout_b : std_logic_vector(7 downto 0);
	signal port_1c : std_logic_vector(7 downto 0);
	signal port_08 : std_logic_vector(7 downto 0);
	signal port_50 : std_logic_vector(7 downto 0);
	signal port_D0 : std_logic_vector(7 downto 0);
	signal attr_ram_wea : std_logic;
	signal attr_ram_dout : std_logic_vector(7 downto 0);
	signal attr_ram_dout_b : std_logic_vector(7 downto 0);
	signal color_ram_wea : std_logic;
	signal color_ram_dout : std_logic_vector(7 downto 0);
	signal color_ram_dout_b : std_logic_vector(7 downto 0);
	signal pcgram_addr_crtc : std_logic_vector(14 downto 0);
	signal pcgram_addr_b : std_logic_vector(13 downto 0);
	signal pcgram_dout_b : std_logic_vector(7 downto 0);
	signal pcgram_dout_b_range_tested : std_logic_vector(7 downto 0);
	signal crtc_addr_port : std_logic;
	signal crtc_data_port : std_logic;
	signal crtc_wr : std_logic;
	signal crtc_rd : std_logic;
	signal crtc_dout : std_logic_vector(7 downto 0);
	signal vsync_internal : std_logic;
	signal pio_port_b : std_logic_vector(7 downto 0);
	signal MicrobeeSwitches : std_logic_vector(0 to 63);
	signal shift_key_pressed : std_logic;
	signal ctrl_key_pressed : std_logic;
	signal debug_data : std_logic_vector(31 downto 0);
	signal debug_leds : std_logic_vector(7 downto 0);
	signal KeyboardMessageAvailable : std_logic;
	signal KeyboardMessageAvailable_prev : std_logic;
	signal KeyboardMessage : std_logic_vector(9 downto 0);
	signal disk_port : std_logic;
	signal disk_port_write : std_logic;
	signal disk_port_read : std_logic;
	signal disk_dout : std_logic_vector(7 downto 0);
	signal disk_busy : std_logic;

	signal video_blank : std_logic;
	signal vga_pixel_x_internal : std_logic_vector(10 downto 0);
	signal vga_pixel_y_internal : std_logic_vector(10 downto 0);

	signal vgaRed_mbee: std_logic_vector(1 downto 0);
	signal vgaGreen_mbee: std_logic_vector(1 downto 0);
	signal vgaBlue_mbee: std_logic_vector(1 downto 0);
	signal vgaRed_pcu: std_logic_vector(1 downto 0);
	signal vgaGreen_pcu: std_logic_vector(1 downto 0);
	signal vgaBlue_pcu: std_logic_vector(1 downto 0);
	signal pcu_pixel_visible : std_logic;

	signal status_pixel : std_logic_vector(1 downto 0);

	signal pcu_mode : std_logic;
	signal pcu_display_mode : std_logic_vector(7 downto 0);
	signal pcu_exit_request : std_logic;

	signal pcu_char_ram_wea : std_logic;
	signal pcu_char_ram_dout : std_logic_vector(7 downto 0);
	signal pcu_char_ram_addr_b : std_logic_vector(8 downto 0);
	signal pcu_char_ram_dout_b : std_logic_vector(7 downto 0);
	signal pcu_color_ram_wea : std_logic;
	signal pcu_color_ram_dout : std_logic_vector(7 downto 0);
	signal pcu_color_ram_dout_b : std_logic_vector(7 downto 0);
	signal pcu_char_ram_range : std_logic;
	signal pcu_color_ram_range : std_logic;

	signal pcu_key_fifo_full : std_logic;
	signal pcu_key_fifo_available : std_logic;
	signal pcu_key_fifo_din : std_logic_vector(9 downto 0);
	signal pcu_key_fifo_dout : std_logic_vector(9 downto 0);
	signal pcu_key_fifo_wr : std_logic;
	signal pcu_key_fifo_rd : std_logic;
	signal pcu_key_port : std_logic;
	signal pcu_key_port_prev : std_logic;

	signal current_pc : std_logic_vector(15 downto 0);

	signal translated_address : std_logic_vector(17 downto 0);

	signal soft_reset_shifter : std_logic_vector(7 downto 0);
	signal request_soft_reset : std_logic;
	signal mbee_reset : std_logic;
	signal mbee_reset_n : std_logic;

	signal dac_i : std_logic_vector(7 downto 0);
	signal volume : unsigned(7 downto 0) := x"F0";
	signal speaker_aout : unsigned(7 downto 0);
	signal pardac : unsigned(7 downto 0);

	signal psg_ce_n : std_logic;
	signal psg_we_n : std_logic;
	signal psg_ready : std_logic;
	signal psg_aout : signed(0 to 7);
	signal psg_wait : std_logic;

begin

	-- Misc continuous assignments
	pio_port_b(0) <= '0';
	mbee_reset <= '1' when soft_reset_shifter(0)='1' or reset='1' else '0';
	mbee_reset_n <= NOT mbee_reset;

	vga_pixel_x <= vga_pixel_x_internal;
	vga_pixel_y <= vga_pixel_y_internal;

	-- Debug data
	debug_data(15 downto 0) <= current_pc;
	debug_data(31 downto 16) <= hex_reg;
	debug_leds <= led_reg;
	
	-- Output video
	process (vgaRed_mbee, vgaGreen_mbee, vgaBlue_mbee, 
				vgaRed_pcu, vgaGreen_pcu, vgaBlue_pcu,
				pcu_display_mode, pcu_pixel_visible, 
				status_pixel, video_blank)
	begin

		if video_blank='1' or status_pixel="01" then

			-- Video blank, or status panel background
			vga_red <= "00";
			vga_green <= "00";
			vga_blue <= "00";

		elsif status_pixel="10" then

			-- Dull status pixel (off led)
			vga_red <= "10";
			vga_green <= "10";
			vga_blue <= "10";

		elsif status_pixel="11" then

			-- Bright status pixel
			vga_red <= "11";
			vga_green <= "00";
			vga_blue <= "00";

		elsif pcu_pixel_visible='1' and pcu_display_mode(0)='1' then

			-- PCU display
			vga_red <= vgaRed_pcu;
			vga_green <= vgaGreen_pcu;
			vga_blue <= vgaBlue_pcu;

		else

			-- Microbee display
			vga_red <= vgaRed_mbee;
			vga_green <= vgaGreen_mbee;
			vga_blue <= vgaBlue_mbee;

		end if;

	end process;


	process(clktb_3_375, reset)
	begin
		if reset='1' then

			soft_reset_shifter <= (others=>'0');

		elsif rising_edge(clktb_3_375) then

			if clken_3_375='1' then
				if request_soft_reset='1' then
					soft_reset_shifter <= (others=>'1');
				else
					soft_reset_shifter <= '0' & soft_reset_shifter(7 downto 1);
				end if;
			end if;

		end if;
	end process;



	-- Reset, clock and simple port writes...
	process(clktb_3_375, mbee_reset)
	begin
		if mbee_reset='1' then
		
			boot_scan <= '1';
			latch_rom <= '0';
			port_1c <= (others=>'0');
			port_08 <= (others=>'0');
			port_50 <= (others=>'0');
			port_D0 <= (others=>'0');
			led_reg <= (others=>'0');
			hex_reg <= (others=>'0');
			z80_nmi_n <= '1';
			pcu_mode <= '1';
			pcu_exit_request <= '0';
			pcu_display_mode <= (others=>'0');
			request_soft_reset <= '0';

			pcu_key_fifo_rd <= '0';
			pcu_key_port_prev <= '0';

		elsif rising_edge(clktb_3_375) then

			if clken_3_375='1' then

				request_soft_reset <= '0';
			
				-- On first read of a memory address >= 0x8000, clear the boot scan flag
				if z80_addr(15)='1' and mem_rd = '1' and pcu_mode='0' then
					boot_scan <= '0';
				end if;

				if z80_addr(7 downto 0)=x"00" and port_wr = '1' then
					pardac <= unsigned(z80_dout);
				end if;
				
				if z80_addr(7 downto 0)=x"A0" and port_wr = '1' then
					led_reg <= z80_dout;
				end if;
				
				if z80_addr(7 downto 0)=x"A1" and port_wr = '1' then
					hex_reg(7 downto 0) <= z80_dout;
				end if;
				
				if z80_addr(7 downto 0)=x"A2" and port_wr = '1' then
					hex_reg(15 downto 8) <= z80_dout;
				end if;
				
				-- Port 0b (11) is the VDU latch rom
				-- when 1, mem 0xF000 -> FFFFF comes from charrom
				-- when 0, mem 0xF000 -> FFFFF is the video/pcg ram
				if z80_addr(7 downto 0)=x"0b" and port_wr = '1' then
					latch_rom <= z80_dout(0);
				end if;
				
				-- Write to port 2 (PIO port B)
				if (z80_addr(7 downto 0)=x"02" and port_wr = '1') then
					pio_port_b(7 downto 1) <= z80_dout(7 downto 1);		-- not the 0 bit which is used for tape input
				end if;

				-- Write to port 0x1C, 0x1D, 0x1E and 0x1F
				if (z80_addr(7 downto 2)="000111" and port_wr = '1') then
					port_1c <= z80_dout(7 downto 0);
				end if;
				
				-- Write to port 0x08
				if (z80_addr(7 downto 0)=x"08" and port_wr = '1') then
					port_08 <= z80_dout(7 downto 0);
				end if;

				-- Write to port 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57
				if (z80_addr(7 downto 3)="01010" and port_wr = '1') then
					port_50 <= z80_dout(7 downto 0);
				end if;

				-- Write to port 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57
				if (z80_addr(7 downto 0)=x"D0" and port_wr = '1') then
					port_D0 <= z80_dout(7 downto 0);
				end if;

				-- Trigger NMI if there are keys in the PCU keyboard buffer and 
				-- we're not already triggering the NMI
				if pcu_mode='0' and z80_nmi_n='1' and pcu_key_fifo_available='1' then
					z80_nmi_n <= '0';
				end if;

				-- On the first instruction after an NMI, switch to PCU mode
				if z80_m1_n='0' and z80_nmi_n='0' and z80_addr=x"0066" then
					pcu_mode <= '1';
					pcu_exit_request <= '0';
					z80_nmi_n <= '1';
				end if;

				-- Any write to port 80 while in pcu mode is a request to exit pcu mode.
				-- We need to wait for the RETN instruction to be read before the bank switch.
				-- To exit PCU mode:
				--      OUT	(80h),A
				--      RETN
				if pcu_mode='1' and z80_addr(7 downto 0)=x"80" and port_wr = '1' then

					-- If we're in boot scan mode, then the PCU startup code is running and
					-- we're not in an NMI handler.  Rather than do the normal pcu exit request
					-- simply exit PCU mode which cause the normal boot scan to take over
					-- until 8000h
					if boot_scan='1' then
						pcu_mode <= '0';
					else
						pcu_exit_request <= '1';
					end if;

				end if;

				-- Writing to port 0xFF starts a soft reset
				if pcu_mode='1' and z80_addr(7 downto 0)=x"FF" and port_wr='1' then
					request_soft_reset <= '1';
				end if;

				-- Switching back from PCU mode
				-- RETN instruction = ED 45 - (just look for the 45)
				if pcu_exit_request='1' and z80_din=x"45" and z80_wait_n='1' then
					pcu_mode <= '0';
					pcu_exit_request <= '0';
				end if; 

				if pcu_mode='1' and z80_addr(7 downto 0)=x"81" and port_wr = '1' then
					pcu_display_mode <= z80_dout;
				end if;

				-- After reading from the pcu key port, read the next key.
				pcu_key_fifo_rd <= '0';
				pcu_key_port_prev <= pcu_key_port;
				if pcu_key_port_prev='1' and pcu_key_port='0' then
					pcu_key_fifo_rd <= '1';
				end if;

				if (z80_m1_n='0') then
					current_pc <= z80_addr;
				end if;

			end if;
		end if; 
	end process;

	-- Generate Z80 wait signal
	z80_wait_n <= not (ram_wait or psg_wait);

	-- Decode I/O control signals from Z80
	mem_rd <= '1' when (z80_mreq_n = '0' and z80_iorq_n = '1' and z80_rd_n = '0') else '0';
	mem_wr <= '1' when (z80_mreq_n = '0' and z80_iorq_n = '1' and z80_wr_n = '0') else '0';
	port_rd <= '1' when (z80_iorq_n = '0' and z80_mreq_n = '1' and z80_rd_n = '0') else '0';
	port_wr <= '1' when (z80_iorq_n = '0' and z80_mreq_n = '1' and z80_wr_n = '0') else '0';

	-- PCU port read
	pcu_key_port <= '1' when (port_rd='1' and z80_addr(7 downto 0)=x"83" and pcu_mode='1') else '0';

	-- CRTC ports
	crtc_data_port <= '1' when (z80_addr(7 downto 0) = x"0d") else '0';
	crtc_addr_port <= '1' when (z80_addr(7 downto 0) = x"0c") else '0';
	crtc_wr <= '1' when (port_wr='1' and (crtc_addr_port='1' or crtc_data_port='1')) else '0';
	crtc_rd <= '1' when (crtc_data_port='1') else '0';

	-- Memory write signals
	char_ram_wea <= mem_wr and char_ram_range;
	attr_ram_wea <= mem_wr and attr_ram_range;
	color_ram_wea <= mem_wr and color_ram_range;
	pcgram_wea <= mem_wr and pcg_ram_range;
	pcu_char_ram_wea <= mem_wr and pcu_char_ram_range;
	pcu_color_ram_wea <= mem_wr and pcu_color_ram_range;

	-- Disk controller ports
	disk_port <= '1' when z80_addr(7 downto 3)=(pcu_mode & "1000") else '0';		-- 0x40 -> 0x47 or 0xc0 => 0xc7 in pcu mode
	disk_port_write <= disk_port and port_wr;
	disk_port_read <= disk_port and port_rd;

	-- When extended PCG range is enabled (port_1c(7)) and attempt to read memory beyond the first 16K
	-- return 0, rather than wrapping the address.
	pcgram_dout_b_range_tested <= pcgram_dout_b when pcgram_addr_crtc(14)='0' or port_1c(7)='0' else x"00";
	pcgram_addr_b <= pcgram_addr_crtc(13 downto 0) when port_1c(7)='1' else "000" & pcgram_addr_crtc(10 downto 0);
		
	-- Flash/Cellular memory
	ram_addr <= translated_address;
	ram_wr <= '1' when (ram_range='1' and mem_wr='1' and ram_range_ro='0') else '0';
	ram_rd <= '1' when (ram_range='1' and mem_rd='1') else '0';
	ram_wr_data <= z80_dout;

	-- Map z80 addresses
	process (z80_addr, port_50, port_1c, port_08, port_D0, latch_rom, small_char_set_selected, mem_rd, pcu_mode)
	begin

		ram_range <= '0';
		ram_range_ro <= '0';
		char_ram_range <= '0';
		attr_ram_range <= '0';
		pcg_ram_range <= '0';
		color_ram_range <= '0';
		charrom_range <= '0';
		pcu_char_ram_range <= '0';
		pcu_color_ram_range <= '0';

		-- Default translated address
		translated_address <= "00" & z80_addr;

		if pcu_mode='1' then

			if z80_addr(15 downto 14)="10" and port_D0(7)='1' then

				-- 0x8000-0xBFFF mapped to 16K Microbee ROM banks (store in RAM at 0x20000)
				ram_range <= '1';
				translated_address <= "10" & port_D0(1 downto 0) & z80_addr(13 downto 0);

			elsif z80_addr(15 downto 12)="1111" then

				if z80_addr(11 downto 9)="000" then

					-- F000 - F1FF is PCU's video character buffer
					pcu_char_ram_range <= '1';

				elsif z80_addr(11 downto 9)="001" then

					-- F000 - F3FF is PCU's video color buffer
					pcu_color_ram_range <= '1';

				end if;


			else

				-- PCU main memory resides in RAM at 0x30000
				translated_address <= "11" & z80_addr;
				ram_range <= '1';
			
			end if;

		elsif port_50(3)='0' and 											-- Video RAM enabled
			((port_50(4)='0' and z80_addr(15 downto 12)=x"F") or			-- 0xF000 - 0xFFFF
			 (port_50(4)='1' and z80_addr(15 downto 12)=x"8")) then		    -- 0x8000 - 0x8FFF

			if z80_addr(11)='0' then					

				if latch_rom='0' then

					-- Lower video RAM 
					if port_1c(4)='0' then
						char_ram_range <= '1';
					else
						attr_ram_range <= '1';
					end if;

				else

					translated_address <= "000000" & small_char_set_selected & z80_addr(10 downto 0);
					charrom_range <= '1';

				end if;

			else

				-- Upper video RAM
				if port_08(6)='0' then

					pcg_ram_range <= '1';
					if port_1c(7)='1' then

						-- Extended PCG banks enabled
						translated_address <= "0000" & port_1c(2 downto 0) & z80_addr(10 downto 0);
						pcg_ram_range <= not port_1c(3);  -- if accessing >16K PCG ram, ignore/return 0

					else

						-- Extended PCG banks disabled
						translated_address <= "0000000" & z80_addr(10 downto 0);

					end if; 
				else

					color_ram_range <='1';

				end if;
			end if;

		elsif port_50(2)='0' and z80_addr(15)='1' then

			-- Microbee ROM Range
			-- Roms are stored in RAM (initialize by PCU from SD card)
			ram_range <= '1';
			ram_range_ro <= '1';		-- Prevent write to RAM


			if z80_addr(14)='0' then 		-- < 0xC000

				-- ROM 1 0x8000->0xBFFF (comes from flash 0x20000 -> 0x23FFF)
				translated_address <= "10" & "00" & z80_addr(13 downto 0);

			elsif port_50(5)='0' then 

				-- ROM 2 0xC000->0xFFFF (comes from flash 0x24000 -> 0x27FFF)
				translated_address <= "10" & "01" & z80_addr(13 downto 0);

			else

				-- ROM 3 0xC000->0xFFFF (comes from flash 0x28000 -> 0x2BFFF)
				translated_address <= "10" & "10" & z80_addr(13 downto 0);

			end if;

		elsif z80_addr(15)='1' then

			-- RAM access above 0x8000 is always to bank 0 block 0
			ram_range <= '1';
			translated_address <= "000" & z80_addr(14 downto 0);

		else

			-- Banked RAM access
			-- NB: when port50 bit 2 is set, the meaning of port50 bit 1 is inverted - hence the xor below
			ram_range <= '1';
			translated_address <= "0" & (port_50(1) xor port_50(2)) & port_50(0) & z80_addr(14 downto 0);

		end if;

	end process;

	-- Multiplex data into the CPU
	process (mem_rd, port_rd, boot_scan, char_ram_range, attr_ram_range, pcg_ram_range, color_ram_range, charrom_range, ram_range, crtc_addr_port, crtc_data_port,
				char_ram_dout, pcgram_dout, charrom_dout, color_ram_dout, attr_ram_dout, ram_rd_data, crtc_dout, pio_port_b,
				disk_port_read, disk_dout,
				port_1c, port_08, port_50, z80_addr,
				pcu_mode, pcu_display_mode, pcu_char_ram_range, pcu_color_ram_range, pcu_char_ram_dout, pcu_color_ram_dout, 
				pcu_key_fifo_dout, pcu_key_port, pcu_key_fifo_available, shift_key_pressed, ctrl_key_pressed
				)
	begin

		z80_din <= (others=>'0');

		if mem_rd='1' then

			if pcu_mode='0' and boot_scan='1' then

				-- boot scan from 0000 -> 7fff
				z80_din <= x"00";

			elsif charrom_range='1' then

				-- Read from character ROM
				z80_din <= charrom_dout;

			elsif char_ram_range='1' then

				z80_din <= char_ram_dout;

			elsif attr_ram_range='1' then

				z80_din <= attr_ram_dout;

			elsif pcg_ram_range='1' then

				z80_din <= pcgram_dout;

			elsif color_ram_range='1' then

				z80_din <= color_ram_dout;

			elsif ram_range='1' then

				z80_din <= ram_rd_data;
				
			elsif pcu_char_ram_range='1' then

				z80_din <= pcu_char_ram_dout;

			elsif pcu_color_ram_range='1' then

				z80_din <= pcu_color_ram_dout;

			end if;

		elsif port_rd='1' then

			if crtc_addr_port='1' or crtc_data_port='1' then 

				-- Read from 6545
				z80_din <= crtc_dout;

			elsif disk_port_read='1' then

				-- Read from disk
				z80_din <= disk_dout;

			elsif z80_addr(7 downto 0)=x"1c" then

				-- Read from port 1C
				z80_din <= port_1c;

			elsif z80_addr(7 downto 0)=x"02" then 

				-- Read from pio port B (cassette in)
				z80_din <= pio_port_b;

			elsif z80_addr(7 downto 0)=x"81" and pcu_mode='1' then

				z80_din <= pcu_display_mode;

			elsif z80_addr(7 downto 0)=x"82" and pcu_mode='1' then

				z80_din <= pcu_key_fifo_dout(7 downto 0);

			elsif pcu_key_port='1' then

				-- Get the next key
				z80_din <= pcu_key_fifo_available & "000" & ctrl_key_pressed & shift_key_pressed & pcu_key_fifo_dout(9 downto 8);

			end if;

		end if;

	end process;


	-- Process watches for keypresses that should be sent to the PCU
	-- and enqueues them in the PCU keypress fifo.
	process (clktb_3_375, reset)
	begin
		if reset='1' then

			KeyboardMessageAvailable_prev <= '0';

			volume <= x"F0";

		elsif rising_edge(clktb_3_375) then

			if clken_3_375='1' then

				KeyboardMessageAvailable_prev <= KeyboardMessageAvailable;
				pcu_key_fifo_wr <= '0';

				-- Key press available? (edge detect, keydown only)
				if KeyboardMessageAvailable='1' and KeyboardMessageAvailable_prev='0' and KeyboardMessage(9)='0' then

					-- Only pass keys when pcu key mode enabled, or if it's F12
					if pcu_display_mode(1)='1' or KeyboardMessage=("00" & x"07") then	-- F12

						-- Fifo have room?
						if pcu_key_fifo_full='0' then

							-- Write the keypress to the fifo
							pcu_key_fifo_din <= KeyboardMessage;
							pcu_key_fifo_wr <= '1';

						end if;
					end if;

					-- F10
					if KeyboardMessage=("00" & x"09") then
						volume <= unsigned(volume) - x"10";
					end if;

					-- F11
					if KeyboardMessage=("00" & x"78") then
						volume <= unsigned(volume) + x"10";
					end if;
				end if;
			end if;
		end if;

	end process;

	-- Z80 CPU Core
	z80_core: entity work.T80se 
	GENERIC MAP
	(
		Mode 	=> 0,		-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		T2Write => 1,		-- 0 => WR_n active in T3, /=0 => WR_n active in T2
		IOWait 	=> 1		-- 0 => Single cycle I/O, 1 => Std I/O cycle
	)
	PORT MAP
	(
		RESET_n => mbee_reset_n,
		CLK_n =>  clktb_3_375,
		A => z80_addr,
		DI => z80_din,
		DO => z80_dout,
		MREQ_n => z80_mreq_n,
		IORQ_n => z80_iorq_n,
		RD_n => z80_rd_n,
		WR_n => z80_wr_n,
		CLKEN => clken_3_375,
		WAIT_n => z80_wait_n,
		INT_n => '1',
		NMI_n => z80_nmi_n,
		BUSRQ_n => '1',
		M1_n => z80_m1_n,
		RFSH_n => open,
		HALT_n => open,
		BUSAK_n => open
	);
		
	-- CRTC 6545
	Crtc6545: entity work.Crtc6545 
	PORT MAP
	(
		clktb_3_375 => clktb_3_375,
		clken_3_375 => clken_3_375,
		reset => mbee_reset,
		wr => crtc_wr,
		rs => crtc_rd,
		din => z80_dout,
		dout => crtc_dout,
		
		pixel_clock => clock_40_000,
		vga_pixel_x => vga_pixel_x_internal,
		vga_pixel_y => vga_pixel_y_internal,
		vgaRed => vgaRed_mbee,
		vgaGreen => vgaGreen_mbee,
		vgaBlue => vgaBlue_mbee,

		vram_addr => char_ram_addr_b,
		char_ram_dout => char_ram_dout_b,
		attr_ram_dout => attr_ram_dout_b,
		color_ram_dout => color_ram_dout_b,
		pcgram_addr => pcgram_addr_crtc,
		pcgram_dout => pcgram_dout_b_range_tested,
		charrom_addr => charrom_addr_b,
		charrom_dout => charrom_dout_b,
		
		clock_100_000 => clock_100_000,
		MicrobeeSwitches => MicrobeeSwitches,
		suppress_keyboard => pcu_display_mode(1),
		latch_rom => latch_rom,
		small_char_set_selected => small_char_set_selected
	);

	-- 2k Video RAM at 0xF000 - 0xF7FF (when latchrom = 0)
	char_ram : entity work.RamDualPort
	GENERIC MAP
	(
		ADDR_WIDTH => 11
	)
	PORT MAP 
	(
		-- port A for CPU read/write
		clock_a => clktb_3_375,
		clken_a => clken_3_375,
		wr_a => char_ram_wea,
		addr_a => translated_address(10 downto 0),
		din_a => z80_dout,
		dout_a => char_ram_dout,

		-- port B for 6545, read-only
		clock_b => clock_40_000,
		addr_b => char_ram_addr_b,
		dout_b => char_ram_dout_b
	);


	-- 2k Attribute RAM at 0xF000 - 0xF7FF
	attr_ram : entity work.RamDualPort
	GENERIC MAP
	(
		ADDR_WIDTH => 11
	)
	PORT MAP 
	(
		-- port A for CPU read/write
		clock_a => clktb_3_375,
		clken_a => clken_3_375,
		wr_a => attr_ram_wea,
		addr_a => translated_address(10 downto 0),
		din_a => z80_dout,
		dout_a => attr_ram_dout,

		-- port B for 6545, read-only
		clock_b => clock_40_000,
		addr_b => char_ram_addr_b,
		dout_b => attr_ram_dout_b
	);

	-- 2k Color RAM at 0xF800 - 0xFFFF
	color_ram : entity work.RamDualPort
	GENERIC MAP
	(
		ADDR_WIDTH => 11
	)
	PORT MAP 
	(
		-- port A for CPU read/write
		clock_a => clktb_3_375,
		clken_a => clken_3_375,
		wr_a => color_ram_wea,
		addr_a => translated_address(10 downto 0),
		din_a => z80_dout,
		dout_a => color_ram_dout,

		-- port B for 6545, read-only
		clock_b => clock_40_000,
		addr_b => char_ram_addr_b,
		dout_b => color_ram_dout_b
	);

	-- 2k PCG RAM at 0xF800 - 0xFFFF (when latchrom = 0)
	-- 8 banks controlled by port 1C
	pcgram : entity work.RamDualPort
	GENERIC MAP
	(
		ADDR_WIDTH => 14
	)
	PORT MAP 
	(
		-- port A for CPU read/write
		clock_a => clktb_3_375,
		clken_a => clken_3_375,
		wr_a => pcgram_wea,
		addr_a => translated_address(13 downto 0),
		din_a => z80_dout,
		dout_a => pcgram_dout,

		-- port B for 6545, read-only
		clock_b => clock_40_000,
		addr_b => pcgram_addr_b,
		dout_b => pcgram_dout_b
	);

	-- 4k Character ROM at 0xF000 - 0xFFFF (when latchrom = 1)
	-- content loaded by core generator from 4k charrom.bin
	charrom : entity work.CharRom
	PORT MAP 
	(
		-- port A for CPU
		clock_a => clktb_3_375,
		clken_a => clken_3_375,
		addr_a => translated_address(11 downto 0),
		dout_a => charrom_dout,

		-- port B for 6545
		clock_b => clock_40_000,
		addr_b => charrom_addr_b,
		dout_b => charrom_dout_b
	);

	-- PCU Video Character RAM (512 bytes at 0xf000)
	pcu_char_ram : entity work.RamDualPort
	GENERIC MAP
	(
		ADDR_WIDTH => 9
	)
	PORT MAP 
	(
		-- port A for CPU read/write
		clock_a => clktb_3_375,
		clken_a => clken_3_375,
		wr_a => pcu_char_ram_wea,
		addr_a => translated_address(8 downto 0),
		din_a => z80_dout,
		dout_a => pcu_char_ram_dout,

		-- port B for PCU video controller, read-only
		clock_b => clock_40_000,
		addr_b => pcu_char_ram_addr_b,
		dout_b => pcu_char_ram_dout_b
	);

	-- PCU Color RAM (512 bytes at 0xf200)
	pcu_color_ram : entity work.RamDualPort
	GENERIC MAP
	(
		ADDR_WIDTH => 9
	)
	PORT MAP 
	(
		-- port A for CPU read/write
		clock_a => clktb_3_375,
		clken_a => clken_3_375,
		wr_a => pcu_color_ram_wea,
		addr_a => translated_address(8 downto 0),
		din_a => z80_dout,
		dout_a => pcu_color_ram_dout,

		-- port B for PCU video controller, read-only
		clock_b => clock_40_000,
		addr_b => pcu_char_ram_addr_b,
		dout_b => pcu_color_ram_dout_b
	);

	-- PCU Video Controller
	PcuVideoController: entity work.PcuVideoController
	PORT MAP
	(
		reset => reset,
		pixel_clock => clock_40_000,
		vga_pixel_x => vga_pixel_x_internal,
		vga_pixel_y => vga_pixel_y_internal,
		vgaRed => vgaRed_pcu,
		vgaGreen => vgaGreen_pcu,
		vgaBlue => vgaBlue_pcu,
		pixel_visible => pcu_pixel_visible,
		vram_addr => pcu_char_ram_addr_b,
		char_ram_dout => pcu_char_ram_dout_b,
		color_ram_dout => pcu_color_ram_dout_b
	);

	-- VGA timing
	vga_controller: entity work.vga_controller_800_60 
	PORT MAP
	(
		rst => reset,
		pixel_clk => clock_40_000,
		HS => vga_hsync,
		VS => vga_vsync,
		hcount => vga_pixel_x_internal,
		vcount => vga_pixel_y_internal,
		blank => video_blank
	);

	-- Status Panel
	StatusPanel : entity work.StatusPanel
	PORT MAP
	(
		reset => reset,
		pixel_clock => clock_40_000,
		enable => show_status_panel,
		leds => debug_leds,
		hex => debug_data,
		vga_x_pixel => vga_pixel_x_internal,
		vga_y_pixel => vga_pixel_y_internal,
		pixel_out => status_pixel
	);


	-- Keyboard Port
	KeyboardPort : entity work.KeyboardPort
	PORT MAP
	(
		clock => clock_100_000,
		reset => reset,
		PS2KeyboardData => ps2_keyboard_data,
		PS2KeyboardClk => ps2_keyboard_clock,
		KeyboardMessageAvailable => KeyboardMessageAvailable,
		KeyboardMessage => KeyboardMessage
	);

	-- Microbee keyboard decoder - decodes PS2 to Microbee switch states
	MicrobeeKeyboardDecoder: entity work.MicrobeeKeyboardDecoder 
	PORT MAP
	(
		clock => clock_100_000,
		reset => reset,
		MonitorKey => monitor_key,
		KeyboardMessageAvailable => KeyboardMessageAvailable,
		KeyboardMessage => KeyboardMessage,
		MicrobeeSwitches => MicrobeeSwitches,
		raw_shift => shift_key_pressed,
		raw_ctrl => ctrl_key_pressed
	);

	-- Disk controller
	DiskController : entity work.DiskController
	PORT MAP
	(
		reset => reset,
		clktb_3_375 => clktb_3_375,
		clken_3_375 => clken_3_375,
		clock_100_000 => clock_100_000,
		cpu_port(3) => pcu_mode,
		cpu_port(2 downto 0) => z80_addr(2 downto 0),
		din => z80_dout,
		dout => disk_dout,
		wr => disk_port_write,
		rd => disk_port_read,
		sd_ss_n => sd_ss_n,
		sd_mosi => sd_mosi,
		sd_miso => sd_miso,
		sd_sclk => sd_sclk
	);

	PcuKeyboardFifo : entity work.Fifo
	GENERIC MAP
	(
		ADDR_WIDTH => 3,
		DATA_WIDTH => 10
	)
	PORT MAP
	(
		reset => reset,
		clock_rd => clktb_3_375,
		clken_rd => clken_3_375,
		clock_wr => clktb_3_375,
		clken_wr => clken_3_375,
		full => pcu_key_fifo_full,
		available => pcu_key_fifo_available,
		din => pcu_key_fifo_din,
		dout => pcu_key_fifo_dout,
		wr => pcu_key_fifo_wr,
		rd => pcu_key_fifo_rd
	);

	Dac : entity work.Dac
	GENERIC MAP
	(
		SAMPLE_WIDTH => 8
	)
	PORT MAP
	(
		clock => clktb_3_375,
		clken => clken_3_375,
		reset => reset,
		dac_i => dac_i,
		dac_o => speaker
	);

	sn76489 : entity work.sn76489_top
	GENERIC MAP
	(
		clock_div_16_g => 1
	)
	PORT MAP
	(
	    clock_i => clktb_3_375,
	    clock_en_i => clken_3_375,
	    res_n_i => mbee_reset_n,
	    ce_n_i => psg_ce_n,
	    we_n_i => psg_we_n,
	    ready_o => psg_ready,
	    d_i => z80_dout,
	    aout_o => psg_aout
	);

	-- Write to ports 0x10, 0x11, 0x12, 0x13
	psg_we_n <= '0' when port_wr='1' else '1';
	psg_ce_n <= '0' when z80_addr(7 downto 2)="000100" else '1';
	psg_wait <= '1' when psg_we_n='0' and psg_ce_n='0' and psg_ready='0' else '0';

	-- Convert speaker out bit to audio signal level
	speaker_aout <= volume when pio_port_b(6)='1' else to_unsigned(0, 8);

	-- Send audio to DAC
	dac_i <= std_logic_vector(speaker_aout + pardac + unsigned(psg_aout + 128));

end Behavioral;

