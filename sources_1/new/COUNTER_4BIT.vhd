----------------------------------------------------------------------------------
-- Engineer: Riley Cambon
-- Module Name: COUNTER_4BIT - Behavioral
-- Project Name: CORDIC
-- Description: Syncronous 4 Bit counter with inc enable and reset
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity COUNTER_4BIT is
PORT(
clk:        IN STD_LOGIC;                      --Clock 
reset:      IN STD_LOGIC;                      --Reset to value "0000"
clear:      IN STD_LOGIC;                      --Clears counter to value "0000"
inc:        IN STD_LOGIC;                      --enables counting
count_out:  OUT STD_LOGIC_VECTOR(3 downto 0)   --Count output
);
END COUNTER_4BIT;

ARCHITECTURE Behavioral of COUNTER_4BIT is

SIGNAL c: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

BEGIN

--Syncronous counter with inc enable and reset
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
END Behavioral;
