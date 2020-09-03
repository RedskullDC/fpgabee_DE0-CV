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
library UNISIM;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use UNISIM.VComponents.all;


entity FpgaBee_Xula2 is
port 
( 
    clock : in  STD_LOGIC;

    vga_red : out std_logic_vector(1 downto 0);
    vga_green : out std_logic_vector(1 downto 0);
    vga_blue : out std_logic_vector(1 downto 0);
    vga_hsync : out std_logic;
    vga_vsync : out std_logic;

    sdClk_o : out std_logic;
    sdClkFb_i : in std_logic;
    sdCke_o : out std_logic;      -- Clock-enable to SDRAM.
    sdCe_bo : out std_logic;      -- Chip-select to SDRAM.
    sdRas_bo : out std_logic;
    sdCas_bo : out std_logic;
    sdWe_bo : out std_logic;
    sdBs_o : out std_logic_vector(1 downto 0);
    sdAddr_o : out std_logic_vector(12 downto 0); 
    sdData_io : inout std_logic_vector(15 downto 0);
    sdDqmh_o  : out std_logic;
    sdDqml_o  : out std_logic;

    sd_sclk : out std_logic;
    sd_mosi : out std_logic;
    sd_miso : in std_logic;
    sd_ss_n : out std_logic;

    ps2_keyboard_data : inout std_logic;
    ps2_keyboard_clock : inout std_logic;

    speaker : out std_logic
);
end FpgaBee_Xula2;

architecture Behavioral of FpgaBee_Xula2 is

    signal clken_3_375 : std_logic;
    signal clktb_3_375 : std_logic;
    signal clock_27_000 : std_logic;
    signal clock_40_000 : std_logic;
    signal clock_100_000 : std_logic;

	signal core_ram_addr : std_logic_vector(17 downto 0);
	signal core_ram_rd_data : std_logic_vector(7 downto 0);
	signal core_ram_wr_data : std_logic_vector(7 downto 0);
	signal core_ram_wr : std_logic;
	signal core_ram_rd : std_logic;
	signal core_ram_wait : std_logic;

    signal ram_dout : std_logic_vector(7 downto 0);
    signal ram_wr : std_logic;
    signal ram_rd : std_logic;
    signal ram_wait : std_logic;

    signal pcu_rom_range : std_logic;
    signal pcu_rom_dout : std_logic_vector(7 downto 0);

    signal reset_shifter : std_logic_vector(7 downto 0) := "11111111";
    signal reset : std_logic;

begin

    -- Simulate a reset to get z80 running
    reset <= reset_shifter(0);
    process (clktb_3_375)
    begin
        if rising_edge(clktb_3_375) then
            if clken_3_375='1' then
                reset_shifter <= "0" & reset_shifter(7 downto 1);
            end if;
        end if;
    end process;

    -- Clocking
    ClockCore : entity work.ClockCore
    PORT MAP
    (
        reset => '0',
        clock_12_000 => clock,
        clken_3_375 => clken_3_375,
        clktb_3_375 => clktb_3_375,
        clock_40_000 => clock_40_000,
        clock_100_000 => clock_100_000,
        clock_100_000_L => sdClk_o
    );

	-- FPGABee Core
	FpgaBeeCore : entity work.FpgaBeeCore
	PORT MAP
	(
		clock_100_000 => clock_100_000,
		clock_40_000 => clock_40_000,

		clktb_3_375 => clktb_3_375,
		clken_3_375 => clken_3_375,

		reset => reset,
		monitor_key => '0',
        show_status_panel => '1',

		ram_addr => core_ram_addr,
		ram_wr_data => core_ram_wr_data,
		ram_rd_data => core_ram_rd_Data,
		ram_wr => core_ram_wr,
		ram_rd => core_ram_rd,
		ram_wait => core_ram_wait,

		vga_red => vga_red,
		vga_green => vga_green,
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

    -- PCU ROM sits at 0x30000 to 0x33FFF
    pcu_rom_range <= '1' when core_ram_addr(17 downto 14)="1100" else '0';
    core_ram_rd_data <= pcu_rom_dout when pcu_rom_range ='1' else ram_dout;
    ram_wr <= '1' when core_ram_wr='1' and pcu_rom_range='0' else '0';
    ram_rd <= '1' when core_ram_rd='1' and pcu_rom_range='0' else '0';

    Z80RamController : entity work.Z80RamController
    PORT MAP
    (
        reset => reset,

        ram_addr => core_ram_addr,
        ram_din => core_ram_wr_data,
        ram_dout => ram_dout,
        ram_wr => ram_wr,
        ram_rd => ram_rd,
        ram_wait => core_ram_wait,

        sdClkFb_i => sdClkFb_i,
        sdCke_o => sdCke_o,
        sdCe_bo => sdCe_bo,
        sdRas_bo => sdRas_bo,
        sdCas_bo => sdCas_bo,
        sdWe_bo => sdWe_bo,
        sdBs_o => sdBs_o,
        sdAddr_o => sdAddr_o,
        sdData_io => sdData_io,
        sdDqmh_o => sdDqmh_o,
        sdDqml_o => sdDqml_o
    );

    -- PCU firmware
    pcu_rom : entity work.pcu_rom
    PORT MAP
    (
        clock => clktb_3_375,
        clken => clken_3_375,
        addr => core_ram_addr(11 downto 0),
        dout => pcu_rom_dout
    );


end Behavioral;

