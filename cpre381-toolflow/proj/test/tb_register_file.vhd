-------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_dffg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- edge-triggered flip-flop with parallel access and reset.
--
--
-- NOTES:
-- 8/19/16 by JAZ::Design created.
-- 11/25/19 by H3:Changed name to avoid name conflict with Quartus
--          primitives.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MIPS_types.all;

entity tb_register_file is
  generic(gCLK_HPER   : time := 50 ns);
end tb_register_file;

architecture mixed of tb_register_file is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component register_file is
generic(N : integer := 32);
  port(rs           : in std_logic_Vector(4 downto 0);     
       rt           : in std_logic_Vector(4 downto 0);     
       wrt          : in std_logic_Vector(4 downto 0);
       rd	    : in std_logic_Vector(N-1 downto 0);     
       clk          : in std_logic;
       reset        : in std_logic;
       enable       : in std_logic;   
       o_O1         : out std_logic_Vector(N-1 downto 0);
       o_O2         : out std_logic_Vector(N-1 downto 0));   

end component;

  
  signal s_CLK  : std_logic;
  signal s_rs : std_logic_Vector(4 downto 0);
  signal s_rt : std_logic_Vector(4 downto 0);
  signal s_wrt : std_logic_Vector(4 downto 0);
  signal s_rd : std_logic_Vector(31 downto 0);
  signal s_reset : std_logic;
  signal s_enable : std_logic;
signal s_O1 : std_logic_Vector(31 downto 0);
signal s_O2 : std_logic_Vector(31 downto 0);
  

begin

  DUT: register_file 
  port map(rs => s_rs, 
           rt => s_rt,
	   wrt => s_wrt,
	   rd => s_rd,
	   reset => s_reset,
	   enable => s_enable,
	   clk => s_CLK,
	   o_O1 => s_O1,
           o_O2  => s_O2);

  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK: process
  begin
    s_CLK <= '0';
    wait for gCLK_HPER;
    s_CLK <= '1';
    wait for gCLK_HPER;
  end process;
  
  -- Testbench process  
  P_TB: process
  begin
wait for gCLK_HPER/2;
    -- Reset the FF
    --test1:
	s_rs <= "00001";
	s_rt <= "00010";
	s_wrt <= "00001";
	s_rd <= x"12345678";
	s_reset <= '0';
	s_enable <= '1';
    wait for cCLK_PER;

    --test2:
	s_rs <= "00001";
	s_rt <= "00010";
	s_wrt <= "00010";
	s_rd <= x"11111111";
	s_reset <= '0';
	s_enable <= '1';
    wait for cCLK_PER;

    --test3:
	s_rs <= "11111";
	s_rt <= "00010";
	s_wrt <= "11111";
	s_rd <= x"44444444";
	s_reset <= '0';
	s_enable <= '1';
    wait for cCLK_PER;

    --test4:
	s_rs <= "11111";
	s_rt <= "10101";
	s_wrt <= "10101";
	s_rd <= x"33333333";
	s_reset <= '0';
	s_enable <= '1';
    wait for cCLK_PER;

    --test5:
	s_rs <= "11111";
	s_rt <= "10101";
	s_wrt <= "10101";
	s_rd <= x"67867867";
	s_reset <= '1';
	s_enable <= '1';
    wait for cCLK_PER;

    --test6:
	s_rs <= "00001";
	s_rt <= "00010";
	s_wrt <= "00001";
	s_rd <= x"55555555";
	s_reset <= '0';
	s_enable <= '0';
    wait for cCLK_PER;

    --test7:
	s_rs <= "00001";
	s_rt <= "00010";
	s_wrt <= "00001";
	s_rd <= x"55555555";
	s_reset <= '0';
	s_enable <= '1';
    wait for cCLK_PER;
  


    wait for 10 ns;
  end process;
  
end mixed;