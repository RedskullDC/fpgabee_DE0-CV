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


entity FpgaBee_DE0CV is
port 
( 
	clock : in std_logic;
	reset : in std_logic;
	
	MemWR : out std_logic;
	MemOE : out std_logic;
	MemAdv : out std_logic;
	MemClk : out std_logic;
	MemCE : out std_logic;
	MemCRE : out std_logic;
	MemLB : out std_logic;
	MemUB : out std_logic;
	FlashCS : out std_logic;
	FlashRP : out std_logic;
	
	MemAdr : out std_logic_vector(26 downto 1);
	MemDB : inout std_logic_vector(15 downto 0);
	
	vga_red: out std_logic_vector(2 downto 0);
	vga_green: out std_logic_vector(2 downto 0);
	vga_blue: out std_logic_vector(2 downto 1);
	vga_hsync: out std_logic;
	vga_vsync: out std_logic;
	
	ps2_keyboard_data : inout std_logic;
	ps2_keyboard_clock : inout std_logic;
	
	speaker : out std_logic;
	
	sd_sclk : out std_logic;
	sd_mosi : out std_logic;
	sd_miso : in std_logic;
	sd_ss_n : out std_logic
);
end FpgaBee_DE0CV;

architecture Behavioral of FpgaBee_DE0CV is

	signal clktb_3_375 : std_logic;
	signal clken_3_375 : std_logic;
	signal clock_100_000 : std_logic;
	signal clock_25_000 : std_logic;
	signal clock_40_000 : std_logic;

	signal ram_addr : std_logic_vector(17 downto 0);
	signal ram_rd_data : std_logic_vector(7 downto 0);
	signal ram_wr_data : std_logic_vector(7 downto 0);
	signal ram_rd : std_logic;
	signal ram_wr : std_logic;

	constant pcu_rom_base_address: std_logic_vector(26 downto 0) := "000" & x"200000";
	signal pcu_rom_range : std_logic;

	signal ext_ram_addr : std_logic_vector(26 downto 0);

begin

	-- Clock Generation
	clock_core : entity work.ClockCore
	PORT MAP 
	(
		clock => clock,					-- input clock = 100Mhz
		clktb_3_375 => clktb_3_375,		-- 3.375Mhz for main z80 clock
		clken_3_375 => clken_3_375,
		clock_100_000 => clock_100_000,	-- 100Mhz redistributed for fast video ram/charrom clock
		clock_25_000 => clock_25_000,	-- 25Mhz for 640x480 VGA display timing
		clock_40_000 => clock_40_000,	-- 25Mhz for 800x600 VGA display timing
		reset  => reset
	);

	vga_red(0) <= '0';
	vga_green(0) <= '0';


	-- FPGABee Core
	FpgaBeeCore : entity work.FpgaBeeCore
	PORT MAP
	(
		clktb_3_375 => clktb_3_375,
		clken_3_375 => clken_3_375,
		clock_40_000 => clock_40_000,
		clock_100_000 => clock_100_000,

		reset => reset,
		monitor_key => '0',
		show_status_panel => '0',

		ram_addr => ram_addr,
		ram_rd_data => ram_rd_data,
		ram_wr_data => ram_wr_data,
		ram_wr => ram_wr,
		ram_rd => ram_rd,
		ram_wait => '0',

		vga_red => vga_red(2 downto 1),
		vga_green => vga_green(2 downto 1),
		vga_blue => vga_blue,
		vga_hsync => vga_hsync,
		vga_vsync => vga_vsync,
		vga_pixel_x => open,
		vga_pixel_y => open,

		sd_sclk => sd_sclk,
		sd_mosi => sd_mosi,
		sd_miso => sd_miso,
		sd_ss_n => sd_ss_n,

		ps2_keyboard_data => ps2_keyboard_data,
		ps2_keyboard_clock => ps2_keyboard_clock,

		speaker => speaker
	);



	-- Flash/Cellular memory
	MemAdv <= '0';			-- Asynchronous mode
	MemClk <= '0'; 			-- Asynchronous mode
	MemCRE <= '0';			-- Asynchronous mode
	MemOE <= '0' when (ram_rd='1') else '1';
	MemWR <= '0' when (ram_wr='1') else '1';
	MemCE <= '0' when (ram_rd='1' or ram_wr='1') and pcu_rom_range='0' else '1';
	MemLB <= '0' when (ram_addr(0)='0' and (ram_wr='1' or ram_rd='1')) else '1';
	MemUB <= '0' when (ram_addr(0)='1' and (ram_wr='1' or ram_rd='1')) else '1';
	
	FlashRP <= not reset;
	FlashCS <= '0' when (pcu_rom_range='1' and ram_rd='1') else '1';
	
	MemDB <= (ram_wr_data & ram_wr_data) when ram_wr='1' else "ZZZZZZZZZZZZZZZZ";
	
	MemAdr <= ext_ram_addr(26 downto 1);

	-- Is it in the PCU ROM range (0x30000 - 0x33FFF)
	pcu_rom_range <= '1' when ram_addr(17 downto 14)="1100" else '0';

	-- Which byte?
	ram_rd_data <= MemDB(7 downto 0) when ram_addr(0)='0' else MemDB(15 downto 8);

	process (ram_addr, pcu_rom_range)
	begin

		if pcu_rom_range='1' then

			-- PCU ROM comes from flash
			ext_ram_addr <= pcu_rom_base_address(26 downto 16) & ram_addr(15 downto 0);

		else

			-- Everything else is in cellular ram
			ext_ram_addr(17 downto 1) <= ram_addr(17 downto 1);
			ext_ram_addr(26 downto 18) <= (others=>'0');

		end if;

	end process;



end Behavioral;

