----------------------------------------------------------------------------------
-- Engineer: Riley Cambon
-- Module Name: TOP - Behavioral
-- Project Name: CORDIC
-- Description: CORDIC top layer
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.CORDIC_package.ALL;
library xil_deafultlib;
use xil_deafultlib.all;

--BASYS 3 Development board Input/outputs
entity top is
PORT (
    
    clk         : IN STD_LOGIC; -- 100MHz Clock 
	
	--Button Inputs
	btnC    	: IN STD_LOGIC; -- User Button
	btnU    	: IN STD_LOGIC; -- Reset Button 
	btnR    	: IN STD_LOGIC; -- Next state 
	 
    --User switches to enter x,y,z values
	sw          : IN STD_LOGIC_VECTOR(15 downto 0); --Slide switch vector
	
	--LED output
	led         : OUT STD_LOGIC_VECTOR(15 downto 0); --LED output vector
	
	--7-segment display 
	seg         : OUT STD_LOGIC_VECTOR(6 downto 0); --Cathodes
	an         : OUT STD_LOGIC_VECTOR(3 downto 0)); --Anodes 
END top;

ARCHITECTURE structural of top is

-------Components for CORDIC------------


-----Driver for 7 segment display-------
COMPONENT hex_driver is 
PORT(
    clk	    : IN STD_LOGIC;                         -- Clock
    reset	: IN STD_LOGIC;                         -- Reset
    done	: IN STD_LOGIC;                         -- Display enable 
	d_in	: IN STD_LOGIC_VECTOR ( 15 downto 0 );  -- Display data
	anodes 	: OUT STD_LOGIC_VECTOR ( 3 downto 0 );  -- 7 segment Anodes
	cathodes: OUT STD_LOGIC_VECTOR ( 6 downto 0 )); -- 7 Segment Cathodes
END COMPONENT;


-------General purpose button debouncer----------
COMPONENT debouncer is
    PORT ( 
           clk_100MHz    : IN  STD_LOGIC;   -- Clock 
           reset         : IN  STD_LOGIC;   -- Reset
           PB_IN         : IN STD_LOGIC;    -- the Input PB that is bouncy
           PB_OUT        : OUT STD_LOGIC    -- the de-bounced output
        );  
END COMPONENT;


------------Finite state machine-----------------
COMPONENT FSM is
 PORT ( 
     clk:       IN STD_LOGIC;                       --Clock
     x:         IN STD_LOGIC;                       --FSM input
     reset:     IN STD_LOGIC;                       --Reset
     y:         OUT STD_LOGIC_VECTOR(3 downto 0));  --FSM output
END COMPONENT;

--------------Edge detector-----------------------
--(Single pulse on falling edge of the signal)
COMPONENT EdgeDetector is
   PORT (
      clk      :IN STD_LOGIC;   --Clock
      d        :IN STD_LOGIC;   --Signal input
      edge     :OUT STD_LOGIC   --Edge output
   );   
END COMPONENT EdgeDetector;

------------16Bbit 3 x parallel RAM----------------
COMPONENT RAM16 is
    PORT(
    clk         :IN STD_LOGIC;                          --Clock
    clear       :IN STD_LOGIC;                          --Clear RAM to zero values 
    write_en_x    :IN STD_LOGIC;                        --Write enable x
    write_en_y    :IN STD_LOGIC;                        --Write enable y
    write_en_z    :IN STD_LOGIC;                        --Write enable z
    d_x           :IN STD_LOGIC_VECTOR(15 downto 0);    --Write data x
    d_y           :IN STD_LOGIC_VECTOR(15 downto 0);    --Write data y
    d_z           :IN STD_LOGIC_VECTOR(15 downto 0);    --Write data z
    q_x           :OUT STD_LOGIC_VECTOR(15 downto 0);   --Output data x
    q_y           :OUT STD_LOGIC_VECTOR(15 downto 0);   --Output data y
    q_z           :OUT STD_LOGIC_VECTOR(15 downto 0));  --Output data z
END COMPONENT RAM16;

