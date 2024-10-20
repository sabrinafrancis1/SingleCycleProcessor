-- dffg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an edge-triggered
-- flip-flop with parallel access and reset.
--
--
-- NOTES:
-- 8/19/16 by JAZ::Design created.
-- 11/25/19 by H3:Changed name to avoid name conflict with Quartus
--          primitives.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity register_N is
generic(N : integer := 32);
  port(i_clk        : in std_logic;     -- Clock input
       i_reset      : in std_logic;     -- Reset input
       i_enable     : in std_logic;     -- Write enable input
       i_D          : in std_logic_Vector(N-1 downto 0);     -- Data value input
       o_Q          : out std_logic_Vector(N-1 downto 0));   -- Data value output

end register_N;

architecture structural of register_N is

component dffg is

  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic;     -- Data value input
       o_Q          : out std_logic);   -- Data value output
end component;


begin


C1: for i in 0 to N-1 generate 
   DFFGI: dffg port map(
              	i_CLK      => i_clk,    
              	i_RST     => i_reset, 
              	i_WE     => i_enable, 
              	i_D      => i_D(i),
 	      	o_Q      => o_Q(i)); 
 end generate;
 
  
end structural;