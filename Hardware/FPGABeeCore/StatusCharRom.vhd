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


entity StatusCharRom is
	port
	(
		clock : in std_logic;
		addr : in std_logic_vector(7 downto 0);
		dout : out std_logic_vector(7 downto 0)
	);
end StatusCharRom;
 
architecture behavior of StatusCharRom is 
	type mem_type is array(0 to 255) of std_logic_vector(7 downto 0);
	signal rom : mem_type := 
	(
		x"38", x"44", x"4c", x"54", x"64", x"44", x"38", x"00", 		-- 0
		x"10", x"30", x"10", x"10", x"10", x"10", x"38", x"00", 		-- 1
		x"38", x"44", x"04", x"38", x"40", x"40", x"7c", x"00", 		-- 2
		x"38", x"44", x"04", x"18", x"04", x"44", x"38", x"00", 		-- 3
		x"08", x"18", x"28", x"48", x"7c", x"08", x"08", x"00", 		-- 4
		x"7c", x"40", x"38", x"04", x"04", x"44", x"38", x"00", 		-- 5
		x"18", x"20", x"40", x"78", x"44", x"44", x"38", x"00", 		-- 6
		x"7c", x"04", x"08", x"10", x"20", x"40", x"40", x"00", 		-- 7
		x"38", x"44", x"44", x"38", x"44", x"44", x"38", x"00", 		-- 8
		x"38", x"44", x"44", x"3c", x"04", x"08", x"30", x"00", 		-- 9
		x"10", x"28", x"44", x"44", x"7c", x"44", x"44", x"00", 		-- A
		x"78", x"24", x"24", x"38", x"24", x"24", x"78", x"00", 		-- B
		x"38", x"44", x"40", x"40", x"40", x"44", x"38", x"00", 		-- C
		x"78", x"24", x"24", x"24", x"24", x"24", x"78", x"00", 		-- D
		x"7c", x"40", x"40", x"70", x"40", x"40", x"7c", x"00", 		-- E
		x"7c", x"40", x"40", x"70", x"40", x"40", x"40", x"00", 		-- F
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 		-- space
		x"3c", x"24", x"24", x"24", x"24", x"24", x"3c", x"00", 		-- LED Off
		x"3c", x"3c", x"3c", x"3c", x"3c", x"3c", x"3c", x"00",	 		-- LED On
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00" 
	);
begin

	process (clock)
	begin
		if rising_edge(clock) then
			dout <= rom(to_integer(unsigned(addr)));
		end if;
	end process;
end;