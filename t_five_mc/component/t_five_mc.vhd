library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity t_five_mc is
    port (
        clock, reset: in std_logic
    );
end entity t_five_mc;

architecture fd_uc of t_five_mc is
    component fd_mc is
        port (
            clk, reset  : in    std_logic;
    
            -- Sinais de controle
            pc_en       : in    std_logic;
            ri_en       : in    std_logic;
            reg_write   : in    std_logic;
            alu_op     	: in 	std_logic_vector(1 downto 0);
            se_op     	: in 	std_logic_vector(1 downto 0);
            m1_sel      : in    std_logic;
            m2_sel      : in    std_logic_vector(1 downto 0);
            m3_sel      : in    std_logic_vector(1 downto 0);
    
            -- Sinais de dado
            opcode      : out   std_logic_vector(6 downto 0);
            branch      : out   std_logic;
    
            -- Entradas de dados
            imem_out   : in    std_logic_vector(31 downto 0);
            dmem_out   : in    std_logic_vector(31 downto 0);
    
            -- Saídas de dados
            imem_add   : out   std_logic_vector(31 downto 0);
            dmem_add   : out   std_logic_vector(31 downto 0);
            dmem_in    : out   std_logic_vector(31 downto 0)
        );
    end component fd_mc;

    component uc_mc is
        port (
            clk, reset: in std_logic;
    
            -- Sinais de dado
            opcode:     in std_logic_vector(6 downto 0); 
            branch:     in std_logic;
    
            -- Sinais de controle
            pc_en:      out std_logic;
            ri_en:      out std_logic;
            reg_write:  out std_logic;
            alu_op:     out std_logic_vector(1 downto 0);
            se_op:      out std_logic_vector(1 downto 0);
            m1_sel:     out std_logic;
            m2_sel:     out std_logic_vector(1 downto 0); 
            m3_sel:     out std_logic_vector(1 downto 0);
            
            rw:         out std_logic
    
        );
    end component uc_mc;

    component ram is
        generic(
             BE : integer := 12;
             BP : integer := 32;
             file_name : string := "t_five_mc/data/mram.txt";
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
    
    signal s_branch, s_pc_en, s_ri_en, s_reg_write, s_m1_sel, s_rw: std_logic;
    signal s_alu_op, s_se_op, s_m2_sel, s_m3_sel: std_logic_vector(1 downto 0);
    signal s_opcode: std_logic_vector(6 downto 0); 
    signal s_imem_out, s_dmem_out, s_imem_add, s_dmem_add, s_dmem_in: std_logic_vector(31 downto 0);

begin

    FD : fd_mc port map(
        clock,
        reset,

        s_pc_en,
        s_ri_en,
        s_reg_write,
        s_alu_op,
        s_se_op,
        s_m1_sel,
        s_m2_sel,
        s_m3_sel,

        s_opcode,
        s_branch,

        s_imem_out,
        s_dmem_out,

        s_imem_add,
        s_dmem_add,
        s_dmem_in
    );

    UC : entity work.uc_mc(state_qualifier) port map(
        clock,
        reset,

        s_opcode,
        s_branch,
        
        s_pc_en,
        s_ri_en,
        s_reg_write,
        s_alu_op,
        s_se_op,
        s_m1_sel,
        s_m2_sel,
        s_m3_sel,

        s_rw
    );
    
    RAM_DMEM: ram port map( 
        clock,
        reset,
        s_rw,
        s_dmem_add(13 downto 2),
        s_dmem_in,
        s_dmem_out
    );    

    RAM_IMEM: ram port map( 
        clock,
        reset,
        '0',
        s_imem_add(13 downto 2),
        (others => '0'),
        s_imem_out
    ); 

end architecture fd_uc;