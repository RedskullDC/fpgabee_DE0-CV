-- Entity StatusPanel

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
	ram_clock : in std_logic;									-- Z80 clock (slow)
	ram_addr : in std_logic_vector(17 downto 0);				-- 256K
	ram_din : in std_logic_vector(7 downto 0);
	ram_dout : out std_logic_vector(7 downto 0);
	ram_wr : in std_logic;
	ram_rd : in std_logic;
	ram_wait : out std_logic;

	-- Signals to/from off-board SDRAM
    sdClkFb_i : in std_logic;									-- SDRAM clock feedback (fast)
    sdRas_bo : out std_logic;
    sdCas_bo : out std_logic;
    sdWe_bo : out std_logic;
    sdBs_o : out std_logic;
    sdAddr_o : out std_logic_vector(11 downto 0); 
    sdData_io : inout std_logic_vector(15 downto 0)
);
end Z80RamController;

architecture behavior of Z80RamController is 

	signal ram_rd_sync_1 : std_logic := '0';
	signal ram_wr_sync_1 : std_logic := '0';
	signal ram_rd_sync : std_logic := '0';
	signal ram_wr_sync_2 : std_logic := '0';
	signal ram_rd_prev : std_logic := '0';
	signal ram_wr_prev : std_logic := '0';

	signal rd_s				: std_logic;
	signal wr_s				: std_logic;
	signal earlyBegun_s		: std_logic;
	signal begun_s			: std_logic;
	signal rdPending_s		: std_logic;
	signal done_s			: std_logic;
	signal rdDone_s			: std_logic;
	signal hAddr_s			: std_logic_vector(22 downto 0);
	signal hDIn_s			: std_logic_vector(15 downto 0);
	signal hDOut_s			: std_logic_vector(15 downto 0);
	signal sdBs_internal_o 	: std_logic_vector(1 downto 0);

	type state_kind is (state_idle, state_wait_rd, state_delay_then_idle, state_wait_wr);
	signal state : state_kind  := state_idle;

begin

	rd_s <= '1' when state=state_wait_rd else '0';
	wr_s <= '1' when state=state_wait_wr else '0';
	hDIn_s <= "00000000" & ram_din;
	hAddr_s <= "00000" & ram_addr;
	ram_dout <= hDOut_s(7 downto 0);
	ram_wait <= '0' when state=state_idle else '1';

	process (reset, sdClkFb_i)
	begin

		if reset='1' then

			state <= state_idle;
			ram_rd_sync_1 <= '0';
			ram_wr_sync_1 <= '0';
			ram_rd_sync <= '0';
			ram_wr_sync_2 <= '0';
			ram_rd_prev <= '0';
			ram_wr_prev <= '0';

		elsif rising_edge(sdClkFb_i) then

			-- Synchronize control signals and do edge detection
			ram_rd_sync <= ram_rd;
			ram_wr_sync_2 <= ram_wr;
			ram_rd_prev <= ram_rd_sync;
			ram_wr_prev <= ram_wr_sync_2;

			case state is

				when state_idle =>
					if ram_rd_prev='0' and ram_rd_sync='1' then

						-- Start a read
						state <= state_wait_rd;

					elsif ram_wr_prev='0' and ram_wr_sync_2='1' then

						-- Start a write
						state <= state_wait_wr;

					end if;

				when state_wait_rd =>
					if done_s='1' then
						state <= state_delay_then_idle;
					else
					end if;

				when state_wait_wr =>
					if done_s='1' then
						state <= state_idle;
					else
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
		NROWS_G       => 4096,
		NCOLS_G       => 512,
		HADDR_WIDTH_G => 23,			-- Only use 22 though (2 banks lost on XuLA)
		SADDR_WIDTH_G => 12
	)
	port map
	(
		clk_i          => sdClkFb_i,  		-- master clock from external clock source (unbuffered)
		lock_i         => YES,   			-- no DLLs, so frequency is always locked
		rst_i          => reset,        	-- reset
		rd_i           => rd_s,  			-- host-side SDRAM read control
		wr_i           => wr_s,  			-- host-side SDRAM write control
		earlyOpBegun_o => earlyBegun_s, 	-- early indicator that memory operation has begun
		opBegun_o      => begun_s,  		-- indicates memory read/write has begun
		rdPending_o    => rdPending_s,  	-- read operation to SDRAM is in progress_o
		done_o         => done_s,  			-- SDRAM memory read/write done indicator
		rdDone_o       => rdDone_s,  		-- indicates SDRAM memory read operation is done
		addr_i         => hAddr_s,  		-- host-side address from memory tester to SDRAM
		data_i         => hDIn_s,  			-- test data pattern from memory tester to SDRAM
		data_o         => hDOut_s,      	-- SDRAM data output to memory tester
		status_o       => open,  			-- SDRAM controller state (for diagnostics)
--		sdCke_o        => sdCke_o,			-- Not supported on XuLA
--		sdCe_bo        => sdCe_bo,			-- Not supported on XuLA
		sdRas_bo       => sdRas_bo,     	-- SDRAM RAS
		sdCas_bo       => sdCas_bo,     	-- SDRAM CAS
		sdWe_bo        => sdWe_bo,      	-- SDRAM write-enable
		sdBs_o         => sdBs_internal_o,  -- SDRAM bank address
		sdAddr_o       => sdAddr_o,     	-- SDRAM address
		sdData_io      => sdData_io     	-- data to/from SDRAM
--		sdDqmh_o       => sdDqmh_o,  		-- upper-byte enable for SDRAM data bus.	-- Not supported on XuLA
--		sdDqml_o       => sdDqml_o  		-- lower-byte enable for SDRAM data bus.	-- Not supported on XuLA
	);

	sdBs_o <= sdBs_internal_o(0);
end;



