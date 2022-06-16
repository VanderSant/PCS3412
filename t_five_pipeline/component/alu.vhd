-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : Biblioteca_de_Componentes
-- Author      : Wilson Ruggiero
-- Company     : LARC-EPUSP
--
-------------------------------------------------------------------------------
--
-- File        : C:\My_Designs\Biblioteca_de_ComponentesV4.5\compile\alu.vhd
-- Generated   : Thu Feb  1 16:01:18 2018
-- From        : C:\My_Designs\Biblioteca_de_ComponentesV4.5\src\alu.bde
-- By          : Bde2Vhdl ver. 2.6
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------
-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-- use IEEE.std_logic_arith.all;
-- use IEEE.std_logic_signed.all;

entity alu is
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
end alu;

architecture alu_arch of alu is

---- Architecture declarations -----
constant c_add_ctrl : std_logic_vector(3 downto 0) := "0000";
constant c_sub_ctrl : std_logic_vector(3 downto 0) := "1000";
constant c_slt_ctrl : std_logic_vector(3 downto 0) := "0010";
constant c_sll_ctrl : std_logic_vector(3 downto 0) := "0001";
constant c_srl_ctrl : std_logic_vector(3 downto 0) := "0101";
constant c_sra_ctrl : std_logic_vector(3 downto 0) := "1101";

signal m_result : std_logic_vector (NB - 1 downto 0) := (others => '0');
signal m_zero 	: std_logic_vector (NB - 1 downto 0) := (others => '0');
signal m_shamt : integer := 0;

signal m_add_out : std_logic_vector (NB - 1 downto 0) := (others => '0');
signal m_sub_out : std_logic_vector (NB - 1 downto 0) := (others => '0');
signal m_slt_out : std_logic_vector (NB - 1 downto 0) := (others => '0');
signal m_sll_out : std_logic_vector (NB - 1 downto 0) := (others => '0');
signal m_srl_out : std_logic_vector (NB - 1 downto 0) := (others => '0');
signal m_sra_out : std_logic_vector (NB - 1 downto 0) := (others => '0');


begin

---- User Signal Assignments ----
m_shamt <= to_integer(unsigned(B(4 downto 0)));

m_add_out <= std_logic_vector(signed(A) + signed(B));
m_sub_out <= std_logic_vector(signed(A) - signed(B));
m_slt_out(0) <= m_sub_out(NB - 1);
m_sll_out <= std_logic_vector(shift_left(unsigned(A), m_shamt));
m_srl_out <= std_logic_vector(shift_right(unsigned(A), m_shamt));
m_sra_out <= std_logic_vector(shift_right(signed(A), m_shamt));

-- Resultado da Operação
m_result <= 	m_add_out after t_sum    when alu_ctrl = c_add_ctrl else
               m_sub_out after t_sub  	when alu_ctrl = c_sub_ctrl else
               m_slt_out after t_sub    when alu_ctrl = c_slt_ctrl else
               m_sll_out after t_shift  when alu_ctrl = c_sll_ctrl else
               m_srl_out after t_shift 	when alu_ctrl = c_srl_ctrl else
               m_sra_out after t_shift 	when alu_ctrl = c_sra_ctrl;

-- Atualização do result
result <= m_result;
-- Atualização do N 
N     <= m_result(NB - 1);
-- Atualização de Z 
Z     <= '1' when m_result = m_zero else '0';


end alu_arch;
