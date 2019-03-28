----------------------------------------------------------------------------------
-- Course: ECE 441 
-- Program: CORDIC
-- File: Top file 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.CORDIC_package.ALL;
library xil_deafultlib;
use xil_deafultlib.all;
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
    CE          : IN STD_LOGIC;
    clear       :IN STD_LOGIC;
    write_en_x    :IN STD_LOGIC;
    write_en_y    :IN STD_LOGIC;
    write_en_z    :IN STD_LOGIC;
    d_x           :IN STD_LOGIC_VECTOR(15 downto 0);
    d_y           :IN STD_LOGIC_VECTOR(15 downto 0);
    d_z           :IN STD_LOGIC_VECTOR(15 downto 0);        
    q_x           :OUT STD_LOGIC_VECTOR(15 downto 0);
    q_y           :OUT STD_LOGIC_VECTOR(15 downto 0);
    q_z           :OUT STD_LOGIC_VECTOR(15 downto 0));
end component RAM16;

component COUNTER_4BIT is
        PORT(
        clk:        IN STD_LOGIC;
        reset:      IN STD_LOGIC;
        clear:      IN STD_LOGIC;
        inc:        IN STD_LOGIC;
        count_out:  OUT STD_LOGIC_VECTOR(3 downto 0)
        );
end component COUNTER_4BIT;

component ROM is
   PORT (
     address :      IN STD_LOGIC_VECTOR (3 downto 0);
     q :            OUT STD_LOGIC_VECTOR (15 downto 0));
 end component ROM;
    
component clk_div_2 is
PORT(
    clk: IN STD_LOGIC;
    reset: IN STD_LOGIC;
    clkdiv2: OUT STD_LOGIC
    );
end COMPONENT clk_div_2;

component alu is 
  Port (
        x_in : in STD_LOGIC_VECTOR(15 DOWNTO 0); 
        y_in : in STD_LOGIC_VECTOR(15 DOWNTO 0);
        z_in : in STD_LOGIC_VECTOR(15 DOWNTO 0);
        theta : in STD_LOGIC_VECTOR(15 DOWNTO 0);
        i : in STD_LOGIC_VECTOR(3 DOWNTO 0);
        add_sub_x : in STD_LOGIC;
        add_sub_y : in STD_LOGIC;
        add_sub_z : in STD_LOGIC;
        x_out : out STD_LOGIC_VECTOR(15 DOWNTO 0); 
        y_out : out STD_LOGIC_VECTOR(15 DOWNTO 0);
        z_out : out STD_LOGIC_VECTOR(15 DOWNTO 0);
        clk   : in STD_LOGIC
        );
  end component alu;

component LATCH_16B is
    Port (
        input_data0  : in STD_LOGIC_VECTOR(15 downto 0);
        input_data1  : in STD_LOGIC_VECTOR(15 downto 0);
        enable      : in STD_LOGIC;
        input_sel   : in STD_LOGIC;
        output_data : out STD_LOGIC_VECTOR(15 downto 0)
         );
end component;

--Data to be displayed on 7-segment display
signal disp_data: STD_LOGIC_VECTOR (15 downto 0):= x"0000"; --Data to be displayed on 7-seg display

--User button debounced
signal user_btn_deb_c: STD_LOGIC  := '0';

--User button debounced
signal user_btn_deb_l: STD_LOGIC  := '0';

--User button debounced
signal user_btn_deb_r: STD_LOGIC  := '0';

--Reset button debounced
signal reset_btn_deb: STD_LOGIC  := '0';

--Button falling edge 
signal btn_edge_c: STD_LOGIC  := '0';
signal btn_edge_r: STD_LOGIC  := '0';
signal btn_edge_l: STD_LOGIC  := '0';

--Done signal from final state of state machine
signal done: STD_LOGIC := '0';

--Current state
signal fsm_state: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

--x,y,z data and register 
signal write_data_x: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal write_data_y: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal write_data_z: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal read_data_x: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal read_data_y: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal read_data_z: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal xdata: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal ydata: STD_LOGIC_VECTOR (15 downto 0) :=  (others => '0');
signal zdata: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');

signal LUT_address: STD_LOGIC_VECTOR (3 downto 0);
signal LUT_data: STD_LOGIC_VECTOR (15 downto 0);

signal WE_x: STD_LOGIC;
signal WE_y: STD_LOGIC;
signal WE_z: STD_LOGIC;

signal CE: STD_LOGIC;

