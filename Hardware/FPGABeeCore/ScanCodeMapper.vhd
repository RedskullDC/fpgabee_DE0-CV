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

entity ScanCodeMapper is
	port
	(
		scancode: in std_logic_vector(7 downto 0);
		extended: in std_logic;
		mb_code: out unsigned(7 downto 0)
	);
end ScanCodeMapper;

architecture Behavioral of ScanCodeMapper is


begin

	process(scancode, extended)
	begin
		
		case (scancode) is
		
			-- A to Z
			when x"1c" => mb_code <= to_unsigned(mbk_A, 8);
			when x"32" => mb_code <= to_unsigned(mbk_B, 8);
			when x"21" => mb_code <= to_unsigned(mbk_C, 8);
			when x"23" => mb_code <= to_unsigned(mbk_D, 8);
			when x"24" => mb_code <= to_unsigned(mbk_E, 8);
			when x"2b" => mb_code <= to_unsigned(mbk_F, 8);
			when x"34" => mb_code <= to_unsigned(mbk_G, 8);
			when x"33" => mb_code <= to_unsigned(mbk_H, 8);
			when x"43" => mb_code <= to_unsigned(mbk_I, 8);
			when x"3b" => mb_code <= to_unsigned(mbk_J, 8);
			when x"42" => mb_code <= to_unsigned(mbk_K, 8);
			when x"4b" => mb_code <= to_unsigned(mbk_L, 8);
			when x"3a" => mb_code <= to_unsigned(mbk_M, 8);
			when x"31" => mb_code <= to_unsigned(mbk_N, 8);
			when x"44" => mb_code <= to_unsigned(mbk_O, 8);
			when x"4d" => mb_code <= to_unsigned(mbk_P, 8);
			when x"15" => mb_code <= to_unsigned(mbk_Q, 8);
			when x"2d" => mb_code <= to_unsigned(mbk_R, 8);
			when x"1b" => mb_code <= to_unsigned(mbk_S, 8);
			when x"2c" => mb_code <= to_unsigned(mbk_T, 8);
			when x"3c" => mb_code <= to_unsigned(mbk_U, 8);
			when x"2a" => mb_code <= to_unsigned(mbk_V, 8);
			when x"1d" => mb_code <= to_unsigned(mbk_W, 8);
			when x"22" => mb_code <= to_unsigned(mbk_X, 8);
			when x"35" => mb_code <= to_unsigned(mbk_Y, 8);
			when x"1a" => mb_code <= to_unsigned(mbk_Z, 8);

			-- [{
			when x"54" => mb_code <= to_unsigned(mbk_open_square, 8);

			-- \|
			when x"5d" => mb_code <= to_unsigned(mbk_backslash, 8);
			
			-- ]}
			when x"5b" => mb_code <= to_unsigned(mbk_close_square, 8);
			
			-- 1e = ^
			
			when x"71" => 
				-- DELETE
				if (extended='1') then
					mb_code <= to_unsigned(mbk_delete, 8);
				else 
					mb_code <= x"00";
				end if;
			
			-- 0 to 9
			when x"45" => mb_code <= to_unsigned(mbk_0, 8);
			when x"16" => mb_code <= to_unsigned(mbk_1, 8);
			when x"1e" => mb_code <= to_unsigned(mbk_2, 8);
			when x"26" => mb_code <= to_unsigned(mbk_3, 8);
			when x"25" => mb_code <= to_unsigned(mbk_4, 8);
			when x"2e" => mb_code <= to_unsigned(mbk_5, 8);
			when x"36" => mb_code <= to_unsigned(mbk_6, 8);
			when x"3d" => mb_code <= to_unsigned(mbk_7, 8);
			when x"3e" => mb_code <= to_unsigned(mbk_8, 8);
			when x"46" => mb_code <= to_unsigned(mbk_9, 8);

			-- 2a : *
			
			-- 2b ; +
			
			when x"41" => mb_code <= to_unsigned(mbk_comma_lt, 8);		-- ,
			
			-- 2d - =
			
			when x"49" => mb_code <= to_unsigned(mbk_period_gt, 8);		-- .
			
			-- 2f - / ?
			when x"4A" => mb_code <= to_unsigned(mbk_slash_question, 8);

			-- 30 - escape
			when x"76" => mb_code <= to_unsigned(mbk_escape, 8);		
			
			-- 31 - backspace
			when x"66" => mb_code <= to_unsigned(mbk_backspace, 8);		
			
			-- 32 - tab
			when x"0d" => mb_code <= to_unsigned(mbk_tab, 8);		
			
			-- 33 - PgUp -> LF
			when x"7d" => 
				if (extended='1') then
					mb_code <= to_unsigned(mbk_lf, 8);
				else
					mb_code <= x"00";
				end if;
			
			-- 34 - CR
			when x"5a" => mb_code <= to_unsigned(mbk_cr, 8);		
			
			-- 35 - CapsLock -> Lock
			when x"58" => mb_code <= to_unsigned(mbk_lock, 8);
			
			-- 36 - Break (F9 key)
			when x"01" => mb_code <= to_unsigned(mbk_break, 8);
			
			-- 37 - Space
			when x"29" => mb_code <= to_unsigned(mbk_space, 8);		
			
			-- 38 - UP
			when x"75" => 
				if (extended='1') then
					mb_code <= to_unsigned(mbk_up, 8);
				else
					mb_code <= x"00";
				end if;
				
			-- 39 Ctrl

			-- 3a - Down Arrow
			when x"72" => 
				if (extended='1') then
					mb_code <= to_unsigned(mbk_down, 8);
				else
					mb_code <= x"00";
				end if;

			-- 3b - Left Arrow
			when x"6b" => 
				if (extended='1') then
					mb_code <= to_unsigned(mbk_left, 8);
				else					
					mb_code <= x"00";
				end if;
				
			-- 3c - unused
			
			-- 3d - unused
			
			-- 3e - Right Arrow
			when x"74" => 
				if (extended='1') then
					mb_code <= to_unsigned(mbk_right, 8);
				else					
					mb_code <= x"00";	
				end if;
				
			-- 3F - Shift


			-- The rest are keys that need special handling

			-- Left Shift
			when x"12" => mb_code <= to_unsigned(psk_shift_l, 8);		
			
			-- Right Shift
			when x"59" => mb_code <= to_unsigned(psk_shift_r, 8);		

			-- Left/Right Ctrl
			when x"14" => 
				if (extended='1') then
					mb_code <= to_unsigned(psk_ctrl_l, 8);
				else
					mb_code <= to_unsigned(psk_ctrl_r, 8);
				end if;
				
			-- `~
			when x"0e" => mb_code <= to_unsigned(psk_backtick, 8);
			
			-- -_
			when x"4e" => mb_code <= to_unsigned(psk_minus, 8);
			
			-- =+
			when x"55" => mb_code <= to_unsigned(psk_equals, 8);
			
			-- ;:
			when x"4c" => mb_code <= to_unsigned(psk_semicolon, 8);
			
			-- '"
			when x"52" => mb_code <= to_unsigned(psk_quote, 8);
			
			-- Insert (used for Shift+0)
			when x"70" => 
				if (extended='0') then
					mb_code <= to_unsigned(psk_numpad_0, 8);
				else
					mb_code <= x"00";
				end if;

			when others => mb_code <= x"00";

		end case;
			
	end process;

end Behavioral;

