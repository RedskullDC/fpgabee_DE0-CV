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
use IEEE.STD_LOGIC_1164.all;

package ScanCodes is

	-- Scan codes for microbee keys
	constant mbk_at_backtick : integer := 0;
	constant mbk_A : integer := 1;
	constant mbk_B : integer := 2;
	constant mbk_C : integer := 3;
	constant mbk_D : integer := 4;
	constant mbk_E : integer := 5;
	constant mbk_F : integer := 6;
	constant mbk_G : integer := 7;
	constant mbk_H : integer := 8;
	constant mbk_I : integer := 9;
	constant mbk_J : integer := 10;
	constant mbk_K : integer := 11;
	constant mbk_L : integer := 12;
	constant mbk_M : integer := 13;
	constant mbk_N : integer := 14;
	constant mbk_O : integer := 15;
	constant mbk_P : integer := 16;
	constant mbk_Q : integer := 17;
	constant mbk_R : integer := 18;
	constant mbk_S : integer := 19;
	constant mbk_T : integer := 20;
	constant mbk_U : integer := 21;
	constant mbk_V : integer := 22;
	constant mbk_W : integer := 23;
	constant mbk_X : integer := 24;
	constant mbk_Y : integer := 25;
	constant mbk_Z : integer := 26;
	constant mbk_open_square : integer := 27;
	constant mbk_backslash : integer := 28;
	constant mbk_close_square : integer :=29;
	constant mbk_caret_tilda : integer :=30;
	constant mbk_delete : integer :=31;
	constant mbk_0 : integer := 32;
	constant mbk_1 : integer := 33;
	constant mbk_2 : integer := 34;
	constant mbk_3 : integer := 35;
	constant mbk_4 : integer := 36;
	constant mbk_5 : integer := 37;
	constant mbk_6 : integer := 38;
	constant mbk_7 : integer := 39;
	constant mbk_8 : integer := 40;
	constant mbk_9 : integer := 41;
	constant mbk_colon_asterisk : integer := 42;
	constant mbk_semicolon_plus : integer := 43;
	constant mbk_comma_lt : integer := 44;
	constant mbk_minus_equals : integer := 45;
	constant mbk_period_gt : integer := 46;
	constant mbk_slash_question : integer := 47;
	constant mbk_escape : integer := 48;
	constant mbk_backspace : integer := 49;
	constant mbk_tab : integer := 50;
	constant mbk_lf : integer := 51;
	constant mbk_cr : integer := 52;
	constant mbk_lock : integer := 53;
	constant mbk_break : integer := 54;
	constant mbk_space : integer := 55;
	constant mbk_up : integer := 56;
	constant mbk_ctrl : integer := 57;
	constant mbk_down : integer := 58;
	constant mbk_left : integer := 59;
	constant mbk_unused1 : integer := 60;
	constant mbk_unused2 : integer := 61;
	constant mbk_right : integer := 62;
	constant mbk_shift : integer := 63;
	
	-- pseudo codes
	-- these keys are used by in intermediate translation from 
	-- ps2 scan code to microbee scan code.  They don't map exactly
	-- to a microbee scan code, but their state is required, so we
	-- remember if they're pressed and derive other keys from them.
	constant psk_shift_l : integer := 64;
	constant psk_shift_r : integer := 65; 
	constant psk_ctrl_r : integer := 66;
	constant psk_ctrl_l : integer := 67;
	constant psk_backtick : integer := 68;
	constant psk_minus : integer := 69;
	constant psk_equals : integer := 70;
	constant psk_semicolon : integer := 71;
	constant psk_quote : integer := 72;
	constant psk_numpad_0 : integer := 73; 
	

end ScanCodes;

package body ScanCodes is

 
end ScanCodes;
