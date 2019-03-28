----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/27/2019 02:05:36 PM
-- Design Name: 
-- Module Name: clk_div_2 - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_div_2 is
PORT(
    clk: IN STD_LOGIC;
    reset: IN STD_LOGIC;
    clkdiv2: OUT STD_LOGIC
    );
end clk_div_2;


architecture Behavioral of clk_div_2 is

SIGNAL n : UNSIGNED(15 downto 0)   := (others => '0');

BEGIN
    PROCESS(clk, reset, n)
    BEGIN
    IF reset = '1' THEN
        n <= x"0000";
        clkdiv2 <= '0';
    ELSE
        IF rising_edge(clk) THEN
        n <= n + 1;   
            IF (n < x"F000") THEN
                clkdiv2 <= '0';
            ELSE
                clkdiv2 <= '1';
                n <= x"0000";
            END IF;
        END IF;
     END IF;
    END PROCESS;
END Behavioral;
