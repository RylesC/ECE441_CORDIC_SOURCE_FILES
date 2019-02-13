----------------------------------------------------------------------------------
--
-- A Push Button (PB) switch de-deboucer
--
-- (c)2018 Dr. D. Capson    Dept. of ECE
--                          University of Victoria
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity debouncer is
    Port ( 
           clk_100MHz    : in  STD_LOGIC;
           reset         : in  STD_LOGIC;
           PB_in         : in std_logic;    -- the input PB that is bouncy
           PB_out        : out std_logic    -- the de-bounced output
        );  
end debouncer;

architecture behavioural of debouncer is

constant COUNT_MAX : integer := 100000;   -- number of clocks to delay to get past bouncing periods
signal count : integer := 0; -- the counter to implement the delays.  10 to 12ms is typical. 10000000=10ms

type   state_type is (wait_for_push, push_detected, wait_for_release, release_detected);  --state types for PB debouncer
signal state : state_type := wait_for_push;  -- intialized to waiting for push of the PB

begin

-- process for implementing the state transitions
-- for de-bouncing the push button switch (PB_in)
process(reset, clk_100MHz)  
begin
   if(reset = '1') then
        state <= wait_for_push;
    
   elsif rising_edge(clk_100MHz) then
        
        case (state) is
        
            when wait_for_push =>
                if(PB_in = '1') then  
                    state <= push_detected;
                else
                    state <= wait_for_push;
                end if;
                            
            when push_detected =>
                if(count = COUNT_MAX) then
                    if(PB_in = '1') then
                        count <= 0;
                        state <= wait_for_release;
                    else
                        state <= wait_for_push;
                    end if;
                else    
                    count <= count + 1; 
                end if;

            when wait_for_release =>
                if(PB_in = '0') then  
                    state <= release_detected;
                else
                    state <= wait_for_release;
                end if;  
                 
            when release_detected =>
               if(count = COUNT_MAX) then
                   if(PB_in = '0') then
                      count <= 0;  
                      state <= wait_for_push;
                   else
                      state <= release_detected;
                   end if;  
               else
                     count <= count + 1;
               end if;
 
        end case;       
    end if;        
end process;                  


process (state) -- PROCESS to define the Moore outputs of the debouncer state machine
begin 
   case state is
      when wait_for_push => PB_out <= '0';
      when push_detected => PB_out <= '0';	
      when wait_for_release => PB_out <= '1';	
      when release_detected => PB_out <= '0';	
   end case;
end process;

end behavioural;
