LIBRARY ieee;
USE ieee.std_logic_1164.all;

use std.textio.all;
use work.txt_util.all;

entity rom_tb is
end rom_tb;

 architecture behav of rom_tb is
    --  Declaration of the component that will be instantiated.
    component rom is
        generic(
            BE : integer := 28;
            BP : integer := 32;
            file_name : string := "mrom.txt";
            Tread : time := 5 ns
        );
        port(
            reset : in std_logic;
            ender : in std_logic_vector(BE - 1 downto 0);
            dado_out : out std_logic_vector(BP - 1 downto 0)
        );
    end component;
   --  Specifies which entity is bound with the component.
   for rom_0: rom use entity work.rom;

   signal dado_out, address : std_logic_vector(31 DOWNTO 0) := (others => '0');
   signal reset : std_logic := '0';

begin

   --  Component instantiation.
   rom_0: rom
   generic map(
        BE => 12,
        BP => 32,
        file_name => "t_five_pipeline/data/default_imem.txt",
        Tread => 5 ns
    )
    port map (
        reset => reset,
        ender => address(13 downto 2),
        dado_out => dado_out
    );

   --  This process does the real job.
   process
      type pattern_type is record
        address, dado_out: std_logic_vector(31 DOWNTO 0);
      end record;

      --  The patterns to apply.
      type pattern_array is array (natural range <>) of pattern_type;
      constant patterns : pattern_array := (
      --    Address      Dado Out
         (x"00000000", x"00300393"),
         (x"00000004", x"00400413"),
         (x"00000008", x"008384B3"),
         (x"0000000C", x"00000000")
      );
   begin
      report "BOT";
      reset <= '1';
      wait for 10 ns;
      reset <= '0';

      --  Check each pattern.
      for x in patterns'range loop
         --  Set the inputs.
         address <= patterns(x).address;

         --  Wait for the results.
         wait for 10 ns;
         --  Check the outputs.
         assert dado_out = patterns(x).dado_out
            report "Output Error" & LF &
               "bad: "&str(dado_out) & LF &
               "exp: "&str(patterns(x).dado_out) & LF severity error;
      end loop;
      assert false report "end of test" severity note;
      --  Wait forever; this will finish the simulation.
      report "EOT";
      wait;
   end process;
end behav;
