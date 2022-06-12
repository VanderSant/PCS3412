-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : Biblioteca_de_Componentes
-- Author      : Wilson Ruggiero
-- Company     : LARC-EPUSP
--
-------------------------------------------------------------------------------
--
-- File        : C:\My_Designs\Biblioteca_de_ComponentesV4.5\compile\buffertristate.vhd
-- Generated   : Thu Feb  1 16:01:23 2018
-- From        : C:\My_Designs\Biblioteca_de_ComponentesV4.5\src\buffertristate.bde
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

entity bufferTristate is
  generic(
       NB : integer := 32;
       Tenable : time := 0.5 ns;
       Tdisable : time := 0.25 ns
  );
  port(
       Oe : in std_logic;
       I : in std_logic_vector(NumeroBits - 1 downto 0);
       O : out std_logic_vector(NumeroBits - 1 downto 0)
  );
end bufferTristate;

architecture bufferTristate of bufferTristate is

begin

---- User Signal Assignments ----
O <= I after Tenable when Oe = '1' else		-- Porta aberta
	(others => 'Z') after Tdisable;		-- Porta em alta impedância

end bufferTristate;
