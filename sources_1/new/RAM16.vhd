----------------------------------------------------------------------------------
-- Engineer: Riley Cambon
-- Module Name: RAM16 Behavioral 
-- Project Name: CORDIC
-- Description: 3 x 16bit parallel in parallel out RAM 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.CORDIC_package.ALL;

ENTITY RAM16 IS
PORT ( 
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
    
END RAM16;

ARCHITECTURE Behavioral OF RAM16 IS
    
TYPE memory IS ARRAY (0 to 15) OF STD_LOGIC_VECTOR(15 downto 0);

SIGNAL ram: memory;

BEGIN
    RW: PROCESS(clk,clear, write_en_x, write_en_y, write_en_z)
    BEGIN  
       IF (clear = '1') THEN ram <= (others => (others => '0'));
       ELSE          
            IF rising_edge(clk) THEN 
                q_x <= ram(to_integer(UNSIGNED(x_address)));
                q_y <= ram(to_integer(UNSIGNED(y_address)));
                q_z <= ram(to_integer(UNSIGNED(z_address)));
                
                IF write_en_x = '1' THEN
                    ram(to_integer(UNSIGNED(x_address))) <= d_x;
                END IF;
                IF write_en_y = '1' THEN
                    ram(to_integer(UNSIGNED(y_address))) <= d_y;
                END IF;                
                IF write_en_z = '1' THEN
                    ram(to_integer(UNSIGNED(z_address))) <= d_z;
                END IF;                
             END IF;
        END IF;
    END process RW;
END Behavioral;
