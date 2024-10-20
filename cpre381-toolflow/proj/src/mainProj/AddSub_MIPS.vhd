-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux2t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 2:1
-- mux using structural VHDL, generics, and generate statements.
--
--
-- NOTES:
-- 1/6/20 by H3::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity Add_Sub_MIPS1 is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(rst               : in std_logic;
       clk               : in std_logic;
       i_Af              : in std_logic_vector(N-1 downto 0);
       i_Bf              : in std_logic_vector(N-1 downto 0);
       immidiate	 : in std_logic_vector(N-1 downto 0);
       i_Sf              : in std_logic;
       ALUsrc		 : in std_logic;
       s_O               : in std_logic;
       o_Of              : out std_logic_vector(N-1 downto 0);
       o_Cf      	 : out std_logic;
       overflow          : out std_logic);

end Add_Sub_MIPS1;

architecture structural of Add_Sub_MIPS1 is

  component fullAdder_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(rst               : in std_logic;
       clk               : in std_logic;
       i_A1              : in std_logic_vector(N-1 downto 0);
       i_B1              : in std_logic_vector(N-1 downto 0);
       i_C1              : in std_logic;
       s_O               : in std_logic;
       o_S1              : out std_logic_vector(N-1 downto 0);
       o_C1              : out std_logic;
       overflow          : out std_logic);
  end component;

  component onesComp is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_X          : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));
  end component;
  
  component mux2t1_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));
  end component;

signal t0 : std_logic_vector(N-1 downto 0);
signal t1 : std_logic_vector(N-1 downto 0);
signal t2 : std_logic_vector(N-1 downto 0);

begin

  -- Instantiate N mux instances.

  
  --G_NBit_MUX: for i in 0 to N-1 generate

    P0: mux2t1_N port map(
              i_S      => ALUsrc,      
              i_D0     => i_Bf,  
              i_D1     => immidiate,  
              o_O      => t0);

    P1: onesComp port map(
              i_X      => t0,     
              o_O      => t1);  

    P2: mux2t1_N port map(
              i_S      => i_Sf,      
              i_D0     => t0,  
              i_D1     => t1,  
              o_O      => t2);  
   
    P3: fullAdder_N port map(
	      rst      => rst,
	      clk      => clk,
              i_A1     => i_Af,     
              i_B1     => t2, 
              i_C1     => i_Sf,
              o_S1     => o_Of,
              s_O      => s_O,
	      o_C1     => o_Cf,
              overflow => overflow); 
  --end generate G_NBit_MUX;


  
end structural;