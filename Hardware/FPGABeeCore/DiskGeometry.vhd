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
 
entity DiskGeometry is
	port
	(
		reset : in std_logic;
		clock : in std_logic;
		clken : in std_logic;
		invoke : in std_logic;							-- Assert to start calculation
		ready : out std_logic;							-- Asserts when calculation finished
		error : out std_logic;							-- Indicates track/head/sector out of range

		disk_type : in std_logic_vector(3 downto 0);	-- DISK_xxx constant
		track : in std_logic_vector(15 downto 0);		-- 0 - 511  supported
		head : in std_logic_vector(2 downto 0);			-- 0 - 3    supported
		sector : in std_logic_vector(7 downto 0);		-- 0 - 63   supported

		cluster : out std_logic_vector(16 downto 0)		-- Calculated cluster offset
	);
end DiskGeometry;
 
architecture behavior of DiskGeometry is 

	type states is 
	(
		STATE_READY,
		MUL_PIPE_1,
		MUL_PIPE_2,
		MUL_PIPE_3,
		MUL_PIPE_4,
		MUL_PIPE_5
	);

	signal state : states;

	signal disk_tracks : std_logic_vector(8 downto 0);
	signal disk_heads : std_logic_vector(2 downto 0);
	signal disk_sectors : std_logic_vector(5 downto 0);
	signal disk_data_track : std_logic_vector(1 downto 0);
	signal disk_data_sector : std_logic_vector(4 downto 0);

	signal mult_a : std_logic_vector(8 downto 0);
	signal mult_result : std_logic_vector(14 downto 0);

	signal track_times_sector_per_track : std_logic_vector(14 downto 0);
	signal track_offset : std_logic_vector(16 downto 0);
	signal head_offset : std_logic_vector(7 downto 0);
	signal sector_offset : std_logic_vector(5 downto 0);

	signal masked_track : std_logic_vector(8 downto 0);
	signal masked_sector : std_logic_vector(5 downto 0);
	signal hibit_error : std_logic;
begin

	masked_track <= track(8 downto 0);
	masked_sector <= sector(5 downto 0);
	hibit_error <=
		track(15) or 
		track(14) or 
		track(13) or 
		track(12) or 
		track(11) or 
		track(10) or 
		track(9) or
		sector(7) or
		sector(6);

	-- Main state machine
	process (clock, reset)
	begin

		if reset = '1' then

			state <= STATE_READY;
			mult_a <= (others=>'0');
			track_times_sector_per_track <= (others => '0');
			head_offset <= (others => '0');


		elsif rising_edge(clock) then

			if clken='1' then

				case state is

					when STATE_READY =>

						if invoke='1' then
							mult_a <= masked_track;
							state <= MUL_PIPE_1;
						end if;

					when MUL_PIPE_1 =>
						state <= MUL_PIPE_2;
						mult_a <= "000000" & head;

					when MUL_PIPE_2 =>
						state <= MUL_PIPE_3;

					when MUL_PIPE_3 =>
						state <= MUL_PIPE_4;

					when MUL_PIPE_4 =>
						track_times_sector_per_track <= mult_result;
						state <= MUL_PIPE_5;

					when MUL_PIPE_5 =>
						head_offset <= mult_result(7 downto 0);
						state <= STATE_READY;

				end case;

			end if;

		end if;

	end process;

	-- Calculate the actual sector offset within the track
	process (masked_track, disk_data_track, masked_sector, disk_data_sector)
	begin
		if unsigned(masked_track) >= unsigned(disk_data_track) then
			sector_offset <= std_logic_vector(unsigned(masked_sector) - unsigned(disk_data_sector));
		else
			sector_offset <= std_logic_vector(unsigned(masked_sector) - 1);
		end if;
	end process;

	-- Calculate the final cluster number
	cluster <= std_logic_vector(unsigned(track_offset) + unsigned(head_offset) + unsigned(sector_offset));
	ready <= '1' when state=STATE_READY else '0';

	-- Multiplier for number of disk heads
	process (disk_heads, track_times_sector_per_track)
	begin
		case disk_heads is

			when "001" =>
				-- *1
				track_offset <= "00" & track_times_sector_per_track;

			when "010" =>
				-- *2
				track_offset <= "0" & track_times_sector_per_track & "0";

			when "100" =>
				-- *4
				track_offset <= track_times_sector_per_track & "00";

			when others =>
				track_offset <= (others => '0');

		end case;
	end process;


	-- The multiplier (3 stage pipeline) for sectors_per_track
	DiskControllerMultiplier : entity work.DiskControllerMultiplier
	PORT MAP
	(
		clk => clock,
		clken => clken,
		a => mult_a,
		b => disk_sectors,
		p => mult_result
	);

	-- Error reporting
	process (masked_track, head, sector_offset, disk_tracks, disk_heads, disk_sectors, hibit_error)
	begin

		if disk_heads="000" then
			error <= '1';		-- no disk
		elsif masked_track >= disk_tracks then
			error <= '1';
		elsif head >= disk_heads then
			error <= '1';
		elsif sector_offset >= disk_sectors then
			error <= '1';
		else
			error <= hibit_error;
		end if;

	end process;

	-- Process to generate the geometry of the selected disk type
	process (disk_type)
	begin

		disk_data_track <= "01";
		disk_data_sector <= "00001";

		case disk_type is

			when DISK_DS40 =>
				disk_tracks <= "000101000";		-- 40
				disk_heads <= "010";				-- 2
				disk_sectors <= "001010";			-- 10

			when DISK_SS80 =>
				disk_tracks <= "001010000";		-- 80
				disk_heads <= "001";				-- 1
				disk_sectors <= "001010";			-- 10

			when DISK_DS80 =>
				disk_tracks <= "001010000";		-- 80
				disk_heads <= "010";				-- 2
				disk_sectors <= "001010";			-- 10
				disk_data_track <= "10";			-- 2

			when DISK_DS82 =>
				disk_tracks <= "001010000";		-- 80
				disk_heads <= "010";				-- 2
				disk_sectors <= "001010";			-- 10

			when DISK_DS84 =>
				disk_tracks <= "001010000";		-- 80
				disk_heads <= "010";				-- 2
				disk_sectors <= "001010";			-- 10

			when DISK_DS8B =>
				disk_tracks <= "001010000";		-- 80
				disk_heads <= "010";				-- 2
				disk_sectors <= "001010";			-- 10
				disk_data_track <= "10";			-- 2
				disk_data_sector <= "10101";		-- 21

			when DISK_HD0 =>
				disk_tracks <= "100110010";		-- 306
				disk_heads <= "100";				-- 4
				disk_sectors <= "010001";			-- 17

			when DISK_HD1 =>
				disk_tracks <= "001010000";		-- 80
				disk_heads <= "100";				-- 4
				disk_sectors <= "111111";			-- 63

			when others =>
				disk_tracks <= (others => '0');
				disk_heads <= (others => '0');
				disk_sectors <= (others => '0');

		end case;

	end process;

end;
