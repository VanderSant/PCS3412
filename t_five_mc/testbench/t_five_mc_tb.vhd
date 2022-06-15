LIBRARY ieee;
USE ieee.std_logic_1164.all;

use std.textio.all;
use work.txt_util.all;

entity t_five_mc_tb is
end t_five_mc_tb;

architecture behav of t_five_mc_tb is

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

--  Specifies which entity is bound with the component.
    for fd_mc_0: fd_mc use entity work.fd_mc;
    for uc_mc_0: uc_mc use entity work.uc_mc;
    for ram_0: ram use entity work.ram;
    for ram_1: ram use entity work.ram;

    signal clk:          std_logic := '0';
    signal rst:          std_logic := '0';

    signal n_clock: std_logic;
    signal s_branch, s_pc_en, s_ri_en, s_reg_write, s_m1_sel, s_rw: std_logic;
    signal s_alu_op, s_se_op, s_m2_sel, s_m3_sel: std_logic_vector(1 downto 0);
    signal s_opcode: std_logic_vector(6 downto 0); 
    signal imem_out, dmem_out, imem_add, dmem_add, dmem_in: std_logic_vector(31 downto 0);

    -- constant PERIOD : time := 20 ns;
    -- signal finished: boolean := false;

begin
    -- clk <= not clk after PERIOD/2 when not finished else '0';
    n_clock <= not(clk);
    fd_mc_0 : fd_mc port map(
        clk,
        rst,

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

    uc_mc_0 : uc_mc port map(
        n_clock,
        rst,

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
    
    ram_0: ram port map( 
        n_clock,
        rst,
        s_rw,
        dmem_add,
        dmem_in,
        dmem_out
    );    

    ram_1: ram port map( 
        n_clock,
        rst,
        '0',
        imem_add,
        (others => '0'),
        imem_out
    ); 

    test1: process

    begin
        -- rst inputs
        rst <= '1';
        wait for 50 ns;

        rst <= '0';
        wait;
    end process;

    clock_gen: process
    begin
        clk <= '0', '1' after 20 ns;
        wait for 40 ns;
    end process clock_gen;

end behav;
