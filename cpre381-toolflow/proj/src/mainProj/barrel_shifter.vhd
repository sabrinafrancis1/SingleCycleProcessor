library IEEE;
use IEEE.std_logic_1164.all;
use work.MIPS_types.all;

entity barrel_shifter is

  port(input            : in std_logic_vector(31 downto 0);      -- 32 bit input
       i_shftamt        : in std_logic_vector(4 downto 0);       -- # of bits to shift
       i_dir            : in std_logic;                          -- direction of shift (0 = right, 1 = left)
       i_type           : in std_logic;                          -- type of shift (0 = logical, 1 = arithmetic)
       output           : out std_logic_vector(31 downto 0));    -- shifted output

end barrel_shifter;

architecture mixed of barrel_shifter is

  component Mux2to1 is
    port(i_S          : in std_logic;
         i_D0         : in std_logic;
         i_D1         : in std_logic;
         o_O          : out std_logic);
  end component;
  
  component mux2t1_N is
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(31 downto 0);
         i_D1         : in std_logic_vector(31 downto 0);
         o_O          : out std_logic_vector(31 downto 0));
  end component;

  signal s_shift_in         : std_logic;
  signal s_reversed_input   : std_logic_vector(31 downto 0);
  signal s_reversed_output  : std_logic_vector(31 downto 0);
  signal s_new_input        : std_logic_vector(31 downto 0);      -- stores value after deciding if we need to shift left/right
  signal s_extended_input   : std_logic_vector(63 downto 0);
  signal s_shift1_O         : std_logic_vector(63 downto 0);      -- output of first layer of shifting (shift by 1 bit)
  signal s_shift2_O         : std_logic_vector(63 downto 0);      -- output of second layer of shifting (shift by 2 bits)
  signal s_shift4_O         : std_logic_vector(63 downto 0);      -- output of third layer of shifting (shift by 4 bits)
  signal s_shift8_O         : std_logic_vector(63 downto 0);      -- output of fourth layer of shifting (shift by 8 bits)
  signal s_shift16_O        : std_logic_vector(31 downto 0);      -- output of fifth layer of shifting (shift by 16 bits)

begin

s_shift_in <= input(31) when (i_type = '1' and i_dir = '0') else    -- decides which bit to shift in (zero/sign)
              '0';

reverse : for i in 0 to 31 generate
     s_reversed_input(i) <= input(31-i);
end generate reverse;

leftRightShift : mux2t1_N port map(i_S    => i_dir,
                                   i_D0   => input,
                            	   i_D1   => s_reversed_input,
                            	   o_O    => s_new_input);

extender : for i in 0 to 31 generate
       s_extended_input(i) <= s_new_input(i);
end generate extender;

extender1 : for i in 32 to 63 generate
       s_extended_input(i)    <= s_shift_in;
       s_shift1_O(i)          <= s_shift_in;
       s_shift2_O(i)          <= s_shift_in;
       s_shift4_O(i)          <= s_shift_in;
       s_shift8_O(i)          <= s_shift_in;
end generate extender1;

----------------------------- Loops for shifting input bits -------------------------------------------------------------


layer1Shift : for i in 0 to 31 generate                                -- shifts input by 1
           layer1ShiftMux : Mux2to1 port map(i_S    => i_shftamt(0),
                            		     i_D0   => s_extended_input(i),
                            		     i_D1   => s_extended_input(i+1),
                            		     o_O    => s_shift1_O(i));
end generate layer1shift;

layer2Shift : for i in 0 to 31 generate                                -- shifts input by 2
           layer2ShiftMux : Mux2to1 port map(i_S    => i_shftamt(1),
                            		       i_D0   => s_shift1_O(i),
                            		       i_D1   => s_shift1_O(i+2),
                            		       o_O    => s_shift2_O(i));
end generate layer2Shift;

layer3Shift : for i in 0 to 31 generate                                -- shifts input by 4
           layer3ShiftMux : Mux2to1 port map(i_S    => i_shftamt(2),
                            		       i_D0   => s_shift2_O(i),
                            		       i_D1   => s_shift2_O(i+4),
                           		        o_O    => s_shift4_O(i));
end generate layer3Shift;

layer4Shift : for i in 0 to 31 generate                                -- shifts input by 8
           layer4ShiftMux : Mux2to1 port map(i_S    => i_shftamt(3),
                            		       i_D0   => s_shift4_O(i),
                            		       i_D1   => s_shift4_O(i+8),
                            		       o_O    => s_shift8_O(i));
end generate layer4Shift;

layer5Shift : for i in 0 to 31 generate                                -- shifts input by 16
           layer5ShiftMux : Mux2to1 port map(i_S    => i_shftamt(4),
                            		       i_D0   => s_shift8_O(i),
                            		       i_D1   => s_shift8_O(i+16),
                            		       o_O    => s_shift16_O(i));
end generate layer5Shift;


reverse0 : for i in 0 to 31 generate
     s_reversed_output(i) <= s_shift16_O(31-i);
end generate reverse0;

determineOutput : mux2t1_N port map(i_S   => i_dir,
                            	    i_D0   => s_shift16_O,
                            	    i_D1   => s_reversed_output,
                            	    o_O    => output);

end mixed;