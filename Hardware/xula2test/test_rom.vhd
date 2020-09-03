library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;


entity test_rom is
	port
	(
		clock : in std_logic;
		clken : in std_logic;
		addr : in std_logic_vector(7 downto 0);
		dout : out std_logic_vector(7 downto 0)
	);
end test_rom;
 
architecture behavior of test_rom is 
	type mem_type is array(0 to 255) of std_logic_vector(7 downto 0);	signal rom : mem_type := 
	(
	x"3e", x"a5", x"32", x"10", x"80", x"3a", x"10", x"80", x"fe", x"a5", x"20", x"10", x"31", x"00", x"f4", x"3e", 
	x"01", x"32", x"00", x"f0", x"cd", x"22", x"00", x"cd", x"41", x"00", x"18", x"fe", x"3e", x"f1", x"d3", x"a0", 
	x"18", x"fe", x"21", x"00", x"40", x"11", x"01", x"40", x"01", x"ff", x"7f", x"36", x"aa", x"ed", x"b0", x"21", 
	x"00", x"40", x"01", x"00", x"80", x"7e", x"fe", x"aa", x"20", x"59", x"23", x"0b", x"78", x"b1", x"20", x"f5", 
	x"c9", x"21", x"00", x"40", x"11", x"01", x"40", x"01", x"ff", x"7f", x"36", x"ba", x"ed", x"b0", x"21", x"00", 
	x"40", x"01", x"00", x"00", x"c5", x"7c", x"d3", x"a2", x"7d", x"d3", x"a1", x"11", x"00", x"40", x"7e", x"19", 
	x"be", x"20", x"36", x"cd", x"ab", x"00", x"b7", x"ed", x"52", x"77", x"46", x"b8", x"20", x"31", x"19", x"f5", 
	x"7c", x"d3", x"a2", x"7d", x"d3", x"a1", x"f1", x"77", x"46", x"b8", x"20", x"29", x"23", x"7c", x"e6", x"3f", 
	x"f6", x"40", x"67", x"c1", x"0b", x"78", x"b1", x"20", x"cb", x"01", x"00", x"00", x"0b", x"78", x"b1", x"20", 
	x"fb", x"18", x"c1", x"3e", x"f2", x"d3", x"a0", x"18", x"fe", x"3e", x"f3", x"d3", x"a0", x"18", x"fe", x"3e", 
	x"f4", x"d3", x"a0", x"18", x"fe", x"3e", x"f5", x"d3", x"a0", x"18", x"fe", x"3a", x"00", x"f0", x"e6", x"b8", 
	x"37", x"e2", x"b5", x"00", x"3f", x"3a", x"00", x"f0", x"17", x"32", x"00", x"f0", x"c9", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
	x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"
	
	);
begin

	process (clock)
	begin
		if rising_edge(clock) then
			if clken='1' then
				dout <= rom(to_integer(unsigned(addr)));
			end if;
		end if;
	end process;
end;

