-------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- Multiplier.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a behavioral 
-- multiplier operating on integer inputs. 
--
--
-- NOTES: Integer data type is not typically useful when doing hardware
-- design. We use it here for simplicity, but in future labs it will be
-- important to switch to std_logic_vector types and associated math
-- libraries (e.g. signed, unsigned). 


-- 8/19/09 by JAZ::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity extension is
 
  port(input            : in std_logic_Vector(15 downto 0);
       i_S              : in std_logic; -- if 0 then zero extend, if 1 then sign extend
       output              : out std_logic_Vector(31 downto 0));

end extension;

architecture behavior of extension is

signal fillVector : std_logic_vector(31 downto 0);
begin


process(input, i_S)
begin
if (i_S = '0') then
	for i in 31 downto 16 loop
		fillVector(i) <= '0';
	end loop;
	for i in 15 downto 0 loop
		fillVector(i) <= input(i);
	end loop;
else 
	if (input(15) = '0') then
		for i in 31 downto 16 loop
			fillVector(i) <= '0';
		end loop;
		for i in 15 downto 0 loop
			fillVector(i) <= input(i);
		end loop;
	else
		for i in 31 downto 16 loop
			fillVector(i) <= '1';
		end loop;
		for i in 15 downto 0 loop
			fillVector(i) <= input(i);
		end loop;

	end if;
end if;

--wait for 10 ns;
end process;


output <= fillVector;


  
end behavior;