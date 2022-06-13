-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : Biblioteca_de_Componentes
-- Author      : Wilson Ruggiero
-- Company     : LARC-EPUSP
--
-------------------------------------------------------------------------------
--
-- File        : C:\My_Designs\Biblioteca_de_ComponentesV4.5\compile\ALU.vhd
-- Generated   : Thu Feb  1 16:01:18 2018
-- From        : C:\My_Designs\Biblioteca_de_ComponentesV4.5\src\ALU.bde
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

entity ALU is
  generic(
       NB 	: integer := 32;
       Tsum 	: time := 1 ns;
       Tsub 	: time := 1.25 ns;
       Tshift 	: time := 1 ns
  );
  port(
       A 		: in 	std_logic_vector(NB - 1 downto 0);
       B 		: in 	std_logic_vector(NB - 1 downto 0);
       ALUctrl	: in 	std_logic_vector(2 downto 0);
       Nflag 	: out 	std_logic;
       Zflag 	: out 	std_logic;
       result 	: out 	std_logic_vector(NB - 1 downto 0)
  );
end ALU;

architecture ALU of ALU is

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

-- with ALUctrl select
--      m_res <=	(A + B)	               when "000" after Tsum,
--                     (A - B)	               when "010" after Tsub,
-- 				(A - B)	               when "011" after Tsub,
-- 				(A sll B(4 downto 0))	when "100" after Tshift,
-- 				(A srl B(4 downto 0))	when "110" after Tshift,
-- 				(A sra B(4 downto 0))	when "111" after Tshift,
-- 				(others => '0')		when others;
m_add_out <= std_logic_vector(signed(A) + signed(B));
m_sub_out <= std_logic_vector(signed(A) - signed(B));
m_slt_out(0) <= m_sub_out(NB - 1);
m_sll_out <= std_logic_vector(shift_left(unsigned(A), m_shamt));
m_srl_out <= std_logic_vector(shift_right(unsigned(A), m_shamt));
m_sra_out <= std_logic_vector(shift_right(signed(A), m_shamt));

-- Resultado da Operação
m_result <= 	m_add_out after Tsum     when ALUctrl = "000" else
               m_sub_out after Tsub  	when ALUctrl = "010" else
               m_slt_out after Tsub     when ALUctrl = "011" else
               m_sll_out after Tshift  	when ALUctrl = "100" else
               m_srl_out after Tshift 	when ALUctrl = "110" else
               m_sra_out after Tshift 	when ALUctrl = "111";

-- Atualização do result
result <= m_result;
-- Atualização do Nflag
Nflag <= m_result(NB - 1);
-- Atualização de Zflag
Zflag <= '1' when m_result = m_zero else '0';


end ALU;
