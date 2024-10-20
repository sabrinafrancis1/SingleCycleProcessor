-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.MIPS_types.all;

entity MIPS_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic := '0';
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  MIPS_Processor;


architecture structure of MIPS_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated


  -- Our Signals:
     -- Control Signals:
signal RegDst : std_logic;
signal Jump : std_logic;
signal Branch : std_logic;
signal jalSig : std_logic;
signal jrSig : std_logic;
signal MemtoReg : std_logic;
signal ALUOp : std_logic_vector(5 downto 0);
signal ALUSrc : std_logic;

    -- Other:
signal extended_imm : std_logic_vector(31 downto 0);
signal ALU_control : std_logic_vector(4 downto 0);
signal shifted2 : std_logic_vector(31 downto 0);
signal A : std_logic_vector(31 downto 0);
signal Bi : std_logic_vector(31 downto 0);
signal tempALUout : std_logic_vector(31 downto 0);

signal s_zero : std_logic;

signal s_branch : std_logic; 
signal branched : std_logic_vector(31 downto 0); --choose between branch or PC
signal branchAdded : std_logic_vector(31 downto 0);
signal jump_Addr : std_logic_vector(31 downto 0);

signal PC_4 : std_logic_vector(31 downto 0);
signal opt2 : std_logic_vector(4 downto 0);

signal Af : std_logic_vector(31 downto 0);
signal Bf : std_logic_vector(31 downto 0);

signal jumpF : std_logic_vector(31 downto 0);

signal finalAddr : std_logic_vector(31 downto 0);




  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;


--Our components:

component Add_Sub_MIPS1 is
  generic(N : integer := 32); 
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
end component;

component extension is
  port(input            : in std_logic_Vector(15 downto 0);
       i_S              : in std_logic; -- if 0 then zero extend, if 1 then sign extend
       output              : out std_logic_Vector(31 downto 0));
end component;


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

component mux2t1_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));
  end component;


component ALU is
  port(rst               : in std_logic;
       clk              : std_logic;
       A       		: in std_logic_Vector(31 downto 0);
       B       		: in std_logic_Vector(31 downto 0);
       shftamt          : in std_logic_Vector(4 downto 0);
       s_F     		: in std_logic_Vector(4 downto 0) := "11111";
       output       : out std_logic_Vector(31 downto 0);
       zero  		: out std_logic;
       overflow         : out std_logic);  
end component;

component ALUcontrol is
  port(s_type       : in std_logic_Vector(5 downto 0);
       opcode       : in std_logic_Vector(5 downto 0);
       s_out        : out std_logic_Vector(4 downto 0));   
end component;

component control is
port( readIn   :   in std_logic_vector(5 downto 0); --bits 31-26 opcode
      jrCode   :   in std_logic_vector(5 downto 0);
      ALUControl   :   out std_logic_vector(5 downto 0); --0010 will perform add of A and B
      ALUSrc   :   out std_logic; --use correcty extended immediate from B
      MemtoReg   :   out std_logic; -- on 0 does not read from memory
      jalSig   :   out std_logic;
      jrSig    : out std_logic;
      s_DMemWr   :   out std_logic; --memwrite from text, on 0 does not write to memory
      s_RegWr   :   out std_logic; --Regwrite from text, on 1 writes back to a register
	Jump	: 	out std_logic;
	Branch	: 	out std_logic;
	s_Halt  :       out std_logic;
      RegDst   :   out std_logic); --uses rt as destination register rather than rd

end component;

component barrel_shifter is

  port(input            : in std_logic_vector(31 downto 0);      -- 32 bit input
       i_shftamt        : in std_logic_vector(4 downto 0);       -- # of bits to shift
       i_dir            : in std_logic;                          -- direction of shift (0 = right, 1 = left)
       i_type           : in std_logic;                          -- type of shift (0 = logical, 1 = arithmetic)
       output           : out std_logic_vector(31 downto 0));    -- shifted output

end component;

component JumpAddress is
  port(inst         : in std_logic_Vector(25 downto 0);
       PC           : in std_logic_Vector(31 downto 0);
       jumpAddress  : out std_logic_Vector(31 downto 0));   

end component;

component andg2 is
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;


component PC is
  port(i_CLK : in std_logic;
       i_RST : in std_logic;
       i_input        : in std_logic_Vector(31 downto 0);
       PC           : out std_logic_Vector(31 downto 0));   
end component;



  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

