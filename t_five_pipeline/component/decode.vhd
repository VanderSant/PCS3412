-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decode is 
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
end entity;

architecture decode_arch of decode is

    signal instruction, regA, regB, NPC : std_logic_vector(31 downto 0) := (others => '0');
    signal rt, rd : std_logic_vector(4 downto 0) := (others => '0');
    
    component control is
        port (
            -- input
            opcode: std_logic_vector(6 downto 0);

            -- output
            cWbo: out std_logic_vector(1 downto 0);
            cMo: out std_logic_vector(2 downto 0);
            cExo: out std_logic_vector(5 downto 0)

        ) ;
    end component;

    component reg_file is  
        generic(
            NBadd : integer := 5;
            NBdata : integer := 32;
            t_read : time := 5 ns;
            t_write : time := 5 ns
        );
        port(
            clk, reset : in std_logic;
            we : in std_logic;
            adda : in std_logic_vector(NBadd - 1 downto 0);
            addb : in std_logic_vector(NBadd - 1 downto 0);
            addw : in std_logic_vector(NBadd - 1 downto 0);
            data_in : in std_logic_vector(NBdata - 1 downto 0);
            data_outa : out std_logic_vector(NBdata - 1 downto 0);
            data_outb : out std_logic_vector(NBdata - 1 downto 0)
        );
 
      end component;

begin

    instruction <= RI_out(31 downto 0);
    NPC <= RI_out(63 downto 32);

    rd <= instruction(11 downto 7);
    rt <= instruction(19 downto 15);

    UC: control
    port map (
        opcode => instruction(6 downto 0),
        cWbo => cWbo,
        cMo => cMo,
        cExo => cExo
    );

    GPR: reg_file
    generic map(
        NBadd => 5,
        NBdata => 32,
        t_read => 5 ns,
        t_write => 5 ns
        )
    port map(
        clk => clk,
        reset => '0',
        we => reg_write,
        adda => instruction(19 downto 15),
        addb => instruction(24 downto 20),
        addw => enderW,
        data_in => dataW,
        data_outa => regA,
        data_outb => regB
    );
        
    RD_out(4 downto 0) <= rd;
    RD_out(9 downto 5) <= rt;
    RD_OUT(41 downto 10) <= instruction;
    RD_out(73 downto 42) <= regA;
    RD_out(105 downto 74) <= regB;
    RD_out(137 downto 106) <= NPC;
end architecture decode_arch;
