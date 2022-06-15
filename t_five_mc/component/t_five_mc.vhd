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
            
            mem_en:     out std_logic;
            rw:         out std_logic
    
        );
    end component uc_mc;
    
    signal n_clock: std_logic;
    signal s_branch, s_pc_en, s_ri_en, s_reg_write, s_mem_en, s_m1_sel, s_rw: std_logic;
    signal s_alu_op, s_se_op, s_m2_sel, s_m3_sel: std_logic_vector(1 downto 0);
    signal s_opcode: std_logic_vector(6 downto 0); 
    signal imem_out, dmem_out, imem_add, dmem_add, dmem_in: std_logic_vector(31 downto 0);

begin

    FD : fd_mc port map(clock,
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

                        imem_out,
                        dmem_out,

                        imem_add,
                        dmem_add,
                        dmem_in
                        );

    UC : uc_mc port map(n_clock,
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

                        s_mem_en,
                        s_rw
                        );

    n_clock <= not(clock);

end architecture fd_uc;