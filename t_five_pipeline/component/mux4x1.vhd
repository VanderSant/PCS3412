-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : componentes
-- Author      : Wilson Ruggiero
-- Company     : LARC-EPUSP
--
-------------------------------------------------------------------------------
--
-- File        : C:\My_Designs\Componentes\componentes\compile\mux4x1.vhd
-- Generated   : Thu Feb  1 16:31:20 2018
-- From        : C:\My_Designs\Componentes\componentes\src\mux4x1.bde
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

entity mux4x1 is
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
end mux4x1;

architecture mux4x1_arch of mux4x1 is

begin

---- Processes ----

mux4x1_p :
process (I0, I1, I2, I3, Sel)
-- Section above this comment may be overwritten according to
-- "Update sensitivity list automatically" option status
begin
	case Sel is
		when "00" => O <= I0 after t_sel;
		when "01" => O <= I1 after t_sel;
		when "10"	=> O <= I2 after t_sel;
		when "11"	=> O <= I3 after t_sel;
		when others => O <= (others => 'X') after t_sel;
	end case;
end process mux4x1_p;

end mux4x1_arch;
