-------------------------------------------------------------------------------
--
-- Title       : Registrador com processo - Projeto Raiz Quadrada
-- Design      : Biblioteca_de_Componentes
-- Author      : Wilson Ruggiero
-- Company     : LARC-EPUSP
--
-------------------------------------------------------------------------------
--
-- File        : C:\My_Designs\Biblioteca_de_ComponentesV4.5\compile\reg.vhd
-- Generated   : Thu Feb  1 16:01:24 2018
-- From        : C:\My_Designs\Biblioteca_de_ComponentesV4.5\src\reg.bde
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


entity reg is
  generic(
       NB : integer := 32;
       t_prop : time := 1 ns;
       t_hold : time := 0.25 ns;
       t_setup : time := 0.25 ns
  );
  port(
       clk : in std_logic;
       CE : in std_logic;
       R : in std_logic;
       S : in std_logic;
       D : in std_logic_vector(NB - 1 downto 0);
       Q : out std_logic_vector(NB - 1 downto 0)
  );
end reg;

architecture reg_arch of reg is

---- Signal declarations used on the diagram ----

signal qi : std_logic_vector(NB - 1 downto 0) := (others => '0');

begin

---- Processes ----

regsiter_p :
process (clk, S, R, CE)
-- Section above this comment may be overwritten according to
-- "Update sensitivity list automatically" option status
begin
	if R='1' then	-- 	Reset assíncrono
		qi(NB -1 downto 0) <= (others => '0');-- Inicializaçãoo com zero
	elsif S = '1' then -- Set assíncrono
		qi(NB - 1 downto 0) <= (others => '1'); -- Inicializaçãoo com um
	elsif (clk'event and clk='1') then  -- Clock na borda de subida
		if D'last_event < t_setup then 
			report "Violação de Set-up time no registrador, valor da sada indefinido = U.";
			qi <= (others => 'U');
		else
               if CE = '1' then
			     qi <= D;
               else
                    null;
               end if;
		end if;
	end if;
end process;

---- User Signal Assignments ----
Q <= qi after t_prop;

end reg_arch;
