
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

package CORDIC_package is 
    
    TYPE state IS
        (ST0,ST1,ST2,ST3,ST4,ST5,ST6,ST7);
            
            
constant x_address : STD_LOGIC_VECTOR(3 downto 0) := x"0";
constant y_address : STD_LOGIC_VECTOR(3 downto 0) := x"1";  
constant z_address : STD_LOGIC_VECTOR(3 downto 0) := x"2";  

end package CORDIC_package;