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

entity Crtc6545 is
	port
	(
		-- CPU Control
		clktb_3_375: in STD_LOGIC;
		clken_3_375: in STD_LOGIC;
		reset: in STD_LOGIC;
		wr: in STD_LOGIC;
		rs: in STD_LOGIC;
		din: in STD_LOGIC_VECTOR(7 downto 0);
		dout: out STD_LOGIC_VECTOR(7 downto 0);

		-- VGA connection
		vga_pixel_x : in STD_LOGIC_VECTOR(10 downto 0);
		vga_pixel_y : in STD_LOGIC_VECTOR(10 downto 0);
		vgaRed: out STD_LOGIC_VECTOR(1 downto 0);
		vgaGreen: out STD_LOGIC_VECTOR(1 downto 0);
		vgaBlue: out STD_LOGIC_VECTOR(1 downto 0);

		-- Video Controller
		pixel_clock: in STD_LOGIC;
		vram_addr : out STD_LOGIC_VECTOR(10 downto 0);
		char_ram_dout : in STD_LOGIC_VECTOR(7 downto 0);
		attr_ram_dout : in STD_LOGIC_VECTOR(7 downto 0);
		color_ram_dout : in STD_LOGIC_VECTOR(7 downto 0);
		pcgram_addr : out STD_LOGIC_VECTOR(14 downto 0);
		pcgram_dout : in STD_LOGIC_VECTOR(7 downto 0);
		charrom_addr : out STD_LOGIC_VECTOR(11 downto 0);
		charrom_dout : in STD_LOGIC_VECTOR(7 downto 0);
		
		-- 6545 is responsible for keyboard interface, so we need the state of the microbee key switches
		MicrobeeSwitches : in STD_LOGIC_VECTOR(0 to 63);
		suppress_keyboard : in STD_LOGIC;

		-- The latch rom signal serves purpose not only enabling access to the charrom but also 
		-- controlling the keyboard scan functionality
		latch_rom: in STD_LOGIC;

		-- Asserts when the small character set is selected by setting the base address >= 0x2000
		small_char_set_selected : out std_logic;


		-- The 100mhz clock is used to generate the fake vertical retrace signal
		clock_100_000 : in STD_LOGIC
	);
end Crtc6545;

architecture Behavioral of Crtc6545 is

	-- 6545 registers
	signal reg_addr: std_logic_vector(4 downto 0);
	signal reg_screen_width_chars: std_logic_vector(6 downto 0);	-- R1
	signal reg_screen_height_chars: std_logic_vector(6 downto 0);	-- R6
	signal reg_char_height_minus_1: std_logic_vector(4 downto 0);	-- R9
	signal reg_cursor_mode : std_logic_vector(1 downto 0); 			-- R10 (high)
	signal reg_cursor_startline: std_logic_vector(4 downto 0); 		-- R10 (low)
	signal reg_cursor_endline: std_logic_vector(4 downto 0);   		-- R11
	signal reg_base_addr: std_logic_vector(13 downto 0);			-- R12/13
	signal reg_cursor_pos : std_logic_vector(13 downto 0);			-- R14/15
	signal reg_light_pen : std_logic_vector(13 downto 0);			-- R16/17
	signal reg_update_addr : std_logic_vector(13 downto 0);			-- R18/19
	signal reg_status_light_pen_ready : std_logic; 		-- status register bit 6
	
	signal in_retrace : std_logic;
	signal char_height: std_logic_vector(4 downto 0);
	signal blink_counter : unsigned(21 downto 0);
	signal retrace_counter : unsigned(20 downto 0);
	signal key_scan_addr : unsigned(5 downto 0);


	signal horz_resolution : std_logic_vector(10 downto 0);				-- total microbee screen width in pixels
	signal vert_resolution : std_logic_vector(10 downto 0);				-- total microbee screen height in pixels 
	signal vert_resolution_by_2 : std_logic_vector(11 downto 0);		-- total microbee screen height in pixels * 2
	signal blank_lines_at_top : std_logic_vector(10 downto 0);			-- number of blank scan lines to place at top to vertically center the microbee screen
	signal blank_pixels_at_left : std_logic_vector(10 downto 0);		-- number of blank pixels at left horizontally center the microbee screen
	signal unused_lines : std_logic_vector(11 downto 0);				-- total number of unused lines (VGA_HEIGHT-vert_resolution)
	signal unused_horz_pixels : std_logic_vector(10 downto 0);			-- total number of unsed horizotanal pixels (VGA_WIDTH-horz_resolution)

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
	signal cursor_pixel : std_logic;
	signal cursor_on : std_logic;
	signal current_pixel : std_logic;
	signal vram_addr_current : std_logic_vector(13 downto 0);
	signal vram_addr_upcoming : std_logic_vector(13 downto 0);
	signal vram_addr_row : std_logic_vector(13 downto 0);

	-- Delayed signals
	signal pcg_select : std_logic;
	signal color_delayed : std_logic_vector(7 downto 0);
	
	-- Worker signals used by the multiplier that 
	signal iter_rows_left : std_logic_vector(6 downto 0);
	signal accum_vert_resolution : std_logic_vector(10 downto 0);

