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
        cMo: out std_logic_vector(3 downto 0);
        cExo: out std_logic_vector(4 downto 0)
    );
end control;

architecture control_arch of control is
    ---- Architecture declarations -----
    constant c_r_ctrl :    std_logic_vector(6 downto 0) := "0110011";
    constant c_i_ctrl :    std_logic_vector(6 downto 0) := "0010011";
    constant c_lw_ctrl :   std_logic_vector(6 downto 0) := "0000011";
    constant c_sw_ctrl :   std_logic_vector(6 downto 0) := "0100011";
    constant c_b_ctrl :    std_logic_vector(6 downto 0) := "1100011";
    constant c_jal_ctrl :  std_logic_vector(6 downto 0) := "1101111";
    constant c_jalr_ctrl : std_logic_vector(6 downto 0) := "1100111";

begin

    -- ula_src & ula_op & se_op
    cExo <= "00" & "00" & '0' when opcode = c_r_ctrl else -- R
            "00" & "01" & '1' when opcode = c_i_ctrl else -- Immediato
            "00" & "10" & '1' when opcode = c_lw_ctrl else -- Load
            "01" & "10" & '1' when opcode = c_sw_ctrl else -- Store
            "10" & "11" & '0' when opcode = c_b_ctrl else -- Branch
            "11" & "00" & '0' when opcode = c_jal_ctrl else -- Jal
            "00" & "10" & '1' when opcode = c_jalr_ctrl else -- Jalr
            "00" & "00" & '0';
            
    -- write_mem & jump_type & uncond_branch & cond_branch
    cMo <=  '0' & '0' & '0' & '0' when opcode = c_r_ctrl else -- R
            '0' & '0' & '0' & '0' when opcode = c_i_ctrl else -- Immediato
            '0' & '0' & '0' & '0' when opcode = c_lw_ctrl else -- Load
            '1' & '0' & '0' & '0' when opcode = c_sw_ctrl else -- Store
            '0' & '0' & '0' & '1' when opcode = c_b_ctrl else -- Branch
            '0' & '0' & '1' & '0' when opcode = c_jal_ctrl else -- Jal
            '0' & '1' & '1' & '0' when opcode = c_jalr_ctrl else -- Jalr
            '0' & '0' & '0' & '0';
        
        --  reg_write & wb_src
    cWbo <=  '0' & '1' when opcode = c_r_ctrl else -- R
             '0' & '1' when opcode = c_i_ctrl else -- Immediato
             '1' & '1' when opcode = c_lw_ctrl else -- Load
             '0' & '0' when opcode = c_sw_ctrl else -- Store
             '0' & '0' when opcode = c_b_ctrl else -- Branch
             '0' & '1' when opcode = c_jal_ctrl else -- Jal
             '0' & '1' when opcode = c_jalr_ctrl else -- Jalr
             '0' & '0';


end control_arch ; -- control_arch
