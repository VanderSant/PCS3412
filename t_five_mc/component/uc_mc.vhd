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


architecture state_qualifier of uc_mc is
    component reg is
        generic(
            NB : integer := 32;
            t_prop : time := 1 ns;
            t_hold : time := 0.25 ns;
            t_setup : time := 0.25 ns
        );
        port(
            clk : in std_logic;
            CE : in std_logic;
            R : in std_logic;
            S : in std_logic;
            D : in std_logic_vector(NB - 1 downto 0);
            Q : out std_logic_vector(NB - 1 downto 0)
        );
    end component;

    component mux2x1 is
        generic(
           NB : integer := 32;
           t_sel : time := 0.5 ns;
           t_data : time := 0.25 ns
        );
        port(
           Sel : in std_logic;
           I0 : in std_logic_vector(NB - 1 downto 0);
           I1 : in std_logic_vector(NB - 1 downto 0);
           O : out std_logic_vector(NB - 1 downto 0)
        );
    end component;

    component mux8x1_1b is
        generic(
           t_sel : time := 0.5 ns;
           t_data : time := 0.25 ns
        );
        port(
           Sel : in std_logic_vector(2 downto 0);
           I0 : in std_logic;
           I1 : in std_logic;
           I2 : in std_logic;
           I3 : in std_logic;
           I4 : in std_logic;
           I5 : in std_logic;
           I6 : in std_logic;
           I7 : in std_logic;
           O : out std_logic
        );
      end component;

    component rom is
        generic(
            BE : integer := 12;
            BP : integer := 32;
            file_name : string := "mrom.txt";
            Tread : time := 5 ns
        );
        port(
            reset : in std_logic;
            ender : in std_logic_vector(BE - 1 downto 0);
            dado_out : out std_logic_vector(BP - 1 downto 0)
        );
    end component;

    -- Internal signals
    signal m_state, m_next_state, m_next_state_false, m_next_state_true : std_logic_vector(3 downto 0) := (others => '0');
    signal m_test : std_logic_vector(2 downto 0) := (others => '0');
    signal m_test_result : std_logic := '0';
    signal m_memory_out : std_logic_vector(23 downto 0) := (others => '0');

begin

RE: reg
    generic map(
        NB => 4,
        t_prop => 1 ns,
        t_hold => 0.25 ns,
        t_setup => 0.25 ns
    )
    port map(
        clk => clk,
        CE => '1',
        R => reset,
        S => '0',
        D => m_next_state,
        Q => m_state
    );

MUX1: mux2x1
    generic map(
        NB => 4,
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        Sel => m_test_result,
        I0 => m_next_state_false,
        I1 => m_next_state_true,
        O => m_next_state
    );

MUX2: mux8x1_1b
    generic map(
        t_sel => 0.5 ns,
        t_data => 0.25 ns
    )
    port map(
        Sel => m_test,
        I0 => opcode(0),
        I1 => opcode(1),
        I2 => opcode(2),
        I3 => opcode(3),
        I4 => opcode(4),
        I5 => opcode(5),
        I6 => opcode(6),
        I7 => branch,
        O => m_test_result
    );

CM: rom
    generic map(
        BE => 4,
        BP => 24,
        file_name => "t_five_mc/data/mrom.txt",
        Tread => 5 ns
    )
    port map(
        reset => reset,
        ender => m_state,
        dado_out => m_memory_out
    );

    m_test <= m_memory_out(23 downto 21);
    m_next_state_true <= m_memory_out(20 downto 17);
    m_next_state_false <= m_memory_out(16 downto 13);
    pc_en <= m_memory_out(12);
    ri_en <= m_memory_out(11);
    reg_write <= m_memory_out(10);
    alu_op <= m_memory_out(9 downto 8);
    se_op <= m_memory_out(7 downto 6);
    m1_sel <= m_memory_out(5);
    m2_sel <= m_memory_out(4 downto 3);
    m3_sel  <= m_memory_out(2 downto 1);
    rw <= m_memory_out(0);

end architecture state_qualifier;


architecture fsm of uc_mc is

    ---- Architecture declarations -----
    constant c_r_ctrl :    std_logic_vector(6 downto 0) := "0110011";
    constant c_i_ctrl :    std_logic_vector(6 downto 0) := "0010011";
    constant c_lw_ctrl :   std_logic_vector(6 downto 0) := "0000011";
    constant c_sw_ctrl :   std_logic_vector(6 downto 0) := "0100011";
    constant c_b_ctrl :    std_logic_vector(6 downto 0) := "1100011";
    constant c_jal_ctrl :  std_logic_vector(6 downto 0) := "1101111";
    constant c_jalr_ctrl : std_logic_vector(6 downto 0) := "1100111";


    type state_t is (fetch_s, decode_s, r_type_s, i_type_s, lw1_s, lw2_s, sw_s, b1_s, b2_s, jal_s, jalr_s);
    signal next_state, current_state: state_t := fetch_s;

begin
    timing: process(reset, clk) is
    begin
        if reset = '1' then
            current_state <= fetch_s;
        elsif (clk'event and clk = '1') then
            current_state <= next_state;
        end if;
    end process timing;

    -- Next state logic
    next_state <=
        fetch_s when (current_state = r_type_s) or
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
        fetch_s;
    
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