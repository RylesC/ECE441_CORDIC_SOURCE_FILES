----------------------------------------------------------------------------------
-- Engineer: Riley Cambon
-- Module Name: LATCH_16B - Behavioral
-- Project Name: CORDIC
-- Description: 16 Bit latch with 2 input MUX
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LATCH_16B is
    PORT (
        clear       : IN STD_LOGIC;                         --clear latch
        input_data0  : IN STD_LOGIC_VECTOR(15 downto 0);    --Input data 0
        input_data1  : IN STD_LOGIC_VECTOR(15 downto 0);    --Input data 1
        enable      : IN STD_LOGIC;                         --Enable
        input_sel   : IN STD_LOGIC;                         --Input select (0: input 0, 1: input 1)
        output_data : OUT STD_LOGIC_VECTOR(15 downto 0)     --Latch output
         );
    END LATCH_16B;

ARCHITECTURE Behavioral OF LATCH_16B IS

BEGIN
    --16 Bit latch with 2 input MUX
    PROCESS (clear,input_data0,input_data1, input_sel, enable)
    BEGIN
        IF clear = '1' THEN
            output_data <= x"0000";
        ELSE
            IF enable = '1' THEN
                IF input_sel = '0' THEN
                output_data <= input_data0;
                ELSIF input_sel = '1' THEN
                output_data <= input_data1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;
