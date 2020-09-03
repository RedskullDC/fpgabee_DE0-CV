----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:32:11 07/24/2013 
-- Design Name: 
-- Module Name:    test - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;


entity xulatest is
	Port 
	(
		clock : in  STD_LOGIC;

		vgaRed : out std_logic_vector(1 downto 0);
		vgaGreen : out std_logic_vector(1 downto 0);
		vgaBlue : out std_logic_vector(1 downto 0);
		vgaHSync : out std_logic;
		vgaVSync : out std_logic;

		PS2KeyboardData : inout std_logic;
		PS2KeyboardClock : inout std_logic;

	    sdClk_o : out std_logic;
	    sdClkFb_i : in std_logic;
	    sdRas_bo : out std_logic;
	    sdCas_bo : out std_logic;
	    sdWe_bo : out std_logic;
	    sdBs_o : out std_logic;
	    sdAddr_o : out std_logic_vector(11 downto 0); 
	    sdData_io : inout std_logic_vector(15 downto 0)
	);
end xulatest;

architecture Behavioral of xulatest is

	signal clock_3_375 : std_logic;
	signal clock_40_000 : std_logic;
	signal clock_100_000 : std_logic;
	signal vga_x_pixel : std_logic_vector(10 downto 0);
	signal vga_y_pixel : std_logic_vector(10 downto 0);
	signal vga_blank : std_logic;
	signal grid_line : std_logic;
	signal status_pixel : std_logic_vector(1 downto 0);
	signal debug_leds : std_logic_vector(7 downto 0);
	signal debug_data : std_logic_vector(31 downto 0);
	signal reset : std_logic;
	signal reset_n : std_logic;

	signal z80_addr : std_logic_vector(15 downto 0);
	signal z80_din : std_logic_vector(7 downto 0);
	signal z80_dout : std_logic_vector(7 downto 0);
	signal z80_mreq_n : std_logic;
	signal z80_iorq_n : std_logic;
	signal z80_rd_n : std_logic;
	signal z80_wr_n : std_logic;
	signal z80_m1_n : std_logic;
	signal current_pc : std_logic_vector(15 downto 0);
	signal test_rom_dout : std_logic_vector(7 downto 0);
	signal port_00 : std_logic_vector(7 downto 0);
	signal port_01 : std_logic_vector(7 downto 0);
	signal port_02 : std_logic_vector(7 downto 0);
	signal mem_rd : std_logic;
	signal mem_wr : std_logic;
	signal port_rd : std_logic;
	signal port_wr : std_logic;

	signal KeyboardMessageAvailable : std_logic;
	signal KeyboardMessage : std_logic_vector(9 downto 0);

	signal delay : unsigned(20 downto 0);
	signal counter : unsigned(7 downto 0);


	signal ram_range : std_logic;
	signal ram_dout : std_logic_vector(7 downto 0);
	signal ram_addr : std_logic_vector(17 downto 0);
	signal ram_wr : std_logic;
	signal ram_rd : std_logic;
	signal ram_wait : std_logic;
	signal ram_wait_n : std_logic;
	signal ram_stall : std_logic;