begin



  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;

   PC_COMP: PC port map(i_CLK => iCLK,
	 i_RST => iRST,
	 i_input => finalAddr,
	 PC => s_NextInstAddr);

  ADD_FOUR: fullAdder_N port map(
	rst => iRST,
	clk => iCLK,
	i_A1 => s_NextInstAddr,
	i_B1 => x"00000004",
	i_C1 => '0',
	s_O => '0',
	o_S1 => PC_4);


  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);

  CNTRL: control port map(
	readIn => s_Inst(31 downto 26),
        jrCode => s_Inst(5 downto 0),
	ALUControl => ALUOp,
	ALUSrc => ALUSrc,
	MemtoReg => MemtoReg,
	jalSig => jalSig,
	jrSig => jrSig,
	s_DMemWr => s_DMemWr,
	s_RegWr => s_RegWr,
	Branch => Branch,
	Jump => Jump,
	RegDst => RegDst,
	s_Halt => s_Halt);
  
  EXTEND_IMM: extension port map(
	input => s_Inst(15 downto 0),
	i_S => '1',
	output => extended_imm);   

  SHIFT_I: barrel_shifter port map(
	input => extended_imm,
	i_shftamt => "00010",
	i_dir => '1',
	i_type => '0',
	output => shifted2);

  ALU_CONT: ALUcontrol port map(
	s_type => s_Inst(5 downto 0),
        opcode => ALUOp,
        s_out => ALU_control);

  MUX_DATA_WRT2: mux2t1_N 
 generic map(N => 5)
port map(
	i_S => jalSig,
	i_D0 => s_Inst(20 downto 16),
	i_D1 => "11111",
	o_O => opt2);

  MUX_RT_RD: mux2t1_N
 generic map(N => 5)
 port map(
	i_S => RegDst,
	i_D0 => opt2,
	i_D1 => s_Inst(15 downto 11),
	o_O => s_RegWrAddr);

  MAIN_REG_FILE: register_file port map(
       rs => s_Inst(25 downto 21),
       rt => s_Inst(20 downto 16),      
       wrt => s_RegWrAddr,
       rd => s_RegWrData, --was addr_data    
       clk => iCLK,
       reset => iRST,
       enable => s_RegWr,
       o_O1 => A,
       o_O2 => s_DMemData); 

  MUX_B_IMM: mux2t1_N 
 generic map(N => 32)
port map(
	i_S => ALUSrc,
	i_D0 => s_DMemData,
	i_D1 => extended_imm,
	o_O => Bi);

  MUX_ALU1: mux2t1_N 
 generic map(N => 32)
port map(
	i_S => jalSig,
	i_D0 => A,
	i_D1 => PC_4,
	o_O => Af);

  MUX_ALU2: mux2t1_N 
 generic map(N => 32)
port map(
	i_S => jalSig,
	i_D0 => Bi,
	i_D1 => x"00000000",
	o_O => Bf);

  MAIN_ALU: ALU port map(
	rst => iRST,
	clk => iCLK,
        A => Af,
        B => Bf,
	shftamt => s_Inst(10 downto 6),
        s_F => ALU_control,
        output => s_DMemAddr,
        zero => s_zero, 
        overflow => s_Ovfl);  

  oALUout <= s_DMemAddr;

  ANDI: andg2 port map(
	i_A => s_zero,
	i_B => Branch,
	o_F => s_branch);

  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  MUX_ADDR_DATA: mux2t1_N 
 generic map(N => 32)
port map(
	i_S => MemtoReg,
	i_D0 => s_DMemAddr,
	i_D1 => s_DMemOut,
	o_O => s_RegWrData);

  ADD_BRANCH: fullAdder_N port map(
	rst => iRST,
	clk => iCLK,
	i_A1 => PC_4,
	i_B1 => shifted2,
	i_C1 => '0',
	s_O => '0',
	o_S1 => branchAdded);

  MUX_BRANCH: mux2t1_N port map(
	i_S => s_branch,
	i_D0 => PC_4,
	i_D1 => branchAdded,
	o_O => branched);

  JUMPADDR: JumpAddress port map(
	inst => s_Inst(25 downto 0),
	PC => PC_4,
	jumpAddress => jump_Addr);

  MUX_JAL: mux2t1_N 
 generic map(N => 32)
port map(
	i_S => jrSig,
	i_D0 => jump_Addr,
	i_D1 => A,
	o_O => jumpF);

  MUX_BRANCH_JUMP: mux2t1_N port map(
	i_S => Jump,
	i_D0 => branched,
	i_D1 => jumpF,
	o_O => finalAddr);



  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 

end structure;

