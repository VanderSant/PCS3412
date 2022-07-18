library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity hazard is
  port (
    clock: in std_logic;
    
    -- control signals
    regWex: in std_logic;
    regWmem: in std_logic;
    regWwb: in std_logic;

    -- writing registers
    reg_exA: in std_logic_vector(4 downto 0);
    reg_memA: in std_logic_vector(4 downto 0);
    reg_wbA: in std_logic_vector(4 downto 0);

    reg_exB: in std_logic_vector(4 downto 0);
    reg_memB: in std_logic_vector(4 downto 0);
    reg_wbB: in std_logic_vector(4 downto 0);

    reg_ID: in std_logic_vector(4 downto 0);

    --output signals
    cHzA: out std_logic_vector(1 downto 0);
    cHzB: out std_logic_vector(1 downto 0)


    ) ;
end hazard;

architecture hazard_arch of hazard is

signal conflict_exA, conflict_memA, conflict_wbA: std_logic;
signal conflict_exB, conflict_memB, conflict_wbB: std_logic;
begin


    conflict_exA <= regWex when (reg_exA = reg_ID) else '0';

    
    conflict_memA <= regWmem when (reg_memA = reg_ID) else '0';
    conflict_wbA <= regWwb when (reg_wbA = reg_ID) else '0';

    cHzA <= "01" when (conflict_exA = '1') else
            "10" when (conflict_memA = '1') else
            "11" when (conflict_wbA = '1') else
            "00";

    conflict_exB <= regWex when (reg_exB = reg_ID) else '0';
    conflict_memB <= regWmem when (reg_memB = reg_ID) else '0';
    conflict_wbB <= regWwb when (reg_wbB = reg_ID) else '0';

    cHzB <= "01" when (conflict_exB = '1') else
            "10" when (conflict_memB = '1') else
            "11" when (conflict_wbB = '1')   else
            "00";

end hazard_arch ; -- hazard_arch