----------------Counter-----------------------
signal cout: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal inc_counter: STD_LOGIC := '0';
signal clear_counter: STD_LOGIC := '0';
signal iteration    : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

--alu
 signal x_in : STD_LOGIC_VECTOR(15 DOWNTO 0); 
 signal y_in : STD_LOGIC_VECTOR(15 DOWNTO 0);
 signal z_in :  STD_LOGIC_VECTOR(15 DOWNTO 0);
 signal i :      STD_LOGIC_VECTOR(4 DOWNTO 0);
 signal add_sub_x :  STD_LOGIC;
 signal add_sub_y :  STD_LOGIC;
 signal add_sub_z :  STD_LOGIC;
 signal x_out :  STD_LOGIC_VECTOR(15 DOWNTO 0); 
 signal y_out :  STD_LOGIC_VECTOR(15 DOWNTO 0);
 signal z_out :  STD_LOGIC_VECTOR(15 DOWNTO 0);
 signal alu_clk: STD_LOGIC; 

 signal write_flag :  STD_LOGIC := '0';


----------------Latch-------------------
--Initial values for x,y and z
signal x_init : STD_LOGIC_VECTOR(15 downto 0);
signal y_init : STD_LOGIC_VECTOR(15 downto 0);
signal z_init : STD_LOGIC_VECTOR(15 downto 0);
      
--Input to latch from ram
signal ram_out_x  : STD_LOGIC_VECTOR(15 downto 0);      
signal ram_out_y  : STD_LOGIC_VECTOR(15 downto 0);   
signal ram_out_z  : STD_LOGIC_VECTOR(15 downto 0);         
signal theta      : STD_LOGIC_VECTOR(15 downto 0);
      
--Latch enable
signal latch_en : STD_LOGIC := '0';

--input select (0 for inital value, 1 for calculated value)      
signal input_sel : STD_LOGIC;
signal cordic_iterate_en : STD_LOGIC := '0';
signal clkdiv2: STD_LOGIC := '0';


--Latch outputs
signal latch_out_x  : STD_LOGIC_VECTOR(15 downto 0);      
signal latch_out_y  : STD_LOGIC_VECTOR(15 downto 0);   
signal latch_out_z  : STD_LOGIC_VECTOR(15 downto 0);    

begin  
  --Debouncer for user button
  User_DB_C:      debouncer port map (clk_100Mhz => clk, reset => reset_btn_deb, PB_in => btnC, PB_out => user_btn_deb_c);
  User_DB_R:      debouncer port map (clk_100Mhz => clk, reset => reset_btn_deb, PB_in => btnR, PB_out => user_btn_deb_r);
  User_DB_L:      debouncer port map (clk_100Mhz => clk, reset => reset_btn_deb, PB_in => btnl, PB_out => user_btn_deb_l);

  --Debouncer for reset button
  Reset_DB:     debouncer port map (clk_100Mhz => clk, reset => reset_btn_deb, PB_in => btnU, PB_out => reset_btn_deb);
 
  -- Edge detechtor for user button
  ED_C:      EdgeDetector port map(clk => clk, d => user_btn_deb_c, edge => btn_edge_c);
  ED_R:      EdgeDetector port map(clk => clk, d => user_btn_deb_r, edge => btn_edge_r);
  ED_L:      EdgeDetector port map(clk => clk, d => user_btn_deb_l, edge => btn_edge_l);

   --Hex driver to display "disp_data"
  HEX:     hex_driver port map (clk => clk, reset => reset_btn_deb, done => done, d_in => disp_data, anodes => an, cathodes => seg);   
  
  
  -- Finite state machine for CORDIC algorithm
  USER_FSM:       FSM port map(clk => clk, x => btn_edge_r, reset => reset_btn_deb, y => fsm_state);
  
  CORDIC_FSM:     FSM port map(clk => clk, x => cordic_iterate_en, reset => reset_btn_deb, y => iteration);


  X_LATCH:        LATCH_16B port map(input_data0 => x_init, input_data1 => ram_out_x, enable => '1', input_sel => input_sel, output_data => latch_out_x);
  Y_LATCH:        LATCH_16B port map(input_data0 => y_init, input_data1 => ram_out_y, enable => '1', input_sel => input_sel, output_data => latch_out_y);
  Z_LATCH:        LATCH_16B port map(input_data0 => z_init, input_data1 => ram_out_z, enable => '1', input_sel => input_sel, output_data => latch_out_z);   
  
  --RAM
  
    RAM:          RAM16 port map(
                  clk => clk, CE => CE, clear => reset_btn_deb, 
                  write_en_x => WE_x, write_en_y => WE_y, write_en_z => WE_z,
                  d_x => x_out, d_y => y_out, d_z => z_out,  
                  q_x => ram_out_x, q_y => ram_out_y, q_z => ram_out_z);


    CLK_DIV:       clk_div_2 port map(clk => clk, reset => reset_btn_deb, clkdiv2 => clkdiv2);
    
     LUT:          ROM port map(address => iteration, q => LUT_data);
    
    --counter
    Data_counter:           COUNTER_4BIT port map(clk => clk, reset => btn_edge_r, clear => clear_counter, inc => btn_edge_c, count_out => cout);
    --Iteration_Counter:      COUNTER_4BIT port map(clk => clk, reset => btn_edge_r, clear => clear_counter, inc => btn_edge_l, count_out => iteration);
    
    ALU1:        alu port map(clk => clk, x_in => latch_out_x, y_in =>latch_out_y, z_in => latch_out_z, theta => LUT_data, i => iteration, add_sub_x => add_sub_x, add_sub_y => add_sub_y, add_sub_z => add_sub_z, x_out=> x_out, y_out => y_out, z_out => z_out); 
    
    CORDIC: PROCESS (clk, btn_edge_r, btn_edge_c, clkdiv2, fsm_state, iteration) IS
    BEGIN
    done <= '1';
    
    CASE fsm_state IS 
    WHEN x"0" => --User input x variable
        led <= x"1000";
        input_sel <= '0';