begin

	reset <= '0';
	reset_n <= NOT reset;
	debug_leds <= port_00;
	debug_data(31 downto 16) <= current_pc;
	debug_data(15 downto 10) <= (others=>'0');
	debug_data(9 downto 0) <= KeyboardMessage;

	process (clock)
	begin

		if rising_edge(clock) then
			delay <= delay + 1;
			if delay=0 then
				counter <= counter + 1;
			end if;
		end if;

	end process;

	--  12Mhz * 9 / 32 = 3.375Mhz
	DCM_SP_inst_3_375 : DCM_SP
	generic map 
	(
		CLKFX_DIVIDE => 32,
		CLKFX_MULTIPLY => 9
	)
	port map 
	(
		CLKFX => clock_3_375, 
		CLKIN => clock,
		RST => reset
	);

	--  12Mhz * 10 / 3 = 40Mhz
	DCM_SP_inst_40_000 : DCM_SP
	generic map 
	(
		CLKFX_DIVIDE => 3,
		CLKFX_MULTIPLY => 10
	)
	port map 
	(
		CLKFX => clock_40_000, 
		CLKIN => clock,
		RST => reset
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
		CLKFX => clock_100_000, 
		CLKIN => clock,
		RST => reset
	);

	-- VGA timing
	vga_timing: entity work.vga_controller_800_60
	PORT MAP
	(
		rst => '0',
		pixel_clk => clock_40_000,
		HS => vgaHSync,
		VS => vgaVSync,
		hcount => vga_x_pixel,
		vcount => vga_y_pixel,
		blank => vga_blank
	);

	StatusPanel : entity work.StatusPanel
	PORT MAP
	(
		reset => reset,
		pixel_clock => clock_40_000,
		leds => debug_leds,
		hex => debug_data,
		vga_x_pixel => vga_x_pixel,
		vga_y_pixel => vga_y_pixel,
		pixel_out => status_pixel
	);

	-- Generate a grid pattern
	grid_line <= '1' when vga_x_pixel(3 downto 0)="0000" or vga_y_pixel(3 downto 0)="0000" else '0';

	process (grid_line, vga_blank, status_pixel)
	begin

		if vga_blank='1' then

			vgaRed <= "00";
			vgaGreen <= "00";
			vgaBlue <= "00";

		else

			case status_pixel is

				when "00" =>
					if grid_line='1' then
						vgaRed <= "00";
						vgaGreen <= "10";
						vgaBlue <= "00";
					else
						vgaRed <= "00";
						vgaGreen <= "00";
						vgaBlue <= "00";
					end if;

				when "01" =>
					vgaRed <= "00";
					vgaGreen <= "00";
					vgaBlue <= "00";

				when "10" =>
					vgaRed <= "10";
					vgaGreen <= "10";
					vgaBlue <= "10";

				when "11" =>
					vgaRed <= "11";
					vgaGreen <= "00";
					vgaBlue <= "00";

				when others =>
					vgaRed <= "11";
					vgaGreen <= "00";
					vgaBlue <= "00";

			end case;
		end if;
	end process;

	KeyboardPort : entity work.KeyboardPort
		PORT MAP
		(
			clock => clock_100_000,
			reset => reset,
			PS2KeyboardData => PS2KeyboardData,
			PS2KeyboardClk => PS2KeyboardClock,
			KeyboardMessageAvailable => KeyboardMessageAvailable,
			KeyboardMessage => KeyboardMessage
		);


	-- Z80 CPU Core
	z80_core: entity work.T80se 
	GENERIC MAP
	(
		Mode 	=> 0,		-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		T2Write => 1,		-- 0 => WR_n active in T3, /=0 => WR_n active in T2
		IOWait 	=> 1		-- 0 => Single cycle I/O, 1 => Std I/O cycle
	)
	PORT MAP
	(
		RESET_n => reset_n,
		CLK_n =>  clock_3_375,
		A => z80_addr,
		DI => z80_din,
		DO => z80_dout,
		MREQ_n => z80_mreq_n,
		IORQ_n => z80_iorq_n,
		RD_n => z80_rd_n,
		WR_n => z80_wr_n,
		CLKEN => '1',
		WAIT_n => ram_wait_n,
		INT_n => '1',
		NMI_n => '1',
		BUSRQ_n => '1',
		M1_n => z80_m1_n,
		RFSH_n => open,
		HALT_n => open,
		BUSAK_n => open
	);
		
	-- Decode I/O control signals from Z80
	mem_rd <= '1' when (z80_mreq_n = '0' and z80_iorq_n = '1' and z80_rd_n = '0') else '0';
	mem_wr <= '1' when (z80_mreq_n = '0' and z80_iorq_n = '1' and z80_wr_n = '0') else '0';
	port_rd <= '1' when (z80_iorq_n = '0' and z80_mreq_n = '1' and z80_rd_n = '0') else '0';
	port_wr <= '1' when (z80_iorq_n = '0' and z80_mreq_n = '1' and z80_wr_n = '0') else '0';

	-- Multiplex data into the CPU
	process (test_rom_dout, port_00, port_01, port_02, mem_rd, port_rd, z80_addr)
	begin

		z80_din <= (others=>'0');

		if mem_rd='1' then

			if ram_range='1' then
				z80_din <= ram_dout;
			else
				z80_din <= test_rom_dout;
			end if;

		elsif port_rd='1' then

			if z80_addr(7 downto 0)=x"00" then

				z80_din <= port_00;

			elsif z80_addr(7 downto 0)=x"01" then

				z80_din <= port_01;

			elsif z80_addr(7 downto 0)=x"02" then

				z80_din <= port_02;

			end if;

		end if;

	end process;


	-- Reset, clock and simple port writes...
	process(clock_3_375, reset)
	begin
		if reset='1' then
		
			port_00 <= (others=>'0');
			port_01 <= (others=>'0');
			port_02 <= (others=>'0');

			ram_stall <= '0';

		elsif (rising_edge(clock_3_375)) then

			-- Write port 0 -> LEDs
			if z80_addr(7 downto 0)=x"00" and port_wr = '1' then
				port_00 <= z80_dout;
			end if;

			-- Write port 0 -> LEDs
			if z80_addr(7 downto 0)=x"01" and port_wr = '1' then
				port_01 <= z80_dout;
			end if;

			-- Write port 0 -> LEDs
			if z80_addr(7 downto 0)=x"02" and port_wr = '1' then
				port_02 <= z80_dout;
			end if;
			
			if (z80_m1_n='0') then
				current_pc <= z80_addr;
			end if;

			if (mem_rd='1' or mem_wr='1') and ram_wait='1' then
				ram_stall <= '1';
			else
				ram_stall <= '0';
			end if;

		end if; 
	end process;

	ram_addr <= "00" & z80_addr;
	ram_range <= z80_addr(15);
	ram_wr <= mem_wr and ram_range;
	ram_rd <= mem_rd and ram_range;
	ram_wait_n <= NOT ram_wait;


	-- Test ROM
	test_rom : entity work.test_rom
	PORT MAP
	(
		clock => clock_3_375,
		addr => z80_addr(5 downto 0),
		dout => test_rom_dout
	);


	sdClk_o <= clock_100_000;

	Z80RamController : entity work.Z80RamController
	PORT MAP
	(
		reset => reset,
		ram_clock => clock_3_375,
		ram_addr => ram_addr,
		ram_din => z80_dout,
		ram_dout => ram_dout,
		ram_wr => ram_wr,
		ram_rd => ram_rd,
		ram_wait => ram_wait,

		sdClkFb_i => sdClkFb_i,
		sdRas_bo => sdRas_bo,
		sdCas_bo => sdCas_bo,
		sdWe_bo => sdWe_bo,
		sdBs_o => sdBs_o,
		sdAddr_o => sdAddr_o,
		sdData_io => sdData_io

	);




end Behavioral;

