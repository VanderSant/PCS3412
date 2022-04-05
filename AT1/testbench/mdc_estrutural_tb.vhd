Library IEEE;
use IEEE.std_logic_1164.all;

entity mdc_estrutural_tb is
end entity mdc_estrutural_tb;

architecture tb of mdc_estrutural_tb is
    component mdc_estrutural is
        port (
            a, b: in std_logic_vector(7 downto 0);
            clock, reset, set, start: in std_logic;
            ready: out std_logic;
            mdc: out std_logic_vector(7 downto 0)
        );
    end component mdc_estrutural;

    signal reset: std_logic := '0';
    signal set: std_logic := '0';
    signal start: std_logic := '1';                     -- igual exemplo
    signal clock: std_logic := '1';

    signal a: std_logic_vector(7 downto 0) := x"0A";    -- igual exemplo
    signal b: std_logic_vector(7 downto 0) := x"1A";    -- igual exemplo
    signal mdc: std_logic_vector(7 downto 0) := "00000000";
    signal ready: std_logic := '0';

    signal keep_simulating: std_logic := '0';
    constant clockPeriod: time := 20 ns;

begin
    clock <= ((not clock) and keep_simulating) after clockPeriod / 2;

    dut: mdc_estrutural port map(a, b, clock, reset, set, start, ready, mdc);
    stimulus: process is
    begin
        report "Simulation start";
        keep_simulating <= '1';

        reset <= '1';
        wait for 9 ns;
        reset <= '0';

        a <= x"0A";
        b <= x"1A";

        start <= '1';
        wait for clockPeriod;
        start <= '0';

        wait on ready;
        if mdc = x"02" then
            report "Correto!!";
        else
            report "Errado!!";
        end if;
        wait for clockPeriod;
        
        reset <= '1';
        wait for 9 ns;
        reset <= '0';
        a <= x"45";
        b <= x"E6";
        start <= '1';
        wait for clockPeriod;
        start <= '0';
        wait on ready;
        if mdc = x"17" then
            report "Correto!!";
        else
            report "Errado!!";
        end if;
        report "Simulation end";
        keep_simulating <= '0';
        wait;
    end process stimulus;
end architecture tb;
