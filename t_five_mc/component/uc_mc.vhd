library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uc_mc is
    port (
        clk, reset: in std_logic;

        -- Sinais de dado
        opcode:     in std_logic_vector(6 downto 0); 
        branch:     in std_logic;

        -- Sinais de controle
        pc_en:      out std_logic;
        ri_en:      out std_logic;
        reg_write:  out std_logic;
        alu_op:     out std_logic_vector(1 downto 0);
        se_op:      out std_logic_vector(1 downto 0);
        m1_sel:     out std_logic;
        m2_sel:     out std_logic_vector(1 downto 0); 
        m3_sel:     out std_logic_vector(1 downto 0);
        
        rw:         out std_logic

    );
end entity uc_mc;

architecture fsm of uc_mc is

    ---- Architecture declarations -----
    constant c_r_ctrl :    std_logic_vector(6 downto 0) := "0110011";
    constant c_i_ctrl :    std_logic_vector(6 downto 0) := "0010011";
    constant c_lw_ctrl :   std_logic_vector(6 downto 0) := "0000011";
    constant c_sw_ctrl :   std_logic_vector(6 downto 0) := "0100011";
    constant c_b_ctrl :    std_logic_vector(6 downto 0) := "1100011";
    constant c_jal_ctrl :  std_logic_vector(6 downto 0) := "1101111";
    constant c_jalr_ctrl : std_logic_vector(6 downto 0) := "1100111";


    type state_t is (idle_s, fetch_s, decode_s, r_type_s, i_type_s, lw1_s, lw2_s, sw_s, b1_s, b2_s, jal_s, jalr_s);
    signal next_state, current_state: state_t := idle_s;

begin
    timing: process(reset, clk) is
    begin
        if reset = '1' then
            current_state <= idle_s;
        elsif (clk'event and clk = '1') then
            current_state <= next_state;
        end if;
    end process timing;

    -- Next state logic
    next_state <=
        fetch_s when (current_state = idle_s) or
                     (current_state = r_type_s) or
                     (current_state = i_type_s) or
                     (current_state = lw2_s) or
                     (current_state = sw_s) or
                     ((current_state = b1_s) and (branch = '0')) or
                     (current_state = b2_s) or
                     (current_state = jal_s) or
                     (current_state = jalr_s) else
        decode_s when (current_state = fetch_s) else
        r_type_s when (current_state = decode_s) and (opcode = c_r_ctrl) else
        i_type_s when (current_state = decode_s) and (opcode = c_i_ctrl) else
        lw1_s when (current_state = decode_s) and (opcode = c_lw_ctrl) else
        lw2_s when (current_state = lw1_s) else
        sw_s when (current_state = decode_s) and (opcode = c_sw_ctrl) else
        b1_s when (current_state = decode_s) and (opcode = c_b_ctrl) else
        b2_s when (current_state = b1_s) and (branch = '1') else
        jal_s when (current_state = decode_s) and (opcode = c_jal_ctrl) else
        jalr_s when (current_state = decode_s) and (opcode = c_jalr_ctrl) else
        idle_s;
    
    -- Signals logic
    pc_en       <= '1' when (current_state = fetch_s) or
                            (current_state = b2_s) or
                            (current_state = jal_s) or
                            (current_state = jalr_s) else
                   '0';
    
    ri_en       <= '1' when (current_state = fetch_s) else
                   '0';

    reg_write   <= '1' when (current_state = r_type_s) or
                            (current_state = i_type_s) or
                            (current_state = lw2_s) or
                            (current_state = jal_s) or
                            (current_state = jalr_s) else
                   '0';

    alu_op      <= "00" when (current_state = r_type_s) else
                   "01" when (current_state = i_type_s) else
                   "11" when (current_state = b1_s) else
                   "10";

    se_op       <= "01" when (current_state = sw_s) else
                   "10" when (current_state = b1_s) or
                             (current_state = b2_s) else
                   "11" when (current_state = jal_s) else
                   "00";
    
    m1_sel      <= '1' when (current_state = fetch_s) or
                            (current_state = b2_s) or
                            (current_state = jal_s) else
                   '0';
    
    m2_sel      <= "01" when (current_state = i_type_s) or
                             (current_state = lw1_s) or
                             (current_state = lw2_s) or
                             (current_state = sw_s) or
                             (current_state = b2_s) or
                             (current_state = jal_s) or
                             (current_state = jalr_s) else
                   "10" when (current_state = fetch_s) else
                   "00";
    
    m3_sel      <= "01" when (current_state = lw2_s) else
                   "10" when (current_state = jal_s) or
                             (current_state = jalr_s) else
                   "00";
    
    rw          <= '1' when (current_state = sw_s) else
                   '0';


end architecture fsm;