--	constant VGA_WIDTH : integer := 640;
--	constant VGA_HEIGHT : integer := 480;
--	constant VGA_TIMING_WIDTH : integer := 800;

	constant VGA_WIDTH : integer := 800;
	constant VGA_HEIGHT : integer := 600;
	constant VGA_TIMING_WIDTH : integer := 1056;


begin

	-- When the base address is >0x2000 use the small character set
	small_char_set_selected <= reg_base_addr(13);

	-------------- CPU CONTROL ---------------

	process(clktb_3_375, reset)
	begin
		if (reset='1') then
		
			-- reset all registers
			reg_addr <= (others=>'0');
			reg_screen_width_chars <= "1000000";			-- 80
			reg_screen_height_chars <= "0001100";		-- 24
			reg_char_height_minus_1 <= "01111";		-- 16
			reg_cursor_mode <= (others=>'0');
			reg_cursor_startline <= (others=>'0');
			reg_cursor_endline <= (others=>'0');
			reg_base_addr <= (others=>'0');
			reg_cursor_pos <= (others=>'0');
			reg_light_pen <= (others=>'0');
			reg_update_addr <= (others=>'0');
			reg_status_light_pen_ready <= '0';
			key_scan_addr <= (others=>'0');
			
		
		elsif rising_edge(clktb_3_375) then

			if clken_3_375='1' then
		
				key_scan_addr <= key_scan_addr + 1;
			
				-- Keyboard scan
				-- Cycles through each Microbee key switch
				--    vram address lower bits as an index
				-- When a pressed key is found, store in the light pen address register
				--    and set the light pen ready flag
				if ((reg_status_light_pen_ready = '0') and (latch_rom = '0') and
						(MicrobeeSwitches(to_integer(key_scan_addr))='1' and suppress_keyboard='0') ) then
						
					reg_status_light_pen_ready <= '1';
					reg_light_pen(9 downto 4) <= std_logic_vector(key_scan_addr);
					
				end if;

				blink_counter <= blink_counter + 1;
				
				if (wr = '1') then
				
					if (rs = '1') then
					
						-- write to register
						case (reg_addr) is

							when "00001" =>
								-- characters per row (R1)
								reg_screen_width_chars <= din(6 downto 0);

							when "00110" =>
								-- rows per screen (R6)
								reg_screen_height_chars <= din(6 downto 0);

							when "01001" =>
								-- scan lines per row (R9)
								reg_char_height_minus_1 <= din(4 downto 0);
						
							when "01010" =>
								-- cursor start scan line R10
								reg_cursor_startline <= din(4 downto 0);
								reg_cursor_mode <= din(6 downto 5);
								
							when "01011" =>
								-- cursor end scan line R11
								reg_cursor_endline <= din(4 downto 0);

							when "01100" =>
								-- base address h R12
								reg_base_addr(13 downto 8) <= din(5 downto 0);

							when "01101" =>
								-- base address l R13
								reg_base_addr(7 downto 0) <= din(7 downto 0);
								
							when "01110" =>
								-- cursor pos h R14
								reg_cursor_pos(13 downto 8) <= din(5 downto 0);
						
							when "01111" =>
								-- cursor pos l R15
								reg_cursor_pos(7 downto 0) <= din(7 downto 0);
								
							when "10010" =>
								-- update address h R18
								reg_update_addr(13 downto 8) <= din(5 downto 0);
								
							when "10011" =>
								-- update address v R19
								reg_update_addr(7 downto 0) <= din(7 downto 0);
								
							when "11111" =>
								-- write the R31 - scan keyboard
								if (MicrobeeSwitches(to_integer(unsigned(reg_update_addr(9 downto 4))))='1' 
										and suppress_keyboard='0' 
										and reg_status_light_pen_ready='0') then
										 
									reg_light_pen <= reg_update_addr;
									reg_status_light_pen_ready <= '1';
										
								end if;
								
							when others => 
								null;
							
						end case;
					
					else
					
						-- write to address register
						reg_addr <= din(4 downto 0);
					
					end if;
					
				else
				
					if (rs = '1') then
					
						-- read register
						case (reg_addr) is
							
							when "01110" =>
								-- cursor pos H R14
								dout <= "00" & reg_cursor_pos(13 downto 8);
								
							when "01111" =>
								-- cursor pos L R15
								dout <= reg_cursor_pos(7 downto 0);
								
							when "10000" =>
								-- light pen H R16
								dout <= "00" & reg_light_pen(13 downto 8);
								reg_status_light_pen_ready <= '0';
								
							when "10001" =>
								-- light pen L R17
								dout <= reg_light_pen(7 downto 0);
								reg_status_light_pen_ready <= '0';
								
							when others =>
								dout <= (others => '0');
							
						end case;
					
					else
					
						-- read status register
						dout <= 	'1' & 
									reg_status_light_pen_ready & 
									in_retrace & 
									"00000";
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Generate a fake retrace signal for CPU - 50Hz, 15% duty cycle
	process (clock_100_000)
	begin
		if (rising_edge(clock_100_000)) then
			if (retrace_counter<to_unsigned(2000000,21)) then
				retrace_counter <= retrace_counter + 1;
			else
				retrace_counter <= (others=>'0');
			end if;
		end if;
	end process;
	
	in_retrace <= '1' when retrace_counter < to_unsigned(300000,21) else '0';
	

	-------------- VIDEO GENERATION ---------------

	process (pixel_clock)
	begin
		if (rising_edge(pixel_clock)) then
			pcg_select <= char_ram_dout(7);
			color_delayed <= color_ram_dout;
		end if;
	end process;

	-- Calculate vertical resolution = char_height * reg_screen_height_chars 
	char_height <= std_logic_vector(unsigned(reg_char_height_minus_1) + 1);
	process (pixel_clock, reset)
	begin
		if reset='1' then

			vert_resolution <= "00110000000";		-- 384
			iter_rows_left <= "0010000";				-- 16
			accum_vert_resolution <= (others=>'0');	

		elsif rising_edge(pixel_clock) then

			if iter_rows_left="0000000" then
				vert_resolution <= accum_vert_resolution;
				iter_rows_left <= reg_screen_height_chars;
				accum_vert_resolution <= (others => '0');
			else
				accum_vert_resolution <= std_logic_vector(unsigned(accum_vert_resolution) + unsigned(char_height));
				iter_rows_left <= std_logic_vector(unsigned(iter_rows_left) - 1);
			end if;

		end if;
	end process;

	-- Count the vertical scan lines
	process (pixel_clock, reset)
	begin
		if reset='1' then

			vram_addr_row <= (others=>'0');
			current_ypos_in_char <= (others=>'0');
			current_char_row <= (others=>'0');

		elsif rising_edge(pixel_clock) then

			-- Pick one pixel somewhere in the back porch to trigger line counter
			if vga_pixel_x = std_logic_vector(to_unsigned(VGA_TIMING_WIDTH-10, 11)) and vga_pixel_y(0)='0' then

				if vga_pixel_y = blank_lines_at_top then

					-- First microbee pixel row
					vram_addr_row <= reg_base_addr;
					current_ypos_in_char <= (others=>'0');
					current_char_row <= (others=>'0');

				else

					-- Increment our row counters
					if (current_ypos_in_char = reg_char_height_minus_1) then
						vram_addr_row <= std_logic_vector(unsigned(vram_addr_row) + unsigned(reg_screen_width_chars));
						current_ypos_in_char <= (others=>'0');
						current_char_row <= std_logic_vector(unsigned(current_char_row)+1);
					else
						current_ypos_in_char <= std_logic_vector(unsigned(current_ypos_in_char) + 1);
					end if;

				end if;

			end if;

		end if;
	end process;

	-- Work out blank lines at the top (total lines - vert_resolution)/2
	vert_resolution_by_2 <= vert_resolution & "0";
	unused_lines <= std_logic_vector(VGA_HEIGHT - unsigned(vert_resolution_by_2));
	blank_lines_at_top <= unused_lines(11 downto 1);

	-- Calculate horizontal resolution (chars per row * 8)
	horz_resolution <= "0" & reg_screen_width_chars & "000";

	-- Work out blank pixels at the left
	unused_horz_pixels <= std_logic_vector(VGA_WIDTH - unsigned(horz_resolution));
	blank_pixels_at_left <= '0' & unused_horz_pixels(10 downto 1);

	-- Calculate the current microbee x coordinate
	current_x_coord <= std_logic_vector(unsigned(vga_pixel_x) - unsigned(blank_pixels_at_left));

	-- Calculate the upcoming microbee x coordinate
	-- We need to request from memory 2 pixels in advance: 1 for the
	--  character memory access and 1 for the charrom/PCG lookup
	-- Also, need to correctly calculate the upcoming pixel for when
	--  the current pixel is at the very RHS of display to wrap to the
	--  first pixel
	-- NB: For 640x480 resolution VGA, the horizontal pixel count goes from 0 -> 800
	process (current_x_coord)
	begin
		if unsigned(current_x_coord)=(VGA_TIMING_WIDTH-2) then
			upcoming_x_coord <= "00000000000";
		elsif unsigned(current_x_coord)=VGA_TIMING_WIDTH-1 then
			upcoming_x_coord <= "00000000001";
		else
			upcoming_x_coord <= std_logic_vector(unsigned(current_x_coord)+2);
		end if;
	end process;

	-- Calculate the current horizontal character char number (xcoord / 8)
	current_char_column <= current_x_coord(9 downto 3);

	-- Calculate the upcoming horizontal character char number (xcoord / 8)
	upcoming_char_column <= upcoming_x_coord(9 downto 3);

	-- Calculate the current position within the char (xcoord % 8)
	current_xpos_in_char <= current_x_coord(2 downto 0);

	-- Work out if the current pixel is "onscreen"
	pixel_in_x_range <= '1' when unsigned(current_char_column) < unsigned(reg_screen_width_chars) else '0';
	pixel_in_y_range <= '1' when unsigned(current_char_row) < unsigned(reg_screen_height_chars) else '0';

	-- Work out the memory address of the current char
	vram_addr_current <= std_logic_vector(unsigned(vram_addr_row) + unsigned(current_char_column));

	-- Work out the memory address of the upcoming char
	vram_addr_upcoming <= std_logic_vector(unsigned(vram_addr_row) + unsigned(upcoming_char_column));

	-- The upcoming vram address is the one we need to request now
	vram_addr <= vram_addr_upcoming(10 downto 0);
	
	-- Setup PCG look up address
	-- NB: Lowest 3 bits of attribute selects which bank of PCG RAM is used
	pcgram_addr <= attr_ram_dout(3 downto 0) & char_ram_dout(6 downto 0) & current_ypos_in_char(3 downto 0);

	-- Setup Character Rom lookup address.
	-- NB: Base address of >0x2000 selects the second 2K of the character ROM.
	charrom_addr <= reg_base_addr(13) & char_ram_dout(6 downto 0) & current_ypos_in_char(3 downto 0);
	
	-- Select the appropriate pixel data from either charrom or pcg ram
	character_bitmap <= pcgram_dout when (pcg_select='1') else charrom_dout;
	
	-- Workout if cursor on/off/blinking
	cursor_on <= '1' when (reg_cursor_mode="00") else									-- cursor on
						'0' when (reg_cursor_mode="01") else								-- cursor off
						blink_counter(21) when (reg_cursor_mode="10") else		-- slow blink
						blink_counter(20);													-- fast blink
	
	-- Work out if cursor is in the current character and scanline range
	cursor_pixel <= '1' when (
			(cursor_on = '1') and 
			(current_ypos_in_char>=reg_cursor_startline) and
			(current_ypos_in_char<=reg_cursor_endline) and
			(vram_addr_current = reg_cursor_pos)
			) else '0';

	-- Work out the current pixel value
	current_pixel <= character_bitmap(to_integer(unsigned(not current_xpos_in_char)));
 				
	-- Is the pixel within range
	pixel_in_range <= pixel_in_x_range and pixel_in_y_range;

	-- Invert pixels where the cursor is
	pixel <= not current_pixel when (cursor_pixel = '1') else current_pixel;

	-- Select the appropriate half of the color byte
	color_nibble <= color_delayed(3 downto 0) when (pixel='1') else color_delayed(7 downto 4);

	-- Generate pixel color
	process (pixel_in_range, color_nibble)
	begin

		if pixel_in_range='1' then

			-- Translate color
			vgaRed <= color_nibble(0) & color_nibble(3);
			vgaGreen <= color_nibble(1) & color_nibble(3);
			vgaBlue <= color_nibble(2) & color_nibble(3);

		else
		
			-- We're rendering outside the microbee display area
			vgaRed <= "00";
			vgaGreen <= "00";
			vgaBlue <= "00";
		
		end if;

	end process;	

end Behavioral;