--        latch_en <='1';
        disp_data <= sw;
        if btn_edge_c = '1' then
            x_init <= sw;
        END IF;
        
    WHEN x"1" => --User input y variable
        led <= x"2000";
        input_sel <= '0';
        --latch_en <='1';        
        disp_data <= sw;
        if btn_edge_c = '1' then
            y_init <= sw;
        END IF;        
        
    WHEN x"2" => --User input z variable 
        led <= x"4000";
        input_sel <= '0';
        --latch_en <='1';        
        disp_data <= sw;
        if btn_edge_c = '1' then
            z_init <= sw;
        END IF;        
        
    WHEN x"3" => --loop through input data
        input_sel <= '0';
        
        CASE cout IS
        WHEN  x"0" =>
            led <= x"0001";
            disp_data <= latch_out_x;
        WHEN  x"1" =>
            led <= x"0002";
            disp_data <= latch_out_y;
        WHEN  x"2" =>
            led <= x"0004";
            disp_data <= latch_out_z; 
        WHEN OTHERS =>
            IF cout >= x"3" THEN
                clear_counter <= '1';
            ELSIF cout < x"3" THEN
                clear_counter <= '0';
            END IF;
        END CASE;
        
    WHEN x"4" => --Run CORDIC algorithm 
   
    WE_x <= clkdiv2;
    WE_y <= clkdiv2;
    WE_z <= clkdiv2;
    --done <= '0';
    cordic_iterate_en <= clkdiv2;
    
    disp_data <= ram_out_z;          
    
    --Load inital values in first itteration
    IF iteration = x"0" THEN
        input_sel <= '0';
    ELSIF iteration = x"F" THEN
        led <= x"5555";
        WE_x <= '0';
        WE_y <= '0';
        WE_z <= '0';
        cordic_iterate_en <= '0';            
    ELSIF iteration > x"0" THEN
        input_sel <= '1';
        led <= (15 downto iteration'length => '0') & iteration;         
    END IF;        
   
        IF SIGNED(latch_out_z) >= 0 THEN 
        add_sub_x <= '1';
        add_sub_y <= '0'; 
        add_sub_z <= '1';
        ELSE
        add_sub_x <= '0';
        add_sub_y <= '1'; 
        add_sub_z <= '0';
        END IF;      
        
    WHEN x"5" => --Run CORDIC algorithm 
    led <= x"0005"; 
        
        CASE cout IS
        WHEN  x"0" =>
            led <= x"0001";
            disp_data <= ram_out_x;
        WHEN  x"1" =>
            led <= x"0002";
            disp_data <= ram_out_y;
        WHEN  x"2" =>
            led <= x"0004";
            disp_data <= ram_out_z; 
        WHEN OTHERS =>
            IF cout >= x"3" THEN
                clear_counter <= '1';
            ELSIF cout < x"3" THEN
                clear_counter <= '0';
            END IF;
        END CASE;
        
    WHEN OTHERS =>
        led <= x"ffff";
        disp_data <= sw;
    END CASE;
    
END PROCESS CORDIC;          
        
    
end structural;