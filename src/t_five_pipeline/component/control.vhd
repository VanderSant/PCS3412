-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control is
  port (
    -- input
    opcode: std_logic_vector(6 downto 0);

    -- output
    cWbo: out std_logic_vector(1 downto 0);
    cMo: out std_logic_vector(2 downto 0);
    cExo: out std_logic_vector(5 downto 0)

  ) ;
end control;

architecture control_arch of control is
begin
    -- RegDst & ULAsrc & ULAop & se_op
    cExo <= '1' & '0' & "10" & "00" when opcode = "0110011" else -- R
            '1' & '1' & "10" & "00" when opcode = "0010011" else -- Immediato
            '1' & '1' & "00" & "00" when opcode = "0000011" else -- Load
            'X' & '1' & "00" & "01" when opcode = "0100011" else -- Store
            'X' & 'X' & "XX" & "10" when opcode = "1100011" else -- Branch
            'X' & 'X' & "XX" & "11";                 -- Jump
            
    -- Branch & MemRead & MemWrite 
    cMo <=  '0' & '0' & '0' when opcode = "0110011" else -- R
            '0' & '0' & '0' when opcode = "0010011" else -- Immediato
            '0' & '1' & '0' when opcode = "0000011" else -- Load
            '0' & '0' & '1' when opcode = "0100011" else -- Store
            '1' & '0' & '0' when opcode = "1100011" else -- Branch
            '1' & '0' & '0';                 -- Jump
        
        --  RegWrite & MemToReg
    cWbo <=  '1' & '0' when opcode = "0110011" else -- R
             '1' & '0' when opcode = "0010011" else -- Immediato
             '1' & '1' when opcode = "0000011" else -- Load
             '0' & '0' when opcode = "0100011" else -- Store
             '0' & '0' when opcode = "1100011" else -- Branch
             '0' & '0';                 -- Jump


end control_arch ; -- control_arch
