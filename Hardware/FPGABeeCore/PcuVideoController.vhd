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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 1280 x 1024

entity PcuVideoController is
	port
	(
		reset : in std_logic;

		-- VGA connection
		vga_pixel_x : in STD_LOGIC_VECTOR(10 downto 0);
		vga_pixel_y : in STD_LOGIC_VECTOR(10 downto 0);
		vgaRed: out STD_LOGIC_VECTOR(1 downto 0);
		vgaGreen: out STD_LOGIC_VECTOR(1 downto 0);
		vgaBlue: out STD_LOGIC_VECTOR(1 downto 0);
		pixel_visible : out std_logic;

		-- Video Controller
		pixel_clock: in STD_LOGIC;
		vram_addr : out STD_LOGIC_VECTOR(8 downto 0);
		char_ram_dout : in STD_LOGIC_VECTOR(7 downto 0);
		color_ram_dout : in STD_LOGIC_VECTOR(7 downto 0)
	);
end PcuVideoController;

architecture Behavioral of PcuVideoController is


	-- Internal Video Generation Signals
	signal pixel_in_range : std_logic;
	signal pixel : std_logic;
	signal color_nibble : std_logic_vector(3 downto 0);

	signal current_x_coord : std_logic_vector(10 downto 0);
	signal upcoming_x_coord : std_logic_vector(10 downto 0);
	signal current_char_column : std_logic_vector(6 downto 0);
	signal current_char_row : std_logic_vector(6 downto 0);
	signal upcoming_char_column : std_logic_vector(6 downto 0);
	signal current_xpos_in_char : std_logic_vector(2 downto 0);
	signal current_ypos_in_char : std_logic_vector(4 downto 0);

	signal pixel_in_x_range : std_logic;
	signal pixel_in_y_range : std_logic;
	signal character_bitmap : std_logic_vector(7 downto 0);
	signal current_pixel : std_logic;
	signal charrom_addr : std_logic_vector(10 downto 0);
	signal charrom_dout : std_logic_vector(7 downto 0);
	signal vram_addr_upcoming : std_logic_vector(8 downto 0);

	-- Delayed signals
	signal color_delayed : std_logic_vector(7 downto 0);

	constant VGA_WIDTH : integer := 800;
	constant VGA_HEIGHT : integer := 600;
	constant VGA_TIMING_WIDTH : integer := 1056;

begin

	-------------- VIDEO GENERATION ---------------

	process (pixel_clock)
	begin
		if (rising_edge(pixel_clock)) then
			color_delayed <= color_ram_dout;
		end if;
	end process;

	-- Count the vertical scan/character lines
	process (pixel_clock, reset)
	begin
		if reset='1' then

			current_ypos_in_char <= (others=>'0');
			current_char_row <= (others=>'0');

		elsif rising_edge(pixel_clock) then

			-- Pick one pixel somewhere in the back porch to trigger line counter
			if vga_pixel_x = std_logic_vector(to_unsigned(VGA_TIMING_WIDTH-10, 11)) then

--				if unsigned(vga_pixel_y) = (VGA_HEIGHT-192)/2 then			-- (use this for centered)
				if unsigned(vga_pixel_y) = 0 then					-- top

					-- First microbee pixel row
					current_ypos_in_char <= (others=>'0');
					current_char_row <= (others=>'0');

				else

					-- Increment our row counters
					if (current_ypos_in_char = "01011") then
						current_ypos_in_char <= (others=>'0');
						current_char_row <= std_logic_vector(unsigned(current_char_row)+1);
					else
						current_ypos_in_char <= std_logic_vector(unsigned(current_ypos_in_char) + 1);
					end if;

				end if;

			end if;

		end if;
	end process;


	-- Calculate the current and upcoming microbee x coordinate
--	current_x_coord <= std_logic_vector(unsigned(vga_pixel_x) - (800-256)/2);		-- use this for centered
	current_x_coord <= std_logic_vector(unsigned(vga_pixel_x) - (VGA_WIDTH-256));			-- right
	upcoming_x_coord <= std_logic_vector(unsigned(current_x_coord)+2);

	-- Calculate the current and upcoming horizontal character char number (xcoord / 8)
	current_char_column <= current_x_coord(9 downto 3);
	upcoming_char_column <= upcoming_x_coord(9 downto 3);

	-- Calculate the current position within the char (xcoord % 8)
	current_xpos_in_char <= current_x_coord(2 downto 0);

	-- Work out if the current pixel is "onscreen"
	pixel_in_x_range <= '1' when unsigned(current_char_column) < 32 else '0';
	pixel_in_y_range <= '1' when unsigned(current_char_row) < 16 else '0';

	-- Work out the memory address of the current char
	--vram_addr_current <= current_char_row(3 downto 0) & current_char_column(4 downto 0);

	-- Work out the memory address of the upcoming char
	vram_addr_upcoming <= current_char_row(3 downto 0) & upcoming_char_column(4 downto 0);

	-- The upcoming vram address is the one we need to request now
	vram_addr <= vram_addr_upcoming;
	
	-- Setup Character Rom lookup address.
	charrom_addr <= char_ram_dout(6 downto 0) & current_ypos_in_char(3 downto 0);
	
	-- Work out the current pixel value
	current_pixel <= charrom_dout(to_integer(unsigned(not current_xpos_in_char)));
 				
	-- Is the pixel within range
	pixel_in_range <= pixel_in_x_range and pixel_in_y_range;
	pixel_visible <= '1' when pixel_in_range='1' and (current_pixel='1' or color_delayed(3 downto 0)/=color_delayed(7 downto 4)) else '0';

	-- Select the appropriate half of the color byte
	color_nibble <= color_delayed(3 downto 0) when (current_pixel='1') else color_delayed(7 downto 4);

	vgaRed <= color_nibble(0) & color_nibble(3);
	vgaGreen <= color_nibble(1) & color_nibble(3);
	vgaBlue <= color_nibble(2) & color_nibble(3);

	-- PCU Character ROM
	charrom : entity work.PcuCharRom
	PORT MAP 
	(
		clock => pixel_clock,
		addr => charrom_addr,
		dout => charrom_dout
	);

end Behavioral;

