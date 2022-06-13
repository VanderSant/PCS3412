LIBRARY ieee;
USE ieee.std_logic_1164.all;

use std.textio.all;
use work.txt_util.all;

entity alu_tb is
end alu_tb;

 architecture behav of alu_tb is
    --  Declaration of the component that will be instantiated.
    component alu
        generic(
            NB 	: integer := 32;
            t_sum 	: time := 1 ns;
            t_sub 	: time := 1.25 ns;
            t_shift 	: time := 1 ns
        );
        port(
            A 		: in 	std_logic_vector(NB - 1 downto 0);
            B 		: in 	std_logic_vector(NB - 1 downto 0);
            alu_ctrl	: in 	std_logic_vector(3 downto 0);
            N 	: out 	std_logic;
            Z 	: out 	std_logic;
            result 	: out 	std_logic_vector(NB - 1 downto 0)
        );
    end component;
    --  Specifies which entity is bound with the component.
    for alu_0: alu use entity work.alu;
    signal Value1,Value2,ValueOut: STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    signal Operation: STD_LOGIC_vector(3 downto 0) := (others => '0');
    signal Negative,Zero: STD_LOGIC := '0';
 begin
    --  Component instantiation.
    alu_0: alu port map (A => Value1,
                         B => Value2,
                         alu_ctrl => Operation,
                         result => ValueOut,
                         N => Negative,
                         Z => Zero);
    --  This process does the real job.
    
    process
       type pattern_type is record
         Value1,Value2: STD_LOGIC_VECTOR(31 DOWNTO 0);
         Operation: STD_LOGIC_vector(3 downto 0);
         ValueOut: STD_LOGIC_VECTOR(31 DOWNTO 0);
         Negative,Zero: STD_LOGIC;
       end record;
       --  The patterns to apply.
       type pattern_array is array (natural range <>) of pattern_type;
        constant patterns : pattern_array :=
        -- Value 1      Value 2     Op      ValueOut    N    Z
        -- Add
       ((x"00000000", x"00000000", "0000", x"00000000", '0', '1'),
        (x"00000001", x"00000001", "0000", x"00000002", '0', '0'),
        (x"FFFFFFFE", x"00000001", "0000", x"FFFFFFFF", '1', '0'),
        (x"FFFFFFFF", x"00000001", "0000", x"00000000", '0', '1'),
        -- Subtract
        (x"00000010", x"00000010", "1000", x"00000000", '0', '1'),
        (x"00000200", x"00000100", "1000", x"00000100", '0', '0'),
        (x"00000400", x"00000100", "1000", x"00000300", '0', '0'),
        -- Set Less Than
        (x"00000000", x"00000001", "0010", x"00000001", '0', '0'),
        (x"00000020", x"00000001", "0010", x"00000000", '0', '1'),
        (x"00000040", x"00000040", "0010", x"00000000", '0', '1'),
        -- Left Shift
        (x"00000001", x"00000004", "0001", x"00000010", '0', '0'),
        (x"00000001", x"00000001", "0001", x"00000002", '0', '0'),
        -- Right Shift
        (x"80000000", x"00000004", "0101", x"08000000", '0', '0'),
        (x"80000000", x"00000001", "0101", x"40000000", '0', '0'),
        -- Right Shift Arithmetic
        (x"04000000", x"00000004", "1101", x"00400000", '0', '0'),
        (x"80400000", x"00000001", "1101", x"C0200000", '1', '0'),

        (x"00000000", x"00000000", "0000", x"00000000", '0', '1'));
    begin
       --  Check each pattern.
       for x in patterns'range loop
      --  Set the inputs.
      Value1 <= patterns(x).Value1;
      Value2 <= patterns(x).Value2;
      Operation <= patterns(x).Operation;
      --  Wait for the results.
      wait for 10.0 ns;
      --  Check the outputs.
      assert ValueOut = patterns(x).ValueOut
         report "Output Error" & LF &
          "bad: "&str(ValueOut) & LF &
          "exp: "&str(patterns(x).ValueOut) & LF severity error;
      assert Zero = patterns(x).Zero
         report "Zero Error" & LF &
          "bad: "&str(Zero) & LF &
          "exp: "&str(patterns(x).Zero) & LF severity error;
      assert Negative = patterns(x).Negative
         report "Negative Error" & LF &
          "bad: "&str(Negative) & LF &
          "exp: "&str(patterns(x).Negative) & LF severity error;
       end loop;
       assert false report "end of test" severity note;
       --  Wait forever; this will finish the simulation.
       wait;
    end process;
 end behav;
