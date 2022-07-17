-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity writeback is 
    port(
        clk, reset: in std_logic;

        -- Interface MEM/WB
        MEM_WB: in std_logic_vector(70 downto 0);  

        -- Saídas
        reg_write: out std_logic;
        rd: out std_logic_vector(4 downto 0);
        data_write: out std_logic_vector(31 downto 0)

    );
end entity;

architecture writeback_arch of writeback is
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

    signal m_data_write : std_logic_vector(31 downto 0) := (others => '0');

begin

MUX5: mux2x1
    generic map(
        NB => 32,
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        Sel => MEM_WB(70),
        I0 => MEM_WB(68 downto 37),
        I1 => MEM_WB(36 downto 5),
        O => m_data_write
    );

    reg_write <= MEM_WB(69);
    rd <= MEM_WB(4 downto 0);
    data_write <= m_data_write;
    
end architecture writeback_arch;
