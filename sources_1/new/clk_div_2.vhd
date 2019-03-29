----------------------------------------------------------------------------------
-- Engineer: Riley Cambon
-- Module Name: clk_div_2 - Behavioral
-- Project Name: CORDIC
-- Description: Clock divider with single clock cycle pulses 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY clk_div_2 IS
PORT(
    clk:        IN STD_LOGIC;   --Clock
    reset:      IN STD_LOGIC;   --Reset
    clkdiv2:    OUT STD_LOGIC   --Clock pulses at twice clock period 
    );
END clk_div_2;


ARCHITECTURE Behavioral OF clk_div_2 IS

SIGNAL n : UNSIGNED(3 downto 0)   := (OTHERS => '0'); --Clock edge counter 

BEGIN

    --Sets clock output to pulse when counter reaches specified value
    PROCESS(clk, reset, n)
    BEGIN
    IF reset = '1' THEN
        n <= x"0";
        clkdiv2 <= '0';
    ELSE
        IF rising_edge(clk) THEN
        n <= n + 1;   
            IF (n < x"1") THEN
                clkdiv2 <= '0';
            ELSE
                clkdiv2 <= '1';
                n <= x"0";
            END IF;
        END IF;
     END IF;
    END PROCESS;
END Behavioral;
