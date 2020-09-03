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

entity seg7_display is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  addr : in STD_LOGIC_VECTOR (1 downto 0);
           din : in  STD_LOGIC_VECTOR (3 downto 0);
			  wea : in STD_LOGIC;
           cath : out  STD_LOGIC_VECTOR (7 downto 0);			-- Output cathodes
           an : out  STD_LOGIC_VECTOR (3 downto 0)			   -- Output anodes
			);	
end seg7_display;

architecture Behavioral of seg7_display is

	-- divide input clock
	constant COUNTER_BITS: integer:=16;
	signal counter, counter_next : unsigned(COUNTER_BITS-1 downto 0);
	
	type nibarray is array(0 to 3) of std_logic_vector(3 downto 0);
	
	-- selected digit/nibble
	signal digit_index: STD_LOGIC_VECTOR (1 downto 0);
	signal nibble: STD_LOGIC_VECTOR (3 downto 0);
	signal mem: nibarray;

begin

	process(clk, reset)
	begin
		if reset='1' then
			mem(0) <= x"E";
			mem(1) <= x"C";
			mem(2) <= x"A";
			mem(3) <= x"F";
			counter <= (others=>'0');
		elsif (clk'event and clk='1') then
			counter <= counter_next;
			if (wea='1') then
				mem(to_integer(signed(addr))) <= din;
			end if;
		end if; 
	end process;
	
	-- Next state
	counter_next <= counter + 1;
	
	-- Use the top two bits of the counter as the digit index that's to be display
	digit_index <= std_logic_vector(counter(COUNTER_BITS-1 downto COUNTER_BITS-2));
	nibble <= mem(to_integer(signed(digit_index)));
	process(digit_index)
	begin
		case digit_index is
			when "00" =>
				an <= "1110";
			when "01" =>
				an <= "1101";
			when "10" =>
				an <= "1011";
			when others =>
				an <= "0111";
			end case;
	end process;

	-- Decode the selected nibble
	decoder: entity work.seg7_decoder 
		port map (
			nibble => nibble,
			blank => '0',
			error => '0',
			segments => cath(6 downto 0)
		);
		
	-- Turn off decimal point
	cath(7) <= '1';
		

end Behavioral;

