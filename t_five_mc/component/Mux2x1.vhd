-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : componentes
-- Author      : Wilson Ruggiero
-- Company     : LARC-EPUSP
--
-------------------------------------------------------------------------------
--
-- File        : C:\My_Designs\Componentes\componentes\compile\Mux2x1.vhd
-- Generated   : Thu Feb  1 16:31:20 2018
-- From        : C:\My_Designs\Componentes\componentes\src\Mux2x1.bde
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
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;

entity Mux2x1 is
  generic(
     NB : integer := 32;
     Tsel : time := 0.5 ns;
     Tdata : time := 0.25 ns
  );
  port(
     Sel : in std_logic;
     I0 : in std_logic_vector(NB - 1 downto 0);
     I1 : in std_logic_vector(NB - 1 downto 0);
     O : out std_logic_vector(NB - 1 downto 0)
  );
end Mux2x1;

architecture Mux2x1 of Mux2x1 is

begin

---- Processes ----

Mux2x1 :
process (I0, I1, Sel)
-- Section above this comment may be overwritten according to
-- "Update sensitivity list automatically" option status
-- declarations
begin
-- statements
	Case Sel is
		when '0' => O <= I0 after Tsel;
		when '1' => O <= I1 after Tsel;
		when others => O <= (others => 'X') after Tsel;
	end case;
end process Mux2x1;

end Mux2x1;
