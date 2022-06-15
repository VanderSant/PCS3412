LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.txt_util.all;


entity fetch_tb is
end fetch_tb;

architecture behav of fetch_tb is
    component fetch  
        port(
            clk, reset: in std_logic;

            -- Sinais de controle
            pc_sel     : in std_logic;
            
            -- Interface com memoria de instrucoes
            imem_out   : in    std_logic_vector(31 downto 0);
            imem_add   : out   std_logic_vector(31 downto 0);

            -- Interface IF/ID
            RI_out     : out   std_logic_vector(63 downto 0);

            -- Branches
            NPCJ       : in    std_logic_vector(31 downto 0)
        );
    end component;

    signal clk, reset, finished, pc_sel : std_logic := '0';

    signal imem_out, imem_add, NPCJ : std_logic_vector(31 downto 0);

    signal RI_out : std_logic_vector(63 downto 0);

    constant half_period : time := 100 ns;


begin
    clk <= not clk after half_period when finished /= '1' else '0';
    
    fetch_0: fetch port map(
        clk      => clk,
        reset    => reset,
        pc_sel   => pc_sel,
        imem_out => imem_out,
        imem_add => imem_add,
        RI_out => RI_out,
        NPCJ => NPCJ
    );


    process
        type pattern_type is record
            imem_out: std_logic_vector(31 downto 0);
            imem_add: std_logic_vector(31 downto 0);
            NPCJ: std_logic_vector(31 downto 0);
            pc_sel: std_logic;
        end record;
        --  The patterns to apply.
        type pattern_array is array (natural range <>) of pattern_type;
        constant patterns : pattern_array :=
        -- Instruction                       InstructionAddress (expected)       NPCJ                                 PCSel
       (("00000000000000001111111111111111", "00000000000000000000000000000000","00000000000000000000000000000000",  '0'),
        ("00000000001111111111111111111111", "00000000000000000000000000000100","00000000000000000000000000000000",  '0'),
        ("00000000000000001111111111111111", "00000000000000000000000000001000","00000000000000000000000000011111",  '1'),
        ("00000000000000001111111111111111", "00000000000000000000000000011111","00000000000000000000000000000000",  '0'));


        variable nextInstructionAddress: std_logic_vector(31 downto 0);
    begin
        
        --  Check each pattern.
        for x in patterns'range loop
        --  Set the inputs.
        imem_out <= patterns(x).imem_out;
        pc_sel <= patterns(x).pc_sel;
        NPCJ <= patterns(x).NPCJ;
        --  Wait for the results.
        wait until clk  = '1';

        --  Check the outputs.
        nextInstructionAddress := std_logic_vector(unsigned(imem_add) + to_unsigned(4, 32));

        assert imem_add = patterns(x).imem_add
            report "Instruction Address error" & LF &
            "bad: " & str(imem_add) & LF &
            "exp: " & str(patterns(x).imem_add) & LF severity error;


        assert RI_out = nextInstructionAddress & patterns(x).imem_out
            report "RI_out Error" & LF &
            "bad: " & str(RI_out) & LF &
            "exp: " & str(nextInstructionAddress & patterns(x).imem_out) & LF severity error;

       end loop;
       assert false report "end of test" severity note;
       finished <= '1';
       wait;
    end process;


end behav;
