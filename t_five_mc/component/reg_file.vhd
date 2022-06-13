-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : Biblioteca_de_Componentes
-- Author      : Wilson Ruggiero
-- Company     : LARC-EPUSP
--
-------------------------------------------------------------------------------
--
-- File        : C:\My_Designs\Biblioteca_de_ComponentesV4.5\compile\reg_file.vhd
-- Generated   : Thu Feb  1 16:01:23 2018
-- From        : C:\My_Designs\Biblioteca_de_ComponentesV4.5\src\reg_file.bde
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
use ieee.numeric_std.all;

entity reg_file is
  generic(
       NBadd : integer := 5;
       NBdata : integer := 32;
       t_read : time := 5 ns;
       t_write : time := 5 ns
  );
  port(
       clk : in std_logic;
       we : in std_logic;
       data_in : in std_logic_vector(NBdata - 1 downto 0);
       adda : in std_logic_vector(NBadd - 1 downto 0);
       addb : in std_logic_vector(NBadd - 1 downto 0);
       data_outa : out std_logic_vector(NBdata - 1 downto 0);
       data_outb : out std_logic_vector(NBdata - 1 downto 0)
  );
end reg_file;

architecture reg_file of reg_file is

---- Architecture declarations -----
type ram_type is array (0 to 2**NBadd - 1)
        of std_logic_vector (NBdata - 1 downto 0);
signal ram: ram_type;



---- Signal declarations used on the diagram ----

signal adda_reg : std_logic_vector(NBadd - 1 downto 0);
signal addb_reg : std_logic_vector(NBadd - 1 downto 0);

begin

---- Processes ----

RegisterMemory :
process (clk)
-- Section above this comment may be overwritten according to
-- "Update sensitivity list automatically" option status
-- declarations
begin
	if (clk'event and clk = '1') then
          if (we = '1') then
               ram(to_integer(unsigned(adda))) <= data_in after t_write;
          end if;
          adda_reg <= adda;
          addb_reg <= addb;
     end if;
end process;

---- User Signal Assignments ----
data_outa <= ram(to_integer(unsigned (adda_reg))) after t_read;
data_outb <= ram(to_integer(unsigned (addb_reg))) after t_read;

end reg_file;
