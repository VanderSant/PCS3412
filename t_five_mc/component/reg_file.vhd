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
       clk, reset : in std_logic;
       we : in std_logic;
       adda : in std_logic_vector(NBadd - 1 downto 0);
       addb : in std_logic_vector(NBadd - 1 downto 0);
       addw : in std_logic_vector(NBadd - 1 downto 0);
       data_in : in std_logic_vector(NBdata - 1 downto 0);
       data_outa : out std_logic_vector(NBdata - 1 downto 0);
       data_outb : out std_logic_vector(NBdata - 1 downto 0)
  );
end reg_file;

architecture reg_file of reg_file is

---- Architecture declarations -----
type reg_file_t is array (0 to 2**NBadd - 1)
        of std_logic_vector (NBdata - 1 downto 0);

signal regs: reg_file_t := (others => (others => '0'));

begin

---- Processes ----

RegisterMemory :
process (clk, reset)

begin
     if (reset = '1') then
          regs <= (others => (others => '0'));
	elsif (clk'event and clk = '1') then
          if (we = '1') then
               if to_integer(unsigned(addw)) /= 0 then
                    regs(to_integer(unsigned(addw))) <= data_in after t_write;
               end if;
          end if;
     end if;
end process;

---- User Signal Assignments ----
data_outa <= regs(to_integer(unsigned (adda))) after t_read;
data_outb <= regs(to_integer(unsigned (addb))) after t_read;

end reg_file;
