LIBRARY ieee;
USE ieee.std_logic_1164.all;

use std.textio.all;
use work.txt_util.all;

entity t_five_mc_tb is
end t_five_mc_tb;

architecture behav of t_five_mc_tb is

    component t_five_mc is
        port (
            clock, reset: in std_logic
        );
    end component t_five_mc;

--  Specifies which entity is bound with the component.
    for t_five_mc_0: t_five_mc use entity work.t_five_mc;

    signal clk:          std_logic := '0';
    signal rst:          std_logic := '0';

    -- constant PERIOD : time := 20 ns;
    -- signal finished: boolean := false;

begin

    t_five_mc_0: t_five_mc port map(
        clk,
        rst
    );

    test1: process
    begin
        -- rst inputs
        rst <= '1';
        wait for 50 ns;

        rst <= '0';
        wait;
    end process;

    clock_gen: process
    begin
        clk <= '0', '1' after 20 ns;
        wait for 40 ns;
    end process clock_gen;

end behav;
