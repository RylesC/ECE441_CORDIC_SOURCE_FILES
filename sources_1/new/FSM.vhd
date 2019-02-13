----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2019 11:22:50 AM
-- Design Name: 
-- Module Name: FSM - Behavioral
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
use work.CORDIC_package.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM is
 Port ( 
 clk:       IN std_logic;
 x:         IN std_logic;
 reset:     IN std_logic;
 y:         OUT std_logic_vector(15 downto 0));
end FSM;

architecture Behavioral of FSM is

signal current_state: state;
signal next_state: state;

begin

    cs: PROCESS (clk, reset) IS BEGIN
        IF reset = '1' THEN current_state <= ST0; --default state
        ELSIF rising_edge (clk) THEN current_state <= next_state;  --make next state current state
        END IF;
    END PROCESS cs;
    
    ns: PROCESS (current_state, x) IS BEGIN
        CASE current_state IS 
        WHEN ST0 =>
            y <= x"0000";
            IF x = '1' THEN next_state <= ST1;
            ELSE next_state <= ST0;
            END IF;
        WHEN ST1 =>
            y <= x"1111";
            IF x = '1' THEN next_state <= ST2;
            ELSE next_state <= ST1;  
            END IF;          
        WHEN ST2 =>
            y <= x"2222";
            IF x = '1' THEN next_state <= ST3;
            ELSE next_state <= ST2;  
            END IF;          
        WHEN ST3 =>
            y <= x"3333";
            IF x = '1' THEN next_state <= ST4;
            ELSE next_state <= ST3;
            END IF;
        WHEN ST4 =>
            y <= x"4444";
            IF x = '1' THEN next_state <= ST5;
            ELSE next_state <= ST4;
            END IF;
        WHEN ST5 =>
            y <= x"5555";
            IF x = '1' THEN next_state <= ST6;
            ELSE next_state <= ST5;
            END IF;
        WHEN ST6 =>
            y <= x"6666";
            IF x = '1' THEN next_state <= ST7;
            ELSE next_state <= ST6;
            END IF;
        WHEN ST7 =>
            y <= x"7777";
            IF x = '1' THEN next_state <= ST0;
            ELSE next_state <= ST7;
            END IF;
        WHEN OTHERS =>
            next_state <= ST0;
        END CASE;
    END PROCESS ns;          
                                             
end Behavioral;
