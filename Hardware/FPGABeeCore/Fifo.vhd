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

entity Fifo is
	generic
	(
		ADDR_WIDTH : integer;
		DATA_WIDTH : integer := 8
	);
	port
	(
		reset : in std_logic;
		clock_rd : in std_logic;
		clken_rd : in std_logic;
		clock_wr : in std_logic;
		clken_wr : in std_logic;
		full : out std_logic;
		available : out std_logic;
		din : in std_logic_vector(DATA_WIDTH-1 downto 0);
		dout : out std_logic_vector(DATA_WIDTH-1 downto 0);
		wr : in std_logic;
		rd : in std_logic
	);
end Fifo;
 
architecture behavior of Fifo is 
	constant MEM_DEPTH : integer := 2**ADDR_WIDTH;
	type mem_type is array(0 to MEM_DEPTH) of std_logic_vector(DATA_WIDTH-1 downto 0);
	signal ram : mem_type;
	signal wrat : std_logic_vector(ADDR_WIDTH-1 downto 0);
	signal rdat : std_logic_vector(ADDR_WIDTH-1 downto 0);
	signal wrat_plus1 : std_logic_vector(ADDR_WIDTH-1 downto 0);
	signal rdat_plus1 : std_logic_vector(ADDR_WIDTH-1 downto 0);
	signal full_internal : std_logic;
	signal empty_internal : std_logic;
begin

	wrat_plus1 <= std_logic_vector(unsigned(wrat)+1);
	rdat_plus1 <= std_logic_vector(unsigned(rdat)+1);
	empty_internal <= '1' when wrat=rdat else '0';
	full_internal <= '1' when wrat_plus1=rdat else '0';
	available <= NOT empty_internal;
	full <= full_internal;

	dout <= ram(to_integer(unsigned(rdat)));

	process (clock_wr, reset)
	begin
		if reset = '1' then

			wrat <= (others=>'0');

		elsif rising_edge(clock_wr) then

			if clken_wr='1' then

				if wr='1' and full_internal='0' then
					ram(to_integer(unsigned(wrat))) <= din;
					wrat <= wrat_plus1;
				end if;

			end if;

		end if;
	end process;


	process (clock_rd, reset)
	begin
		if reset = '1' then

			rdat <= (others=>'0');

		elsif rising_edge(clock_rd) then

			if clken_rd='1' then

				if rd='1' and empty_internal='0' then
					rdat <= rdat_plus1;
				end if;

			end if;
			
		end if;
	end process;
end;
