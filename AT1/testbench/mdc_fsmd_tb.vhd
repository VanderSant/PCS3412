library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mdc_fsmd_tb is
end entity mdc_fsmd_tb;

architecture ligacao of mdc_fsmd_tb is
    component mdc_fsmd is
        port (
            A, B: in std_logic_vector(7 downto 0);
            Reset, Clock, Start: in std_logic;
            MDC: out std_logic_vector(7 downto 0);
            Ready: out std_logic
        );
    end component mdc_fsmd;

    component test_mdc_fsmd is
        port (
            Ready: in std_logic;
            MDC: in std_logic_vector(7 downto 0);
            Clock, Reset, Start: out std_logic;
            A, B: out std_logic_vector(7 downto 0)
        );
    end component test_mdc_fsmd;

    signal A,B,MDC: std_logic_vector(7 downto 0);
    signal Reset,Clock,Start,Ready: std_logic;

begin

    DUT: mdc_fsmd port map( A,B,Reset,Clock,Start,MDC,Ready );
    TB: test_mdc_fsmd port map( Ready,MDC,Clock,Reset,Start,A,B );

end architecture ligacao; 
