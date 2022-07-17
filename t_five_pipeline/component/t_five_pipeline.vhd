library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity t_five_pipeline is
    port (
        clock, reset: in std_logic
    );
end entity t_five_pipeline;

architecture structural of t_five_pipeline is
    component rom is
        generic(
            BE : integer := 12;
            BP : integer := 32;
            file_name : string := "mrom.txt";
            Tread : time := 5 ns
        );
        port(
            reset : in std_logic;
            ender : in std_logic_vector(BE - 1 downto 0);
            dado_out : out std_logic_vector(BP - 1 downto 0)
        );
    end component;

    component ram is
        generic(
            BE : integer := 12;
            BP : integer := 32;
            file_name : string := "mram.txt";
            Tz : time := 2 ns;
            Twrite : time := 5 ns;
            Tread : time := 5 ns
        );
        port(
            clk, reset :   in std_logic;
            rw :           in std_logic;
            ender :        in std_logic_vector(BE - 1 downto 0);
            dado_in :      in std_logic_vector(BP - 1 downto 0);
            dado_out :     out std_logic_vector(BP - 1 downto 0)
        );
    end component ram;

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

    component fetch is
        port(
            clk, reset: in std_logic;
    
            -- Sinais de controle
            pc_src     : in std_logic;
            
            -- Branches
            NPCJ       : in    std_logic_vector(31 downto 0);
    
            -- Interface com memoria de instrucoes
            imem_out   : in    std_logic_vector(31 downto 0);
            imem_add   : out   std_logic_vector(31 downto 0);
    
            -- Interface IF/ID
            IF_ID     : out   std_logic_vector(63 downto 0)
    
        );
    end component;
    
    component decode is 
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
    end component;

    component execute is 
        port(
            ID_EX : in std_logic_vector(138 downto 0);
            EX_MEM : out std_logic_vector(139 downto 0)
        );
    end component execute;
    
    component mem is 
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
    end component mem;

    component writeback is 
    port(
        clk, reset: in std_logic;

        -- Interface MEM/WB
        MEM_WB: in std_logic_vector(70 downto 0);  

        -- Saídas
        reg_write: out std_logic;
        rd: out std_logic_vector(4 downto 0);
        data_write: out std_logic_vector(31 downto 0)

    );
    end component;

    -- Sinais internos para memória
    signal m_rw: std_logic;
    signal m_imem_add, m_imem_out, m_dmem_add, m_dmem_out, m_dmem_in: std_logic_vector(31 downto 0);

    -- Sinais para registradores entre os estágios
    signal m_if_id_d, m_if_id_q : std_logic_vector(63 downto 0) := (others => '0');
    signal m_id_ex_d, m_id_ex_q : std_logic_vector(138 downto 0) := (others => '0');
    signal m_ex_mem_d, m_ex_mem_q : std_logic_vector(139 downto 0) := (others => '0');
    signal m_mem_wb_d, m_mem_wb_q : std_logic_vector(70 downto 0) := (others => '0');

    -- Entradas e saídas entre os estágios
    signal m_pc_src : std_logic := '0';
    signal m_NPCJ : std_logic_vector(31 downto 0) := (others => '0');

    signal m_reg_write : std_logic := '0';
    signal m_reg_data_write : std_logic_vector(31 downto 0) := (others => '0');
    signal m_rd : std_logic_vector(4 downto 0) := (others => '0');

begin
IMEM: rom
    generic map(
        BE => 12,
        BP => 32,
        file_name => "t_five_pipeline/data/default_imem.txt",
        Tread => 5 ns
    )    
    port map( 
        reset => reset,
        ender => m_imem_add(13 downto 2),
        dado_out => m_imem_out
    );

DMEM: ram
    generic map(
        BE => 12,
        BP => 32,
        file_name => "t_five_pipeline/data/default_dmem.txt",
        Tz => 2 ns,
        Twrite => 5 ns,
        Tread => 5 ns
    )
    port map( 
        clk => clock,
        reset => reset,
        rw => m_rw,
        ender => m_dmem_add(13 downto 2),
        dado_in => m_dmem_in,
        dado_out => m_dmem_out
    );   

IF_ID: reg
    generic map(
        NB => 64,
        t_prop => 1 ns,
        t_hold => 0.25 ns,
        t_setup => 0.25 ns
    )

    port map(
        clk => clock,
        CE => '1',
        R => reset,
        S => '0',
        D => m_if_id_d,
        Q => m_if_id_q
    );

ID_EX: reg
    generic map(
        NB => 139,
        t_prop => 1 ns,
        t_hold => 0.25 ns,
        t_setup => 0.25 ns
    )

    port map(
        clk => clock,
        CE => '1',
        R => reset,
        S => '0',
        D => m_id_ex_d,
        Q => m_id_ex_q
    );

EX_MEM: reg
    generic map(
        NB => 140,
        t_prop => 1 ns,
        t_hold => 0.25 ns,
        t_setup => 0.25 ns
    )

    port map(
        clk => clock,
        CE => '1',
        R => reset,
        S => '0',
        D => m_ex_mem_d,
        Q => m_ex_mem_q
    );

MEM_WB: reg
    generic map(
        NB => 71,
        t_prop => 1 ns,
        t_hold => 0.25 ns,
        t_setup => 0.25 ns
    )

    port map(
        clk => clock,
        CE => '1',
        R => reset,
        S => '0',
        D => m_mem_wb_d,
        Q => m_mem_wb_q
    );

IF_STAGE: fetch 
    port map(
        clk => clock,
        reset => reset,
        pc_src => m_pc_src,
        NPCJ => m_NPCJ,
        imem_out => m_imem_out,
        imem_add => m_imem_add,
        IF_ID => m_if_id_d
    );

ID_STAGE: decode
    port map(
        clk => clock,
        reset => reset,
        IF_ID => m_if_id_q,
        ID_EX =>  m_id_ex_d,
        reg_write => m_reg_write,
        rd => m_rd,
        data_write => m_reg_data_write
    );

EX_STATE: execute
    port map(
        ID_EX => m_id_ex_q,
        EX_MEM => m_ex_mem_d
    );

MEM_STAGE: mem
    port map(
        clk => clock,
        reset => reset,
        EX_MEM => m_ex_mem_q,     
        MEM_WB => m_mem_wb_d,
        rw => m_rw,
        data_write => m_dmem_in,
        address => m_dmem_add,
        data_read => m_dmem_out,
        NPCJ => m_NPCJ,
        PCsrc => m_pc_src
    );


WB_STAGE: writeback
    port map(
        clk => clock,
        reset => reset,
        MEM_WB => m_mem_wb_q,
        reg_write => m_reg_write,
        rd => m_rd,
        data_write => m_reg_data_write
    );

end architecture structural;