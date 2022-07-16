-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem is 
    port(
        clk, reset: in std_logic;

        --interface ID/EX
        RE_out: in std_logic_vector(70 downto 0);     
        
        --interface EX/MEM
        RM_out: out std_logic_vector(?? downto 0);

        --sinais de controle
        cWbi : in std_logic_vector(1 downto 0);
        cMi: in std_logic_vector(2 downto 0);

        cWbo: out std_logic_vector(1 downto 0);

        -- interface com fetch
        NPCJ: out std_logic_vector(31:0);
        pcsrc: out std_logic;
    );
end entity;


architecture mem_arch of mem is

    component ram is
        generic(
             BE : integer := 12;
             BP : integer := 32;
             file_name : string := "t_five_mc/data/mram.txt";
             Tz : time := 2 ns;
             Twrite : time := 5 ns;
             Tread : time := 5 ns
        );
        port(
             clk, reset :   in std_logic;
             rw :           in std_logic;
             ender :        in std_logic_vector(BE - 1 downto 0);
             dado_in :      in std_logic_vector(BP - 1 downto 0);
             dado_out :     out std_logic_vector(BP - 1 downto 0)
        );
      end component ram;


    signal NPCJ_in, mem_address, mem_data_in, mem_data_out : std_logic_vector(31 downto 0); 

    signal end_reg: std_logic_vector(4 downto 0);

    signal mem_read, mem_write, zero, negative;
begin

    end_reg     <= RE_out(4 downto 0);
    mem_address <= RE_out(36 downto 5);
    zero        <= RE_out(37);
    negative    <= RE_out(38); 
    NPCJ_in     <= RE_out(70 downto 39);
    mem_data    <= RE_out(102 downto 71);
    
    mem_read    <= cMi(1);
    reg_out     <= mem_address;

    RAM: ram
    generic map(
         BE => 12;
         BP => 32;
         file_name => "t_five_mc/data/mram.txt";
         Tz => 2 ns;
         Twrite => 5 ns;
         Tread => 5 ns
    );
    port map(
         clk => clk;
         reset => reset;
         rw => mem_read;
         ender =>   mem_address;
         dado_in => mem_data_in;
         dado_out => mem_data_out
    );
      


    cWbo <= cWbi;

    RM_out(4 downto 0)      <= end_reg;
    RM_out(36 downto 5)     <= reg_out;
    RM_out(68 downto 37)    <= mem_data_out;
    
    pcsrc <= zero and cMi(0);

end mem_arch ; -- mem_arch
