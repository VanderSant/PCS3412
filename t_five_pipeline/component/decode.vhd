-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decode is 
    port(
        clk, reset: in std_logic;

        -- Interface IF/ID
        IF_ID: in std_logic_vector(63 downto 0);

        -- Interface ID/EX
        ID_EX: out std_logic_vector(138 downto 0);     

        -- Entradas
        reg_write: in std_logic;
        rd: in std_logic_vector(4 downto 0);
        data_write: in std_logic_vector(31 downto 0)

    );
end entity;

architecture decode_arch of decode is
    -- Dados do IF/ID
    signal instruction, NPC : std_logic_vector(31 downto 0) := (others => '0');

    -- Dados para ID/EX
    signal regA, regB : std_logic_vector(31 downto 0) := (others => '0');
    signal cExo : std_logic_vector(4 downto 0);
    signal cMo : std_logic_vector(3 downto 0);
    signal cWbo : std_logic_vector(1 downto 0);

    -- Sinais internos
    signal rs1, rs2 : std_logic_vector(4 downto 0) := (others => '0');
    
    component control is
        port (
            -- input
            opcode: std_logic_vector(6 downto 0);

            -- output
            cWbo: out std_logic_vector(1 downto 0);
            cMo: out std_logic_vector(3 downto 0);
            cExo: out std_logic_vector(4 downto 0)

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
    NPC <= IF_ID(63 downto 32);
    instruction <= IF_ID(31 downto 0);

    rs2 <= instruction(24 downto 20);
    rs1 <= instruction(19 downto 15);

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
        reset => reset,
        we => reg_write,
        adda => rs1,
        addb => rs2,
        addw => rd,
        data_in => data_write,
        data_outa => regA,
        data_outb => regB
    );
        
    ID_EX(138 downto 137) <= cWbo;
    ID_EX(136 downto 133) <= cMo;
    ID_EX(132 downto 128) <= cExo;
    ID_EX(127 downto 96) <= NPC;
    ID_EX(95 downto 64) <= regA;
    ID_EX(63 downto 32) <= regB;
    ID_EX(31 downto 0) <= instruction;
end architecture decode_arch;
