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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ClockCore is
port
(
    reset : in std_logic;
    clock : in std_logic;

    clktb_3_375 : out std_logic;
    clken_3_375 : out std_logic;
    clock_100_000 : out std_logic;
    clock_25_000 : out std_logic;
    clock_40_000 : out std_logic
);
end ClockCore;

architecture altera of ClockCore is
--    signal clkin1 : std_logic;
    signal clkfbout : std_logic;
    signal clkfbout_buf : std_logic;
    signal clkout0 : std_logic;
    signal clkout1 : std_logic;
    signal clkout2 : std_logic;
    signal clkout3 : std_logic;	
	
	component CLK_3375 is
	port (
		refclk   : in  std_logic := 'X'; -- clk
		rst      : in  std_logic := 'X'; -- reset
		outclk_0 : out std_logic;        -- clk
		outclk_1 : out std_logic;        -- clk
		outclk_2 : out std_logic;        -- clk
		outclk_3 : out std_logic;        -- clk
		locked   : out std_logic         -- export
		);
	end component CLK_3375;

begin

    clken_3_375 <= '1';

	pll_base_inst : CLK_3375
	port map
	(
		refclk   => clock,   		--  refclk.clk
		rst      => '0',      		--   reset.reset
		outclk_0 => clock_100_000, 		-- outclk0.clk
		outclk_1 => clock_25_000, 		-- outclk1.clk
		outclk_2 => clock_40_000, 		-- outclk2.clk
		outclk_3 => clktb_3_375, 		-- outclk3.clk
		locked   => open    		--  locked.export
	);
	
	
end altera;
