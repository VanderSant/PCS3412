LIBRARY ieee;
USE ieee.std_logic_1164.all;

use std.textio.all;
use work.txt_util.all;

entity reg_file_tb is
end reg_file_tb;

 architecture behav of reg_file_tb is
    --  Declaration of the component that will be instantiated.
   component reg_file
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
      end component;
   --  Specifies which entity is bound with the component.
   for reg_file_0: reg_file use entity work.reg_file;

   signal clk, reset, we : std_logic := '0';
   signal addw, adda, addb : std_logic_vector(4 downto 0) := (others => '0');
   signal data_in, data_outa, data_outb : std_logic_vector(31 downto 0) := (others => '0');


   constant PERIOD : time := 20 ns;
   signal finished: boolean := false;
begin
   clk <= not clk after PERIOD/2 when not finished else '0';

   --  Component instantiation.
   reg_file_0: reg_file port map (
      clk => clk,
      reset => reset,
      we => we,
      adda => adda,
      addb => addb,
      addw => addw,
      data_in => data_in,
      data_outa => data_outa,
      data_outb => data_outb
   );

   --  This process does the real job.
   process
      type pattern_type is record
         we : std_logic;
         addw, adda, addb: std_logic_vector(4 downto 0);
         data_in, data_outa, data_outb: std_logic_vector(31 downto 0);
      end record;

      --  The patterns to apply.
      type pattern_array is array (natural range <>) of pattern_type;
      constant patterns : pattern_array := (
      --  rw     Addw    Adda     Addb     data_in      data_outa    data_outb
         ('1', "00000", "00001", "00001", x"00001000", x"00000000", x"00000000"),
         ('0', "00000", "00000", "00001", x"00000000", x"00001000", x"00000000")
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
         we <= patterns(x).we;
         addw <= patterns(x).addw;
         adda <= patterns(x).adda;
         addb <= patterns(x).addb;
         data_in <= patterns(x).data_in;
         data_in <= patterns(x).data_in;

         --  Wait for the results.
         wait for 2 * PERIOD;
         wait for PERIOD / 6;
         --  Check the outputs.
         assert data_outa = patterns(x).data_outa
            report "Output Error" & LF &
               "bad: "&str(data_outa) & LF &
               "exp: "&str(patterns(x).data_outa) & LF severity error;
         assert data_outb = patterns(x).data_outb
            report "Output Error" & LF &
               "bad: "&str(data_outb) & LF &
               "exp: "&str(patterns(x).data_outb) & LF severity error;
      end loop;
      assert false report "end of test" severity note;
      --  Wait forever; this will finish the simulation.
      finished <= true;
      report "EOT";
      wait;
   end process;
end behav;
