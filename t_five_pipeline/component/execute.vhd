-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity execute is 
    port(
        ID_EX : in std_logic_vector(138 downto 0);
        EX_MEM : out std_logic_vector(139 downto 0)
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
    end component mux2x1_1b;

    -- logic signals input
    signal inst, regA, regB, NPC : std_logic_vector(31 downto 0);
    signal cEXo : std_logic_vector(4 downto 0);
    signal cMo : std_logic_vector(3 downto 0);
    signal cWBo : std_logic_vector(1 downto 0);

    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);
    signal rd : std_logic_vector(4 downto 0);

    signal ula_src : std_logic;
    signal ula_op, se_op : std_logic_vector(1 downto 0);

    -- logic signals output
    signal NPCJrel : std_logic_vector(31 downto 0); 

    -- aux signals
    signal sig_ext_out, mux1_out : std_logic_vector(31 downto 0);
    signal alu_control_out : std_logic_vector(3 downto 0);

    signal Nflag, Zflag, xor_out, should_branch : std_logic;
    signal ULAOut : std_logic_vector(31 downto 0); 

    begin
        -- ID_EX divison
        inst <= ID_EX(31 downto 0);
        regA <= ID_EX(63 downto 32);
        regB <= ID_EX(95 downto 64);
        NPC <= ID_EX(127 downto 96);
        cEXo <= ID_EX(132 downto 128);
        cMo <= ID_EX(136 downto 133);
        cWBo <= ID_EX(138 downto 137);

        -- Instruction divison
        funct3 <= inst(14 downto 12);
        funct7 <= inst(31 downto 25);
        rd <= inst(11 downto 7);

        -- xEXo divison
        ula_src <= cEXo(0);
        ula_op <= cEXo(2 downto 1);
        se_op <= cEXo(4 downto 3);

        SIEX: sign_ext
        generic map(
            t_sel => 0.5 ns,
            t_data => 0.25 ns
        )
        port map(
            inst => inst,
            se_op => se_op,
            result => sig_ext_out
        );
            
        MUX1: mux2x1
        generic map(
            NB => 32,
            t_sel => 0.5 ns,
            t_data => 0.25 ns
        )
        port map(
            Sel => ula_src,
            I0 => regB,
            I1 => sig_ext_out,
            O => mux1_out
        );

        ALU1_CONTROL: alu_control
        generic map(
            t_sel => 0.5 ns,
            t_data => 0.25 ns
        )
        port map(
            alu_op => ula_op,
            funct3 => funct3,
            funct7 => funct7,
            alu_ctrl => alu_control_out
        );

        NPCJrel <= std_logic_vector(signed(sig_ext_out) + signed(NPC)) after 1 ns;

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
            alu_ctrl => alu_control_out,
            N => Nflag,
            Z => Zflag,
            result => ULAOut
        );

        xor_out <= Zflag xor funct3(0) after 0.25 ns;
        
        MUX2 : mux2x1_1b
        generic map(
            t_sel => 0.5 ns,
            t_data => 0.25 ns
         )
        port map(
            Sel => funct3(2),
            I0 => xor_out,
            I1 => Nflag,
            O => should_branch
        );

        EX_MEM(4 downto 0) <= rd;
        EX_MEM(36 downto 5) <= regB;
        EX_MEM(68 downto 37) <= ULAOut;
        EX_MEM(69) <= should_branch;
        EX_MEM(101 downto 70) <= NPCJrel;
        EX_MEM(133 downto 102) <= NPC;
        EX_MEM(137 downto 134) <= cMo;
        EX_MEM(139 downto 138) <= cWBo;

end architecture execute_arch ; 
