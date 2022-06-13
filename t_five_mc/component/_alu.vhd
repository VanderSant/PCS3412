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
       Tsum 	: time := 1 ns;
       Tsub 	: time := 1.25 ns;
       Tshift 	: time := 1 ns
  );
  port(
       A 		     : in 	std_logic_vector(NB - 1 downto 0);
       B 		     : in 	std_logic_vector(NB - 1 downto 0);
       alu_ctrl	: in 	std_logic_vector(2 downto 0);
       Nflag 	     : out 	std_logic;
       Zflag 	     : out 	std_logic;
       result 	     : out 	std_logic_vector(NB - 1 downto 0)
  );
end alu;

architecture alu_arch of alu is

---- Architecture declarations -----
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
m_result <= 	m_add_out after Tsum     when alu_ctrl = "000" else
               m_sub_out after Tsub  	when alu_ctrl = "010" else
               m_slt_out after Tsub     when alu_ctrl = "011" else
               m_sll_out after Tshift  	when alu_ctrl = "100" else
               m_srl_out after Tshift 	when alu_ctrl = "110" else
               m_sra_out after Tshift 	when alu_ctrl = "111";

-- Atualização do result
result <= m_result;
-- Atualização do Nflag
Nflag <= m_result(NB - 1);
-- Atualização de Zflag
Zflag <= '1' when m_result = m_zero else '0';


end alu_arch;
