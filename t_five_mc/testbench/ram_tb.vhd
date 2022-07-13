LIBRARY ieee;
USE ieee.std_logic_1164.all;

use std.textio.all;
use work.txt_util.all;

entity ram_tb is
end ram_tb;

 architecture behav of ram_tb is
    --  Declaration of the component that will be instantiated.
   component ram
      generic(
            BE : integer := 12;
            BP : integer := 32;
            file_name : string := "t_five_mc/data/mram.txt";
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
   end component;
   --  Specifies which entity is bound with the component.
   for ram_0: ram use entity work.ram;

   signal dado_in, dado_out, address : std_logic_vector(31 DOWNTO 0) := (others => '0');
   signal clk, reset, rw : std_logic := '0';

   constant PERIOD : time := 20 ns;
   signal finished: boolean := false;
begin
   clk <= not clk after PERIOD/2 when not finished else '0';

   --  Component instantiation.
   ram_0: ram port map (
      clk => clk,
      reset => reset,
      rw => rw,
      ender => address(13 downto 2),
      dado_in => dado_in,
      dado_out => dado_out
   );

   --  This process does the real job.
   process
      type pattern_type is record
         rw : std_logic;
         address, dado_in, dado_out: std_logic_vector(31 DOWNTO 0);
      end record;

      --  The patterns to apply.
      type pattern_array is array (natural range <>) of pattern_type;
      constant patterns : pattern_array := (
      --  rw     Address      Dado In      Dado Out
         ('0', x"00000000", x"00000000", x"0F0F1A1A"),
         ('0', x"00000004", x"00000000", x"2B2B3C3C"),
         ('0', x"00000008", x"00000000", x"4D4D5E5E"),
         ('0', x"0000000C", x"00000000", x"60607878")
      );
   begin
      finished <= false;
      report "BOT";
      reset <= '1';
      wait until clk'event and clk='1';
      wait until clk'event and clk='0';
      reset <= '0';

      --  Check each pattern.
      for x in patterns'range loop
         --  Set the inputs.
         rw <= patterns(x).rw;
         address <= patterns(x).address;
         dado_in <= patterns(x).dado_in;

         --  Wait for the results.
         wait for 2 * PERIOD;
         --  Check the outputs.
         assert dado_out = patterns(x).dado_out
            report "Output Error" & LF &
               "bad: "&str(dado_out) & LF &
               "exp: "&str(patterns(x).dado_out) & LF severity error;
      end loop;
      assert false report "end of test" severity note;
      --  Wait forever; this will finish the simulation.
      finished <= true;
      report "EOT";
      wait;
   end process;
end behav;
