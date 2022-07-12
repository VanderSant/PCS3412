-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fd_mc is
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
end fd_mc;

architecture fd_mc_arch of fd_mc is

---- Architecture declarations -----
component buffer_tri is
    generic(
         NB : integer := 32;
         t_en : time := 0.5 ns;
         t_dis : time := 0.25 ns
    );
    port(
         Oe : in std_logic;
         I : in std_logic_vector(NB - 1 downto 0);
         O : out std_logic_vector(NB - 1 downto 0)
    );
end component;

component mux2x1_1b is
    generic(
        t_sel : time := 0.5 ns;
        t_data : time := 0.25 ns
    );
    port(
        Sel : in std_logic;
        I0 : in std_logic;
        I1 : in std_logic;
        O : out std_logic
    );
end component;

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

component mux4x1 is
    generic(
         NB : integer := 32;
         t_sel : time := 0.5 ns;
         t_data : time := 0.25 ns
    );
    port(
       Sel : in std_logic_vector(1 downto 0);
       I0 : in std_logic_vector(NB - 1 downto 0);
       I1 : in std_logic_vector(NB - 1 downto 0);
       I2 : in std_logic_vector(NB - 1 downto 0);
       I3 : in std_logic_vector(NB - 1 downto 0);
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

component reg_file is
    generic(
         NBadd : integer := 5;
         NBdata : integer := 32;
         t_read : time := 5 ns;
         t_write : time := 5 ns
    );
    port(
         clk,reset : in std_logic;
         we : in std_logic;
         adda : in std_logic_vector(NBadd - 1 downto 0);
         addb : in std_logic_vector(NBadd - 1 downto 0);
         addw : in std_logic_vector(NBadd - 1 downto 0);
         data_in : in std_logic_vector(NBdata - 1 downto 0);
         data_outa : out std_logic_vector(NBdata - 1 downto 0);
         data_outb : out std_logic_vector(NBdata - 1 downto 0)
    );
end component;

component sign_ext is
    generic(
       t_sel    : time := 0.5 ns;
       t_data   : time := 0.25 ns
    );
    port(
        inst        : in 	std_logic_vector(31 downto 0);
        se_op     	: in 	std_logic_vector(1 downto 0);
        result 	    : out 	std_logic_vector(31 downto 0)
    );
end component;

component alu is
    generic(
         NB 	: integer := 32;
         t_sum 	: time := 1 ns;
         t_sub 	: time := 1.25 ns;
         t_shift	: time := 1 ns
    );
    port(
         A  : in 	std_logic_vector(NB - 1 downto 0);
         B 		     : in 	std_logic_vector(NB - 1 downto 0);
         alu_ctrl	: in 	std_logic_vector(3 downto 0);
         N   	     : out 	std_logic;
         Z   	     : out 	std_logic;
         result 	     : out 	std_logic_vector(NB - 1 downto 0)
    );
end component;

component alu_control is
    generic(
       t_sel    : time := 0.5 ns;
       t_data   : time := 0.25 ns
    );
    port(
        alu_op      : in  std_logic_vector(1 downto 0);
        funct3     	: in  std_logic_vector(2 downto 0);
        funct7 	    : in  std_logic_vector(6 downto 0);
        alu_ctrl    : out std_logic_vector(3 downto 0)
    );
end component;

signal m_alu_result,
       m_pc_q, m_ri_q,
       m_imm,
       m_ra, m_rb,
       m_mux1_out, m_mux2_out, m_mux3_out
       : std_logic_vector(31 downto 0) := (others => '0');

signal m_n_flag, m_z_flag, m_branch, m_z_xor_funct3 : std_logic := '0';

signal m_funct7 : std_logic_vector(6 downto 0) := (others => '0');
signal m_funct3 : std_logic_vector(2 downto 0) := (others => '0');
signal m_rs1, m_rs2, m_rd : std_logic_vector(4 downto 0) := (others => '0');
signal m_alu_ctrl : std_logic_vector(3 downto 0) := (others => '0');

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
        CE => pc_en,
        R => reset,
        S => '0',
        D => m_alu_result,
        Q => m_pc_q
    );

RI: reg
    generic map(
        NB => 32,
        t_prop => 1 ns,
        t_hold => 0.25 ns,
        t_setup => 0.25 ns
    )
    port map(
        clk => clk,
        CE => ri_en,
        R => reset,
        S => '0',
        D => imem_out,
        Q => m_ri_q
    );

SEU: sign_ext
    generic map(
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        inst => m_ri_q,
        se_op => se_op,
        result => m_imm
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
        adda => m_rs1,
        addb => m_rs2,
        addw => m_rd,
        data_in => m_mux3_out,
        data_outa => m_ra,
        data_outb => m_rb
    );

MUX1: mux2x1
    generic map(
        NB => 32,
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        Sel => m1_sel,
        I0 => m_ra,
        I1 => m_pc_q,
        O => m_mux1_out
    );

MUX2: mux4x1
    generic map(
        NB => 32,
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        Sel => m2_sel,
        I0 => m_rb,
        I1 => m_imm,
        I2 => x"00000004",
        I3 => x"00000000",
        O => m_mux2_out
    );

MUX3: mux4x1
    generic map(
        NB => 32,
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        Sel => m3_sel,
        I0 => m_alu_result,
        I1 => dmem_out,
        I2 => m_pc_q,
        I3 => x"00000000",
        O => m_mux3_out
    );

MUX4: mux2x1_1b
    generic map(
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        Sel => m_funct3(2),
        I0 => m_z_xor_funct3,
        I1 => m_n_flag,
        O => m_branch
    );

ALU1: alu
    generic map(
        NB => 32,
        t_sum => 1 ns,
        t_sub => 1.25 ns,
        t_shift => 1 ns
    )
    port map(
        A => m_mux1_out,
        B => m_mux2_out,
        alu_ctrl => m_alu_ctrl,
        N => m_n_flag,
        Z => m_z_flag,
        result => m_alu_result
    );

ALU1_CONTROL: alu_control
    generic map(
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        alu_op => alu_op,
        funct3 => m_funct3,
        funct7 => m_funct7,
        alu_ctrl => m_alu_ctrl
    );

---- User Signal Assignments ----
m_rd <= m_ri_q(11 downto 7);
m_funct3 <= m_ri_q(14 downto 12);
m_rs1 <= m_ri_q(19 downto 15);
m_rs2 <= m_ri_q(24 downto 20);
m_funct7 <= m_ri_q(31 downto 25);

m_z_xor_funct3 <= m_z_flag xor m_funct3(0) after 0.25 ns;

---- Sinais de dados ----
opcode <= m_ri_q(6 downto 0);
branch <= m_branch;

---- Saídas de dados ----
imem_add <= m_pc_q;
dmem_add <= m_alu_result;
dmem_in <= m_rb;

end fd_mc_arch;
