----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/03/2019 08:52:22 PM
-- Design Name: 
-- Module Name: reg_16b - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg_16b is
PORT ( 
    d       :IN STD_LOGIC_VECTOR(15 downto 0);
    load    :IN STD_LOGIC;
    clr     :IN STD_LOGIC;
    clk     :IN STD_LOGIC;
    q       :OUT STD_LOGIC_VECTOR(15 downto 0)
    );
end reg_16b;

architecture Behavioral of reg_16b is

begin

P1:    process(clk,clr)
        begin
        if clr = '1' then
            q <= x"0000";
        elsif rising_edge(clk) then 
            if load = '1' then
                q <= d;
            end if;
        end if;
    end process P1;
end Behavioral;
