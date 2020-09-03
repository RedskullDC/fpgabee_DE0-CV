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
use work.ScanCodes.ALL;

entity MicrobeeKeyboardDecoder is  Port 
	( 
		clock : in STD_LOGIC;
		reset : in STD_LOGIC;
		MonitorKey : in STD_LOGIC;
		KeyboardMessageAvailable : in STD_LOGIC;
		KeyboardMessage : in STD_LOGIC_VECTOR(9 downto 0);
      	MicrobeeSwitches : out STD_LOGIC_VECTOR (0 to 63);
      	raw_shift : out std_logic;
      	raw_ctrl : out std_logic
	);
end MicrobeeKeyboardDecoder;

architecture Behavioral of MicrobeeKeyboardDecoder is

	signal mb_code : unsigned(7 downto 0);
	signal keys : std_logic_vector(0 to 73);
	signal shifted : std_logic_vector(0 to 73);
	signal shift : std_logic;
	signal KeyboardMessageAvailable_prev : std_logic;

begin

	-- Scan code mapper maps to "almost" Microbee scan code
	ScanCodeMapper: entity work.ScanCodeMapper PORT MAP
	(
		scancode => KeyboardMessage(7 downto 0),
		extended => KeyboardMessage(8),
		mb_code => mb_code
	);

	-- Process to read the PS2 keys, look them up with ScanCodeMapper and 
	-- store key switch states in "keys" register
	process (clock, reset)
	begin
	
		if reset='1' then
		
			keys <= (others => '0');
			shifted <= (others => '0');
			KeyboardMessageAvailable_prev <= '0';
		
		elsif rising_edge(clock) then
		
			-- Watch for rising edge as signal of new keyboard data available
			KeyboardMessageAvailable_prev <= KeyboardMessageAvailable;
			
			if KeyboardMessageAvailable = '1' and KeyboardMessageAvailable_prev = '0' then
			
				-- Bit 9 means "Key Up"
				if KeyboardMessage(9)='0' then

					-- Pressed key, ignore repeats.  We do this to properly capture
					-- the state of the shift key when the key was original pressed
					-- not on the repeat signals.
					if keys(to_integer(unsigned(mb_code)))='0' then

						-- Mark the key as pressed
						keys(to_integer(unsigned(mb_code))) <= '1';

						-- Remember the shift state
						shifted(to_integer(unsigned(mb_code))) <= shift;

					end if;

				else

					-- Key has been released
					keys(to_integer(unsigned(mb_code))) <= '0';
					
				end if;

			end if;
		
		end if;
	
	end process;

	-- Generate the actual Microbee key switches based on what's pressed in the 
	-- key switch register
	
	shift <= keys(psk_shift_l) or keys(psk_shift_r);
	
	-- @`
	MicrobeeSwitches(mbk_at_backtick) <= 
			'1' when keys(mbk_2) = '1' and shifted(mbk_2) = '1' else				-- shift+2
			'1' when keys(psk_backtick) = '1' and shifted(psk_backtick) = '0' else   -- `
			'0';
	
	-- A-Z
	MicrobeeSwitches(mbk_A to mbk_L) <= keys(mbk_A to mbk_L);
	MicrobeeSwitches(mbk_M) <= keys(mbk_M) or MonitorKey;
	MicrobeeSwitches(mbk_N to mbk_Z) <= keys(mbk_N to mbk_Z);
	
	-- [{ 
	MicrobeeSwitches(mbk_open_square) <= keys(mbk_open_square);
	
	-- \| 
	MicrobeeSwitches(mbk_backslash) <= keys(mbk_backslash);
	
	-- ]}
	MicrobeeSwitches(mbk_close_square) <= keys(mbk_close_square);
	
	-- ^~
	MicrobeeSwitches(mbk_caret_tilda) <= 
			'1' when keys(mbk_6) = '1' and shifted(mbk_6) = '1' else				-- shift+6
			'1' when keys(psk_backtick) = '1' and shifted(psk_backtick) = '1' else   -- shift+`
			'0';

	-- Delete
	MicrobeeSwitches(mbk_delete) <= keys(31);
	
	-- 0
	MicrobeeSwitches(mbk_0) <= 
		'1' when keys(mbk_0) = '1' and shifted(mbk_0) = '0' else
		'1' when keys(psk_numpad_0) = '1' and shifted(psk_numpad_0) = '1' else
		'0';
	
	-- 1!
	MicrobeeSwitches(mbk_1) <= keys(mbk_1);

	-- 2"
	MicrobeeSwitches(mbk_2) <= 
		'1' when keys(mbk_2) = '1' and shifted(mbk_2) = '0' else			-- 2
		'1' when keys(psk_quote) = '1' and shifted(psk_quote) = '1' else   -- shift ' => shift 2 (")
		'0';
	
	-- 3#
	MicrobeeSwitches(mbk_3) <= keys(mbk_3);
	
	-- 4$
	MicrobeeSwitches(mbk_4) <= keys(mbk_4);
	
	-- 5%
	MicrobeeSwitches(mbk_5) <= keys(mbk_5);
	
	-- 6&
	MicrobeeSwitches(mbk_6) <= 
		'1' when keys(mbk_6) = '1' and shifted(mbk_6) = '0' else		-- 6
		'1' when keys(mbk_7) = '1' and shifted(mbk_7) = '1' else    -- shift + 7 = &
		'0';
	
	-- 7'
	MicrobeeSwitches(mbk_7) <= 
		'1' when keys(mbk_7) = '1' and shifted(mbk_7) = '0' else			-- 7
		'1' when keys(psk_quote) = '1' and shifted(psk_quote) = '0' else	-- '
		'0';
	
	-- 8(
	MicrobeeSwitches(mbk_8) <= 
		'1' when keys(mbk_8) = '1' and shifted(mbk_8) = '0' else		-- 8
		'1' when keys(mbk_9) = '1' and shifted(mbk_9) = '1' else		-- shift + 9 = (
		'0';
	
	-- 9)
	MicrobeeSwitches(mbk_9) <= 
		'1' when keys(mbk_9) = '1' and shifted(mbk_9) = '0' else		-- 9
		'1' when keys(mbk_0) = '1' and shifted(mbk_0) = '1' else 	-- shift + 0 = )
		'0';
	
	-- :*
	MicrobeeSwitches(mbk_colon_asterisk) <= 
			'1' when keys(psk_semicolon) = '1' and shifted(psk_semicolon) = '1' else	-- shift+;
			'1' when keys(mbk_8) = '1' and shifted(mbk_8) = '1' else				-- shift+8
			'0';
	
	-- ;+
	MicrobeeSwitches(mbk_semicolon_plus) <= 
			'1' when keys(psk_semicolon) = '1' and shifted(psk_semicolon) = '0' else		-- ;
			'1' when keys(psk_equals) = '1' and shifted(psk_equals) = '1' else		-- shift+=
			'0';
	
	-- ,<
	MicrobeeSwitches(mbk_comma_lt) <= keys(mbk_comma_lt);

	-- -=
	MicrobeeSwitches(mbk_minus_equals) <= 
			'1' when keys(psk_minus) = '1' and shifted(psk_minus) = '0' else		-- -
			'1' when keys(psk_equals) = '1' and shifted(psk_equals) = '0' else		-- =
			'0';

	-- .> /? 48 49 50 51 esc cr lock break space up
	MicrobeeSwitches(mbk_period_gt to mbk_up) <= keys(mbk_period_gt to mbk_up);
	
	-- Control
	MicrobeeSwitches(mbk_ctrl) <= keys(psk_ctrl_l) or keys(psk_ctrl_r);

	-- Down 
	MicrobeeSwitches(mbk_down) <= keys(mbk_down);
	
	-- Left
	MicrobeeSwitches(mbk_left) <= keys(mbk_left);
	
	-- Right
	MicrobeeSwitches(mbk_right) <= keys(mbk_right);
	
	-- Shift
	MicrobeeSwitches(mbk_shift) <=
			'0' when keys(mbk_2) = '1' and shifted(mbk_2) = '1' else		-- turn off when shift+2 = @
			'1' when keys(psk_backtick) = '1' and shifted(psk_backtick) = '0' else		-- turn on when '
			'0' when keys(mbk_6) = '1' and shifted(mbk_6) = '1' else		-- turn off when shift+6 = ^
			'0' when keys(psk_semicolon) = '1' and shifted(psk_semicolon) = '1' else		-- turn off when shift+; = :
			'1' when keys(psk_equals) = '1' and shifted(psk_equals)= '0' else		-- turn on when =
			'1' when keys(psk_quote) = '1' and shifted(psk_quote) = '0' else    -- turn on when shift 7 = '
			shift;
	
	-- Also export raw shift/ctrl for use by PCU
	raw_shift <= keys(psk_shift_l) or keys(psk_shift_r);
	raw_ctrl <= keys(psk_ctrl_l) or keys(psk_ctrl_r);

end Behavioral;

