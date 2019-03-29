----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/15/2019 02:57:50 PM
-- Design Name: 
-- Module Name: adder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- DepENDencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adder is
    PORT ( a : IN STD_LOGIC;
           b : IN STD_LOGIC;
           cin : IN STD_LOGIC;
           d : OUT STD_LOGIC;
           cout : OUT STD_LOGIC);
END adder;

ARCHITECTURE Behavioral of adder is

begin
    process(a,b,cin) begin
            d <= (a xor b) xor cin;
            cout <= (a and b) or ((a xor b) and cin);
    END process;
END Behavioral;
