-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fetch is
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
end fetch;

architecture fetch_arch of fetch is

    component mux2x1 is
        generic(
            NB : integer := 32;
            t_sel : time := 0.5 ns;
            t_data : time := 0.25 ns
        );
        port(
            Sel : in std_logic;
            I0 : in std_logic_vector(NB - 1 downto 0);
            I1 : in std_logic_vector(NB - 1 downto 0);
            O : out std_logic_vector(NB - 1 downto 0)
        );
    end component;

    component reg is
        generic(
             NB : integer := 32;
             t_prop : time := 1 ns;
             t_hold : time := 0.25 ns;
             t_setup : time := 0.25 ns
        );
        port(
             clk : in std_logic;
             CE : in std_logic;
             R : in std_logic;
             S : in std_logic;
             D : in std_logic_vector(NB - 1 downto 0);
             Q : out std_logic_vector(NB - 1 downto 0)
        );
    end component;

    signal NPC : std_logic_vector(31 downto 0) := (others => '0'); 
    
    signal m_mux1_out, m_pc_q : std_logic_vector(31 downto 0) := (others => '0');
begin

    PC: reg
    generic map(
        NB => 32,
        t_prop => 1 ns,
        t_hold => 0.25 ns,
        t_setup => 0.25 ns
    )

    port map(
        clk => clk,
        CE => '1',
        R => reset,
        S => '0',
        D => m_mux1_out,
        Q => m_pc_q
    );

    MUX1: mux2x1
    generic map(
        NB => 32,
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        Sel => pc_sel,
        I0 => NPCJ,
        I1 => NPC,
        O => m_mux1_out
    );

    NPC <= std_logic_vector(unsigned(m_pc_q) + to_unsigned(4, 32));

    imem_add <= m_pc_q;

    RI_out(63 downto 32) <= NPC;
    RI_out(31 downto 0)  <= imem_out;

end fetch_arch;
