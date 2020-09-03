library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;


entity test_rom is
	port
	(
		clock : in std_logic;
		addr : in std_logic_vector(5 downto 0);
		dout : out std_logic_vector(7 downto 0)
	);
end test_rom;
 
architecture behavior of test_rom is 
	type mem_type is array(0 to 41) of std_logic_vector(7 downto 0);	signal rom : mem_type := 
	(
	x"31", x"00", x"c0", x"1e", x"03", x"7b", x"d3", x"00", x"07", x"5f", x"cd", x"12", x"00", x"18", x"f6", x"01", 
	x"e0", x"2e", x"0b", x"78", x"b1", x"20", x"fb", x"c9", x"3a", x"01", x"80", x"e6", x"b8", x"37", x"e2", x"22", 
	x"00", x"3f", x"3a", x"01", x"80", x"17", x"32", x"01", x"80", x"c9"
	);
begin

	process (clock)
	begin
		if rising_edge(clock) then
			dout <= rom(to_integer(unsigned(addr)));
		end if;
	end process;
end;

