----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2019 04:07:48 PM
-- Design Name: 
-- Module Name: alu - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
--library xil_deafultlib;
--use xil_deafultlib.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
ENTITY alu IS
  PORT (
        x_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
        y_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        z_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        theta : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        i : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        add_sub_x : IN STD_LOGIC;
        add_sub_y : IN STD_LOGIC;
        add_sub_z : IN STD_LOGIC;
        x_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); 
        y_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        z_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
  
END alu;
ARCHITECTURE computation OF alu IS
    COMPONENT cordicadder16 IS
    PORT (
        a: IN std_logic_vector (15 DOWNTO 0);
        b: IN std_logic_vector (15 DOWNTO 0);
        sum: OUT std_logic_vector(15 DOWNTO 0);
        cout: OUT std_logic
    );
    END COMPONENT;
    
    SIGNAL x_signed : signed(15 DOWNTO 0)   := (OTHERS => '0');
    SIGNAL y_signed : signed(15 DOWNTO 0)   := (OTHERS => '0');
    SIGNAL theta_signed : signed(15 DOWNTO 0)   := (OTHERS => '0');
    
    BEGIN
    
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
        
    calcx: cordicadder16 PORT MAP (
        a => x_in,
        b => std_logic_vector (x_signed),
        sum => x_out
    );
    
    calcy: cordicadder16 PORT MAP (
        a => y_in,
        b => std_logic_vector (y_signed),
        sum => y_out
    );
    
    calcz: cordicadder16 PORT MAP (
        a => z_in,
        b => std_logic_vector (theta_signed),
        sum => z_out
    );   
         
END computation;