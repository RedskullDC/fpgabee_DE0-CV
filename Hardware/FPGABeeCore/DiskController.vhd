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
use work.DiskConstants.ALL;
 
entity DiskController is
	port
	(
		reset : in std_logic;
		clktb_3_375 : in std_logic;								-- CPU Clock
		clken_3_375 : in std_logic;								-- CPU Clock enable
		clock_100_000 : in std_logic; 							-- 100 Mhz clock drives SD Controller

		cpu_port : in std_logic_vector(3 downto 0);			-- low 3 bits of the z80 port
		wr : in std_logic;									-- write signal
		rd : in std_logic;									-- read signal
		din : in std_logic_vector(7 downto 0);				-- output from z80, input to controller
		dout : out std_logic_vector(7 downto 0);			-- output from controller, input to z80

		-- SD Card Signals
		sd_ss_n : out std_logic;
		sd_mosi : out std_logic;
		sd_miso : in std_logic;
		sd_sclk : out std_logic
	);
end DiskController;

-- Registers
--      rd					wr
-- 0	data				data
-- 1	error				precomp
-- 2	sector count		sector count
-- 3	sector number		sector number
-- 4	track lo			track lo
-- 5	track hi			track hi
-- 6	SDH					SDH
-- 7	status				command

-- STA_BUSY       		"10000000"   -- drive busy
-- STA_RDY        		"01000000"   -- drive ready
-- STA_WF         		"00100000"   -- write fault
-- STA_SC         		"00010000"   -- seek complete
-- STA_DRQ        		"00001000"   -- data request bit - drive ready to transfer data
-- STA_CORR       		"00000100"   -- soft error detected
-- STA_NOTUSED    		"00000010"   -- not used
-- STA_ERROR      		"00000001"   -- set when there is a drive error.

-- HDD_SDH_CRCECC     	"10000000"
-- HDD_SDH_SIZE       	"01100000"
-- HDD_SDH_DRIVE      	"00011000"
-- HDD_SDH_HDHEAD     	"00000111"
-- HDD_SDH_FDSEL      	"00000110"
-- HDD_SDH_FDHEAD     	"00000001"

