----------------------------------------------------------------------------------
-- Engineer: Riley Cambon
-- Module Name: ROM - Behavioral
-- Project Name: CORDIC
-- Description: Read only memory for LUT theta values 
----------------------------------------------------------------------------------

 library ieee;
 use ieee.STD_LOGIC_1164.all;
 use ieee.numeric_std.all;
 
 ENTITY ROM IS
 PORT (
     address :      IN STD_LOGIC_VECTOR (3 downto 0);       --Address for LUT
     q :            OUT STD_LOGIC_VECTOR (15 downto 0));    --Theta value 
 END ROM;
 
 ARCHITECTURE BEHAVIOR OF ROM IS
 
 TYPE ROMTABLE IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR (15 downto 0);

--Special angles for CORDIC
 constant romdata : romtable := (
    x"6488", 
    x"3B57",
    x"1F5C",
    x"0FEC",
    x"07FD",
    x"03FE",
    x"01FF",
    x"0100",
    x"0080",
    x"0042",
    x"0020",
    x"0010",
    x"0008",
    x"0004",
    x"0002",
    x"0001"
 );
 
 BEGIN

 PROCESS (address)
     BEGIN
     
     q <= romdata(TO_INTEGER(UNSIGNED(address)));
     END PROCESS;
     
 END BEHAVIOR;
 
 