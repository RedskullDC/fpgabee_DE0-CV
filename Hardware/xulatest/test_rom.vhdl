library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;


entity test_rom is
	port
	(
		clock : in std_logic;
		addr : in std_logic_vector(2 downto 0);
		dout : out std_logic_vector(7 downto 0)
	);
end test_rom;
 
architecture behavior of test_rom is 
	type mem_type is array(0 to 7) of std_logic_vector(7 downto 0);	signal rom : mem_type := 
	(
	x"3e", x"a5", x"d3", x"00", x"76", x"18", x"fd"
	);
begin

	process (clock)
	begin
		if rising_edge(clock) then
			dout <= rom(to_integer(unsigned(addr)));
		end if;
	end process;
end;

