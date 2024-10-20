-- ALUcontrol.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains the ALU control s_typeion.
--
--
-- NOTES:
-- 10/02/2023 by Sabrina Francis::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ALUcontrol is
  port(s_type       : in std_logic_Vector(5 downto 0);
       opcode       : in std_logic_Vector(5 downto 0);
       s_out        : out std_logic_Vector(4 downto 0));   

end ALUcontrol;

architecture structural of ALUcontrol is

signal temp : std_logic_vector(4 downto 0);

begin

process(s_type, opcode)
--process
begin

if (opcode = "000000") then
	if (s_type = "000000") then--sll
		temp <= "00000";
	elsif (s_type = "000010") then--srl
		temp <= "00001";
	elsif (s_type = "000011") then--sra
		temp <= "00010";
	elsif (s_type = "100000") then--add
		temp <= "00011";
	elsif (s_type = "100001") then--addu
		temp <= "00100";
	elsif (s_type = "100100") then--and
		temp <= "00101";
	elsif (s_type = "001000") then--jr
		temp <= "00110";
	elsif (s_type = "100111") then--nor
		temp <= "00111";
	elsif (s_type = "100101") then--or
		temp <= "01000";
	elsif (s_type = "101010") then--slt
		temp <= "01001";
	elsif (s_type = "100010") then--sub
		temp <= "01010";
	elsif (s_type = "100011") then--subu
		temp <= "01011";
	elsif (s_type = "100110") then--xor
		temp <= "01100";
	end if;

elsif (opcode(5 downto 2) = "0001") then
	if (opcode = "000100") then
		temp <= "01101";
	elsif (opcode = "000101") then
		temp <= "01110";
	end if;

elsif (opcode(5 downto 2) = "0010") then
	if (opcode = "001000") then
		temp <= "01111";
	elsif (opcode = "001001") then
		temp <= "10000";
	elsif (opcode = "001010") then
		temp <= "10001";
	end if;

elsif (opcode(5 downto 2) = "0011") then
	if (opcode = "001100") then
		temp <= "10010";
	elsif (opcode = "001101") then
		temp <= "10011";
	elsif (opcode = "001110") then
		temp <= "10100";
	elsif (opcode = "001111") then
		temp <= "10101";
	end if;

elsif (opcode(5 downto 2) = "1000") then
	if (opcode = "100011") then
		temp <= "10110";
	end if;

elsif (opcode(5 downto 2) = "1010") then
	if (opcode = "101011") then
		temp <= "10111";
	end if;
elsif (opcode(5 downto 0) = "000011") then
		temp <= "11000";
else
	temp <= "11111";

end if;

--wait for 10 ns;

end process;  
s_out <= temp;
end structural;