----------------4 bit counter-------------------------
COMPONENT COUNTER_4BIT is
        PORT(
            clk:        IN STD_LOGIC;                      --Clock 
            reset:      IN STD_LOGIC;                      --Reset to value "0000"
            clear:      IN STD_LOGIC;                      --Clears counter to value "0000"
            inc:        IN STD_LOGIC;                      --enables counting
            count_out:  OUT STD_LOGIC_VECTOR(3 downto 0)   --Count output
        );
END COMPONENT COUNTER_4BIT;

-------------Read only memory for LUT------------------
COMPONENT ROM is
   PORT (
     address :      IN STD_LOGIC_VECTOR (3 downto 0);       --Address for LUT
     q :            OUT STD_LOGIC_VECTOR (15 downto 0));    --Theta value 
 END COMPONENT ROM;

----Clock divider with single clock cycle pulses-----
COMPONENT clk_div_2 is
PORT(
    clk:        IN STD_LOGIC;   --Clock
    reset:      IN STD_LOGIC;   --Reset
    clkdiv2:    OUT STD_LOGIC   --Clock pulses at twice clock period 
    );
END COMPONENT clk_div_2;

---------------ALU for CORDIC Iterations---------------- 
COMPONENT alu is 
  PORT (
        x_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);    --X input
        y_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);    --Y input    
        z_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);    --Z input
        theta : IN STD_LOGIC_VECTOR(15 DOWNTO 0);   --Theta values from LUT
        i : IN STD_LOGIC_VECTOR(3 DOWNTO 0);        --Iteration number
        add_sub_x : IN STD_LOGIC;                   --Subtract x (0: Add, 1: Subtract)
        add_sub_y : IN STD_LOGIC;                   --Subtract y (0: Add, 1: Subtract)
        add_sub_z : IN STD_LOGIC;                   --Subtract z (0: Add, 1: Subtract)
        x_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);  --X output 
        y_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);  --Y output 
        z_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)   --Z output
        );
  END COMPONENT alu;

-----------------------16 Bit latch-------------------------
COMPONENT LATCH_16B is
    PORT (
        input_data0  : IN STD_LOGIC_VECTOR(15 downto 0);    --Input data 0
        input_data1  : IN STD_LOGIC_VECTOR(15 downto 0);    --Input data 1
        enable      : IN STD_LOGIC;                         --Enable
        input_sel   : IN STD_LOGIC;                         --Input select (0: input 0, 1: input 1)
        output_data : OUT STD_LOGIC_VECTOR(15 downto 0)     --Latch output 
         );
END COMPONENT;


-------------------Signals-------------------------

--Reset
signal reset: STD_LOGIC;
signal user_next_state: STD_LOGIC;

--Data to be displayed on 7-segment display
signal disp_data: STD_LOGIC_VECTOR (15 downto 0):= x"0000";

--Center user button debounced
signal user_btn_deb_c: STD_LOGIC  := '0';

--Right user button debounced
signal user_btn_deb_r: STD_LOGIC  := '0';

--Reset button debounced
signal reset_btn_deb: STD_LOGIC  := '0';

--User button falling edge signals 
signal btn_edge_c: STD_LOGIC  := '0';
signal btn_edge_r: STD_LOGIC  := '0';

--CORDIC interations complete signal to enable HEX driver 
signal done: STD_LOGIC := '0';

--Current state in USER FSM 
signal fsm_state: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

--16 Bit RAM x,y,z signals  
signal write_data_x: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal write_data_y: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal write_data_z: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal read_data_x: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal read_data_y: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal read_data_z: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal xdata: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal ydata: STD_LOGIC_VECTOR (15 downto 0) :=  (others => '0');
signal zdata: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal WE_x: STD_LOGIC;
signal WE_y: STD_LOGIC;
signal WE_z: STD_LOGIC;
signal clear_ram: STD_LOGIC;

--LUT address and data signals
signal LUT_address: STD_LOGIC_VECTOR (3 downto 0);
signal LUT_data: STD_LOGIC_VECTOR (15 downto 0);

--Counter singals 
signal cout: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal Inc_counter: STD_LOGIC := '0';
signal clear_counter: STD_LOGIC := '0';
signal iteration    : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

--ALU signals 
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


