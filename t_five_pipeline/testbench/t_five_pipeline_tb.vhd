LIBRARY ieee;
USE ieee.std_logic_1164.all;

use std.textio.all;
use work.txt_util.all;

entity t_five_pipeline_tb is
end t_five_pipeline_tb;

architecture behav of t_five_pipeline_tb is

    component t_five_pipeline is
        port (
            clock, reset: in std_logic
        );
    end component t_five_pipeline;

--  Specifies which entity is bound with the component.
    for t_five_pipeline_0: t_five_pipeline use entity work.t_five_pipeline;

    signal clk:          std_logic := '0';
    signal rst:          std_logic := '0';

    constant PERIOD : time := 20 ns;
    signal finished: boolean := false;

begin
    clk <= not clk after PERIOD/2 when not finished else '0';

    t_five_pipeline_0: t_five_pipeline port map(
        clk,
        rst
    );

    test1: process
    begin
        -- rst inputs
        rst <= '1';
        wait for PERIOD * 3/2;

        rst <= '0';
        wait for PERIOD * 24;
        finished <= true;
        wait;
    end process;

end behav;
