----------------------------------------------------------------------------------
-- Course: ECE 441 
-- Program: CORDIC
-- File: Top file 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.CORDIC_package.ALL;

--BASYS 3 Input/outputs
entity top is
port (
    -- button
    clk         : IN std_logic; -- 100MHz Clock 
	btnC    	: IN std_logic; -- User Button
	btnU    	: IN std_logic; -- Reset Button 
	btnD    	: IN std_logic; --NOT USED 
	btnR    	: IN std_logic; --Next state 
	btnL    	: IN std_logic; --NOT USED 
 
    --switches
	sw          : IN std_logic_vector(15 downto 0); --Slide switch vector
	
	--LEDs
	led         : OUT std_logic_vector(15 downto 0); --LED output vector
	
	--7-segment display 
	seg         : OUT std_logic_vector(6 downto 0); --Cathodes
	an         : OUT std_logic_vector(3 downto 0)); --Anodes 
end top;

architecture structural of top is

--Components for CORDIC

--Driver for 7 segment display
component hex_driver is 
port(
    clk	    : IN STD_LOGIC;
    reset	: in STD_LOGIC;
    done	: in STD_LOGIC;
	d_in	: in STD_LOGIC_VECTOR ( 15 downto 0 );
	anodes 	: out STD_LOGIC_VECTOR ( 3 downto 0 );
	cathodes: out STD_LOGIC_VECTOR ( 6 downto 0 ));
end component;

--General purpose button debouncer
component debouncer is
    Port ( 
           clk_100MHz    : in  STD_LOGIC;
           reset         : in  STD_LOGIC;
           PB_in         : in std_logic;    -- the input PB that is bouncy
           PB_out        : out std_logic    -- the de-bounced output
        );  
end component;

--Finite state machine
component FSM is
 Port ( 
     clk:       IN std_logic;
     x:         IN std_logic;
     reset:     IN std_logic;
     y:         OUT std_logic_vector(3 downto 0));
end component;

--Edge detector: Single pulse on falling edge of the signal
component EdgeDetector is
   port (
      clk      :in std_logic;
      d        :in std_logic;
      edge     :out std_logic
   );
end component EdgeDetector;

component reg_16b is
    PORT (
        d       :IN STD_LOGIC_VECTOR(15 downto 0);
        load    :IN STD_LOGIC;
        clr     :IN STD_LOGIC;
        clk     :IN STD_LOGIC;
        q       :OUT STD_LOGIC_VECTOR(15 downto 0)
        );
end component reg_16b;

component RAM16 is
    PORT(
    clk         :IN STD_LOGIC;
    clear       :IN STD_LOGIC;
    write_en    :IN STD_LOGIC;
    d           :IN STD_LOGIC_VECTOR(15 downto 0);
    address     :IN STD_LOGIC_VECTOR(3 downto 0);
    q           :OUT STD_LOGIC_VECTOR(15 downto 0));
end component RAM16;

component COUNTER_4BIT is
        PORT(
        clk:        IN STD_LOGIC;
        reset:      IN STD_LOGIC;
        clear:      IN STD_LOGIC;
        inc:        IN STD_LOGIC;
        count_out:  OUT STD_LOGIC_VECTOR(15 downto 0)
        );
end component COUNTER_4BIT;

component ROM is
   PORT (
     address :      IN STD_LOGIC_VECTOR (3 downto 0);
     q :            OUT STD_LOGIC_VECTOR (15 downto 0));
 end component ROM;
    

--Data to be displayed on 7-segment display
signal disp_data: STD_LOGIC_VECTOR (15 downto 0):= x"0000"; --Data to be displayed on 7-seg display

--User button debounced
signal user_btn_deb_c: STD_LOGIC  := '0';

--User button debounced
signal user_btn_deb_r: STD_LOGIC  := '0';

--Reset button debounced
signal reset_btn_deb: STD_LOGIC  := '0';

--Button falling edge 
signal btn_edge_c: STD_LOGIC  := '0';
signal btn_edge_r: STD_LOGIC  := '0';

--Done signal from final state of state machine
signal done: STD_LOGIC := '0';

--Current state
signal fsm_state: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

