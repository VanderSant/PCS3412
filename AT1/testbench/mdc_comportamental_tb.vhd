Library IEEE;
use IEEE.std_logic_1164.all;
-- use IEEE.std_logic_arith.all;
-- use IEEE.std_logic_signed.all;

entity mdc_comportamental_tb is
end mdc_comportamental_tb;

architecture mdc_comportamental_tb of mdc_comportamental_tb is
    component mdc_comportamental is
        port (
            a, b: in std_logic_vector(7 downto 0);
            mdc: out std_logic_vector(7 downto 0)
        );
    end component mdc_comportamental;

    signal a: std_logic_vector(7 downto 0) := x"0A";    -- igual exemplo
    signal b: std_logic_vector(7 downto 0) := x"1A";    -- igual exemplo
    signal mdc: std_logic_vector(7 downto 0) := "00000000";

    signal keep_simulating: std_logic := '0';
    
    begin
        dut: mdc_comportamental port map(a, b,mdc);

        Estimulos : process is
    begin
        report "Simulation start";
        keep_simulating <= '1';
        
        a <= x"0A"; b <= x"1A";
        wait for 10 ns;
        if mdc = x"02" then
            report "Correto!!";
        else
            report "Errado!!";
        end if;
        b <= x"1B";
        wait for 10 ns;
        if mdc = x"01" then
            report "Correto!!";
        else
            report "Errado!!";
        end if;
        wait;
        end process Estimulos;
end mdc_comportamental_tb;