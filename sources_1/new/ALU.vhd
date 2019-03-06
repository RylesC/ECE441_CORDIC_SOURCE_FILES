----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/14/2019 03:28:24 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.NUMERIC_STD;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
port(
	clk	        : in STD_LOGIC; --Clock
    reset       : in STD_LOGIC; --reset
    add_sub	    : in STD_LOGIC; --add/subtract. 0 = add, 1 = subtract;
    
    data_x      : in STD_LOGIC_VECTOR(15 downto 0); -- x data
    data_y      : in STD_LOGIC_VECTOR(15 downto 0); -- y data 
    data_z      : in STD_LOGIC_VECTOR(15 downto 0); -- z data
    
    data_x_out      : out STD_LOGIC_VECTOR(15 downto 0); -- x data output
    data_y_out      : out STD_LOGIC_VECTOR(15 downto 0); -- y data output 
    data_z_out      : out STD_LOGIC_VECTOR(15 downto 0) -- z data output
	); 
end ALU;

architecture Behavioral of ALU is

signal user_btn_deb: STD_LOGIC;
begin
-- 

--CORDIC_SUM: process (data_x,data,y,data,z,add_sub,reset)
--begin
--end process;
end Behavioral;
