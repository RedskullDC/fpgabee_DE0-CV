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

entity RamSinglePort is
	generic
	(
		ADDR_WIDTH : integer;
		DATA_WIDTH : integer := 8
	);
	port
	(
		clock : in std_logic;
		clken : in std_logic;
		addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
		din : in std_logic_vector(DATA_WIDTH-1 downto 0);
		dout : out std_logic_vector(DATA_WIDTH-1 downto 0);
		wr : in std_logic
	);
end RamSinglePort;
 
architecture behavior of RamSinglePort is 
	constant MEM_DEPTH : integer := 2**ADDR_WIDTH;
	type mem_type is array(0 to MEM_DEPTH) of std_logic_vector(DATA_WIDTH-1 downto 0);
	signal ram : mem_type;
begin

	process (clock)
	begin
		if rising_edge(clock) then

			if clken='1' then 

				if wr = '1' then
					ram(to_integer(unsigned(addr))) <= din;
				end if;

				dout <= ram(to_integer(unsigned(addr)));

			end if;
		end if;
	end process;
end;
