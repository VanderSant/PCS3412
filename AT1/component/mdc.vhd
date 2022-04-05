library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mdc is
    port (
        a, b: in std_logic_vector(7 downto 0);
        clock, reset, set, start: in std_logic;
        ready: out std_logic;
        mdc_out: out std_logic_vector(7 downto 0)
    );
end entity mdc;

architecture fd_uc of mdc is
    component mdc_fd is
        port (
            a, b: in std_logic_vector(7 downto 0);
            ce_a, ce_b, sel_b, clock, reset, set, compara: in std_logic;
            sel_a: in std_logic_vector(1 downto 0);
            igual, menor: out std_logic;
            mdc: out std_logic_vector(7 downto 0)
        );
    end component mdc_fd;

    component mdc_uc is
        port (
            clock, reset, start, igual, menor: in std_logic;
            ready, ce_a, ce_b, sel_b, compara: out std_logic;
            sel_a: out std_logic_vector(1 downto 0)
        );
    end component mdc_uc;

    signal ce_a, ce_b, sel_b, compara, menor, igual, n_clock: std_logic;
    signal sel_a: std_logic_vector(1 downto 0);

begin

    FD : mdc_fd port map(a, b, ce_a, ce_b, sel_b, n_clock, reset, set, compara, sel_a, igual, menor, mdc_out);
    UC : mdc_uc port map(clock, reset, start, igual, menor, ready, ce_a, ce_b, sel_b, compara, sel_a);

    n_clock <= not(clock);

end architecture fd_uc;