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
        PCsrc:      out std_logic
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

    signal NPCJrel, NPC, ALU_out, regB, ex_data, mem_data : std_logic_vector(31 downto 0); 

    signal cWbo: std_logic_vector(1 downto 0);

    signal rd: std_logic_vector(4 downto 0);

    signal mem_read, mem_write, zero, negative, should_branch, uncond_branch, cond_branch, jump_type, write_mem: std_logic;
begin

    rd              <= EX_MEM(4 downto 0);
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
      
    PCsrc <= (should_branch and cond_branch) or uncond_branch;

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
        O => NPCJ
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

    data_write <= mem_data;
    rw <= write_mem;
    address <= ALU_out;
    data_write <= regB;

    MEM_WB(4 downto 0)      <= rd;
    MEM_WB(36 downto 5)     <= mem_data;
    MEM_WB(68 downto 37)    <= ex_data;
    MEM_WB(70 downto 69)    <= cWbo;

end mem_arch ; -- mem_arch
