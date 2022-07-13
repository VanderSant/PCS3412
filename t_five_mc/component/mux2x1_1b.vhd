-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : componentes
-- Author      : Wilson Ruggiero
-- Company     : LARC-EPUSP
--
-------------------------------------------------------------------------------
--
-- File        : C:\My_Designs\Componentes\componentes\compile\mux2x1_1b.vhd
-- Generated   : Thu Feb  1 16:31:20 2018
-- From        : C:\My_Designs\Componentes\componentes\src\mux2x1_1b.bde
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

entity mux2x1_1b is
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
end mux2x1_1b;

architecture mux2x1_1b_arch of mux2x1_1b is

begin

---- Processes ----

mux2x1_1b_p :
process (I0, I1, Sel)
-- Section above this comment may be overwritten according to
-- "Update sensitivity list automatically" option status
-- declarations
begin
-- statements
	Case Sel is
		when '0' => O <= I0 after t_sel;
		when '1' => O <= I1 after t_sel;
		when others => O <= 'X' after t_sel;
	end case;
end process mux2x1_1b_p;

end mux2x1_1b_arch;
