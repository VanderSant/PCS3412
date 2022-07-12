-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : Biblioteca_de_Componentes
-- Author      : Wilson Ruggiero
-- Company     : LARC-EPUSP
--
-------------------------------------------------------------------------------
--
-- File        : C:\Aldec\Active-HDL-Student-Edition\vlib\Biblioteca_de_ComponentesV4.5\compile\ram.vhd
-- Generated   : Tue Mar  6 12:02:35 2018
-- From        : C:\Aldec\Active-HDL-Student-Edition\vlib\Biblioteca_de_ComponentesV4.5\src\ram.bde
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
-- use IEEE.std_logic_unsigned.all;
use std.textio.all;
-- use ieee.std_logic_arith.all;
use ieee.math_real.all;


entity ram is
  generic(
       BE : integer := 12;
       BP : integer := 32;
       file_name : string := "mram.txt";
       Tz : time := 2 ns;
       Twrite : time := 5 ns;
       Tread : time := 5 ns
  );
  port(
       clk, reset : in std_logic;
       rw : in std_logic;
       ender : in std_logic_vector(BE - 1 downto 0);
       dado_in : in std_logic_vector(BP - 1 downto 0);
       dado_out : out std_logic_vector(BP - 1 downto 0)
  );
end ram;

architecture ram_arch of ram is

---- Architecture declarations -----
type 	tipo_memoria  is array (0 to 2**BE - 1) of std_logic_vector(BP - 1 downto 0);
signal Mram: tipo_memoria := ( others  => (others => '0')) ;

begin

---- Processes ----

Carga_Inicial_e_Ram_Memoria :process (clk, reset, ender, dado_in, rw) 
variable endereco: integer range 0 to (2**BE - 1);
variable inicio: std_logic := '1';

impure function fill_memory return tipo_memoria is
	type HexTable is array (character range <>) of integer;
	-- Caracteres HEX válidos: o, 1, 2 , 3, 4, 5, 6, 6, 7, 8, 9, A, B, C, D, E, F  (somente caracteres maiúsculos)
	constant lookup: HexTable ('0' to 'F') :=
		(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, -1, -1, -1, -1, -1, -1, -1, 10, 11, 12, 13, 14, 15);
	file infile: text open read_mode is file_name; -- Abre o arquivo para leitura
	variable buff: line; 
	variable addr_s: string ((integer(ceil(real(BE)/4.0)) + 1) downto 1); -- Digitos de endereço mais um espaço
	variable data_s: string ((integer(ceil(real(BP)/4.0)) + 1) downto 1); -- ùltimo byte sempre tem um espaço separador
	variable addr_1, pal_cnt: integer;
	variable data: std_logic_vector((BP - 1) downto 0);
	variable up: integer;
	variable upreal: real;
	variable Mem: tipo_memoria := ( others  => (others => '0')) ;
	begin
		while (not endfile(infile)) loop
			readline(infile,buff); -- Lê um linha do infile e coloca no buff
			read(buff, addr_s); -- Leia o conteudo de buff até encontrar um espaço e atribui à addr_s, ou seja, leio o endereço
			read(buff, pal_cnT); -- Leia o número de bytes da próxima linha
			
            addr_1 := 0;
			upreal := real(BE)/4.0;
			up := integer((ceil(upreal)));
			--report "Valor teto = " & real'image(upreal) & " Endereco = " & integer'image(up);
			for i in (up + 1) downto 2 loop
				--report "Indice i = " & integer'image(i);
				addr_1 := addr_1 + lookup(addr_s(i))*16**(i - 2);
			end loop;
			readline(infile, buff);
			for i in 1 to pal_cnt loop
				read(buff, data_s); -- Leia dois dígitos Hex e o espaço separador
				-- data := lookup(data_s(3)) * 16 + lookup(data_s(2)); -- Converte o valor lido em Hex para inteiro
				data := (others => '0');
				upreal := real(BP)/4.0;
				up := integer((ceil(upreal)));
				--report "Indice de conteudo = " & real'image(upreal) & " Indice de conteudo inteiro = " & integer'image(up);
				for j in (up + 1) downto 2 loop
					data((4*(j-2))+3 downto 4*(j-2)) := std_logic_vector(to_unsigned(lookup(data_s(j)),4));
				end loop;
				Mem(addr_1) := data; -- Converte o conteúdo da palavra para std_logic_vector
				addr_1 := addr_1 + 1;	-- Endereça a próxima palavra a ser carregada
			end loop;
		end loop;
	return Mem;
end fill_memory;
 
begin
if inicio = '1' then
	-- Roda somente uma vez na inicialização
	Mram <= fill_memory;
	-- Insere o conteúdo na memória
	inicio := '0';
end if;

if reset'event and reset = '1' then
	dado_out <= (others => 'U');
    Mram <= (others=>(others=>'0'));
    Mram <= fill_memory;
end if;

if reset = '0' then
	endereco := to_integer(unsigned(ender));
	case rw is
		when '0' => -- Ciclo de Leitura
			dado_out <= Mram(endereco) after Tread;
		when '1' => --Ciclo de Escrita
			if clk'event and clk = '1' then
				Mram(endereco) <= dado_in after Twrite;
			end if;
		when others => -- Ciclo inválido
			Null;
	end case;
end if;

end process;

end ram_arch;