
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

package CORDIC_package is 
    
    TYPE state IS
        (ST0,ST1,ST2,ST3,ST4,ST5,ST6,ST7);
            
            
constant x_address : unsigned := x"1";  
constant y_address : unsigned := x"2";  
constant z_address : unsigned := x"3";  

end package CORDIC_package;