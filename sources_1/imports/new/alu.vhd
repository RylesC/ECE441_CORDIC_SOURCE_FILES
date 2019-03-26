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
entity alu is
  Port (
        x_in : in STD_LOGIC_VECTOR(15 DOWNTO 0); 
        y_in : in STD_LOGIC_VECTOR(15 DOWNTO 0);
        z_in : in STD_LOGIC_VECTOR(15 DOWNTO 0);
        theta : in STD_LOGIC_VECTOR(15 DOWNTO 0);
        i : in STD_LOGIC_VECTOR(3 DOWNTO 0);
        add_sub_x : in STD_LOGIC;
        add_sub_y : in STD_LOGIC;
        add_sub_z : in STD_LOGIC;
        x_out : out STD_LOGIC_VECTOR(15 DOWNTO 0); 
        y_out : out STD_LOGIC_VECTOR(15 DOWNTO 0);
        z_out : out STD_LOGIC_VECTOR(15 DOWNTO 0);
        clk: in std_logic
  );
  
end alu;
architecture computation of alu is
    COMPONENT cordicadder16 is
    port (
        a: IN std_logic_vector (15 DOWNTO 0);
        b: IN std_logic_vector (15 DOWNTO 0);
        clk: IN std_logic;
        sum: OUT std_logic_vector(15 DOWNTO 0);
        cout: OUT std_logic
    );
    END COMPONENT;
    
    SIGNAL x_signed : signed(15 downto 0)   := (others => '0');
    SIGNAL y_signed : signed(15 downto 0)   := (others => '0');
    SIGNAL theta_signed : STD_LOGIC_VECTOR(15 downto 0)   := (others => '0');
    
    begin
    
    conversion: process(x_in,y_in,z_in, add_sub_x,add_sub_y, add_sub_z, theta,i, x_signed, y_signed) is begin
     
                x_signed <= shift_right(signed(y_in),to_integer(unsigned(i)));
                y_signed <= shift_right(signed(x_in),to_integer(unsigned(i)));
                
                if add_sub_x = '1' then
                    x_out <= STD_LOGIC_VECTOR(signed(x_in) - signed(x_signed));
                ELSE 
                    x_out <= STD_LOGIC_VECTOR(signed(x_in) + signed(x_signed));                  
                end if;
                
                if add_sub_y = '1' then
                    y_out <= STD_LOGIC_VECTOR(signed(y_in) - signed(y_signed));
                ELSE 
                    y_out <= STD_LOGIC_VECTOR(signed(y_in) + signed(y_signed));                  
                end if;

                IF add_sub_z = '1' THEN
                z_out <= STD_LOGIC_VECTOR(signed(z_in) - signed(theta));
                ELSE
                z_out <= STD_LOGIC_VECTOR(signed(z_in) + signed(theta));
                END IF;
                
        end process conversion;
        
         
end computation;