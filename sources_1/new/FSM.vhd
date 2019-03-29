----------------------------------------------------------------------------------
-- Engineer: Riley Cambon
-- Module Name: FSM - Behavioral
-- Project Name: CORDIC
-- Description: 2 Process Finite State Machine
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.CORDIC_package.ALL;

ENTITY FSM IS
 PORT ( 
     clk:       IN STD_LOGIC;                       --Clock
     x:         IN STD_LOGIC;                       --FSM input
     reset:     IN STD_LOGIC;                       --Reset
     y:         OUT STD_LOGIC_VECTOR(3 downto 0));  --FSM output
END FSM;

ARCHITECTURE Behavioral OF FSM IS

SIGNAL current_state: state;    --Current state of FSM
SIGNAL next_state: state;       --Next state of FSM

BEGIN
--------------- 2 process Moore FSM------------------- 
    --Current state process
    cs: PROCESS (clk, reset) IS BEGin
        IF reset = '1' THEN current_state <= ST0; --default state
        ELSIF rising_edge (clk) THEN current_state <= next_state;  --make next state current state
        END IF;
    END PROCESS cs;
    
    --Next state process (16 states, increment to next state when x = '1')
    ns: PROCESS (current_state, x) IS BEGIN
        CASE current_state IS 
        WHEN ST0 => --User input x variable
            y <= x"0";
            IF x = '1' THEN next_state <= ST1;
            ELSE next_state <= ST0;
            END IF;
        WHEN ST1 => --User input y variable
            y <= x"1";
            IF x = '1' THEN next_state <= ST2;
            ELSE next_state <= ST1;  
            END IF;          
        WHEN ST2 => 
            y <= x"2";
            IF x = '1' THEN next_state <= ST3;
            ELSE next_state <= ST2;  
            END IF;          
        WHEN ST3 =>
            y <= x"3";
            IF x = '1' THEN next_state <= ST4;
            ELSE next_state <= ST3;
            END IF;
        WHEN ST4 =>
            y <= x"4";
            IF x = '1' THEN next_state <= ST5;
            ELSE next_state <= ST4;
            END IF;
        WHEN ST5 =>
            y <= x"5";
            IF x = '1' THEN next_state <= ST6;
            ELSE next_state <= ST5;
            END IF;            
         WHEN ST6 =>
            y <= x"6";
            IF x = '1' THEN next_state <= ST7;
            ELSE next_state <= ST6;           
            END IF;
         WHEN ST7 =>
            y <= x"7";
            IF x = '1' THEN next_state <= ST8;
            ELSE next_state <= ST7;           
            END IF;   
         WHEN ST8 =>
            y <= x"8";
            IF x = '1' THEN next_state <= ST9;
            ELSE next_state <= ST8;           
            END IF;   
         WHEN ST9 =>
            y <= x"9";
            IF x = '1' THEN next_state <= ST10;
            ELSE next_state <= ST9;           
            END IF;   
         WHEN ST10 =>
            y <= x"A";
            IF x = '1' THEN next_state <= ST11;
            ELSE next_state <= ST10;           
            END IF;   
         WHEN ST11 =>
            y <= x"B";
            IF x = '1' THEN next_state <= ST12;
            ELSE next_state <= ST11;           
            END IF;   
         WHEN ST12 =>
            y <= x"C";
            IF x = '1' THEN next_state <= ST13;
            ELSE next_state <= ST12;           
            END IF;   
         WHEN ST13 =>
            y <= x"D";
            IF x = '1' THEN next_state <= ST14;
            ELSE next_state <= ST13;           
            END IF;  
         WHEN ST14 =>
            y <= x"E";
            IF x = '1' THEN next_state <= ST15;
            ELSE next_state <= ST14;           
            END IF;
         WHEN ST15 =>
            y <= x"F";
            IF x = '1' THEN next_state <= ST0;
            ELSE next_state <= ST15;         
            END IF;                                                                                                                                            
        WHEN OTHERS =>
            next_state <= ST0;
        END CASE;
    END PROCESS ns;          
                                             
END Behavioral;
