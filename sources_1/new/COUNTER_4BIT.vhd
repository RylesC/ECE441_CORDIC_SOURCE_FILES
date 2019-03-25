----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/06/2019 12:56:49 PM
-- Design Name: 
-- Module Name: COUNTER_4BIT - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity COUNTER_4BIT is
PORT(
clk:        IN STD_LOGIC;
reset:      IN STD_LOGIC;
clear:      IN STD_LOGIC;
inc:        IN STD_LOGIC;
count_out:  OUT STD_LOGIC_VECTOR(3 downto 0)
);
end COUNTER_4BIT;

architecture Behavioral of COUNTER_4BIT is

signal c: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

begin

PROCESS(clk, reset, clear)
    BEGIN
        IF ((reset = '1') or (clear = '1')) then 
            c <= (OTHERS => '0');
        ELSIF(rising_edge(clk)) then
            IF inc = '1' then
                c <= c + 1;
            END IF;
        END IF;
    END PROCESS;
    count_out <= c;
end Behavioral;
