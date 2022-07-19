-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem is 
    port(
        clk, reset: in std_logic;

        --interface EX/MEM
        EX_MEM:     in std_logic_vector(139 downto 0);     

        --interface MEM/WB
        MEM_WB:     out std_logic_vector(70 downto 0);

        -- interface com memória
        rw:         out std_logic;
        address:    out std_logic_vector(31 downto 0);
        data_write: out std_logic_vector(31 downto 0);
        data_read:  in std_logic_vector(31 downto 0);

        -- interface com fetch
        NPCJ:       out std_logic_vector(31 downto 0);
        PCsrc:      out std_logic;

        --interface de Hazard
        MEM_predict: out std_logic_vector(31 downto 0);
        regWmem: out std_logic;
        rd : out std_logic_vector(4 downto 0)
    );
end entity;


architecture mem_arch of mem is

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

    signal m_NPCJ, NPCJrel, NPC, ALU_out, regB, ex_data : std_logic_vector(31 downto 0) := (others => '0'); 

    signal cWbo: std_logic_vector(1 downto 0) := (others => '0');

    signal m_rd: std_logic_vector(4 downto 0) := (others => '0');

    signal zero, 
           negative, 
           should_branch, 
           uncond_branch, 
           cond_branch, 
           jump_type, 
           write_mem,
           and_out: std_logic := '0';
begin

    m_rd              <= EX_MEM(4 downto 0);
    regB            <= EX_MEM(36 downto 5);
    ALU_out         <= EX_MEM(68 downto 37);
    should_branch   <= EX_MEM(69); 
    NPCJrel         <= EX_MEM(101 downto 70);
    NPC             <= EX_MEM(133 downto 102);
    cond_branch     <= EX_MEM(134);
    uncond_branch   <= EX_MEM(135);
    jump_type       <= EX_MEM(136);
    write_mem       <= EX_MEM(137);
    cWbo            <= EX_MEM(139 downto 138);

    MUX3: mux2x1
    generic map(
        NB => 32,
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        Sel => jump_type,
        I0 => NPCJrel,
        I1 => ALU_out,
        O => m_NPCJ
    );

MUX4: mux2x1
    generic map(
        NB => 32,
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        Sel => uncond_branch,
        I0 => ALU_out,
        I1 => NPC,
        O => ex_data
    );
    
MUX9: mux2x1
    generic map(
        NB => 32,
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        Sel => cWbo(1),
        I0 => ex_data,
        I1 => data_read,
        O => MEM_predict
    );


    and_out <= should_branch and cond_branch after 0.25 ns;

    rw <= write_mem;
    address <= ALU_out;
    data_write <= regB;

    PCsrc <= and_out or uncond_branch after 0.25 ns;
    NPCJ <= m_NPCJ;

    MEM_WB(4 downto 0)      <= m_rd;
    MEM_WB(36 downto 5)     <= data_read;
    MEM_WB(68 downto 37)    <= ex_data;
    MEM_WB(70 downto 69)    <= cWbo;

    regWmem <= cWbo(0);
    
    rd <= m_rd;
end mem_arch ; -- mem_arch
