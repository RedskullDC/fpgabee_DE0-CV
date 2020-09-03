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

library unisim;
use unisim.vcomponents.all;

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

architecture xilinx of ClockCore is
    signal clkin1 : std_logic;
    signal clkfbout : std_logic;
    signal clkfbout_buf : std_logic;
    signal clkout0 : std_logic;
    signal clkout1 : std_logic;
    signal clkout2 : std_logic;
    signal clkout3 : std_logic;
begin

    clken_3_375 <= '1';

    -- Input buffer
    clkin1_buf : IBUFG
    port map
    (
        I => clock,
        O => clkin1
    );


    -- PLL
    pll_base_inst : PLL_BASE
    generic map
    (
        BANDWIDTH => "OPTIMIZED",
        CLK_FEEDBACK => "CLKFBOUT",
        COMPENSATION => "SYSTEM_SYNCHRONOUS",
        DIVCLK_DIVIDE => 1,
        CLKFBOUT_MULT => 4,
        CLKFBOUT_PHASE => 0.000,
        CLKOUT0_DIVIDE => 119,
        CLKOUT0_PHASE => 0.000,
        CLKOUT0_DUTY_CYCLE => 0.500,
        CLKOUT1_DIVIDE => 4,
        CLKOUT1_PHASE => 0.000,
        CLKOUT1_DUTY_CYCLE => 0.500,
        CLKOUT2_DIVIDE => 16,
        CLKOUT2_PHASE => 0.000,
        CLKOUT2_DUTY_CYCLE => 0.500,
        CLKOUT3_DIVIDE => 10,
        CLKOUT3_PHASE => 0.000,
        CLKOUT3_DUTY_CYCLE => 0.500,
        CLKIN_PERIOD => 10.0,
        REF_JITTER => 0.010
    )
    port map
    (
        RST => RESET,
        CLKIN => clkin1,
        CLKFBOUT => clkfbout,
        CLKFBIN => clkfbout_buf,
        CLKOUT0 => clkout0,
        CLKOUT1 => clkout1,
        CLKOUT2 => clkout2,
        CLKOUT3 => clkout3,
        CLKOUT4 => open,
        CLKOUT5 => open,
        LOCKED => open
    );

    clkf_buf : BUFG
    port map
    (
        I => clkfbout,
        O => clkfbout_buf
    );


    clkout1_buf : BUFG
    port map
    (
        I => clkout0,
        O => clktb_3_375
    );

    clkout2_buf : BUFG
    port map
    (
        I => clkout1,
        O => clock_100_000
    );

    clkout3_buf : BUFG
    port map
    (
        I => clkout2,
        O => clock_25_000
    );

    clkout4_buf : BUFG
    port map
    (
        I => clkout3,
        O => clock_40_000
    );

end xilinx;
