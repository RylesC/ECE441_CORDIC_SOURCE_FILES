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
        count_out:  OUT STD_LOGIC_VECTOR(15 downto 0)
        );
end component COUNTER_4BIT;

component ROM is
   PORT (
     address :      IN STD_LOGIC_VECTOR (3 downto 0);
     q :            OUT STD_LOGIC_VECTOR (15 downto 0));
 end component ROM;
    

component alu is 
  Port (
        x_in : in STD_LOGIC_VECTOR(15 DOWNTO 0); 
        y_in : in STD_LOGIC_VECTOR(15 DOWNTO 0);
        z_in : in STD_LOGIC_VECTOR(15 DOWNTO 0);
        theta : in STD_LOGIC_VECTOR(15 DOWNTO 0);
        i : in STD_LOGIC_VECTOR(4 DOWNTO 0);
        add_sub_x : in STD_LOGIC;
        add_sub_y : in STD_LOGIC;
        add_sub_z : in STD_LOGIC;
        x_out : out STD_LOGIC_VECTOR(15 DOWNTO 0); 
        y_out : out STD_LOGIC_VECTOR(15 DOWNTO 0);
        z_out : out STD_LOGIC_VECTOR(15 DOWNTO 0);
        clk   : in STD_LOGIC
        );
  end component alu;

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


signal cout: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal inc_counter: STD_LOGIC := '0';
signal clear_counter: STD_LOGIC := '0';

--alu
 signal x_in : STD_LOGIC_VECTOR(15 DOWNTO 0); 
 signal y_in : STD_LOGIC_VECTOR(15 DOWNTO 0);
 signal z_in :  STD_LOGIC_VECTOR(15 DOWNTO 0);
 signal theta :  STD_LOGIC_VECTOR(15 DOWNTO 0);
 signal i :      STD_LOGIC_VECTOR(4 DOWNTO 0);
 signal add_sub_x :  STD_LOGIC;
 signal add_sub_y :  STD_LOGIC;
 signal add_sub_z :  STD_LOGIC;
 signal x_out :  STD_LOGIC_VECTOR(15 DOWNTO 0); 
 signal y_out :  STD_LOGIC_VECTOR(15 DOWNTO 0);
 signal z_out :  STD_LOGIC_VECTOR(15 DOWNTO 0);



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
  
    RAM:          RAM16 port map(
                  clk => clk, clear => btnU, 
                  write_en_x => WE_x, write_en_y => WE_y, write_en_z => WE_z,
                  d_x => write_data_x, d_y => write_data_y, d_z => write_data_z,  
                  q_x => read_data_x, q_y => read_data_y, q_z => read_data_z);

  --LUT
     LUT:          ROM port map(address => LUT_address, q => LUT_data);
    
    --counter
    C1:         COUNTER_4BIT port map(clk => clk, reset => btn_edge_r, clear => clear_counter, inc => btn_edge_c, count_out => cout);
    
    ALU1:        alu port map(clk => clk, x_in => x_in, y_in =>y_in, z_in => z_in, theta => theta, i => i, add_sub_x => add_sub_x, add_sub_y => add_sub_y, add_sub_z => add_sub_z,x_out=> x_out, y_out => y_out, z_out => z_out); 
    
    CORDIC: PROCESS (clk, btn_edge_r, btn_edge_c, fsm_state) IS
    BEGIN
    done <= '1';
    
    CASE fsm_state IS 
    WHEN x"0" => --User input x variable
        led <= x"0000";
        disp_data <= sw;
        if btn_edge_c = '1' then
            write_data_x <= sw;
            WE_x <= '1';
        ELSE
            WE_x <= '0';
        END IF;
        
    WHEN x"1" => --User input y variable
        led <= x"0001";
        disp_data <= sw;
        if btn_edge_c = '1' then
            write_data_y <= sw;
            WE_y <= '1';
        ELSE
            WE_y <= '0';
        END IF;        
        
    WHEN x"2" => --User input z variable 
        led <= x"0002";
        disp_data <= sw;
        if btn_edge_c = '1' then
            write_data_z <= sw;
            WE_z <= '1';
        ELSE
            WE_z <= '0';
        END IF;        
        
    WHEN x"3" => --loop through input data
        led <= x"0003";
        
        CASE cout IS
        WHEN  x"0000" =>
        disp_data <= read_data_x;
        WHEN  x"0001" =>
        disp_data <= read_data_y;
        WHEN  x"0002" =>
        disp_data <= read_data_z; 
        WHEN OTHERS =>
        IF cout >= x"0003" THEN
            clear_counter <= '1';
        else
            clear_counter <= '0';
        END IF;
        disp_data <= read_data_x;
        END CASE;
        
    WHEN x"4" => --Run CORDIC algorithm 
        led <= x"0004"; 
        
        x_in <= read_data_x; 
        y_in <= read_data_y; 
        z_in <= read_data_z;         
        
        FOR index in 0 to 15 LOOP
                
                IF index > 0 THEN
                x_in <= x_out;
                y_in <= y_out;
                z_in <= z_out;
                ELSE
                NULL;
                END IF;
                
                i <= STD_LOGIC_VECTOR(TO_UNSIGNED(index, 5));
                LUT_address <= i(3 downto 0);
                theta <= LUT_data;
                
                --mu 
                IF z_in < x"0000" THEN
                    add_sub_x <= '1';
                    add_sub_y <= '1';
                    add_sub_z <= '1';
                ELSE
                    add_sub_x <= '0';
                    add_sub_y <= '0';
                    add_sub_z <= '0';
                END IF;
 
            IF z_out = x"0000" then
            write_data_x <= x_out;
            write_data_y <= y_out;
            write_data_z <= z_out;
            WE_x <= '1';
            WE_y <= '1';
            WE_z <= '1';
            led <= x"7777";
            exit;
            END IF;        
        END LOOP;
        
    WHEN x"5" => --Run CORDIC algorithm 
       led <= x"0005"; 

        CASE cout IS
        WHEN  x"0000" =>
        disp_data <= read_data_x;
        WHEN  x"0001" =>
        disp_data <= read_data_y;
        WHEN  x"0002" =>
        disp_data <= read_data_z; 
        WHEN OTHERS =>
        IF cout >= x"0003" THEN
            clear_counter <= '1';
        else
            clear_counter <= '0';
        END IF;
        disp_data <= read_data_x;
        END CASE;
        
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