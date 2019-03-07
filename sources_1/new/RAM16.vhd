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
    write_en    :IN STD_LOGIC;
    d           :IN STD_LOGIC_VECTOR(15 downto 0);
    address     :IN STD_LOGIC_VECTOR(3 downto 0);
    q           :OUT STD_LOGIC_VECTOR(15 downto 0));
end RAM16;

architecture Behavioral of RAM16 is
    
type memory is array (0 to 15) of STD_LOGIC_VECTOR(15 downto 0);

signal ram: memory;

begin

    RW: process(clk)
    begin   
        if rising_edge(clk) then 
            q <= ram(to_integer(UNSIGNED(address)));
    
            if write_en = '1' then
                ram(to_integer(UNSIGNED(address))) <= d;
            end if;
         end if;
    end process RW;
end Behavioral;
