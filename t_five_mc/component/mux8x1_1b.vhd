-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : componentes
-- Author      : Wilson Ruggiero
-- Company     : LARC-EPUSP
--
-------------------------------------------------------------------------------
--
-- File        : C:\My_Designs\Componentes\componentes\compile\mux8x1_1b.vhd
-- Generated   : Thu Feb  1 16:31:20 2018
-- From        : C:\My_Designs\Componentes\componentes\src\mux8x1_1b.bde
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

entity mux8x1_1b is
  generic(
     t_sel : time := 0.5 ns;
     t_data : time := 0.25 ns
  );
  port(
     Sel : in std_logic_vector(2 downto 0);
     I0 : in std_logic;
     I1 : in std_logic;
     I2 : in std_logic;
     I3 : in std_logic;
     I4 : in std_logic;
     I5 : in std_logic;
     I6 : in std_logic;
     I7 : in std_logic;
     O : out std_logic
  );
end mux8x1_1b;

architecture mux8x1_1b_arch of mux8x1_1b is

begin

---- Processes ----

mux8x1_1b_p :
process (I0, I1, Sel)
-- Section above this comment may be overwritten according to
-- "Update sensitivity list automatically" option status
-- declarations
begin
-- statements
	Case Sel is
		when "000" => O <= I0 after t_sel;
		when "001" => O <= I1 after t_sel;
		when "010" => O <= I2 after t_sel;
		when "011" => O <= I3 after t_sel;
		when "100" => O <= I4 after t_sel;
		when "101" => O <= I5 after t_sel;
		when "110" => O <= I6 after t_sel;
		when "111" => O <= I7 after t_sel;
		when others => O <= 'X' after t_sel;
	end case;
end process mux8x1_1b_p;

end mux8x1_1b_arch;
