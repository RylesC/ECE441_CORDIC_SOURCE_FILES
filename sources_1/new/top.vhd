----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/07/2019 04:42:09 PM
-- Design Name: 
-- Module Name: top - structural
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
port (
    -- button
    clk         : IN std_logic;
	btnC    	: IN std_logic;
	btnU    	: IN std_logic;
	btnD    	: IN std_logic;
	btnR    	: IN std_logic;
	btnL    	: IN std_logic;
    --switches
	sw          : IN std_logic_vector(15 downto 0);
	--LEDs
	led         : OUT std_logic_vector(15 downto 0);
	--7-segment display 
	seg         : OUT std_logic_vector(6 downto 0);
	an         : OUT std_logic_vector(3 downto 0));

end top;

architecture structural of top is

component hex_driver is 
port(
    clk	    : IN STD_LOGIC;
    reset	: in STD_LOGIC;
    done	: in STD_LOGIC;
	d_in	: in STD_LOGIC_VECTOR ( 15 downto 0 );
	anodes 	: out STD_LOGIC_VECTOR ( 3 downto 0 );
	cathodes: out STD_LOGIC_VECTOR ( 6 downto 0 ));
end component;

component debouncer is
    Port ( 
           clk_100MHz    : in  STD_LOGIC;
           reset         : in  STD_LOGIC;
           PB_in         : in std_logic;    -- the input PB that is bouncy
           PB_out        : out std_logic    -- the de-bounced output
        );  
end component;

component FSM is
 Port ( 
 clk:       IN std_logic;
 x:         IN std_logic;
 reset:     IN std_logic;
 y:         OUT std_logic_vector(15 downto 0));
end component;

component EdgeDetector is
   port (
      clk      :in std_logic;
      d        :in std_logic;
      edge     :out std_logic
   );
end component EdgeDetector;


--signals here
signal disp_data: STD_LOGIC_VECTOR (15 downto 0); --Data to be displayed on 7-seg display
signal btn_deb: STD_LOGIC;
signal reset: STD_LOGIC;
signal btn_r: STD_LOGIC;

--reset <= '1';

begin

  DB1:      debouncer port map (clk_100Mhz => clk, reset => '0', PB_in => btnC, PB_out => btn_deb);
  HEX1:     hex_driver port map (clk => clk, reset => '0', done => '1', d_in => disp_data, anodes => an, cathodes => seg);   
  FSM1:     FSM port map(clk => clk, x => btn_r, reset => '0', y => disp_data);
  ED1:      EdgeDetector port map(clk => clk, d => btn_deb, edge => btn_r);
  
--P1: process (btn_deb)
--    begin 
--        IF (btn_deb'event and btn_deb = '1') then
--            btn_r <= '1';
--        ELSE
--            btn_r <= '0';
--        END IF;
--    -- end if;
--end process P1;
    
end structural;