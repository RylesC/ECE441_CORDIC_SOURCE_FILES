----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/20/2019 06:41:56 PM
-- Design Name: 
-- Module Name: LATCH_16B - Behavioral
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

entity LATCH_16B is
    Port (
        input_data0  : in STD_LOGIC_VECTOR(15 downto 0);
        input_data1  : in STD_LOGIC_VECTOR(15 downto 0);
        enable      : in STD_LOGIC;
        input_sel   : in STD_LOGIC;
        output_data : out STD_LOGIC_VECTOR(15 downto 0)
         );
    end LATCH_16B;

architecture Behavioral of LATCH_16B is

begin

    PROCESS (input_data0,input_data1, input_sel, enable)
    BEGIN
        IF enable = '1' THEN
            IF input_sel = '0' THEN
            output_data <= input_data0;
            ELSIF input_sel = '1' THEN
            output_data <= input_data1;
            END IF;
        END IF;
    END PROCESS;

end Behavioral;
