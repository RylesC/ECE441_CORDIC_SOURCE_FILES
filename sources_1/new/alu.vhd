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
library xil_deafultlib;
use xil_deafultlib.all;

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
        i : in STD_LOGIC_VECTOR(4 DOWNTO 0);
        add_sub_x : in STD_LOGIC;
        add_sub_y : in STD_LOGIC;
        add_sub_z : in STD_LOGIC;
        x_out : out STD_LOGIC_VECTOR(15 DOWNTO 0); 
        y_out : out STD_LOGIC_VECTOR(15 DOWNTO 0);
        z_out : out STD_LOGIC_VECTOR(15 DOWNTO 0)
  
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
    SIGNAL theta_signed : signed(15 downto 0)   := (others => '0');

    begin
        conversion: process
        begin
            --xin -+ yin
            x_signed <= shift_right(signed(y_in),1);
            --yin +-xin
            y_signed <= shift_right(signed(x_in),1);
            --zin-+thetain
            theta_signed <= signed(theta);
            
            if add_sub_x = '1' then
               x_signed <= not(x_signed) + "00000001";
            end if;
            if add_sub_y = '1' then
               y_signed <= not(x_signed) + "00000001";
            end if;
            if add_sub_z = '1' then
               theta_signed <= not(x_signed) + "00000001";
            end if;
            
        end process conversion;
        
        calcx: cordicadder16 port map (
            a => x_in,
            b => std_logic_vector (x_signed),
            clk => '1',
            sum => x_out
        );
        
        calcy: cordicadder16 port map (
            a => y_in,
            b => std_logic_vector (y_signed),
            clk => '1',
            sum => y_out
            );
        
        calcz: cordicadder16 port map (
            a => z_in,
            b => std_logic_vector (theta_signed),
            clk => '1',
            sum => z_out
            );
         
end computation;
