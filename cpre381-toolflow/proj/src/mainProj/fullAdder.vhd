-------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- Adder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a behavioral 
-- adder operating on integer inputs. 
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

entity fullAdder is

  port(i_A1              : in std_logic;
       i_B1              : in std_logic;
       i_C1              : in std_logic;
       o_S1              : out std_logic;
       o_C1              : out std_logic);

end fullAdder;

architecture structure of fullAdder is

--or
  component org2 is

  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
  end component;

--and
  component andg2 is

  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
  end component;

--xor
  component xorg2 is

  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
  end component;


  signal t1	: std_logic;
  signal t2	: std_logic;
  signal t3	: std_logic;
 
  begin

  g_Xor1: xorg2		--A xor B
    port MAP(i_A               => i_A1,
             i_B               => i_B1,
             o_F               => t1);

  g_And1: andg2		--A and B
    port MAP(i_A               => i_A1,
             i_B               => i_B1,
             o_F               => t2);

  g_And2: andg2		--t1 and Cin
    port MAP(i_A               => t1,
             i_B               => i_C1,
             o_F               => t3);

  g_Xor2: xorg2		--t1 xor Cin
    port MAP(i_A               => t1,
             i_B               => i_C1,
             o_F               => o_S1);

  g_Or1: org2		--t2 or t3
    port MAP(i_A               => t2,
             i_B               => t3,
             o_F               => o_C1);
   

  
end structure;