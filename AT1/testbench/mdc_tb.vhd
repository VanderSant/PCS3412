library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mdc_tb is
end entity mdc_tb;

architecture tb of mdc_tb is
    component mdc is
        port (
            a, b: in std_logic_vector(7 downto 0);
            clock, reset, set, start: in std_logic;
            ready: out std_logic;
            mdc_out: out std_logic_vector(7 downto 0)
        );
    end component mdc;

    signal reset: std_logic := '0';
    signal set: std_logic := '0';
    signal start: std_logic := '1';                     -- igual exemplo
    signal clock: std_logic := '1';

    signal a: std_logic_vector(7 downto 0) := x"0A";    -- igual exemplo
    signal b: std_logic_vector(7 downto 0) := x"1A";    -- igual exemplo
    signal mdc_out: std_logic_vector(7 downto 0) := "00000000";
    signal ready: std_logic := '0';

    signal keep_simulating: std_logic := '0';
    constant clockPeriod: time := 20 ns;

begin
    clock <= ((not clock) and keep_simulating) after clockPeriod / 2;

    dut: mdc port map(a, b, clock, reset, set, start, ready, mdc_out);

    stimulus: process is
    begin
        report "Simulation start";
        keep_simulating <= '1';

        reset <= '1';
        wait for 9 ns;
        reset <= '0';

        wait on ready;
        wait for 19 ns;

        assert (mdc_out /= x"02") report "OK. mdc(0x0A, 0x1A) = 0x02";

        report "Simulation end";
        keep_simulating <= '0';

        wait;
    end process stimulus;
end architecture tb;
