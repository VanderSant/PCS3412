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
    constant c_add_ctrl :  std_logic_vector(6 downto 0) := "0110011";
    constant c_addi_ctrl : std_logic_vector(6 downto 0) := "0010011";

    constant c_sub_ctrl :  std_logic_vector(6 downto 0) := "0110011";

    constant c_slt_ctrl :  std_logic_vector(6 downto 0) := "0110011";
    constant c_slti_ctrl : std_logic_vector(6 downto 0) := "0010011";

    constant c_sll_ctrl :  std_logic_vector(6 downto 0) := "0110011";
    constant c_slli_ctrl : std_logic_vector(6 downto 0) := "0010011";

    constant c_srl_ctrl :  std_logic_vector(6 downto 0) := "0110011";
    constant c_srli_ctrl : std_logic_vector(6 downto 0) := "0010011";

    constant c_sra_ctrl :  std_logic_vector(6 downto 0) := "0110011";
    constant c_srai_ctrl : std_logic_vector(6 downto 0) := "0010011";

    constant c_lw_ctrl :   std_logic_vector(6 downto 0) := "0000011";
    constant c_sw_ctrl :   std_logic_vector(6 downto 0) := "0100011";
    constant c_beq_ctrl :  std_logic_vector(6 downto 0) := "1100011";
    constant c_bne_ctrl :  std_logic_vector(6 downto 0) := "1100011";
    constant c_blt_ctrl :  std_logic_vector(6 downto 0) := "1100011";
    constant c_jal_ctrl :  std_logic_vector(6 downto 0) := "1101111";
    constant c_jalr_ctrl : std_logic_vector(6 downto 0) := "1100111";


    type state_t is (fetch, decode, st_opcode, st_lw_2, st_beq_bne_blt_2 );
    signal next_state, current_state: state_t := fetch;

begin
    timing: process(reset, clk) is
    begin
        if reset = '1' then
            current_state <= fetch;
        elsif (clk'event and clk = '1') then
            current_state <= next_state;
        end if;
    end process timing;

    next_state_output: process(branch, current_state) is
    begin

        case current_state is
            when fetch =>
                ri_en <= '1';
                pc_en <= '1';
                m1_sel <= '1';
                m2_sel <= "10";
                next_state <= decode;
            when decode =>
                m1_sel <= '0';
                m2_sel <= "00";
                next_state <= st_opcode;
            when st_opcode =>
                if ((opcode = c_add_ctrl) and (opcode = c_slt_ctrl)) then
                    m1_sel <= '0';
                    m2_sel <= "00";
                    m3_sel <= "00";
                    reg_write <= '1';
                    alu_op <= "00";
                    ri_en <= '0';
                elsif ((opcode = c_addi_ctrl) and (opcode = c_slti_ctrl) and (opcode = c_slli_ctrl) and (opcode = c_srli_ctrl) and (opcode = c_srai_ctrl)) then
                    m1_sel <= '0';
                    m2_sel <= "01";
                    m3_sel <= "00";
                    reg_write <= '1';
                    se_op <= "00";
                    alu_op <= "01";
                    ri_en <= '0';
                elsif (opcode = c_lw_ctrl) then
                    alu_op <= "10";
                    se_op <= "00";
                    rw <= '0';
                    m1_sel <= '0';
                    m2_sel <= "01";
                    next_state <= st_lw_2;
                elsif (opcode = c_sw_ctrl) then
                    alu_op <= "10";
                    se_op <= "01";
                    rw <= '1';
                    m1_sel <= '0';
                    m2_sel <= "01";
                elsif ((opcode = c_beq_ctrl) and (opcode = c_bne_ctrl) and (opcode = c_blt_ctrl)) then
                    alu_op <= "11";
                    se_op <= "10";
                    m1_sel <= '0';
                    m2_sel <= "00";
                    if(branch = '1') then 
                        next_state <= st_beq_bne_blt_2;
                    end if;
                elsif (opcode = c_jal_ctrl) then 
                    m1_sel <= '1';
                    m2_sel <= "01";
                    alu_op <= "10";
                    se_op <= "11";
                    pc_en <= '1';
                    m3_sel <= "10";
                    reg_write <= '1';
                elsif (opcode = c_jalr_ctrl) then
                    m1_sel <= '0';
                    m2_sel <= "01";
                    alu_op <= "10";
                    se_op <= "00";
                    pc_en <= '1';
                    m3_sel <= "10";
                    reg_write <= '1';
                end if;
            when st_lw_2 => 
                reg_write <= '1';
                m3_sel <= "01";
            when st_beq_bne_blt_2 => 
                alu_op <= "10";
                se_op <= "10";
                m1_sel <= '1';
                m2_sel <= "01";
                pc_en <= '1';
        end case;
    end process next_state_output;

end architecture fsm;