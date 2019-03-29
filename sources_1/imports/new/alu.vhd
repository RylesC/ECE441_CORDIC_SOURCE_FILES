----------------------------------------------------------------------------------
-- Engineer: Mark Bonwick
-- Module Name: alu computation 
-- Project Name: CORDIC
-- Description: parallel ALU for CORDIC iterations
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY alu IS
  PORT (
        x_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);    --X input
        y_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);    --Y input    
        z_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);    --Z input
        theta : IN STD_LOGIC_VECTOR(15 DOWNTO 0);   --Theta values from LUT
        i : IN STD_LOGIC_VECTOR(3 DOWNTO 0);        --Iteration number
        add_sub_x : IN STD_LOGIC;                   --Subtract x (0: Add, 1: Subtract)
        add_sub_y : IN STD_LOGIC;                   --Subtract y (0: Add, 1: Subtract)
        add_sub_z : IN STD_LOGIC;                   --Subtract z (0: Add, 1: Subtract)
        x_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);  --X output 
        y_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);  --Y output 
        z_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)   --Z output
  );
  
END alu;
ARCHITECTURE computation OF alu IS
    --16 bit adder
    COMPONENT cordicadder16 IS
    PORT (
        a: IN STD_LOGIC_VECTOR (15 DOWNTO 0);   --input varable A
        b: IN STD_LOGIC_VECTOR (15 DOWNTO 0);   --input varable B
        sum: OUT STD_LOGIC_VECTOR(15 DOWNTO 0); --Addition result
        cout: OUT STD_LOGIC                     --Carry bit
    );
    END COMPONENT;
    
    SIGNAL x_signed : signed(15 DOWNTO 0)   := (OTHERS => '0');
    SIGNAL y_signed : signed(15 DOWNTO 0)   := (OTHERS => '0');
    SIGNAL theta_signed : signed(15 DOWNTO 0)   := (OTHERS => '0');
    
    BEGin
    
    --Performs conversion of input x,y,z though bit shifting and inverting based on add_sub inputs
    conversion: PROCESS(x_in, y_in, z_in, add_sub_x, add_sub_y, add_sub_z, theta,i) IS BEGIN
                
                IF add_sub_x = '1' THEN
                    x_signed <= -(shift_right(signed(y_in),to_integer(unsigned(i))));
                ELSE
                    x_signed <= shift_right(signed(y_in),to_integer(unsigned(i)));
                END IF;
                
                IF add_sub_y = '1' THEN
                    y_signed <= -(shift_right(signed(x_in),to_integer(unsigned(i)))); 
                ELSE
                    y_signed <= shift_right(signed(x_in),to_integer(unsigned(i)));              
                END IF;

                IF add_sub_z = '1' THEN
                    theta_signed <= -(signed(theta));
                ELSE
                    theta_signed <= signed(theta); 
                END IF;
                
        END PROCESS conversion;
     
    -------------16 bit adders--------------
    calcx: cordicadder16 PORT MAP (
        a => x_in,
        b => STD_LOGIC_VECTOR (x_signed),
        sum => x_OUT
    );
    
    calcy: cordicadder16 PORT MAP (
        a => y_in,
        b => STD_LOGIC_VECTOR (y_signed),
        sum => y_OUT
    );
    
    calcz: cordicadder16 PORT MAP (
        a => z_in,
        b => STD_LOGIC_VECTOR (theta_signed),
        sum => z_OUT
    );   
         
END computation;