----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/04/2019 04:05:53 PM
-- Design Name: 
-- Module Name: RAM16 - Behavioral
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
use IEEE.NUMERIC_STD.all;
use work.CORDIC_package.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM16 is
PORT ( 
    clk         :IN STD_LOGIC;
    clear       :IN STD_LOGIC;
    write_en_x    :IN STD_LOGIC;
    write_en_y    :IN STD_LOGIC;
    write_en_z    :IN STD_LOGIC;
    d_x           :IN STD_LOGIC_VECTOR(15 downto 0);
    d_y           :IN STD_LOGIC_VECTOR(15 downto 0);
    d_z           :IN STD_LOGIC_VECTOR(15 downto 0);        
    q_x           :OUT STD_LOGIC_VECTOR(15 downto 0);
    q_y           :OUT STD_LOGIC_VECTOR(15 downto 0);
    q_z           :OUT STD_LOGIC_VECTOR(15 downto 0));
    
end RAM16;

architecture Behavioral of RAM16 is
    
type memory is array (0 to 15) of STD_LOGIC_VECTOR(15 downto 0);

signal ram: memory;

begin
    RW: process(clk,clear, write_en_x, write_en_y, write_en_z)
    begin   
       IF clear = '1' THEN ram <= (others => (others => '0'));
       end if;          
            if rising_edge(clk) then 
                q_x <= ram(to_integer(UNSIGNED(x_address)));
                q_y <= ram(to_integer(UNSIGNED(y_address)));
                q_z <= ram(to_integer(UNSIGNED(z_address)));
                
                if write_en_x = '1' then
                    ram(to_integer(UNSIGNED(x_address))) <= d_x;
                end if;
                if write_en_y = '1' then
                    ram(to_integer(UNSIGNED(y_address))) <= d_y;
                end if;                
                if write_en_z = '1' then
                    ram(to_integer(UNSIGNED(z_address))) <= d_z;
                end if;                
             end if;
    end process RW;
end Behavioral;
