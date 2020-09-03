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

entity RamTrueDualPort is
	generic
	(
		ADDR_WIDTH : integer;
		DATA_WIDTH : integer := 8
	);
	port
	(
		-- Port A
		clock_a : in std_logic;
		clken_a : in std_logic;
		addr_a : in std_logic_vector(ADDR_WIDTH-1 downto 0);
		din_a : in std_logic_vector(DATA_WIDTH-1 downto 0);
		dout_a : out std_logic_vector(DATA_WIDTH-1 downto 0);
		wr_a : in std_logic;

		-- Port B
		clock_b : in std_logic;
		addr_b : in std_logic_vector(ADDR_WIDTH-1 downto 0);
		din_b : in std_logic_vector(DATA_WIDTH-1 downto 0);
		dout_b : out std_logic_vector(DATA_WIDTH-1 downto 0);
		wr_b : in std_logic
	);
end RamTrueDualPort;
 
architecture behavior of RamTrueDualPort is 
	constant MEM_DEPTH : integer := 2**ADDR_WIDTH;
	type mem_type is array(0 to MEM_DEPTH) of std_logic_vector(DATA_WIDTH-1 downto 0);
	shared variable ram : mem_type;
begin

	process (clock_a)
	begin
		if rising_edge(clock_a) then

			if clken_a='1' then

				if wr_a = '1' then
					ram(to_integer(unsigned(addr_a))) := din_a;
				end if;

				dout_a <= ram(to_integer(unsigned(addr_a)));

			end if;

		end if;
	end process;

	process (clock_b)
	begin
		if rising_edge(clock_b) then

			if wr_b = '1' then
				ram(to_integer(unsigned(addr_b))) := din_b;
			end if;

			dout_b <= ram(to_integer(unsigned(addr_b)));

		end if;
	end process;

end;
