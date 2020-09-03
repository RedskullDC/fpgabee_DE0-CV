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

entity SDCardController is
	port 
	(
		-- Clocking
		reset : in std_logic;
		clock : in std_logic;

		-- SD Card Signals
		ss_n : out std_logic;
		mosi : out std_logic;
		miso : in std_logic;
		sclk : out std_logic;

		-- Status signals
		status : out std_logic_vector(2 downto 0);

		-- Operation
		op_wr : in std_logic;
		op_cmd : in std_logic_vector(1 downto 0);
		op_block_number : in std_logic_vector(31 downto 0);
				
		-- DMA access
		dma_addr : out std_logic_vector(8 downto 0);
		dma_we : out std_logic;
		dma_dout : in std_logic_vector(7 downto 0);
		dma_din : out std_logic_vector(7 downto 0)

	);

end SDCardController;

architecture Behavioral of SDCardController is

	type states is 
	(
		RST,
		INIT,
		CMD0,
		CMD55,
		CMD41,
		POLL_CMD,
	  
		IDLE,					-- wait for op_cmd
		READ_BLOCK,
		READ_BLOCK_WAIT,
		READ_BLOCK_DATA,
		READ_BLOCK_CRC,
		SEND_CMD,
		RECEIVE_BYTE_WAIT,
		RECEIVE_BYTE,
		WRITE_BLOCK,
		WRITE_BLOCK_INIT,		-- initialise write command
		WRITE_BLOCK_DATA,		-- loop through all data bytes
		WRITE_BLOCK_BYTE,		-- send one byte
		WRITE_BLOCK_WAIT,		-- wait until not busy
		READ_CSD,
		WRITE_DMA,
		ERROR

	);

	constant STATUS_READY : std_logic_vector(2 downto 0) :=   "000";		-- second bit = error
	constant STATUS_NOCARD : std_logic_vector(2 downto 0) :=  "010";
	constant STATUS_ERROR : std_logic_vector(2 downto 0) :=   "011";		
	constant STATUS_READING : std_logic_vector(2 downto 0) := "110";		-- hi bit = busy
	constant STATUS_WRITING : std_logic_vector(2 downto 0) := "111";


	-- one start byte, plus 512 bytes of data, plus two FF end bytes (CRC)
	constant WRITE_DATA_SIZE : integer := 515;

	signal op_wr_prev, op_wr_sync, op_wr_sync1 : std_logic;

	signal state, return_state : states;
	signal sclk_sig : std_logic := '0';
	signal cmd_out : std_logic_vector(55 downto 0);
	signal recv_data : std_logic_vector(7 downto 0);
	signal cmd_mode : std_logic := '1';
	signal response_mode : std_logic := '1';
	signal data_sig : std_logic_vector(7 downto 0) := x"00";

	signal clock_div_limit : unsigned(7 downto 0);
	signal clock_div, clock_div_next : unsigned(7 downto 0);
	signal clock_en : std_logic;

	signal dma_addr_reg : std_logic_vector(8 downto 0);
	signal cmd_address : std_logic_vector(31 downto 0);

