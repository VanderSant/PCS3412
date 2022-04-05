library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MUX_GATE_BUS_2 is
    generic ( Bits : integer ); 
    port (
        a, b: in std_logic_vector((Bits-1) downto 0);
        sel: in std_logic;
        s: out std_logic_vector((Bits-1) downto 0)
    );
end entity MUX_GATE_BUS_2;

architecture structural of MUX_GATE_BUS_2 is
  begin
      with sel select
          s <= a when '0',
               b when others;
  end architecture structural;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MUX_GATE_BUS_4 is
  generic ( Bits : integer ); 
    port (
        a, b, c, d: in std_logic_vector((Bits-1) downto 0);
        sel: in std_logic_vector(1 downto 0);
        s: out std_logic_vector(7 downto 0)
    );
end entity MUX_GATE_BUS_4;

architecture structural of MUX_GATE_BUS_4 is
  begin
      with sel select
          s <= a when "00",
               b when "01",
               c when "10",
               d when others;
  end architecture structural;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DIG_Register_BUS is
  generic ( Bits : integer ); 
    port (
        clock, clock_enable, reset, set: in std_logic;
        d: in std_logic_vector((Bits-1) downto 0);
        q: out std_logic_vector((Bits-1) downto 0)
    );
end entity DIG_Register_BUS;

architecture behaviour of DIG_Register_BUS is
  begin
      activation: process(clock, clock_enable, reset, set) is
          begin
              if reset = '1' then
                  q <= (others => '0');
              elsif set = '1' then
                  q <= (others => '1');
              elsif (clock'event and clock = '1') and clock_enable = '1' then q <= d;
              end if;
          end process activation;
  end architecture behaviour;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity COMP_GATE_UNSIGNED is
  generic ( Bits : integer ); 
    port (
        a, b: in std_logic_vector((Bits-1) downto 0);
        enable: in std_logic;
        menor, igual: out std_logic
    );
end entity COMP_GATE_UNSIGNED;

architecture combinatorial of COMP_GATE_UNSIGNED is
  begin
      activation: process(a, b) is
      begin
          if a = b then
              igual <= '1';
          else
              igual <= '0';
          end if;
  
          if a < b then
              menor <= '1';
          else
              menor <= '0';
          end if;
      end process activation;
  end architecture combinatorial;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DIG_Sub is
  generic ( Bits : integer ); 
    port (
        a, b: in std_logic_vector((Bits-1) downto 0);
        sub: out std_logic_vector((Bits-1) downto 0)
    );
end entity DIG_Sub;

architecture combinatorial of DIG_Sub is
begin
    activation: process(a, b) is
    begin
        sub <= std_logic_vector(unsigned(a) - unsigned(b));
    end process activation;
end architecture combinatorial;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mdc_fd is
    port (
        a, b: in std_logic_vector(7 downto 0);
        ce_a, ce_b, sel_b, clock, reset, set, compara: in std_logic;
        sel_a: in std_logic_vector(1 downto 0);
        igual, menor: out std_logic;
        mdc: out std_logic_vector(7 downto 0)
    );
end entity mdc_fd;

architecture connections of mdc_fd is
    component MUX_GATE_BUS_2 is
        port (
            a, b: in std_logic_vector(7 downto 0);
            sel: in std_logic;
            s: out std_logic_vector(7 downto 0)
        );
    end component MUX_GATE_BUS_2;

    signal a_q: std_logic_vector(7 downto 0) := "00000000";
    signal b_q: std_logic_vector(7 downto 0) := "00000000";
    signal sub_s: std_logic_vector(7 downto 0) := "00000000";

    signal a_d, b_d, i3: std_logic_vector(7 downto 0);

begin

    DIG_Register_BUS_A : entity work.DIG_Register_BUS 
      generic map (
        Bits => 8)
      port map(
        clock => clock, 
        clock_enable => ce_a, 
        reset => reset, 
        set => set, 
        d => a_d, 
        q => a_q
        );
      
    DIG_Register_BUS_B : entity work.DIG_Register_BUS 
      generic map (
        Bits => 8)
      port map(
        clock => clock, 
        clock_enable => ce_b, 
        reset => reset, 
        set => set, 
        d => b_d, 
        q => b_q
        );

    COMP  : entity work.COMP_GATE_UNSIGNED
    generic map (
      Bits => 8)
      port map(
        a => a_q, 
        b => b_q, 
        enable => compara, 
        menor => menor, 
        igual => igual
        );

    SUB   : entity work.DIG_Sub 
    generic map (
      Bits => 8)
      port map(
        a => a_q, 
        b => b_q, 
        sub => sub_s);

    MUX_A : entity work.MUX_GATE_BUS_4 
      generic map (
        Bits => 8)
      port map(
        a => sub_s, 
        b => a, 
        c => b_q, 
        d => i3, 
        sel => sel_a, 
        s => a_d);

    MUX_B : entity work.MUX_GATE_BUS_2 
      generic map (
        Bits => 8)
      port map(
        a => b, 
        b => a_q, 
        sel => sel_b, 
        s => b_d);

    i3 <= "00000000";

    mdc <= a_q;

end architecture connections;