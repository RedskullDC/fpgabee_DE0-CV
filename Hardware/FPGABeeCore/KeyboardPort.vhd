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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity KeyboardPort is  Port 
	( 
		clock : in STD_LOGIC;
		reset : in STD_LOGIC;
		
		PS2KeyboardData : inout STD_LOGIC;
      	PS2KeyboardClk : inout STD_LOGIC;
		
		KeyboardMessageAvailable : out STD_LOGIC;						-- Asserted for 320ns when KeyboardMessage valid
		KeyboardMessage : out STD_LOGIC_VECTOR(9 downto 0) 				-- bit 8 = extended flag
																		-- bit 9 = key up flag
																				
	);
end KeyboardPort;

architecture Behavioral of KeyboardPort is

	signal rx_read : std_logic;
	signal rx_data : std_logic_vector(7 downto 0);
	signal rx_err : std_logic;
	signal keyb_state_break : std_logic;
	signal keyb_state_extended : std_logic;
	signal KeyboardMessageAvailable_delay1 : std_logic;
	signal PulseCounter, PulseCounter_next : unsigned(4 downto 0);

begin

	-- PS2 Decoder
	ps2interface: entity work.ps2interface PORT MAP(
		ps2_clk => PS2KeyboardClk,
		ps2_data => PS2KeyboardData,
		clk => clock,
		rst => reset,
		tx_data => "00000000",
		write => '0',
		rx_data => rx_data,
		read => rx_read,
		busy => open,
		err => rx_err
	);
	
	PulseCounter_next <= PulseCounter + 1;
	
	-- Process to read the PS2 keys, look them up with ScanCodeMapper and 
	-- store key switch states in "keys" register
	process (clock, reset)
	begin
	
		if reset='1' then
		
			keyb_state_break <= '0';
			keyb_state_extended <= '0';
			
			PulseCounter <= (others => '0');
			KeyboardMessageAvailable <= '0';
			KeyboardMessageAvailable_delay1 <= '0';
			KeyboardMessage <= (others=>'0');
		
		elsif rising_edge(clock) then
		
			-- Forward on the delayed available flag
			KeyboardMessageAvailable <= KeyboardMessageAvailable_delay1;
			
			PulseCounter <= PulseCounter_next;
			
			if PulseCounter_next = 0 then
				KeyboardMessageAvailable_delay1 <= '0';
			end if;
		
			if rx_err = '1' then
			
				keyb_state_break <= '0';
				keyb_state_extended <= '0';
		
			elsif rx_read = '1' then
			
				if rx_data = x"f0" then
				
					-- Remember its a key up, not down
					keyb_state_break <= '1';
				
				elsif rx_data = x"e0" then
				
					-- Remember it's an extended key
					keyb_state_extended <= '1';
				
				else

					-- Setup the output message
					KeyboardMessage(9) <= keyb_state_break;
					KeyboardMessage(8) <= keyb_state_extended;
					KeyboardMessage(7 downto 0) <= rx_data;

					-- Reset pulse counter
					PulseCounter <= (others=>'0');
					
					-- Output the message available flag, delayed by one clock tick
					KeyboardMessageAvailable_delay1 <= '1';
					
					-- reset state
					keyb_state_break <= '0';
					keyb_state_extended <= '0';

				end if;

			end if;
		
		end if;
	
	end process;

end Behavioral;

