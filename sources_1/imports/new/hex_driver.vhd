----------------------------------------------------
-- ECE 241 Lab 6 (2018)
-- written by Dr. D. Capson
-- example VHDL code to display 16-bit input from
-- BASYS3 slide switches on four
-- 7-segment displays on BASYS3 board
----------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity hex_driver is

    Port (
	clk	: in STD_LOGIC;
    reset	: in STD_LOGIC;
    done	: in STD_LOGIC;
	d_in	: in STD_LOGIC_VECTOR ( 15 downto 0 );
	anodes 	: out STD_LOGIC_VECTOR ( 3 downto 0 );
	cathodes: out STD_LOGIC_VECTOR ( 6 downto 0 )
	);
  
end hex_driver;

architecture behavioural of hex_driver is

-- Counting number of clock ticks (28 bits required for 100,000,000 ticks !
  signal refresh_display_counter: STD_LOGIC_VECTOR (27 downto 0);    

-- a signal to indicate when we reach the maximum number of clock ticks required for the time period  
  signal refresh_period_reached: STD_LOGIC;  

signal digit_enable_counter: STD_LOGIC_VECTOR (1 downto 0); -- a 2-bit counter for rotating the anode enable among the 4 7-seg digits

signal hex_digit_to_display: STD_LOGIC_VECTOR (3 downto 0); -- hold the current value to be written to the 7-seg digit


begin

process( clk, reset )  -- timer for the refresh period of the 7-seg displays
begin
	if(reset = '1') then
		refresh_display_counter <= x"0000000";

	elsif ( rising_edge( clk )) then
		if(refresh_display_counter >= x"000BC1F") then 
			refresh_display_counter <= x"0000000";

		 else
			refresh_display_counter <= refresh_display_counter + x"0000001";
		end if;
	end if;
end process;

refresh_period_reached <= '1' when refresh_display_counter = x"000BC1F" else '0';


process(clk, reset )  -- 2-bit counter to enable 1 of 4 7-seg digits
begin
        if(reset = '1') then
            digit_enable_counter <= b"00";
        elsif(rising_edge(clk)) then
          if(refresh_period_reached = '1') then
                -- increment the counter when the maximum number of clock ticks has been reached            
                digit_enable_counter <= digit_enable_counter + 1;   
             end if;
        end if;
end process;


process(hex_digit_to_display, done )
begin
  if ( done = '1' ) then
    -- active cathode has 0 on it.
    -- Organized as:                        GFEDCBA
	   case hex_digit_to_display is
		when "0000" => cathodes <= "1000000"; -- "0"     
		when "0001" => cathodes <= "1111001"; -- "1" 
		when "0010" => cathodes <= "0100100"; -- "2" 
		when "0011" => cathodes <= "0110000"; -- "3" 
		when "0100" => cathodes <= "0011001"; -- "4" 
		when "0101" => cathodes <= "0010010"; -- "5" 
		when "0110" => cathodes <= "0000010"; -- "6" 
		when "0111" => cathodes <= "1111000"; -- "7" 
		when "1000" => cathodes <= "0000000"; -- "8"     
		when "1001" => cathodes <= "0010000"; -- "9" 
		when "1010" => cathodes <= "0001000"; -- "A"
		when "1011" => cathodes <= "0000011"; -- "b"
		when "1100" => cathodes <= "1000110"; -- "C"
		when "1101" => cathodes <= "0100001"; -- "d"
		when "1110" => cathodes <= "0000110"; -- "E"
		when "1111" => cathodes <= "0001110"; -- "F"
	   end case;
	
	else
	   cathodes <= "0111111";
	end if;
end process;


process( clk, reset, digit_enable_counter )
begin
    if(reset = '1') then
		anodes <= b"1111";  -- disable all 4 digits while in reset (i.e. blank the display)
    
	elsif(rising_edge( clk )) then


		case digit_enable_counter is  -- this is a 2-line to 4-line decoder function !
        
				when "00" =>
                   anodes <= b"0111"; -- enable AN3 (the left-most 7-seg display)
                   hex_digit_to_display <= d_in(15 downto 12);

				when "01" =>
                   anodes <= b"1011"; -- enable AN2 (the 2nd-from-the-left 7-seg display)
                   hex_digit_to_display <= d_in(11 downto 8);

        
				when "10" =>
                    anodes <= b"1101"; -- enable AN1 (the 2nd-from-the-right 7-seg display)
                    hex_digit_to_display <= d_in(7 downto 4);
        
				when "11" =>
                    anodes <= b"1110"; -- enable AN0 (the right-most 7-seg display)
                    hex_digit_to_display <= d_in(3 downto 0);

		end case;
	end if;
end process;

end behavioural;
