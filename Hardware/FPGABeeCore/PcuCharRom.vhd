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

entity PcuCharRom is
	port
	(
		clock : in std_logic;
		addr : in std_logic_vector(10 downto 0);
		dout : out std_logic_vector(7 downto 0)
	);
end PcuCharRom;
 
architecture behavior of PcuCharRom is 
	type mem_type is array(0 to 2047) of std_logic_vector(7 downto 0);
	signal ram : mem_type := (
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"ff", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"10", x"10", x"10", x"10", x"10", x"10", x"10", x"10", x"10", x"10", x"10", x"10", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"f0", x"10", x"10", x"10", x"10", x"10", x"10", x"00", x"00", x"00", x"00", 
x"10", x"10", x"10", x"10", x"10", x"1f", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"10", x"10", x"10", x"10", x"10", x"f0", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"1f", x"10", x"10", x"10", x"10", x"10", x"10", x"00", x"00", x"00", x"00", 
x"10", x"10", x"10", x"10", x"10", x"ff", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"ff", x"10", x"10", x"10", x"10", x"10", x"10", x"00", x"00", x"00", x"00", 
x"10", x"10", x"10", x"10", x"10", x"1f", x"10", x"10", x"10", x"10", x"10", x"10", x"00", x"00", x"00", x"00", 
x"10", x"10", x"10", x"10", x"10", x"f0", x"10", x"10", x"10", x"10", x"10", x"10", x"00", x"00", x"00", x"00", 
x"10", x"10", x"10", x"10", x"10", x"ff", x"10", x"10", x"10", x"10", x"10", x"10", x"00", x"00", x"00", x"00", 
x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"00", x"00", x"00", 
x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"00", x"00", x"00", x"00", 
x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"00", x"00", x"00", x"00", 
x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3c", x"3c", x"3c", x"3c", x"3c", x"3c", x"3c", x"3c", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"10", x"38", x"38", x"7c", x"7c", x"fe", x"fe", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"fe", x"fe", x"7c", x"7c", x"38", x"38", x"10", x"10", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"80", x"c0", x"e0", x"f8", x"fe", x"f8", x"e0", x"c0", x"80", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"02", x"06", x"0e", x"3e", x"fe", x"3e", x"0e", x"06", x"02", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"08", x"1c", x"2a", x"08", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"08", x"08", x"2a", x"1c", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"10", x"08", x"7c", x"08", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"08", x"10", x"3e", x"10", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"55", x"aa", x"55", x"aa", x"55", x"aa", x"55", x"aa", x"55", x"aa", x"55", x"aa", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"10", x"10", x"10", x"10", x"00", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"28", x"28", x"28", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"28", x"28", x"7c", x"28", x"7c", x"28", x"28", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"3c", x"50", x"38", x"14", x"78", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"60", x"64", x"08", x"10", x"20", x"4c", x"0c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"20", x"50", x"50", x"20", x"54", x"48", x"34", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"30", x"30", x"20", x"40", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"10", x"20", x"20", x"20", x"10", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"20", x"10", x"08", x"08", x"08", x"10", x"20", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"54", x"38", x"7c", x"38", x"54", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"10", x"10", x"7c", x"10", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"30", x"30", x"20", x"40", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"7c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"30", x"30", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"04", x"08", x"10", x"20", x"40", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"38", x"44", x"4c", x"54", x"64", x"44", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"30", x"10", x"10", x"10", x"10", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"38", x"44", x"04", x"38", x"40", x"40", x"7c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"38", x"44", x"04", x"18", x"04", x"44", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"18", x"28", x"48", x"7c", x"08", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"7c", x"40", x"38", x"04", x"04", x"44", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"18", x"20", x"40", x"78", x"44", x"44", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"7c", x"04", x"08", x"10", x"20", x"40", x"40", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"38", x"44", x"44", x"38", x"44", x"44", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"38", x"44", x"44", x"3c", x"04", x"08", x"30", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"30", x"30", x"00", x"30", x"30", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"30", x"30", x"00", x"30", x"30", x"20", x"40", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"10", x"20", x"40", x"20", x"10", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7c", x"00", x"7c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"20", x"10", x"08", x"04", x"08", x"10", x"20", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"38", x"44", x"04", x"08", x"10", x"00", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"38", x"44", x"04", x"34", x"54", x"54", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"28", x"44", x"44", x"7c", x"44", x"44", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"78", x"24", x"24", x"38", x"24", x"24", x"78", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"38", x"44", x"40", x"40", x"40", x"44", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"78", x"24", x"24", x"24", x"24", x"24", x"78", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"7c", x"40", x"40", x"70", x"40", x"40", x"7c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"7c", x"40", x"40", x"70", x"40", x"40", x"40", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"3c", x"40", x"40", x"4c", x"44", x"44", x"3c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"44", x"44", x"44", x"7c", x"44", x"44", x"44", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"38", x"10", x"10", x"10", x"10", x"10", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"04", x"04", x"04", x"04", x"04", x"44", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"44", x"48", x"50", x"60", x"50", x"48", x"44", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"40", x"40", x"40", x"40", x"40", x"40", x"7c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"44", x"6c", x"54", x"54", x"44", x"44", x"44", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"44", x"64", x"54", x"4c", x"44", x"44", x"44", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"38", x"44", x"44", x"44", x"44", x"44", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"78", x"44", x"44", x"78", x"40", x"40", x"40", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"38", x"44", x"44", x"44", x"54", x"48", x"34", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"78", x"44", x"44", x"78", x"50", x"48", x"44", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"38", x"44", x"40", x"38", x"04", x"44", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"7c", x"10", x"10", x"10", x"10", x"10", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"44", x"44", x"44", x"44", x"44", x"44", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"44", x"44", x"44", x"28", x"28", x"10", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"44", x"44", x"44", x"44", x"54", x"6c", x"44", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"44", x"44", x"28", x"10", x"28", x"44", x"44", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"44", x"44", x"28", x"10", x"10", x"10", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"7c", x"04", x"08", x"10", x"20", x"40", x"7c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"38", x"20", x"20", x"20", x"20", x"20", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"40", x"20", x"10", x"08", x"04", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"38", x"08", x"08", x"08", x"08", x"08", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"28", x"44", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"7c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"18", x"18", x"10", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"38", x"04", x"3c", x"44", x"3c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"40", x"40", x"58", x"64", x"44", x"64", x"58", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"38", x"44", x"40", x"44", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"04", x"04", x"34", x"4c", x"44", x"4c", x"34", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"38", x"44", x"7c", x"40", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"14", x"10", x"38", x"10", x"10", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"34", x"4c", x"4c", x"34", x"04", x"44", x"38", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"40", x"40", x"58", x"64", x"44", x"44", x"44", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"00", x"30", x"10", x"10", x"10", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"04", x"00", x"04", x"04", x"04", x"04", x"44", x"38", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"40", x"40", x"48", x"50", x"60", x"50", x"48", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"30", x"10", x"10", x"10", x"10", x"10", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"68", x"54", x"54", x"54", x"54", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"58", x"64", x"44", x"44", x"44", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"38", x"44", x"44", x"44", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"58", x"64", x"44", x"64", x"58", x"40", x"40", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"34", x"4c", x"44", x"4c", x"34", x"04", x"04", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"58", x"64", x"40", x"40", x"40", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"3c", x"40", x"38", x"04", x"78", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"10", x"7c", x"10", x"10", x"14", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"44", x"44", x"44", x"4c", x"34", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"44", x"44", x"44", x"28", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"44", x"44", x"54", x"54", x"28", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"44", x"28", x"10", x"28", x"44", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"44", x"44", x"44", x"3c", x"04", x"44", x"38", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"00", x"00", x"7c", x"08", x"10", x"20", x"7c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"08", x"10", x"10", x"20", x"10", x"10", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"10", x"10", x"10", x"00", x"10", x"10", x"10", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"20", x"10", x"10", x"08", x"10", x"10", x"20", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"20", x"54", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
x"00", x"00", x"28", x"54", x"28", x"54", x"28", x"54", x"28", x"00", x"00", x"00", x"00", x"00", x"00", x"00"
);
begin

	process (clock)
	begin
		if rising_edge(clock) then

			dout <= ram(to_integer(unsigned(addr)));

		end if;
	end process;
end;