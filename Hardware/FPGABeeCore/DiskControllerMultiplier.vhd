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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 

ENTITY DiskControllerMultiplier IS
  PORT (
    clk : IN STD_LOGIC;
    clken : IN STD_LOGIC;
    a : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    p : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
  );
END DiskControllerMultiplier;



ARCHITECTURE behavior OF DiskControllerMultiplier IS 

  signal R_mul : std_logic_vector(14 downto 0);
  signal pipe1 : std_logic_vector(14 downto 0);
  signal pipe2 : std_logic_vector(14 downto 0);
  signal pipe3 : std_logic_vector(14 downto 0);

BEGIN

  -- Do the multiplication
  R_mul <= A * B;

  -- Output result
  P <= pipe3;

  process (clk)
  begin
    if rising_edge(clk) then

      if clken='1' then
        pipe1 <= R_mul;
        pipe2 <= pipe1;
        pipe3 <= pipe2;
      end if;

    end if;
  end process;

END;