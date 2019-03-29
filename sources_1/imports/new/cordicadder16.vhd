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
-- any Xilinx leaf cells INthis code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity cordicadder16 is
    PORT (
        a: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        b: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        sum: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        cout: OUT STD_LOGIC
    );
END cordicadder16;
ARCHITECTURE gen OF cordicadder16 IS
    COMPONENT adder 
        PORT(
            a : IN STD_LOGIC;
            b : IN STD_LOGIC;
            cin: IN STD_LOGIC;
            d : OUT STD_LOGIC;
            cout : OUT STD_LOGIC
            );
     END COMPONENT;
SIGNAL carry_sig: STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGin
Adders:
    for i IN 0 to 15 generate
    ADD0:    
        if i = 0 generate
        Add1:
            adder PORT map (
                a => a(i), 
                b => b(i),
                cin => '0',
                d => sum(i),
                cout => carry_sig(i)            
            );
        END generate;
    ADDN:
        if i < 16 and i /= 0 generate
            Add1:
            adder PORT map (
                a => a(i), 
                b => b(i),
                cin => carry_sig(i-1),
                d => sum(i),
                cout => carry_sig(i)  
            );          
        END generate;
    END generate;
Carry_Out:
    cout <= carry_sig(15);
END ARCHITECTURE;