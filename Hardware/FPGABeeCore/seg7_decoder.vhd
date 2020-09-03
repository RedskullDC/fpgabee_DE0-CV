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

entity seg7_decoder is
	Port 
	( 
		nibble : in  STD_LOGIC_VECTOR (3 downto 0);
		blank : in STD_LOGIC;
		error : in STD_LOGIC;
      segments : out  STD_LOGIC_VECTOR (6 downto 0)
	);
end seg7_decoder;

architecture Behavioral of seg7_decoder is
begin

	segments <= 
			"1111111" when blank = '1' else
			"0111111" when error = '1' else
			"1000000" when nibble = "0000" else		-- 0
			"1111001" when nibble = "0001" else		-- 1
			"0100100" when nibble = "0010" else		-- 2
			"0110000" when nibble = "0011" else		-- 3
			"0011001" when nibble = "0100" else		-- 4
			"0010010" when nibble = "0101" else		-- 5
			"0000010" when nibble = "0110" else		-- 6
			"1111000" when nibble = "0111" else		-- 7
			"0000000" when nibble = "1000" else		-- 8
			"0010000" when nibble = "1001" else		-- 9
			"0001000" when nibble = "1010" else		-- A
			"0000011" when nibble = "1011" else		-- B
			"1000110" when nibble = "1100" else		-- C
			"0100001" when nibble = "1101" else		-- D
			"0000110" when nibble = "1110" else		-- E
			"0001110";										-- F

end Behavioral;