--x,y,z data and register 
signal write_data: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal read_data: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal xdata: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal ydata: STD_LOGIC_VECTOR (15 downto 0) :=  (others => '0');
signal zdata: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');

signal LUT_address: STD_LOGIC_VECTOR (3 downto 0);
signal LUT_data: STD_LOGIC_VECTOR (15 downto 0);

signal RAM_address: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal WE: STD_LOGIC;

signal cout: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal inc_counter: STD_LOGIC := '0';
signal clear_counter: STD_LOGIC := '0';

begin  
  --Debouncer for user button
  User_DB_C:      debouncer port map (clk_100Mhz => clk, reset => reset_btn_deb, PB_in => btnC, PB_out => user_btn_deb_c);
  User_DB_R:      debouncer port map (clk_100Mhz => clk, reset => reset_btn_deb, PB_in => btnR, PB_out => user_btn_deb_r);
  
  --Debouncer for reset button
  Reset_DB:     debouncer port map (clk_100Mhz => clk, reset => reset_btn_deb, PB_in => btnU, PB_out => reset_btn_deb);
  
  --Hex driver to display "disp_data"
  HEX:     hex_driver port map (clk => clk, reset => reset_btn_deb, done => done, d_in => disp_data, anodes => an, cathodes => seg);   
  
  -- Edge detechtor for user button
  ED_C:      EdgeDetector port map(clk => clk, d => user_btn_deb_c, edge => btn_edge_c);
  ED_R:      EdgeDetector port map(clk => clk, d => user_btn_deb_r, edge => btn_edge_r);
  
  -- Finite state machine for CORDIC algorithm
  CORDIC_FSM:     FSM port map(clk => clk, x => btn_edge_r, reset => reset_btn_deb, y => fsm_state);
  
  --RAM
    RAM:          RAM16 port map(clk => clk, clear => reset_btn_deb , write_en => WE, d => write_data, address => RAM_address, q => read_data);

  --LUT
     LUT:          ROM port map(address => LUT_address, q => LUT_data);
    
    --counter
    C1:         COUNTER_4BIT port map(clk => clk, reset => btn_edge_r, clear => clear_counter, inc => inc_counter, count_out => cout);
    
    CORDIC: PROCESS (clk, btn_edge_r, btn_edge_c, fsm_state) IS
    BEGIN
    done <= '1';
    
    CASE fsm_state IS 
    WHEN x"0" => --User input x variable
        led <= x"0000";
        disp_data <= sw;
        if btn_edge_c = '1' then
            write_data <= sw;
            RAM_address <= x_address;
            WE <= '1';
        ELSE
            WE <= '0';
        END IF;
        
    WHEN x"1" => --User input y variable
        led <= x"0001";
        disp_data <= sw;
        if btn_edge_c = '1' then
            write_data <= sw;
            RAM_address <= y_address;
            WE <= '1';
        ELSE
            WE <= '0';
        END IF;        
        
    WHEN x"2" => --User input z variable 
        led <= x"0002";
        disp_data <= sw;
        if btn_edge_c = '1' then
            write_data <= sw;
            RAM_address <=z_address;
            WE <= '1';
        ELSE
            WE <= '0';
        END IF;        
        
    WHEN x"3" => --loop through input data
        led <= x"0003"; 
        disp_data <= read_data;
        RAM_address <= cout(3 downto 0);
        inc_counter <= btn_edge_c;
        
        IF cout >= x"0003" THEN
            clear_counter <= '1';
        else 
            clear_counter <= '0';
        END IF;
        
    WHEN x"4" => --Run CORDIC algorithm 
        led <= x"0004"; 
        disp_data <= LUT_data;
        LUT_address <= cout(3 downto 0);
        inc_counter <= btn_edge_c;
        
        IF cout >= x"0016" THEN
            clear_counter <= '1';
        else 
            clear_counter <= '0';
         END IF;
        
    WHEN x"5" => --Run CORDIC algorithm 
       led <= x"0005"; 

    WHEN x"6" => --Run CORDIC algorithm 
       led <= x"0006"; 

    WHEN x"7" => --Run CORDIC algorithm 
       led <= x"0007";
     
    WHEN OTHERS =>
        led <= x"ffff";
        disp_data <= sw;
    END CASE;
    
END PROCESS CORDIC;          
        
    
end structural;