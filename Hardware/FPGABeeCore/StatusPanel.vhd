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

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;


-- pixel_out:
--  00 - transparent (out of range)
--  01 - off
--  10 - low intensity (non-illuminated LED pixel)
--  11 - high intensity (illuminated LED pixel, or hex digit pixel)

entity StatusPanel is
generic
(
	x_offset : integer := 0
);
port
(
	reset : in std_logic;

	-- Data to display
	leds : in std_logic_vector(7 downto 0);
	hex : in std_logic_vector(31 downto 0);
	enable : in std_logic;

	-- VGA signals
	pixel_clock : in std_logic;
	vga_x_pixel : in std_logic_vector(10 downto 0);
	vga_y_pixel : in std_logic_vector(10 downto 0);

	-- Output pixel
	pixel_out : out std_logic_vector(1 downto 0)
);
end StatusPanel;

architecture behavior of StatusPanel is 

	signal vga_x_pixel_adjusted : std_logic_vector(10 downto 0);
	signal vga_x_pixel_upcoming : std_logic_vector(10 downto 0);
	signal char_x_upcoming : unsigned(7 downto 0);
	signal char_x_current : unsigned(7 downto 0);
	signal char_y : unsigned(7 downto 0);
	signal char_upcoming : std_logic_vector(4 downto 0);
	signal pixel_bright_upcoming : std_logic;
	signal char_rom_addr : std_logic_vector(7 downto 0);
	signal char_rom_dout : std_logic_vector(7 downto 0);
	signal pixel : std_logic;
	signal x_in_range_upcoming : std_logic;

	signal x_in_range : std_logic;
	signal pixel_bright : std_logic;

begin

	-- Shift left/right
	vga_x_pixel_adjusted <= std_logic_vector(unsigned(vga_x_pixel) - to_unsigned(x_offset,11));

	-- Work out the upcoming pixel
	vga_x_pixel_upcoming <= std_logic_vector(unsigned(vga_x_pixel_adjusted) + 1);

	-- Work out the character position
	char_x_current <= unsigned(vga_x_pixel_adjusted(10 downto 3));
	char_x_upcoming <= unsigned(vga_x_pixel_upcoming(10 downto 3));
	char_y <= unsigned(vga_y_pixel(10 downto 3));

	char_rom_addr <= char_upcoming & vga_y_pixel(2 downto 0);

	pixel <= char_rom_dout(to_integer(unsigned(not vga_x_pixel_adjusted(2 downto 0))));

	process (pixel_bright, x_in_range, pixel, char_y, enable)
	begin

		if enable='0' or x_in_range='0' or char_y/="0000000" then

			-- out of range
			pixel_out <= "00";

		elsif pixel='0' then

			-- Pixel is turned off	
			pixel_out <= "01";

		elsif pixel_bright='0' then

			-- Pixel is on, but not brightly illuminated (placeholder for off led)
			pixel_out <= "10";

		else

			-- Brightly lit pixel
			pixel_out <= "11";
		end if;

	end process;

	process (pixel_clock, reset)
	begin
		if reset='1' then

			pixel_bright <= '0';
			x_in_range <= '0';

		elsif rising_edge(pixel_clock) then

			pixel_bright <= pixel_bright_upcoming;
			x_in_range <= x_in_range_upcoming;
			
		end if;
	end process;


	process (char_x_upcoming, char_x_current, leds, hex)
	begin

		-- Assume in range unless proven otherwise
		x_in_range_upcoming <= '1';

		-- Assume bright pixel unless found to be an off led placeholder
		pixel_bright_upcoming <= '1';
		
		char_upcoming <= "10000";

		-- Handle the x coordinate
		case to_integer(char_x_upcoming) is

			when 0|1|2|3|4|5|6|7 =>
				if leds(to_integer(unsigned(not char_x_current(2 downto 0))))='0' then
					char_upcoming <= "10001";
					pixel_bright_upcoming <= '0';
				else
					char_upcoming <= "10010";
				end if;

			when 8 =>
				char_upcoming <= "10000";

			when 9 => char_upcoming <= "0" & hex(31 downto 28);
			when 10 => char_upcoming <= "0" & hex(27 downto 24);
			when 11 => char_upcoming <= "0" & hex(23 downto 20);
			when 12 => char_upcoming <= "0" & hex(19 downto 16);
			when 13 => char_upcoming <= "0" & hex(15 downto 12);
			when 14 => char_upcoming <= "0" & hex(11 downto 8);
			when 15 => char_upcoming <= "0" & hex(7 downto 4);
			when 16 => char_upcoming <= "0" & hex(3 downto 0);

			when others =>
				x_in_range_upcoming <= '0';

		end case;

	end process;

	StatusCharRom : entity work.StatusCharRom
	PORT MAP
	(
		clock => pixel_clock,
		addr => char_rom_addr,
		dout => char_rom_dout
	);



end;