-- HDD_ERR_BAD_BLOCK  	"10000000"   -- bad block detect
-- HDD_ERR_UNREC      	"01000000"   -- unrecoverable error
-- HDD_ERR_CRC_ERR_ID 	"00100000"   -- CRC error ID field
-- HDD_ERR_ID_NFOUND  	"00010000"   -- ID not found
-- HDD_ERR_NOTUSED    	"00001000"   -- -
-- HDD_ERR_ABORT_CMD  	"00000100"   -- aborted command
-- HDD_ERR_TR000      	"00000010"   -- TR000 error
-- HDD_ERR_DAM_NFOUND 	"00000001"   -- DAM not found


 
architecture behavior of DiskController is 

	-- This it the WD1002's "taskfile"
	type regfile_type is array (0 to 7) of std_logic_vector(7 downto 0);
	signal regfile : regfile_type;
	signal reg_status_busy : std_logic;
	signal reg_status_ready : std_logic;
	signal reg_status_sc : std_logic;
	signal reg_status_drq : std_logic;
	signal reg_status_error : std_logic;
	signal reg_error_id_nfound : std_logic;
	signal reg_error_tr000 : std_logic;
	signal reg_error_dam_nfound : std_logic;

	-- These continuous assignments decode the taskfile into more usable representation
	signal reg_track : std_logic_vector(15 downto 0);
	signal reg_drive : std_logic_vector(2 downto 0);
	signal reg_head : std_logic_vector(2 downto 0);
	signal reg_sector : std_logic_vector(7 downto 0);
	signal reg_sector_count : std_logic_vector(7 downto 0);
	signal reg_sdh :std_logic_vector(7 downto 0);

	-- Edge detection the for CPU read/write port signals
	-- (we need this since the Z80 always introduces one wait state
	--  for port instructions and we don't want to inadvertantly double
	--  invoke commands, or increments our DMA buffer address)
	signal wr_prev : std_logic;
	signal rd_prev : std_logic;

	-- Geometry related signals
	signal geo_invoke : std_logic;
	signal geo_ready : std_logic;
	signal geo_error : std_logic;
	signal geo_disk_type : std_logic_vector(3 downto 0);
	signal geo_cluster : std_logic_vector(16 downto 0);
	signal no_disk : std_logic;

	-- Disk operations
	signal multi_sector : std_logic;
	signal calculated_cluster : std_logic_vector(16 downto 0);
	signal calculated_error : std_logic;
	signal diskimage_base_block_number : std_logic_vector(31 downto 0);

	-- DMA buffer - CPU side access (Microbee ports)
	signal secram_addr_plus1 : std_logic_vector(9 downto 0);
	signal secram_addr_inc : std_logic;
	signal secram_we : std_logic;
	signal secram_addr : std_logic_vector(8 DOWNTO 0);
	signal secram_din : std_logic_vector(7 DOWNTO 0);
	signal secram_dout : std_logic_vector(7 DOWNTO 0);

	-- DMA buffer - CPU side access (PCU ports)
	signal pcuram_addr_plus1 : std_logic_vector(9 downto 0);
	signal pcuram_addr_inc : std_logic;
	signal pcuram_we : std_logic;
	signal pcuram_addr : std_logic_vector(8 DOWNTO 0);
	signal pcuram_din : std_logic_vector(7 DOWNTO 0);
	signal pcuram_dout : std_logic_vector(7 DOWNTO 0);

	-- DMA buffer - SD controller side
	signal sdram_we : std_logic;
	signal sdram_mbee_we : std_logic;
	signal sdram_pcu_we : std_logic;
	signal sdram_addr : std_logic_vector(8 DOWNTO 0);
	signal sdram_din : std_logic_vector(7 DOWNTO 0);
	signal sdram_dout : std_logic_vector(7 DOWNTO 0);
	signal sdram_mbee_dout : std_logic_vector(7 DOWNTO 0);
	signal sdram_pcu_dout : std_logic_vector(7 downto 0);
	signal sdram_pcu_cs : std_logic;

	-- SD Controller signals
	signal sd_status : std_logic_vector(2 downto 0);
	signal sd_op_wr : std_logic;
	signal sd_op_cmd : std_logic_vector(1 downto 0);
	signal sd_op_block_number : std_logic_vector(31 downto 0);

	-- Command execution state machine
	type exec_states is 
	(
		STATE_READY,
		STATE_GEO_WAIT_START,
		STATE_GEO_WAIT,
		STATE_SD_WAIT,
		STATE_SD_PCU_WAIT
	);

	type exec_results is
	(
		RESULT_OK,
		RESULT_GEO_ERROR,
		RESULT_SD_ERROR
	);

	-- cmd = 01 = read, 10 = write, 11 = format (read/write same as sd controller)
	signal pending_cmd : std_logic_vector(1 downto 0);	-- Command to execute once buffer filled by host
	signal exec_cmd : std_logic_vector(1 downto 0);		-- Command currently executing (00 if finished)
	signal exec_request : std_logic;					-- Flag to request execution of command
	signal exec_response : std_logic;					-- Flag indicating response from command indication
	signal exec_state : exec_states;					-- Execution state
	signal exec_result : exec_results;					-- Result of the last executed command

	signal pcu_exec_request : std_logic;				-- Request a PCU read/write
	signal pcu_exec_response : std_logic;				-- Indicates response to PCU read/write command
	signal pcu_exec_result : exec_results; 				-- Result of the last executed PCU command	
	signal pcu_exec_write : std_logic;					-- 0 = read 1 = write
	signal pcu_busy : std_logic;						-- 1 = PCU command busy
	signal pcu_error : std_logic;						-- 1 = PCU SD error
	signal pcu_block_number : std_logic_vector(31 downto 0);

	type disk_info_type is record
		base_block_number : std_logic_vector(31 downto 0);
		disk_type : std_logic_vector(3 downto 0);
	end record;

	type disk_info_array_type is array(0 to 7) of disk_info_type;

	signal disk_info_array : disk_info_array_type;
	signal disk_info : disk_info_type;

