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


use WORK.SdramCntlPckg.all;
use work.CommonPckg.all;


entity Z80RamController is
port
(
    reset : in std_logic;

    -- Z80 connections
    ram_addr : in std_logic_vector(17 downto 0);                -- 256K
    ram_din : in std_logic_vector(7 downto 0);
    ram_dout : out std_logic_vector(7 downto 0);
    ram_wr : in std_logic;
    ram_rd : in std_logic;
    ram_wait : out std_logic;

    -- Signals to/from off-board SDRAM
    sdClkFb_i : in std_logic;                                   -- SDRAM clock feedback (fast)
    sdCke_o : out std_logic;      -- Clock-enable to SDRAM.
    sdCe_bo : out std_logic;      -- Chip-select to SDRAM.
    sdRas_bo : out std_logic;
    sdCas_bo : out std_logic;
    sdWe_bo : out std_logic;
    sdBs_o : out std_logic_vector(1 downto 0);
    sdAddr_o : out std_logic_vector(12 downto 0); 
    sdData_io : inout std_logic_vector(15 downto 0);
    sdDqmh_o  : out   std_logic;
    sdDqml_o  : out   std_logic
);
end Z80RamController;

architecture behavior of Z80RamController is 

    signal ram_rd_sync_1 : std_logic := '0';
    signal ram_wr_sync_1 : std_logic := '0';
    signal ram_rd_sync : std_logic := '0';
    signal ram_wr_sync : std_logic := '0';
    signal ram_rd_prev : std_logic := '0';
    signal ram_wr_prev : std_logic := '0';

    signal rd_s             : std_logic;
    signal wr_s             : std_logic;
    signal opBegun_s        : std_logic;
    signal done_s           : std_logic;
    signal hAddr_s          : std_logic_vector(23 downto 0);
    signal hDIn_s           : std_logic_vector(15 downto 0);
    signal hDOut_s          : std_logic_vector(15 downto 0);

--    type state_kind is (state_init, state_idle, state_start_rd, state_start_wr, state_wait_rd, state_wait_wr, state_delay_then_idle);
    type state_kind is (state_idle, state_start_rd, state_start_wr, state_wait_rd, state_wait_wr, state_delay_then_idle);
    signal state : state_kind  := state_idle;
--    signal init_cycles : std_logic_vector(14 downto 0);

begin

    rd_s <= '1' when state=state_wait_rd or state=state_start_rd else '0';
    wr_s <= '1' when state=state_wait_wr or state=state_start_wr else '0';
    hDIn_s <= "00000000" & ram_din;
    hAddr_s <= "000000" & ram_addr;
    ram_dout <= hDOut_s(7 downto 0);
    ram_wait <= '0' when state=state_idle else '1';

    process (reset, sdClkFb_i)
    begin

        if reset='1' then

            ram_rd_sync_1 <= '0';
            ram_wr_sync_1 <= '0';
            ram_rd_sync <= '0';
            ram_wr_sync <= '0';
            ram_rd_prev <= '0';
            ram_wr_prev <= '0';
--            init_cycles <= "111111111111111";
--            state <= state_init;

        elsif rising_edge(sdClkFb_i) then

            -- Synchronize control signals and do edge detection
            ram_rd_sync_1 <= ram_rd;
            ram_wr_sync_1 <= ram_wr;
            ram_rd_sync <= ram_rd_sync_1;
            ram_wr_sync <= ram_wr_sync_1;
            ram_rd_prev <= ram_rd_sync;
            ram_wr_prev <= ram_wr_sync;

            case state is

--                when state_init =>
--                    if init_cycles="000000000000000" then  
--                        state <= state_idle;
--                    else
--                        init_cycles <= std_logic_vector(unsigned(init_cycles) -1);
--                    end if;
--
                when state_idle =>
                    if ram_rd_prev='0' and ram_rd_sync='1' then

                        -- Start a read
                        state <= state_start_rd;

                    elsif ram_wr_prev='0' and ram_wr_sync='1' then

                        -- Start a write
                        state <= state_start_wr;

                    end if;

                when state_start_rd =>
                    if opBegun_s='1' then
                        state <= state_wait_rd;
                    end if;

                when state_wait_rd =>
                    if done_s='1' then
                        state <= state_delay_then_idle;
                    end if;

                when state_start_wr =>
                    if opBegun_s='1' then
                        state <= state_wait_wr;
                    end if;

                when state_wait_wr =>
                    if done_s='1' then
                        state <= state_delay_then_idle;
                    end if;

                when state_delay_then_idle =>
                    state <= state_idle;

            end case;

        end if;

    end process;


    sdram : SdramCntl
    generic map
    (
        FREQ_G        => 100.0,
        IN_PHASE_G    => true,
        PIPE_EN_G     => false,
        MAX_NOP_G     => 10000,
        DATA_WIDTH_G  => 16,
        NROWS_G       => 8192,
        NCOLS_G       => 512,
        HADDR_WIDTH_G => 24,
        SADDR_WIDTH_G => 13
    )
    port map
    (
        clk_i          => sdClkFb_i,        -- master clock from external clock source (unbuffered)
        lock_i         => YES,              -- no DLLs, so frequency is always locked
        rst_i          => reset,            -- reset
        rd_i           => rd_s,             -- host-side SDRAM read control
        wr_i           => wr_s,             -- host-side SDRAM write control
        earlyOpBegun_o => open,             -- early indicator that memory operation has begun
        opBegun_o      => opBegun_s,        -- indicates memory read/write has begun
        rdPending_o    => open,             -- read operation to SDRAM is in progress_o
        done_o         => done_s,           -- SDRAM memory read/write done indicator
        rdDone_o       => open,             -- indicates SDRAM memory read operation is done
        addr_i         => hAddr_s,          -- host-side address from memory tester to SDRAM
        data_i         => hDIn_s,           -- test data pattern from memory tester to SDRAM
        data_o         => hDOut_s,          -- SDRAM data output to memory tester
        status_o       => open,             -- SDRAM controller state (for diagnostics)
        sdCke_o        => sdCke_o,          -- 
        sdCe_bo        => sdCe_bo,          -- 
        sdRas_bo       => sdRas_bo,         -- SDRAM RAS
        sdCas_bo       => sdCas_bo,         -- SDRAM CAS
        sdWe_bo        => sdWe_bo,          -- SDRAM write-enable
        sdBs_o         => sdBs_o,           -- SDRAM bank address
        sdAddr_o       => sdAddr_o,         -- SDRAM address
        sdData_io      => sdData_io,        -- data to/from SDRAM
        sdDqmh_o       => sdDqmh_o,         -- upper-byte enable for SDRAM data bus.
        sdDqml_o       => sdDqml_o          -- lower-byte enable for SDRAM data bus.
    );
end;



