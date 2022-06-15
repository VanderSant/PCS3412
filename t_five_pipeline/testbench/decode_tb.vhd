LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.txt_util.all;

entity decode_tb is
end decode_tb;

architecture behav of decode_tb is
    component decode 
        port(
            clk, reset: in std_logic;

            --interface IF/ID
            RI_out: in std_logic_vector(63 downto 0);

            --interface ID/EX
            RD_out: out std_logic_vector(137 downto 0);     

            --Interface com WB
            enderW: in std_logic_vector(4 downto 0);
            dataW: in std_logic_vector(31 downto 0);

            --sinais de controle
            cWbo: out std_logic_vector(1 downto 0);
            cMo: out std_logic_vector(2 downto 0);
            cExo: out std_logic_vector(5 downto 0);

            reg_write: in std_logic
        );
    end component;

    signal clk, reset, finished: std_logic := '0';

    signal dataW : std_logic_vector(31 downto 0);


    signal cWbo : std_logic_vector(1 downto 0);
    signal cMo :  std_logic_vector(2 downto 0);
    signal cExo : std_logic_vector(5 downto 0);

    signal enderW: std_logic_vector(4 downto 0);
    signal reg_write: std_logic;

    signal RI_out : std_logic_vector(63 downto 0);
    signal RD_out : std_logic_vector(137 downto 0);

    constant half_period : time := 100 ns;


begin
    clk <= not clk after half_period when finished /= '1' else '0';
    
    decode_0: decode port map(
        clk       => clk,
        reset     => reset,
        RI_out    => RI_out,
        RD_out    => RD_out,
        enderW    => enderW,
        dataW     => dataW,
        cWbo      => cWbo,
        cMo       => cMo,
        cExo      => cExo,
        reg_write => reg_write
    );
    
    process
        type pattern_type is record
            RI_out    : std_logic_vector(63 downto 0);
            cWbo      : std_logic_vector(1  downto 0);
            cMo       : std_logic_vector(2  downto 0);
            cExo      : std_logic_vector(5  downto 0);
            enderW    : std_logic_vector(4  downto 0);
            dataW     : std_logic_vector(31 downto 0);
            regA      : std_logic_vector(31 downto 0);
            reg_write : std_logic;
        end record;
        --  The patterns to apply.
        type pattern_array is array (natural range <>) of pattern_type;
        constant patterns : pattern_array :=
        -- RI_out                                         cWbo   cMo    cExo     enderW    dataW       regA reg_write 
        -- add 
       ((x"00000000" & "00000000000000000000000000110011", "10", "000", "101000", "00000", x"00000000", x"00000000", '0'),
        -- imediato  escrevendo 0xFF em r0
        (x"00000000" & "00000000000000000000000000010011", "10", "000", "111000", "00000", x"000000FF", x"00000000", '1'),
        -- Load
        (x"00000000" & "00000000000000000000000000000011", "11", "010", "110000", "00000", x"00000000", x"000000FF", '0'),
        -- Store
        (x"00000000" & "00000000000000000000000000100011", "00", "001", "X10001", "00000", x"00000000", x"000000FF", '0'),
        -- Branch
        (x"00000000" & "00000000000000000000000001100011", "00", "100", "XXXX10", "00000", x"00000000", x"000000FF", '0'));
        

        variable instruction, regA, regB, NPC : std_logic_vector(31 downto 0);
        variable rt, rd : std_logic_vector(4 downto 0);

    begin
        reset <= '1';
        wait until clk = '1';
        reset <= '0';
        --  Check each pattern.
        for x in patterns'range loop
            --  Set the inputs.
            RI_out <= patterns(x).RI_out;
            enderW <= patterns(x).enderW;
            dataW <= patterns(x).dataW;
            reg_write <= patterns(x).reg_write;
            --  Wait for the results.
            wait until clk = '1';
            --  Check the outputs.
            
            instruction := RI_out(31 downto 0);
            NPC := RI_out(63 downto 32);
        
            rd := instruction(11 downto 7);
            rt := instruction(19 downto 15);
            
            -- considerando o mesmo endereço para os dois registradores lido
            assert RD_out = NPC & patterns(x).regA & patterns(x).regA & instruction & rt & rd
                report "Interface Register value error" & LF &
                "bad: " & str(RD_out) & LF &
                "exp: " & str(NPC & patterns(x).regA & patterns(x).regA & instruction & rt & rd) & LF severity error;

            assert cWbo = patterns(x).cWbo
                report "WriteBack control signal value error" & LF &
                    "bad: " & str(cWbo) & LF &
                    "exp: " & str(patterns(x).cWbo) & LF severity error;
            
            assert cMo = patterns(x).cMo
                report "Memory control signal value error" & LF &
                    "bad: " & str(cMo) & LF &
                    "exp: " & str(patterns(x).cMo) & LF severity error;
                
            assert cExo = patterns(x).cExo
                report "Execution control signal value error" & LF &
                    "bad: " & str(cExo) & LF &
                    "exp: " & str(patterns(x).cExo) & LF severity error;

            
       end loop;
       assert false report "end of test" severity note;
       finished <= '1';
       wait;

    end process;


end behav;
