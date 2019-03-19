----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Marc Bonwick
-- 
-- Create Date: 02/20/2019 02:31:29 PM
-- Design Name: 
-- Module Name: cordicadder16 - Behavioral
-- Project Name: CORDIC
-- Description: A syncronous add with a single bit shift on the B register, 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_deafultlib;
use xil_deafultlib.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity cordicadder16 is
    port (
        a: IN std_logic_vector (15 DOWNTO 0);
        b: IN std_logic_vector (15 DOWNTO 0);
        clk: IN std_logic;
        sum: OUT std_logic_vector(15 DOWNTO 0);
        cout: OUT std_logic
    );
end cordicadder16;
ARCHITECTURE gen OF cordicadder16 IS
    COMPONENT adder 
        PORT(
            a : in STD_LOGIC;
            b : in STD_LOGIC;
            cin : in STD_LOGIC;
            clk: in STD_LOGIC;
            d : out STD_LOGIC;
            cout : out STD_LOGIC
            );
     END COMPONENT;
SIGNAL carry_sig: std_logic_vector(15 DOWNTO 0);
BEGIN
Adders:
    for i in 0 to 15 generate
    ADD0:    
        if i = 0 generate
        Add1:
            adder port map (
                a => a(i), 
                b => b(i),
                cin => '0',
                clk => clk,
                d => sum(i),
                cout => carry_sig(i)            
            );
        end generate;
    ADDN:
        if i < 15 and i /= 0 generate
            Add1:
            adder port map (
                a => a(i), 
                b => b(i),
                cin => carry_sig(i-1),
                clk => clk,
                d => sum(i),
                cout => carry_sig(i)  
            );          
        end generate;
    ADD15:
        if i = 15 generate
            Add1:
            adder port map (
                a => a(i), 
                b => b(i),
                cin => carry_sig(i-1),
                clk => clk,
                d => sum(i),
                cout => carry_sig(i)  
            );          
        end generate;
    end generate;
Carry_Out:
    cout <= carry_sig(15);
END architecture;