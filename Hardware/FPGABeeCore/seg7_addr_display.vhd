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
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seg7_addr_display is
    Port 
    ( 
    	clk : in  std_logic;
		reset : in  std_logic;
		blank : in std_logic;
		error : in std_logic;
		addr : in std_logic_vector(15 downto 0);
		cath : out  std_logic_vector(7 downto 0);			-- Output cathodes
		an : out  std_logic_vector(3 downto 0)				-- Output anodes
	);
end seg7_addr_display;

architecture Behavioral of seg7_addr_display is

	-- divide input clock
	constant COUNTER_BITS: integer:=16;
	signal counter, counter_next : unsigned(COUNTER_BITS-1 downto 0);
	
	-- selected digit/nibble
	signal digit_index: std_logic_vector (1 downto 0);
	signal nibble: std_logic_vector (3 downto 0);
	

begin

	process(clk, reset)
	begin
		if reset='1' then
			counter <= (others=>'0');
		elsif (clk'event and clk='1') then
			counter <= counter_next;
		end if; 
	end process;
	
	-- Next state
	counter_next <= counter + 1;
	
	-- Use the top two bits of the counter as the digit index that's to be display
	digit_index <= std_logic_vector(counter(COUNTER_BITS-1 downto COUNTER_BITS-2));
	process(digit_index, addr)
	begin
		case digit_index is
			when "00" =>
				an <= "1110";
				nibble <= addr(3 downto 0);
			when "01" =>
				an <= "1101";
				nibble <= addr(7 downto 4);
			when "10" =>
				an <= "1011";
				nibble <= addr(11 downto 8);
			when others =>
				an <= "0111";
				nibble <= addr(15 downto 12);
			end case;
	end process;

	-- Decode the selected nibble
	decoder: entity work.seg7_decoder 
		port map (
			nibble => nibble,
			blank => blank,
			error => error,
			segments => cath(6 downto 0)
		);
		
	-- Turn off decimal point
	cath(7) <= '1';
		

end Behavioral;

