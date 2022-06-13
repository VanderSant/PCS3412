-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_control is
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
end alu_control;

architecture alu_control_arch of alu_control is

---- Architecture declarations -----
constant c_add_ctrl : std_logic_vector(3 downto 0) := "0000";
constant c_sub_ctrl : std_logic_vector(3 downto 0) := "1000";
constant c_slt_ctrl : std_logic_vector(3 downto 0) := "0010";
constant c_sll_ctrl : std_logic_vector(3 downto 0) := "0001";
constant c_srl_ctrl : std_logic_vector(3 downto 0) := "0101";
constant c_sra_ctrl : std_logic_vector(3 downto 0) := "1101";

signal m_r_ctrl : std_logic_vector(3 downto 0);
signal m_i_ctrl : std_logic_vector(3 downto 0);

begin

---- User Signal Assignments ----

m_r_ctrl <= funct7(5) & funct3;
m_i_ctrl <= funct7(5) & funct3 when funct3 = "101" else
            "0" & funct3;

-- Resultado da Operação
alu_ctrl <= m_r_ctrl    after t_sel when alu_op = "00" else
            m_i_ctrl    after t_sel when alu_op = "01" else
            c_add_ctrl  after t_sel when alu_op = "10" else
            c_sub_ctrl  after t_sel when alu_op = "11";

end alu_control_arch;