begin

	-- Select disk info
	disk_info <= disk_info_array(to_integer(unsigned(reg_drive)));
	geo_disk_type <= disk_info.disk_type;
	diskimage_base_block_number <= disk_info.base_block_number;

	-- Decode registers
	reg_sdh <= regfile(6);
	reg_track <= regfile(5) & regfile(4);
	reg_drive <= "1" & reg_sdh(2 downto 1) when reg_sdh(4 downto 3)="11" else "0" & reg_sdh(4 downto 3);
	reg_head <= "00" & reg_sdh(0) when reg_drive(2)='1' else reg_sdh(2 downto 0);
	reg_sector <= regfile(3);
	reg_sector_count <= regfile(2);

	-- Work out if a disk is present
	no_disk <= geo_disk_type(3);

	-- Calculate the next sector buffer address
	secram_addr_plus1 <= std_logic_vector(unsigned('0' & secram_addr) + 1);
	pcuram_addr_plus1 <= std_logic_vector(unsigned('0' & pcuram_addr) + 1);

	-- Multiplex access to the SD Ram buffers, depending on sdram_pcu_cs
	sdram_dout <= sdram_pcu_dout when sdram_pcu_cs='1' else sdram_mbee_dout;
	sdram_mbee_we <= sdram_we and not sdram_pcu_cs;
	sdram_pcu_we <= sdram_we and sdram_pcu_cs;

	-- Front end CPU interface
	process (clktb_3_375, reset)
	begin

		if reset = '1' then

			regfile <= (others=>(others=>'0'));
			reg_status_busy <= '0';
			reg_status_ready <= '1';
			reg_status_sc <= '0';
			reg_status_drq <= '0';
			reg_status_error <= '0';
			reg_error_id_nfound <= '0';
			reg_error_tr000 <= '0';
			reg_error_dam_nfound <= '0';
			multi_sector <= '0';

			wr_prev <= '0';
			rd_prev <= '0';

			secram_addr <= (others=>'0');
			secram_addr_inc <= '0';
			secram_we <= '0';

			pcuram_addr <= (others=>'0');
			pcuram_addr_inc <= '0';
			pcuram_we <= '0';

			pending_cmd <= (others=>'0');
			exec_cmd <= (others=>'0');
			exec_request <= '0';
			pcu_exec_request <= '0';
			pcu_exec_write <= '0';
			pcu_busy <= '0';

			disk_info_array(0).disk_type <= DISK_NONE;
			disk_info_array(1).disk_type <= DISK_NONE;
			disk_info_array(2).disk_type <= DISK_NONE;
			disk_info_array(3).disk_type <= DISK_NONE;
			disk_info_array(4).disk_type <= DISK_NONE;
			disk_info_array(5).disk_type <= DISK_NONE;
			disk_info_array(6).disk_type <= DISK_NONE;
			disk_info_array(7).disk_type <= DISK_NONE;

		elsif rising_edge(clktb_3_375) then

			if clken_3_375='1' then
				-- Track read/write edges
				wr_prev <= wr;
				rd_prev <= rd;

				-- Reset ram write line
				secram_we <= '0';
				pcuram_we <= '0';
				exec_request <= '0';
				pcu_exec_request <= '0';

				-- Increment sector ram address?
				if secram_addr_inc='1' then
					secram_addr <= secram_addr_plus1(8 downto 0);
					secram_addr_inc<='0';
				end if;

				-- Increment pcu ram address?
				if pcuram_addr_inc='1' then
					pcuram_addr <= pcuram_addr_plus1(8 downto 0);
					pcuram_addr_inc<='0';
				end if;

				-- If busy, check for end of operation
				if exec_response='1' then

					-- Clear busy flag
					reg_status_busy <= '0';

					-- Handle result
					case exec_result is

						when RESULT_OK =>
							reg_status_error <= '0';

						when RESULT_GEO_ERROR =>
							reg_status_error <= '1';
							reg_error_tr000 <= '0';
							reg_error_dam_nfound <= '1';
							reg_error_id_nfound <= '1';

						when RESULT_SD_ERROR =>
							reg_status_error <= '1';
							reg_error_tr000 <= '1';
							reg_error_dam_nfound <= '1';
							reg_error_id_nfound <= '0';

					end case;

				end if;

				if pcu_exec_response='1' then
					pcu_busy <= '0';
					if exec_result=RESULT_OK then
						pcu_error <= '0';
					else
						pcu_error <= '1';
					end if;
				end if;

				-- Port write? (ignore all write operations while busy)
				if wr='1' and wr_prev='0' then

					case cpu_port is

						---------- Microbee Ports -----------

						when "0000" =>
							-- WRITE DATA
							secram_din <= din;
							secram_addr_inc <= '1';
							secram_we <= '1';
							if secram_addr_plus1(9)='1' then
								-- Buffer full, trigger the write
								reg_status_drq <= '0';
								exec_cmd <= pending_cmd;
								exec_request <= '1';
								reg_status_busy <= '1';
							end if;

						when "0111" =>
							if reg_status_busy='0' then 
								case din(7 downto 4) is

									when "0001" =>      
										-- RESTORE command
										if no_disk='1' then
											reg_status_error <= '1';
											reg_error_tr000 <= '1';
											reg_error_dam_nfound <= '0';
											reg_error_id_nfound <= '1';
										else
											reg_status_error <= '0';
											reg_status_drq <= '0';
											regfile(4) <= "00000000";	-- Zero cylinder
											regfile(5) <= "00000000";
										end if;

									when "0111" =>      
										-- SEEK command
										reg_status_sc <= '1';

									when "0010" =>      
										-- READ command
										multi_sector <= din(2);
										reg_status_error <= '0';
										reg_status_drq <= '0';
										secram_addr <= (others => '0');
										if din(2)='0' then
											-- sector count = 1
											regfile(2) <= x"01";		
										end if;
										exec_cmd <= "01";
										exec_request <= '1';
										pending_cmd <= "01";
										reg_status_busy <= '1';

									when "0011" =>      
										-- WRITE command
										multi_sector <= din(2);
										reg_status_error <= '0';
										reg_status_drq <= '1';
										secram_addr <= (others => '0');
										if din(2)='0' then
											-- sector count = 1
											regfile(2) <= x"01";		
										end if;
										pending_cmd <= "10";

									when "0101" =>      
										-- FORMAT command
										reg_status_error <= '0';
										reg_status_drq <= '1';
										secram_addr <= (others => '0');
										pending_cmd <= "11";

									when others =>		
										-- UNKNOWN/UNSUPPORTED command
										reg_status_error <= '0';

								end case;
							end if;

						when "0001" | "0010" | "0011" | "0100" | "0101" | "0110" => 
							-- register write
							regfile(to_integer(unsigned(cpu_port))) <= din;

						---------- PCU Ports -----------

						when "1000" =>
							-- WRITE DATA
							pcuram_din <= din;
							pcuram_addr_inc <= '1';
							pcuram_we <= '1';
							if pcuram_addr_plus1(9)='1' and pcu_exec_write='1' then
								-- Buffer full, trigger the write
								pcu_busy <= '1';
								pcu_exec_request <= '1';
							end if;

						when "1001" =>
							-- WRITE BLOCK NUMBER
							-- LSB first
							pcu_block_number <= din & pcu_block_number(31 downto 8);

						when "1111" =>
							-- COMMAND
							if pcu_busy='0' then
								if din(7)='1' then

									disk_info_array(to_integer(unsigned(din(2 downto 0)))).base_block_number <= pcu_block_number;
									disk_info_array(to_integer(unsigned(din(2 downto 0)))).disk_type <= din(6 downto 3);

								elsif din(0)='0' then
									-- READ
									pcuram_addr <= (others=>'0');
									pcu_exec_write <= '0';		-- read
									pcu_exec_request <= '1';
									pcu_busy <= '1';
								else
									-- WRITE
									pcuram_addr <= (others=>'0');
									pcu_exec_write <= '1';
								end if;
							end if;

						when others =>
							null;

					end case;

				elsif rd='1' and rd_prev='0' then

					case cpu_port is

						---------- Microbee Ports -----------

						when "0000" =>
							-- READ DATA
							dout <= secram_dout;
							secram_addr_inc <= '1';
							if secram_addr_plus1(9)='1' then
								reg_status_drq <= '0';
							end if;

						when "0001" =>
							-- ERROR register
							dout <= "000" & reg_error_id_nfound & "00" & reg_error_tr000 & reg_error_dam_nfound;

						when "0111" =>
							-- STATUS register
							dout <= reg_status_busy & reg_status_ready & "0" & reg_status_sc & reg_status_drq & "00" & reg_status_error;

						when "0010" | "0011" | "0100" | "0101" | "0110" => 
							-- REGISTER read
							dout <= regfile(to_integer(unsigned(cpu_port)));

						---------- PCU Ports -----------

						when "1000" =>
							-- READ DATA
							dout <= pcuram_dout;
							pcuram_addr_inc <= '1';

						when "1111" => 
							-- STATUS
							dout <= pcu_busy & sd_status(1) & "00000" & pcu_error;

						when others =>
							dout <= (others=>'0');

					end case;

				end if;

			end if;

		end if;

	end process;

	-- Command execution unit
	process (clktb_3_375, reset)
	begin
		if reset='1' then

			sd_op_wr <= '0';
			exec_state <= STATE_READY;
			exec_result <= RESULT_OK;
			exec_response <= '0';
			geo_invoke <= '0';
			sd_op_block_number <= x"FFFFFFFF";
			sdram_pcu_cs <= '0';
			pcu_exec_response <= '0';
			pcu_exec_result <= RESULT_OK;


		elsif rising_edge(clktb_3_375) then

			if clken_3_375='1' then

				sd_op_wr <= '0';
				exec_response <= '0';
				pcu_exec_response <= '0';
				geo_invoke <= '0';

				case exec_state is


					when STATE_READY =>

						if exec_request='1' then
							geo_invoke <= '1';
							exec_result <= RESULT_OK;
							exec_state <= STATE_GEO_WAIT_START;
							sdram_pcu_cs <= '0';
						end if;

						if pcu_exec_request='1' then
							sdram_pcu_cs <= '1';
							sd_op_block_number <= pcu_block_number;
							if pcu_exec_write='1' then
								sd_op_cmd <= "10";
							else
								sd_op_cmd <= "01";
							end if;
							sd_op_wr <= '1';
							exec_state <= STATE_SD_PCU_WAIT;
						end if;

					when STATE_GEO_WAIT_START =>
						-- The DiskGeometry component requires one cycle after being
						-- invoked before it leaves the ready state.  So pause one
						-- cycle before checking if the calculation has finished.
						exec_state <= STATE_GEO_WAIT;

					when STATE_GEO_WAIT =>

						if geo_ready='1' then

							if geo_error='1' then

								-- Abort with geometry error
								exec_result <= RESULT_GEO_ERROR;
								exec_state <= STATE_READY;
								exec_response <= '1';

							else

								-- Start the read/write request
								sd_op_block_number <= std_logic_vector(unsigned(diskimage_base_block_number) + unsigned(geo_cluster));
								sd_op_cmd <= exec_cmd;
								sd_op_wr <= '1';
								exec_state <= STATE_SD_WAIT;

							end if;

						end if;

					when STATE_SD_WAIT =>

						if sd_status(2)='0' then

							if sd_status(1)='1' then
								exec_result <= RESULT_SD_ERROR;
							else
								exec_result <= RESULT_OK;
							end if;

							exec_state <= STATE_READY;
							exec_response <= '1';

						end if;

					when STATE_SD_PCU_WAIT =>
						if sd_status(2)='0' then

							if sd_status(1)='1' then
								pcu_exec_result <= RESULT_SD_ERROR;
							else
								pcu_exec_result <= RESULT_OK;
							end if;

							exec_state <= STATE_READY;
							pcu_exec_response <= '1';

						end if;

				end case;
			end if;
		end if;
	end process;

	-- Disk geometry calculation unit
	DiskGeometry : entity work.DiskGeometry
	PORT MAP
	(
		reset => reset,
		clock => clktb_3_375,
		clken => clken_3_375,
		invoke => geo_invoke,
		ready => geo_ready,
		error => geo_error,
		disk_type => geo_disk_type,
		track => reg_track,
		head => reg_head,
		sector => reg_sector,
		cluster => geo_cluster
	);

	-- Sector buffer
	DiskControllerRamMbee : entity work.RamTrueDualPort
	GENERIC MAP
	(
		ADDR_WIDTH => 9
	)
	PORT MAP
	(
		clock_a => clktb_3_375,
		clken_a => clken_3_375,
		wr_a => secram_we,
		addr_a => secram_addr,
		din_a => secram_din,
		dout_a => secram_dout,

		clock_b => clock_100_000,
		wr_b => sdram_mbee_we,
		addr_b => sdram_addr,
		din_b => sdram_din,
		dout_b => sdram_mbee_dout
	);

	-- Sector buffer
	DiskControllerRamPcu : entity work.RamTrueDualPort
	GENERIC MAP
	(
		ADDR_WIDTH => 9
	)
	PORT MAP
	(
		clock_a => clktb_3_375,
		clken_a => clken_3_375,
		wr_a => pcuram_we,
		addr_a => pcuram_addr,
		din_a => pcuram_din,
		dout_a => pcuram_dout,

		clock_b => clock_100_000,
		wr_b => sdram_pcu_we,
		addr_b => sdram_addr,
		din_b => sdram_din,
		dout_b => sdram_pcu_dout
	);

	-- SD Card Controller
	SDCardController : entity work.SDCardController
	PORT MAP
	(
		reset => reset,
		clock => clock_100_000,

		ss_n => sd_ss_n,
		mosi => sd_mosi,
		miso => sd_miso,
		sclk => sd_sclk,

		status => sd_status,
		op_wr => sd_op_wr,
		op_cmd => sd_op_cmd,
		op_block_number => sd_op_block_number,

		dma_addr => sdram_addr,
		dma_we => sdram_we,
		dma_dout => sdram_dout,
		dma_din => sdram_din
	);

end;
