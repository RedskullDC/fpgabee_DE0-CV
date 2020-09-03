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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package Utils is

	function bitlen_unsigned(arg : unsigned) return integer;
	function bitlen_natural(arg : natural) return integer;

end Utils;

package body Utils is

	function bitlen_unsigned(arg : unsigned) return integer is
	begin
	
		case to_integer(arg) is
				when 1 | 0 =>
					return 1;
				when others =>
					return 1 + bitlen_unsigned(arg srl 1);
		end case;
		
	end function bitlen_unsigned;
 
	function bitlen_natural(arg : natural) return integer is
	begin
	
		case arg is
				when 1 | 0 =>
					return 1;
				when others =>
					return 1 + bitlen_natural(arg/2);
		end case;
		
	end function bitlen_natural;
 
end Utils;
