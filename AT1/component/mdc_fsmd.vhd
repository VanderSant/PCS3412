library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mdc_fsmd is
    port (
        A, B: in std_logic_vector(7 downto 0);
        Reset, Clock, Start: in std_logic;
        MDC: out std_logic_vector(7 downto 0);
        Ready: out std_logic
    );
end entity mdc_fsmd; 

architecture Comportamental_fsmd of mdc_fsmd is
    type state is (idle, swap, sub);
    signal current_state, next_state: state;
    signal a_next, b_next: std_logic_vector(7 downto 0);
begin
    timing: process(Clock, Reset)
    begin
        if Reset = '1' then
            current_state <= idle;
        elsif (Clock'event and Clock = '1') then
            current_state <= next_state;
        end if;
    end process timing;

    next_output_state: process(A, B, Start, current_state)

    begin
        case current_state is
        when idle => 
            if Start = '1' then
                a_next <= A;
                b_next <= B;
                next_state <= swap;
            else
                Ready <= '0';
                next_state <= idle;
            end if;
        when swap =>
                if (a_next = b_next) then
                    Ready <= '1';
                    MDC <= a_next;
                    next_state <= idle;
                else
                    if (a_next < b_next) then
                        a_next <= b_next;
                        b_next <= a_next;
                    end if;
                    next_state <= sub;
                end if;
        when sub =>
                a_next <= std_logic_vector(unsigned(a_next) - unsigned(b_next));
                next_state <= swap;
        when others =>
                next_state <= current_state;
        end case;
    end process next_output_state;

end architecture Comportamental_fsmd;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity test_mdc_fsmd is
    port (
        Ready: in std_logic;
        MDC: in std_logic_vector(7 downto 0);
        Clock, Reset, Start: out std_logic;
        A, B: out std_logic_vector(7 downto 0)
    );
end entity test_mdc_fsmd;


architecture dut of test_mdc_fsmd is
    signal keep_simulating: bit := '1'; -- delimita o tempo de geração do clock
begin
    stimulis: process(Ready)
    begin
        keep_simulating <= '1';
        Start <= '1';
        A <= x"0A";
        B <= x"1A";

        if Ready = '1' then
            start <= '0';
            if MDC = x"02" then
                report "Correto!!";
            else
                report "Errado!!";
            end if;
            keep_simulating <= '0';
        end if;
        end process stimulis;

    LAL: process
        begin
        Reset <= '1';
        wait for 10 ns;
        Reset <= '0';
        wait;
    end process LAL;

    Relogio: process
        variable relogin: std_logic := '0';
    begin
        if keep_simulating = '1' then
            Clock <= relogin;
            relogin:=not relogin;
            wait for 10 ns;
        else
            wait;
        end if;
    end process Relogio;

end architecture dut; 