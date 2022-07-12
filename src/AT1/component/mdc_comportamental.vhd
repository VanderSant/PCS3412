library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mdc_comportamental is
    port (
        a, b: in std_logic_vector(7 downto 0);
        mdc: out std_logic_vector(7 downto 0)
    );
end entity mdc_comportamental;

architecture fsm of mdc_comportamental is
    Begin
--- Processes ----
    Algoritmo_MDC :process (a, b)
    variable xv, yv, xvv : std_logic_vector(7 downto 0);
    begin
        xv := A;
        yv := B;
        while (xv /= yv) loop -- IDLE
            if xv < yv then -- SWAP
                xvv := xv;
                xv := yv;
                yv := xvv;
            else
                xv := std_logic_vector(unsigned(xv) - unsigned(yv));
            end if;
        end loop;
        mdc <= xv; -- STOP
    end process Algoritmo_MDC;
end architecture fsm;