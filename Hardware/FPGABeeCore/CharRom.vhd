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
use std.textio.all;
use ieee.std_logic_textio.all;

entity CharRom is
	port
	(
		-- Port A
		clock_a : in std_logic;
		clken_a : in std_logic;
		addr_a : in std_logic_vector(11 downto 0);
		dout_a : out std_logic_vector(7 downto 0);

		-- Port B
		clock_b : in std_logic;
		addr_b : in std_logic_vector(11 downto 0);
		dout_b : out std_logic_vector(7 downto 0)
	);
end CharRom;
 
architecture behavior of CharRom is 
	type mem_type is array(0 to 4095) of std_logic_vector(7 downto 0);
	signal ram : mem_type := (

-- Font rom data included with permission from Microbee Technology Pty Ltd

x"00", x"00", x"00", x"00", x"7f", x"41", x"41", x"41", x"41", x"41", x"41", x"41", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7f", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"08", x"08", x"08", x"08", x"08", x"08", x"08", x"08", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"20", x"10", x"08", x"04", x"3e", x"10", x"08", x"04", x"02", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7f", x"41", x"63", x"55", x"49", x"55", x"63", x"41", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"01", x"02", x"04", x"48", x"50", x"60", x"40", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1c", x"22", x"41", x"41", x"41", x"7f", x"14", x"14", x"77", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"10", x"20", x"7c", x"22", x"11", x"01", x"01", x"01", x"01", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"08", x"04", x"02", x"7f", x"02", x"04", x"08", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7f", x"00", x"00", x"00", x"7f", x"00", x"00", x"00", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"08", x"08", x"08", x"49", x"2a", x"1c", x"08", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"08", x"08", x"2a", x"1c", x"08", x"49", x"2a", x"1c", x"08", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"08", x"10", x"20", x"7f", x"20", x"10", x"08", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1c", x"22", x"63", x"55", x"49", x"55", x"63", x"22", x"1c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1c", x"22", x"41", x"41", x"49", x"41", x"41", x"22", x"1c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7f", x"41", x"41", x"41", x"7f", x"41", x"41", x"41", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1c", x"2a", x"49", x"49", x"4f", x"41", x"41", x"22", x"1c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1c", x"22", x"41", x"41", x"4f", x"49", x"49", x"2a", x"1c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1c", x"22", x"41", x"41", x"79", x"49", x"49", x"2a", x"1c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1c", x"2a", x"49", x"49", x"79", x"41", x"41", x"22", x"1c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"11", x"0a", x"04", x"4a", x"51", x"60", x"40", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"3e", x"22", x"22", x"22", x"22", x"22", x"22", x"22", x"63", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"01", x"01", x"01", x"01", x"7f", x"01", x"01", x"01", x"01", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7f", x"41", x"22", x"14", x"08", x"14", x"22", x"41", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"08", x"08", x"08", x"1c", x"1c", x"08", x"08", x"08", x"08", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"3c", x"42", x"42", x"40", x"30", x"08", x"08", x"00", x"08", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1c", x"22", x"41", x"41", x"7f", x"41", x"41", x"22", x"1c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7f", x"49", x"49", x"49", x"79", x"41", x"41", x"41", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7f", x"41", x"41", x"41", x"79", x"49", x"49", x"49", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7f", x"41", x"41", x"41", x"4f", x"49", x"49", x"49", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7f", x"49", x"49", x"49", x"4f", x"41", x"41", x"41", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"08", x"08", x"08", x"08", x"08", x"00", x"00", x"08", x"08", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"24", x"24", x"24", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"14", x"14", x"14", x"7f", x"14", x"7f", x"14", x"14", x"14", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"08", x"3f", x"48", x"48", x"3e", x"09", x"09", x"7e", x"08", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"20", x"51", x"22", x"04", x"08", x"10", x"22", x"45", x"02", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"38", x"44", x"44", x"28", x"10", x"29", x"46", x"46", x"39", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"0c", x"0c", x"08", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"04", x"08", x"10", x"10", x"10", x"10", x"10", x"08", x"04", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"10", x"08", x"04", x"04", x"04", x"04", x"04", x"08", x"10", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"08", x"49", x"2a", x"1c", x"2a", x"49", x"08", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"08", x"08", x"08", x"7f", x"08", x"08", x"08", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"18", x"18", x"10", x"20", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"7f", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"18", x"18", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"01", x"02", x"04", x"08", x"10", x"20", x"40", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"3e", x"41", x"43", x"45", x"49", x"51", x"61", x"41", x"3e", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"08", x"18", x"28", x"08", x"08", x"08", x"08", x"08", x"3e", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"3e", x"41", x"01", x"02", x"1c", x"20", x"40", x"40", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"3e", x"41", x"01", x"01", x"1e", x"01", x"01", x"41", x"3e", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"02", x"06", x"0a", x"12", x"22", x"42", x"7f", x"02", x"02", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7f", x"40", x"40", x"7c", x"02", x"01", x"01", x"42", x"3c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1e", x"20", x"40", x"40", x"7e", x"41", x"41", x"41", x"3e", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7f", x"41", x"02", x"04", x"08", x"10", x"10", x"10", x"10", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"3e", x"41", x"41", x"41", x"3e", x"41", x"41", x"41", x"3e", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"3e", x"41", x"41", x"41", x"3f", x"01", x"01", x"02", x"3c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"18", x"18", x"00", x"00", x"18", x"18", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"18", x"18", x"00", x"00", x"18", x"18", x"10", x"20", x"00", 
x"00", x"00", x"00", x"00", x"04", x"08", x"10", x"20", x"40", x"20", x"10", x"08", x"04", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"3e", x"00", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"10", x"08", x"04", x"02", x"01", x"02", x"04", x"08", x"10", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1e", x"21", x"21", x"01", x"06", x"08", x"08", x"00", x"08", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1e", x"21", x"4d", x"55", x"55", x"5e", x"40", x"20", x"1e", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1c", x"22", x"41", x"41", x"41", x"7f", x"41", x"41", x"41", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7e", x"21", x"21", x"21", x"3e", x"21", x"21", x"21", x"7e", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1e", x"21", x"40", x"40", x"40", x"40", x"40", x"21", x"1e", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7c", x"22", x"21", x"21", x"21", x"21", x"21", x"22", x"7c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7f", x"40", x"40", x"40", x"78", x"40", x"40", x"40", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7f", x"40", x"40", x"40", x"78", x"40", x"40", x"40", x"40", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1e", x"21", x"40", x"40", x"40", x"4f", x"41", x"21", x"1e", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"41", x"41", x"41", x"41", x"7f", x"41", x"41", x"41", x"41", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"3e", x"08", x"08", x"08", x"08", x"08", x"08", x"08", x"3e", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1f", x"04", x"04", x"04", x"04", x"04", x"04", x"44", x"38", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"41", x"42", x"44", x"48", x"50", x"68", x"44", x"42", x"41", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"41", x"63", x"55", x"49", x"49", x"41", x"41", x"41", x"41", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"41", x"61", x"51", x"49", x"45", x"43", x"41", x"41", x"41", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1c", x"22", x"41", x"41", x"41", x"41", x"41", x"22", x"1c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7e", x"41", x"41", x"41", x"7e", x"40", x"40", x"40", x"40", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1c", x"22", x"41", x"41", x"41", x"49", x"45", x"22", x"1d", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7e", x"41", x"41", x"41", x"7e", x"48", x"44", x"42", x"41", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"3e", x"41", x"40", x"40", x"3e", x"01", x"01", x"41", x"3e", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7f", x"08", x"08", x"08", x"08", x"08", x"08", x"08", x"08", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"41", x"41", x"41", x"41", x"41", x"41", x"41", x"41", x"3e", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"41", x"41", x"41", x"22", x"22", x"14", x"14", x"08", x"08", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"41", x"41", x"41", x"41", x"49", x"49", x"55", x"63", x"41", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"41", x"41", x"22", x"14", x"08", x"14", x"22", x"41", x"41", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"41", x"41", x"22", x"14", x"08", x"08", x"08", x"08", x"08", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7f", x"01", x"02", x"04", x"08", x"10", x"20", x"40", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"3c", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"3c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"40", x"20", x"10", x"08", x"04", x"02", x"01", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"3c", x"04", x"04", x"04", x"04", x"04", x"04", x"04", x"3c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"08", x"14", x"22", x"41", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"7f", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"18", x"18", x"08", x"04", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"3c", x"02", x"3e", x"42", x"42", x"3d", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"40", x"40", x"40", x"5c", x"62", x"42", x"42", x"62", x"5c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"3c", x"42", x"40", x"40", x"42", x"3c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"02", x"02", x"02", x"3a", x"46", x"42", x"42", x"46", x"3a", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"3c", x"42", x"7e", x"40", x"40", x"3c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"0c", x"12", x"10", x"10", x"7c", x"10", x"10", x"10", x"10", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"3a", x"46", x"42", x"46", x"3a", x"02", x"02", x"42", x"3c", 
x"00", x"00", x"00", x"00", x"40", x"40", x"40", x"5c", x"62", x"42", x"42", x"42", x"42", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"08", x"00", x"18", x"08", x"08", x"08", x"08", x"1c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"02", x"00", x"06", x"02", x"02", x"02", x"02", x"02", x"02", x"22", x"1c", 
x"00", x"00", x"00", x"00", x"40", x"40", x"40", x"44", x"48", x"50", x"68", x"44", x"42", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"18", x"08", x"08", x"08", x"08", x"08", x"08", x"08", x"1c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"76", x"49", x"49", x"49", x"49", x"49", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"5c", x"62", x"42", x"42", x"42", x"42", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"3c", x"42", x"42", x"42", x"42", x"3c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"5c", x"62", x"42", x"42", x"62", x"5c", x"40", x"40", x"40", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"3a", x"46", x"42", x"42", x"46", x"3a", x"02", x"02", x"02", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"5c", x"62", x"40", x"40", x"40", x"40", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"3c", x"42", x"30", x"0c", x"42", x"3c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"10", x"10", x"7c", x"10", x"10", x"10", x"12", x"0c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"42", x"42", x"42", x"42", x"46", x"3a", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"41", x"41", x"41", x"22", x"14", x"08", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"41", x"49", x"49", x"49", x"49", x"36", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"42", x"24", x"18", x"18", x"24", x"42", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"42", x"42", x"42", x"42", x"46", x"3a", x"02", x"42", x"3c", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"7e", x"04", x"08", x"10", x"20", x"7e", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"0c", x"10", x"10", x"10", x"20", x"10", x"10", x"10", x"0c", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"08", x"08", x"08", x"00", x"00", x"08", x"08", x"08", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"18", x"04", x"04", x"04", x"02", x"04", x"04", x"04", x"18", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"30", x"49", x"06", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"24", x"49", x"12", x"24", x"49", x"12", x"24", x"49", x"12", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"22", x"22", x"22", x"22", x"22", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"20", x"20", x"20", x"20", x"20", x"20", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"08", x"08", x"08", x"08", x"08", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"02", x"02", x"02", x"02", x"02", x"02", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"08", x"04", x"1e", x"08", x"04", x"02", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"22", x"36", x"2a", x"36", x"22", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"02", x"04", x"28", x"30", x"20", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"22", x"3e", x"14", x"14", x"36", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"10", x"3c", x"12", x"0a", x"02", x"02", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"08", x"04", x"3e", x"04", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"00", x"00", x"3e", x"00", x"00", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"08", x"08", x"2a", x"1c", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"2a", x"1c", x"08", x"2a", x"1c", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"08", x"10", x"3e", x"10", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"36", x"2a", x"36", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"22", x"2a", x"22", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"22", x"22", x"3e", x"22", x"22", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"2a", x"2a", x"2e", x"22", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"22", x"2e", x"2a", x"2a", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"22", x"3a", x"2a", x"2a", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"2a", x"2a", x"3a", x"22", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"0a", x"04", x"2a", x"30", x"20", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"14", x"14", x"14", x"14", x"14", x"36", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"02", x"02", x"02", x"3e", x"02", x"02", x"02", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"22", x"14", x"08", x"14", x"22", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"08", x"1c", x"1c", x"08", x"08", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"20", x"10", x"08", x"00", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"22", x"3e", x"22", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"2a", x"2a", x"3a", x"22", x"22", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"22", x"22", x"3a", x"2a", x"2a", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"22", x"22", x"2e", x"2a", x"2a", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"2a", x"2a", x"2e", x"22", x"22", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"08", x"08", x"08", x"08", x"00", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"14", x"14", x"14", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"14", x"14", x"3e", x"14", x"3e", x"14", x"14", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"1e", x"28", x"1c", x"0a", x"3c", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"30", x"32", x"04", x"08", x"10", x"26", x"06", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"28", x"28", x"10", x"2a", x"24", x"1a", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"18", x"18", x"10", x"20", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"04", x"08", x"10", x"10", x"10", x"08", x"04", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"08", x"04", x"04", x"04", x"08", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"2a", x"1c", x"3e", x"1c", x"2a", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"08", x"08", x"3e", x"08", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"18", x"18", x"10", x"20", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"18", x"18", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"02", x"04", x"08", x"10", x"20", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"26", x"2a", x"32", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"18", x"08", x"08", x"08", x"08", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"02", x"1c", x"20", x"20", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"02", x"0c", x"02", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"04", x"0c", x"14", x"24", x"3e", x"04", x"04", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"20", x"1c", x"02", x"02", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"0c", x"10", x"20", x"3c", x"22", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"02", x"04", x"08", x"10", x"20", x"20", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"22", x"1c", x"22", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"22", x"1e", x"02", x"04", x"18", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"18", x"18", x"00", x"18", x"18", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"18", x"18", x"00", x"18", x"18", x"10", x"20", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"04", x"08", x"10", x"20", x"10", x"08", x"04", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"3e", x"00", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"08", x"04", x"02", x"04", x"08", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"02", x"04", x"08", x"00", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"02", x"1a", x"2a", x"2a", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"14", x"22", x"22", x"3e", x"22", x"22", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3c", x"12", x"12", x"1c", x"12", x"12", x"3c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"20", x"20", x"20", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3c", x"12", x"12", x"12", x"12", x"12", x"3c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"20", x"20", x"38", x"20", x"20", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"20", x"20", x"38", x"20", x"20", x"20", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1e", x"20", x"20", x"26", x"22", x"22", x"1e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"22", x"22", x"22", x"3e", x"22", x"22", x"22", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"08", x"08", x"08", x"08", x"08", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"02", x"02", x"02", x"02", x"02", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"22", x"24", x"28", x"30", x"28", x"24", x"22", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"20", x"20", x"20", x"20", x"20", x"20", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"22", x"36", x"2a", x"2a", x"22", x"22", x"22", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"22", x"32", x"2a", x"26", x"22", x"22", x"22", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"22", x"22", x"22", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3c", x"22", x"22", x"3c", x"20", x"20", x"20", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"22", x"22", x"2a", x"24", x"1a", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3c", x"22", x"22", x"3c", x"28", x"24", x"22", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"22", x"20", x"1c", x"02", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"08", x"08", x"08", x"08", x"08", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"22", x"22", x"22", x"22", x"22", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"22", x"22", x"22", x"14", x"14", x"08", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"22", x"22", x"22", x"22", x"2a", x"36", x"22", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"22", x"22", x"14", x"08", x"14", x"22", x"22", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"22", x"22", x"14", x"08", x"08", x"08", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3e", x"02", x"04", x"08", x"10", x"20", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"10", x"10", x"10", x"10", x"10", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"20", x"10", x"08", x"04", x"02", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"1c", x"04", x"04", x"04", x"04", x"04", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"14", x"22", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"0c", x"0c", x"08", x"04", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1c", x"02", x"1e", x"22", x"1e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"20", x"20", x"2c", x"32", x"22", x"32", x"2c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1c", x"22", x"20", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"02", x"02", x"1a", x"26", x"22", x"26", x"1a", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1c", x"22", x"3e", x"20", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"04", x"0a", x"08", x"1c", x"08", x"08", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1a", x"26", x"26", x"1a", x"02", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"20", x"20", x"2c", x"32", x"22", x"22", x"22", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"00", x"18", x"08", x"08", x"08", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"02", x"00", x"02", x"02", x"02", x"02", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"20", x"20", x"24", x"28", x"30", x"28", x"24", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"18", x"08", x"08", x"08", x"08", x"08", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"34", x"2a", x"2a", x"2a", x"2a", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"2c", x"32", x"22", x"22", x"22", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1c", x"22", x"22", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"2c", x"32", x"22", x"32", x"2c", x"20", x"20", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1a", x"26", x"22", x"26", x"1a", x"02", x"02", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"2c", x"32", x"20", x"20", x"20", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"1e", x"20", x"1c", x"02", x"3c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"08", x"3e", x"08", x"08", x"0a", x"04", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"22", x"22", x"22", x"26", x"1a", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"22", x"22", x"22", x"14", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"22", x"22", x"2a", x"2a", x"14", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"22", x"14", x"08", x"14", x"22", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"22", x"22", x"22", x"1e", x"02", x"22", x"1c", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"3e", x"04", x"08", x"10", x"3e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"04", x"08", x"08", x"10", x"08", x"08", x"04", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"08", x"08", x"00", x"08", x"08", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"08", x"08", x"04", x"08", x"08", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"2a", x"04", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"14", x"2a", x"14", x"2a", x"14", x"2a", x"14", x"00", x"00", x"00", x"00", x"00", x"00", x"00"
);
begin

	process (clock_a)
	begin
		if rising_edge(clock_a) then

			if clken_a='1' then

				dout_a <= ram(to_integer(unsigned(addr_a)));

			end if;

		end if;
	end process;

	process (clock_b)
	begin
		if rising_edge(clock_b) then

			dout_b <= ram(to_integer(unsigned(addr_b)));

		end if;
	end process;

end;
