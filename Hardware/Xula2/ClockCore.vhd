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
    clock_12_000 : in std_logic;

    clktb_3_375 : out std_logic;
    clken_3_375 : out std_logic;
    clock_40_000 : out std_logic;
    clock_100_000 : out std_logic;
    clock_100_000_L : out std_logic
);
end ClockCore;

architecture xilinx of ClockCore is

    signal clock_54_000_int : std_logic;
    signal clkfbout : std_logic;
    signal clkfbout_buf : std_logic;
    signal clock_100_000_P : std_logic;
    signal clock_100_000_N : std_logic;
    signal divide_counter : std_logic_vector(3 downto 0);

begin

    clock_100_000 <= clock_100_000_P;
    clktb_3_375 <= clock_54_000_int;
    clken_3_375 <= '1' when divide_counter="0000" else '0';

    -- Generate clock enable
    process (reset, clock_54_000_int)
    begin
        if reset='1' then
            divide_counter <= (others=>'0');
        elsif rising_edge(clock_54_000_int) then
            divide_counter <= std_logic_vector(unsigned(divide_counter) + 1);
        end if;
    end process;

    --  12Mhz * 9 / 2 = 54Mhz
    DCM_SP_inst_54_000 : DCM_SP
    generic map 
    (
        CLKFX_MULTIPLY => 9,
        CLKFX_DIVIDE => 2
    )
    port map 
    (
        RST => reset,
        CLKIN => clock_12_000,
        CLKFX => clock_54_000_int
    );

    --  12Mhz * 10 / 3 = 40Mhz
    DCM_SP_inst_40_000 : DCM_SP
    generic map 
    (
        CLKFX_MULTIPLY => 10,
        CLKFX_DIVIDE => 3
    )
    port map 
    (
        RST => reset,
        CLKIN => clock_12_000,
        CLKFX => clock_40_000
    );

    --  12Mhz * 25 / 3 = 100Mhz
    DCM_SP_inst_100_000 : DCM_SP
    generic map 
    (
        CLKFX_DIVIDE => 3,
        CLKFX_MULTIPLY => 25
    )
    port map 
    (
        RST => reset,
        CLKIN => clock_12_000,
        CLKFX => clock_100_000_P, 
        CLKFX180 => clock_100_000_N
    );

    -- Use ODDR2 to transfer 100Mhz clock signal from FPGA's clock network to SD RAM controller's clock out
    -- (This stops the synthesis tools from complaining about using a clock as an input
    -- to a logic gate or when driving a pin for an external clock signal.)
    logic_clock_driver : ODDR2
    port map 
    (
        Q  => clock_100_000_L,
        C0 => clock_100_000_P,
        C1 => clock_100_000_N,
        CE => '1',
        D0 => '1',
        D1 => '0',
        R  => '0',
        S  => '0'
    );


--    -- PLL
--    pll_base_inst : PLL_BASE
--    generic map
--    (
--        BANDWIDTH            => "OPTIMIZED",
--        CLK_FEEDBACK         => "CLKFBOUT",
--        COMPENSATION         => "DCM2PLL",
--        DIVCLK_DIVIDE        => 1,
--        CLKFBOUT_MULT        => 10,
--        CLKFBOUT_PHASE       => 0.000,
--        CLKOUT0_DIVIDE       => 80,
--        CLKOUT0_PHASE        => 0.000,
--        CLKOUT0_DUTY_CYCLE   => 0.500,
--        CLKIN_PERIOD         => 37.037,
--        REF_JITTER           => 0.010
--    )
--    port map
--    (
--        RST                 => RESET,
--        CLKIN               => clock_54_000,
--        CLKOUT0             => clock_3_375_nobuf,
--        CLKFBOUT            => clkfbout,
--        CLKFBIN             => clkfbout_buf
--    );
--
--    -- Feedback buffer
--    clkfb_buf : BUFG
--    port map
--    (
--        I => clkfbout,
--        O => clkfbout_buf
--    );

--    -- 3.375 output buffer
--    clkout_3_375_buf : BUFG
--    port map
--    (
--        I   => clock_3_375_nobuf,
--        O   => clock_3_375
--    );

end xilinx;
