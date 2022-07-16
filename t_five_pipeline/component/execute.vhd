-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity execute is 
    port(
        clk, reset: in std_logic;

        --interface ID/EX
        ID_EXout : in std_logic_vector(137 downto 0);     
        
        --sinais de controle
        cWbi : in std_logic_vector(1 downto 0);
        cMi : in std_logic_vector(2 downto 0);
        cExi : in std_logic_vector(5 downto 0);
        ckEX_M : in std_logic;
        
        --interface EX/MEM
        EX_Mo : out std_logic_vector(101 downto 0);

        cWbo : out std_logic_vector(1 downto 0);
        cMo: out std_logic_vector(2 downto 0);
        zeroo: out std_logic
    );
end entity;


architecture execute_arch of execute is

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

    component alu is 
        generic(
            NB 	: integer := 32;
            t_sum 	: time := 1 ns;
            t_sub 	: time := 1.25 ns;
            t_shift	: time := 1 ns
        );
        port(
            A 		     : in 	std_logic_vector(NB - 1 downto 0);
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
    signal instruction, ext_out, regA, regB, mux1_out, NPCJ, NPC, ULA_out : std_logic_vector(31 downto 0);
    
    signal  ULA_op, se_op : std_logic_vector(1 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal ULA_ctrl : std_logic_vector(3 downto 0);
    signal rd, rt, end_reg: std_logic_vector(4 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);

    signal zero, negative, reg_dst, ULA_src: std_logic;
begin

    rd <= ID_EXout (4 downto 0);
    rt <= ID_EXout (9 downto 5);
    instruction <= ID_EXout (41 downto 10);
    funct7 <= instruction(31 downto 25);
    funct3 <= instruction(14 downto 12);
    regA <= ID_EXout (73 downto 42);
    regB <= ID_EXout (105 downto 74);
    NPC <= ID_EXout (137 downto 106);

    reg_dst <= cExi(5);
    ULA_src <= cExi(4);
    ULA_op  <= cExi(3 downto 2);
    se_op  <= cExi(1 downto 0);

    SEU: sign_ext
    generic map(
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        inst => instruction,
        se_op => se_op,
        result => ext_out
    );

    MUX1: mux2x1
    generic map(
        NB => 32,
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        Sel => ULA_src,
        I0 => ext_out,
        I1 => regB,
        O => mux1_out
    );

    MUX2: mux2x1
    generic map(
        NB => 32,
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        Sel => Reg_Dst,
        I0 => rd,
        I1 => rt,
        O => end_reg
    );

    ALU1: alu
    generic map(
        NB => 32,
        t_sum => 1 ns,
        t_sub => 1.25 ns,
        t_shift => 1 ns
    )
    port map(
        A => regA,
        B => mux1_out,
        alu_ctrl => ULA_ctrl,
        N => negative,
        Z => zero,
        result => ULA_out
    );
    
    ALU1_CONTROL: alu_control
    generic map(
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        alu_op => ULA_op,
        funct3 => funct3,
        funct7 => funct7,
        alu_ctrl => ULA_ctrl
    );
    --std_logic_vector(unsigned(m_pc_q) + to_unsigned(4, 32));
    NPCJ <= std_logic_vector(unsigned(ext_out) + unsigned(NPC));

    cWbo <= cWbi;
    cMo <= cMi;

    EX_Mo (31 downto 0) <= NPCJ;
    EX_Mo (63 downto 32) <= ULA_out;
    EX_Mo (95 downto 64) <= regA;
    EX_Mo (100 downto 96) <= end_reg;
    EX_Mo (101) <= ckEX_M;

    zeroo <= zero;

end execute_arch ; -- execute_arch
