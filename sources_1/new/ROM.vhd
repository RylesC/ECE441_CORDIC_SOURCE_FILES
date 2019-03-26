
 library ieee;
 use ieee.std_logic_1164.all;
 use ieee.numeric_std.all;
 
 ENTITY ROM IS
 PORT (
     address :      IN STD_LOGIC_VECTOR (3 downto 0);
     q :            OUT STD_LOGIC_VECTOR (15 downto 0));
 end ROM;
 
 architecture BEHAVIOR of ROM is
 
 type ROMTABLE is array (0 to 15) of std_logic_vector (15 downto 0);

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
 begin

 process (address)
     begin
     
     q <= romdata(to_integer(unsigned(address)));
     end process;
     
 end BEHAVIOR;
 
 