begin
  	
	clock_en <= '1' when clock_div = (clock_div_limit-1) else '0';
	clock_div_next <= (others=>'0') when clock_en='1' else clock_div + 1;

	-- Convert block number to SD card address (*512)
	cmd_address <= op_block_number(22 downto 0) & "000000000";

	process(reset,clock)
	begin
		if reset = '1' then
			clock_div <= (others=>'0');
		elsif rising_edge(clock) then
			clock_div <= clock_div_next;
		end if;
	end process;

	dma_din <= recv_data;
	dma_we <= '1' when state = WRITE_DMA else '0';
	dma_addr <= dma_addr_reg;

 
	process(clock,reset)
		variable byte_counter : integer range 0 to WRITE_DATA_SIZE;
		variable bit_counter : integer range 0 to 160;
	begin

		if reset='1' then
		
 			state <= RST;
			sclk_sig <= '0';

			op_wr_sync1 <= '0';
			op_wr_sync <= '0';
			op_wr_prev <= '0';

		elsif rising_edge(clock) then

			op_wr_sync1 <= op_wr;		-- sync to this clock domain
			op_wr_sync <= op_wr_sync1;	-- sync to this clock domain
			op_wr_prev <= op_wr_sync;	-- edge detect

			-- reset?
			if op_wr_prev = '0' and op_wr_sync = '1' and op_cmd="00" then
				state <= RST;
			end if;

			case state is

				when RST =>
					clock_div_limit <= to_unsigned(125, 8);
					sclk_sig <= '0';
					cmd_out <= (others => '1');
					byte_counter := 512;
					cmd_mode <= '1'; 		-- 0=data, 1=command
					response_mode <= '1';	-- 0=data, 1=command
					bit_counter := 160;
					ss_n <= '1';
					state <= INIT;
					status <= STATUS_NOCARD;

				when INIT =>				-- ss_n=1, send 80 clocks, ss_n=0
					if clock_en='1' then
						if bit_counter = 0 then
							ss_n <= '0';
							state <= CMD0;
						else
							bit_counter := bit_counter - 1;
							sclk_sig <= not sclk_sig;
						end if;	
					end if;
				
				when CMD0 =>
					cmd_out <= x"FF400000000095";
					bit_counter := 55;
					return_state <= CMD55;
					state <= SEND_CMD;

				when CMD55 =>
					cmd_out <= x"FF770000000001";	-- 55d OR 40h = 77h
					bit_counter := 55;
					return_state <= CMD41;
					state <= SEND_CMD;
				
				when CMD41 =>
					cmd_out <= x"FF690000000001";	-- 41d OR 40h = 69h
					bit_counter := 55;
					return_state <= POLL_CMD;
					state <= SEND_CMD;
			
				when POLL_CMD =>
					if recv_data(0) = '0' then
						state <= IDLE;
						clock_div_limit <= to_unsigned(2, 8);
					else
						state <= CMD55;
						byte_counter := byte_counter-1;
						if byte_counter=1 then
							state <= RST;
						end if;
					end if;
			
				when IDLE=>
					status <= STATUS_READY;
					if op_wr_prev = '0' and op_wr_sync = '1' then

						case op_cmd is

							when "01" =>		-- read
								state <= READ_BLOCK;

							when "10" =>		-- write
								state <= WRITE_BLOCK;

							when others =>		-- read CSD
								state <= IDLE;

						end case;
					end if;

				when READ_BLOCK =>
					status <= STATUS_READING;
					dma_addr_reg <= "000000000";
					cmd_mode <= '1';
					cmd_out <= x"FF" & x"51" & cmd_address & x"FF";
					bit_counter := 55;
					state <= SEND_CMD;
					return_state <= READ_BLOCK_WAIT;
				
				when READ_BLOCK_WAIT =>
					if clock_en='1' then
						if sclk_sig='1' then
							if miso='0' then
								byte_counter := 511;
								bit_counter := 7;
								state <= RECEIVE_BYTE;
								return_state <= WRITE_DMA;
							end if;
						end if;
						sclk_sig <= not sclk_sig;
					end if;

				when WRITE_DMA =>
					state <= READ_BLOCK_DATA;

				when READ_BLOCK_DATA =>
					if byte_counter = 0 then
						bit_counter := 7;
						return_state <= READ_BLOCK_CRC;
						state <= RECEIVE_BYTE;
					else
						byte_counter := byte_counter - 1;
						bit_counter := 7;
						state <= RECEIVE_BYTE;
						dma_addr_reg <= std_logic_vector(unsigned(dma_addr_reg) + 1);
						return_state <= WRITE_DMA;
					end if;
			
				when READ_BLOCK_CRC =>
					bit_counter := 7;
					return_state <= IDLE;
					state <= RECEIVE_BYTE;
			
				when SEND_CMD =>
					if clock_en='1' then
						if sclk_sig = '1' then
							if bit_counter = 0 then
								state <= RECEIVE_BYTE_WAIT;
							else
								bit_counter := bit_counter - 1;
								cmd_out <= cmd_out(54 downto 0) & '1';
							end if;
						end if;
						sclk_sig <= not sclk_sig;
					end if;
				
				when RECEIVE_BYTE_WAIT =>
					if clock_en='1' then
						if sclk_sig = '1' then
							if miso = '0' then
								recv_data <= (others => '0');
								if response_mode='0' then
									bit_counter := 3; -- already read bits 7..4
								else
									bit_counter := 6; -- already read bit 7
								end if;
								state <= RECEIVE_BYTE;
							end if;
						end if;
						sclk_sig <= not sclk_sig;
					end if;

				when RECEIVE_BYTE =>
					if clock_en='1' then
						if sclk_sig = '1' then
							recv_data <= recv_data(6 downto 0) & miso;
							if bit_counter = 0 then
								state <= return_state;
							else
								bit_counter := bit_counter - 1;
							end if;
						end if;
						sclk_sig <= not sclk_sig;
					end if;

				when WRITE_BLOCK =>
					status <= STATUS_WRITING;
					dma_addr_reg <= "000000000";
					cmd_mode <= '1';
					cmd_out <= x"FF" & x"58" & cmd_address & x"FF";	-- single block
					bit_counter := 55;
					state <= SEND_CMD;
					return_state <= WRITE_BLOCK_INIT;
					
				when WRITE_BLOCK_INIT => 
					cmd_mode <= '0';
					byte_counter := WRITE_DATA_SIZE; 
					state <= WRITE_BLOCK_DATA;
					
				when WRITE_BLOCK_DATA => 
					if byte_counter = 0 then
						state <= RECEIVE_BYTE_WAIT;
						return_state <= WRITE_BLOCK_WAIT;
						response_mode <= '0';
					else 	
						if (byte_counter = 2) or (byte_counter = 1) then
							data_sig <= x"FF"; -- two CRC bytes
						elsif byte_counter = WRITE_DATA_SIZE then
							data_sig <= x"FE"; -- start byte, single block
						else
							data_sig <= dma_dout;
							dma_addr_reg <= std_logic_vector(unsigned(dma_addr_reg) + 1);
						end if;
						bit_counter := 7;
						state <= WRITE_BLOCK_BYTE;
						byte_counter := byte_counter - 1;
					end if;
				
				when WRITE_BLOCK_BYTE => 
					if clock_en = '1' then
						if sclk_sig = '1' then
							if bit_counter=0 then
								state <= WRITE_BLOCK_DATA;
							else
								data_sig <= data_sig(6 downto 0) & '1';
								bit_counter := bit_counter - 1;
							end if;
						end if;
						sclk_sig <= not sclk_sig;
					end if;
					
				when WRITE_BLOCK_WAIT =>
					if clock_en = '1' then
						response_mode <= '1';
						if sclk_sig='1' then
							if MISO='1' then
								state <= IDLE;
							end if;
						end if;
						sclk_sig <= not sclk_sig;
					end if;

				when others => 
					status <= STATUS_ERROR;
			end case;
		end if;
	end process;

  sclk <= sclk_sig;
  mosi <= cmd_out(55) when cmd_mode='1' else data_sig(7);
  
end Behavioral;


