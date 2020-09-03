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

package DiskConstants is

	constant DISK_DS40 : std_logic_vector(3 downto 0) := x"0";
	constant DISK_SS80 : std_logic_vector(3 downto 0) := x"1";
	constant DISK_DS80 : std_logic_vector(3 downto 0) := x"2";
	constant DISK_DS82 : std_logic_vector(3 downto 0) := x"3";
	constant DISK_DS84 : std_logic_vector(3 downto 0) := x"4";
	constant DISK_DS8B : std_logic_vector(3 downto 0) := x"5";
	constant DISK_HD0  : std_logic_vector(3 downto 0) := x"6";
	constant DISK_HD1  : std_logic_vector(3 downto 0) := x"7";
	constant DISK_NONE : std_logic_vector(3 downto 0) := x"8";
	
end DiskConstants;

package body DiskConstants is

 
end DiskConstants;
