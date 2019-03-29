----------------------------------------------------------------------------------
-- Engineer: Riley Cambon
-- Module Name: EdgeDetector - Behavioral
-- Project Name: CORDIC
-- Description: Falling edge detector
----------------------------------------------------------------------------------

library ieee;
use ieee.STD_LOGIC_1164.all;

ENTITY EdgeDetector IS
   PORT (
      clk      :IN STD_LOGIC;   --Clock
      d        :IN STD_LOGIC;   --Signal input
      edge     :OUT STD_LOGIC   --Edge output
   );
END EdgeDetector;

ARCHITECTURE Behavioral OF EdgeDetector IS

   SIGNAL d1 :STD_LOGIC;
   SIGNAL d2 :STD_LOGIC;

BEGIN
reg: PROCESS(clk)
    BEGIN
       IF rising_edge(clk) THEN
          d1  <= d;
          d2  <= d1;
      END IF;
    END PROCESS;

edge <= d1 AND (NOT d2);

END Behavioral;