--Initial values for x,y and z for latch
signal x_init : STD_LOGIC_VECTOR(15 downto 0);
signal y_init : STD_LOGIC_VECTOR(15 downto 0);
signal z_init : STD_LOGIC_VECTOR(15 downto 0);

      
--Input to latch from ram
signal ram_out_x  : STD_LOGIC_VECTOR(15 downto 0);      
signal ram_out_y  : STD_LOGIC_VECTOR(15 downto 0);   
signal ram_out_z  : STD_LOGIC_VECTOR(15 downto 0); 

--Theta value from LUT        
signal theta      : STD_LOGIC_VECTOR(15 downto 0);
      
--Latch enable
signal latch_en : STD_LOGIC := '0';

--Input select (0 for inital value, 1 for calculated value)      
signal input_sel : STD_LOGIC;
signal cordic_iterate_en : STD_LOGIC := '0';
signal clkdiv2: STD_LOGIC := '0';

--Latch Outputs
signal latch_out_x  : STD_LOGIC_VECTOR(15 downto 0);      
signal latch_out_y  : STD_LOGIC_VECTOR(15 downto 0);   
signal latch_out_z  : STD_LOGIC_VECTOR(15 downto 0);    

BEGIN  

--------------------------------Component Port Maps----------------------------------------
  --Debouncers for user buttons
  User_DB_C:      debouncer PORT map (clk_100Mhz => clk, reset => reset_btn_deb, PB_IN => btnC, PB_OUT => user_btn_deb_c);
  User_DB_R:      debouncer PORT map (clk_100Mhz => clk, reset => reset_btn_deb, PB_IN => btnR, PB_OUT => user_btn_deb_r);

  --Debouncer for reset button
  Reset_DB:     debouncer PORT map (clk_100Mhz => clk, reset => reset_btn_deb, PB_IN => btnU, PB_OUT => reset_btn_deb);
 
  -- Edge detechtor for user buttons
  ED_C:      EdgeDetector PORT map(clk => clk, d => user_btn_deb_c, edge => btn_edge_c);
  ED_R:      EdgeDetector PORT map(clk => clk, d => user_btn_deb_r, edge => btn_edge_r);

   --Hex driver to display "disp_data"
  HEX:     hex_driver PORT map (clk => clk, reset => reset_btn_deb, done => done, d_in => disp_data, anodes => an, cathodes => seg);   
  
  
  -- Finite state machine for USER data input and output STATES
  USER_FSM:       FSM PORT map(clk => clk, x => user_next_state, reset => reset_btn_deb, y => fsm_state);
  
   -- Finite state machine for CORDIC algorithm
  CORDIC_FSM:     FSM PORT map(clk => clk, x => cordic_iterate_en, reset => reset_btn_deb, y => iteration);

  --Latches for taking initial data from user input 
  X_LATCH:        LATCH_16B PORT map(input_data0 => x_init, input_data1 => ram_out_x, enable => '1', input_sel => input_sel, output_data => latch_out_x);
  Y_LATCH:        LATCH_16B PORT map(input_data0 => y_init, input_data1 => ram_out_y, enable => '1', input_sel => input_sel, output_data => latch_out_y);
  Z_LATCH:        LATCH_16B PORT map(input_data0 => z_init, input_data1 => ram_out_z, enable => '1', input_sel => input_sel, output_data => latch_out_z);   
  
  --RAM for holding x,y,z values
    RAM:          RAM16 PORT map(
                  clk => clk, clear => reset_btn_deb, 
                  write_en_x => WE_x, write_en_y => WE_y, write_en_z => WE_z,
                  d_x => x_out, d_y => y_out, d_z => z_out,  
                  q_x => ram_out_x, q_y => ram_out_y, q_z => ram_out_z);

    --Clock divider for iteration control 
    CLK_DIV:       clk_div_2 PORT map(clk => clk, reset => reset_btn_deb, clkdiv2 => clkdiv2);
    
    --Look up table for special angles 
     LUT:          ROM PORT map(address => iteration, q => LUT_data);
    
    --counter for moving between x,y,z values 
    Data_counter:  COUNTER_4BIT PORT map(clk => clk, reset => btn_edge_r, clear => clear_counter, inc => btn_edge_c, count_out => cout);
    
    --ALU for CORDIC iterations 
    ALU1:  alu PORT map(x_in => latch_out_x, y_in =>latch_out_y, z_in => latch_out_z, 
                        theta => LUT_data, i => iteration,
                        add_sub_x => add_sub_x, add_sub_y => add_sub_y, add_sub_z => add_sub_z,
                        x_out=> x_out, y_out => y_out, z_out => z_out); 
    
    
    ---------------------------------------CORDIC Process---------------------------------------------    
    
    CORDIC: PROCESS (reset_btn_deb, clk, btn_edge_r, sw, btn_edge_c, clkdiv2, fsm_state, iteration, latch_out_x, latch_out_y, latch_out_z, ram_out_x, ram_out_y, ram_out_z, cout) IS
    BEGIN
    
    CASE fsm_state IS 
    
    WHEN x"0" => --User input x variable
        done <= '1';
        led <= x"0001";
        input_sel <= '0';
        disp_data <= sw;
        user_next_state <= btn_edge_r;
        if btn_edge_c = '1' then
            x_init <= sw;
        END IF;
        
    WHEN x"1" => --User input y variable
        done <= '1';
        led <= x"0002";
        input_sel <= '0';      
        disp_data <= sw;
        user_next_state <= btn_edge_r;
        if btn_edge_c = '1' then
            y_init <= sw;
        END IF;        
        
    WHEN x"2" => --User input z variable 
        done <= '1';
        led <= x"0004";
        input_sel <= '0';      
        disp_data <= sw;
        user_next_state <= btn_edge_r;
        IF btn_edge_c = '1' THEN
            z_init <= sw;
        END IF;        
        
    WHEN x"3" => --loop through input data (x,y,z) with btnC
        Input_sel <= '0';
        user_next_state <= btn_edge_r;
        done <= '1';
        CASE cout IS
        WHEN  x"0" =>
            led <= x"0F01";
            disp_data <= latch_out_x;
        WHEN  x"1" =>
            led <= x"0F02";
            disp_data <= latch_out_y;
        WHEN  x"2" =>
            led <= x"0F04";
            disp_data <= latch_out_z; 
        WHEN OTHERS =>
            IF cout >= x"3" THEN
                clear_counter <= '1';
            ELSIF cout < x"3" THEN
                clear_counter <= '0';
            END IF;
        END CASE;
        
    WHEN x"4" => --Run CORDIC algorithm 
   
   --Attach clk to write enable on RAM for iteration control 
    WE_x <= clkdiv2;
    WE_y <= clkdiv2;
    WE_z <= clkdiv2;
    done <= '0';
    user_next_state <= '0';
    cordic_iterate_en <= clkdiv2;
    
    --display Z value while itterating 
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
        done <= '1'; 
        user_next_state <= '1';     
    ELSIF iteration > x"0" THEN
        input_sel <= '1';
        led <= (15 downto iteration'length => '0') & iteration;         
    END IF;        
        
        --Set add/sub variable for CORDIC depending on sign of Z 
        IF SIGNED(latch_out_z) >= 0 THEN 
        add_sub_x <= '1';
        add_sub_y <= '0'; 
        add_sub_z <= '1';
        ELSE
        add_sub_x <= '0';
        add_sub_y <= '1'; 
        add_sub_z <= '0';
        END IF;      
    
    WHEN x"5" => --View CORDIC results 
    led <= x"0005"; 
        user_next_state <= btn_edge_r;
        CASE cout IS
        WHEN  x"0" =>
            led <= x"FF01";
            disp_data <= ram_out_x;
        WHEN  x"1" =>
            led <= x"FF02";
            disp_data <= ram_out_y;
        WHEN  x"2" =>
            led <= x"FF04";
            disp_data <= ram_out_z; 
        WHEN OTHERS =>
            IF cout >= x"3" THEN
                clear_counter <= '1';
            ELSIF cout < x"3" THEN
                clear_counter <= '0';
            END IF;
        END CASE;
        
    WHEN OTHERS => --Display warning if invalid state
        user_next_state <= '1';
        led <= x"ffff";
        disp_data <= sw;
    END CASE;
    
END PROCESS CORDIC;          
        
    
END structural;