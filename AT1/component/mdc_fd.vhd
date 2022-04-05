LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity MUX_GATE_BUS_1 is
  generic ( Bits : integer ); 
  port (
    p_out: out std_logic_vector ((Bits-1) downto 0);
    sel: in std_logic;
    
    in_0: in std_logic_vector ((Bits-1) downto 0);
    in_1: in std_logic_vector ((Bits-1) downto 0) );
end MUX_GATE_BUS_1;

architecture Behavioral of MUX_GATE_BUS_1 is
begin
  with sel select
    p_out <=
      in_0 when '0',
      in_1 when '1',
      (others => '0') when others;
end Behavioral;


LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity DIG_Register_BUS is
  generic ( Bits: integer ); 
  port (
    Q: out std_logic_vector ((Bits-1) downto 0);
    D: in std_logic_vector ((Bits-1) downto 0);
    C: in std_logic;
    en: in std_logic; 
    reset, set: in std_logic);
end DIG_Register_BUS;

architecture Behavioral of DIG_Register_BUS is
  signal state : std_logic_vector ((Bits-1) downto 0) := (others => '0');
begin
   Q <= state;

   process ( C,reset,set )
   begin
      if reset = '1' then
        state <= (others => '0');
      elsif set = '1' then
        state <= (others => '1');
      elsif rising_edge(C) and (en='1') then
        state <= D;
      end if;
   end process;
end Behavioral;


LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity MUX_GATE_BUS_2 is
  generic ( Bits : integer ); 
  port (
    p_out: out std_logic_vector ((Bits-1) downto 0);
    sel: in std_logic_vector (1 downto 0);
    
    in_0: in std_logic_vector ((Bits-1) downto 0);
    in_1: in std_logic_vector ((Bits-1) downto 0);
    in_2: in std_logic_vector ((Bits-1) downto 0);
    in_3: in std_logic_vector ((Bits-1) downto 0) );
end MUX_GATE_BUS_2;

architecture Behavioral of MUX_GATE_BUS_2 is
begin
  with sel select
    p_out <=
      in_0 when "00",
      in_1 when "01",
      in_2 when "10",
      in_3 when "11",
      (others => '0') when others;
end Behavioral;


LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity COMP_GATE_UNSIGNED is
  generic ( Bits : integer );
  port (
    gr: out std_logic;
    eq: out std_logic;
    le: out std_logic;
    compara: in std_logic;
    a: in std_logic_vector ((Bits-1) downto 0);
    b: in std_logic_vector ((Bits-1) downto 0) );
end COMP_GATE_UNSIGNED;

architecture Behavioral of COMP_GATE_UNSIGNED is
begin
  process(a, b)
  begin
    if (a > b ) then
      le <= '0';
      eq <= '0';
      gr <= '1';
    elsif (a < b) then
      le <= '1';
      eq <= '0';
      gr <= '0';
    else
      le <= '0';
      eq <= '1';
      gr <= '0';
    end if;
  end process;
end Behavioral;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
-- USE ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity DIG_Sub is
  generic ( Bits: integer ); 
  port (
    s: out std_logic_vector((Bits-1) downto 0);
    c_o: out std_logic;
    a: in std_logic_vector((Bits-1) downto 0);
    b: in std_logic_vector((Bits-1) downto 0);
    c_i: in std_logic );
end DIG_Sub;

architecture Behavioral of DIG_Sub is
   signal temp : std_logic_vector(Bits downto 0);
begin
   temp <= std_logic_vector(unsigned(a) - unsigned(b));

   s    <= temp((Bits-1) downto 0);
   c_o  <= temp(Bits);
end Behavioral;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity mdc_fd is
  port (
    A: in std_logic_vector(7 downto 0);
    B: in std_logic_vector(7 downto 0);
    ce_a: in std_logic;
    ce_b: in std_logic;
    sel_b: in std_logic;
    clock: in std_logic;
    reset, set, compara: in std_logic;
    sel_a: in std_logic_vector(1 downto 0);
    igual: out std_logic;
    menor: out std_logic;
    mdc: out std_logic_vector(7 downto 0) );
end mdc_fd;

architecture Behavioral of mdc_fd is
  signal s0: std_logic_vector(7 downto 0);
  signal s1: std_logic_vector(7 downto 0);
  signal s2: std_logic_vector(7 downto 0);
  signal s3: std_logic_vector(7 downto 0);
  signal mdc_temp: std_logic_vector(7 downto 0);
begin
  gate0: entity work.MUX_GATE_BUS_1
    generic map (
      Bits => 8)
    port map (
      sel => sel_b,
      in_0 => B,
      in_1 => A,
      p_out => s3);
  gate1: entity work.DIG_Register_BUS -- B
    generic map (
      Bits => 8)
    port map (
      D => s3,
      C => clock,
      en => ce_b,
      Q => s1,
      reset => reset,
      set => set);
  gate2: entity work.MUX_GATE_BUS_2
    generic map (
      Bits => 8)
    port map (
      sel => sel_a,
      in_0 => A,
      in_1 => s0,
      in_2 => s1,
      in_3 => "00000000",
      p_out => s2);
  gate3: entity work.DIG_Register_BUS -- A
    generic map (
      Bits => 8)
    port map (
      D => s2,
      C => clock,
      en => ce_a,
      Q => mdc_temp,
      reset => reset,
      set => set);
  gate4: entity work.COMP_GATE_UNSIGNED
    generic map (
      Bits => 8)
    port map (
      a => mdc_temp,
      b => s1,
      compara => compara,
      eq => igual,
      le => menor);
  gate5: entity work.DIG_Sub
    generic map (
      Bits => 8)
    port map (
      a => mdc_temp,
      b => s1,
      c_i => '0',
      s => s0);
  mdc <= mdc_temp;
end Behavioral;
