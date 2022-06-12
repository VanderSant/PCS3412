-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : componentes
-- Author      : Wilson Ruggiero
-- Company     : LARC-EPUSP
--
-------------------------------------------------------------------------------
--
-- File        : C:\My_Designs\Componentes\componentes\compile\Mux4x1.vhd
-- Generated   : Thu Feb  1 16:31:20 2018
-- From        : C:\My_Designs\Componentes\componentes\src\Mux4x1.bde
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


entity Mux4x1 is
  generic(
       NB : integer := 8;
       Tsel : time := 3 ns;
       Tdata : time := 2 ns
  );
  port(
       I0 : in std_logic_vector(NB - 1 downto 0);
       I1 : in std_logic_vector(NB - 1 downto 0);
       I2 : in std_logic_vector(NB - 1 downto 0);
       I3 : in std_logic_vector(NB - 1 downto 0);
       Sel : in std_logic_vector(1 downto 0);
       O : out std_logic_vector(NB - 1 downto 0)
  );
end Mux4x1;

architecture Mux4x1 of Mux4x1 is

begin

---- Processes ----

Mux4x1 :
process (I0, I1, I2, I3, Sel)
-- Section above this comment may be overwritten according to
-- "Update sensitivity list automatically" option status
begin
	case Sel is
		when "00" 	=> O <= I0 				after Tsel;
		when "01" 	=> O <= I1 				after Tsel;
		when "10"	=> O <= I2				after Tsel;
		when "11"	=> O <= I3				after Tsel;
		when others => O <= (others => 'X') after Tsel;
	end case;
end process;


end Mux4x1;
