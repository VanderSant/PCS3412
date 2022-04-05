library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mdc_uc is
    port (
        clock, reset, start, igual, menor: in std_logic;
        ready, ce_a, ce_b, sel_b, compara: out std_logic;
        sel_a: out std_logic_vector(1 downto 0)
    );
end entity mdc_uc;

architecture fsm of mdc_uc is

    type state_t is (idle, swap, sub);
    signal next_state, current_state: state_t := idle;

begin

    timing: process(reset, clock) is
    begin
        if reset = '1' then
            current_state <= idle;
        elsif (clock'event and clock = '1') then
            current_state <= next_state;
        end if;
    end process timing;

    next_state_output: process(start, current_state) is
    begin
        ready <= '0'; ce_a <= '0'; ce_b <= '0'; sel_b <= '0'; compara <= '0'; sel_a <= "01";

        case current_state is
            when idle =>
                if start = '1' then
                    ce_a <= '1';
                    ce_b <= '1';
                    next_state <= swap;
                else
                    next_state <= idle;
                end if;

            when swap =>
                if (igual = '1') then
                    ready <= '1';
                    next_state <= idle;
                elsif (menor = '1') then
                    sel_a <= "10";
                    ce_a <= '1';
                    sel_b <= '1'; ce_b <= '1';
                end if;
                next_state <= sub;
                compara <= '1';

            when sub =>
                ce_a <= '1';
                sel_a <= "00";
                next_state <= swap;
                compara <= '0';

        end case;
    end process next_state_output;


end architecture fsm;