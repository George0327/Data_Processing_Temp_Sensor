library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity statistics is
  Port ( 
    aclk : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

    m_axis_avg_tvalid : OUT STD_LOGIC;
    m_axis_avg_tready : IN STD_LOGIC;
    m_axis_avg_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

    m_axis_min_tvalid : OUT STD_LOGIC;
    m_axis_min_tready : IN STD_LOGIC;
    m_axis_min_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

    m_axis_max_tvalid : OUT STD_LOGIC;
    m_axis_max_tready : IN STD_LOGIC;
    m_axis_max_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
end statistics;

architecture Behavioral of statistics is

  type state_type is (S_READ, S_WRITE);
  signal state : state_type := S_READ;

  type buffer_type is array (0 to 7) of unsigned(31 downto 0);
  signal buff : buffer_type := (others => (others => '0'));
  signal index : integer range 0 to 7 := 0;
  signal sum : unsigned(31 downto 0) := (others => '0');
  signal avg : unsigned(31 downto 0) := (others => '0');
  signal min_val : unsigned(7 downto 0) := (others => '1'); -- Initialized to max value
  signal max_val : unsigned(7 downto 0) := (others => '0'); -- Initialized to min value

  signal data_valid : STD_LOGIC := '0';
  signal internal_ready, external_ready, inputs_valid : STD_LOGIC := '0';

begin
    s_axis_tready <= external_ready;
    m_axis_avg_tvalid <= data_valid;
    m_axis_min_tvalid <= data_valid;
    m_axis_max_tvalid <= data_valid;

    internal_ready <= '1' when state = S_READ else '0';
    inputs_valid <= s_axis_tvalid;
    external_ready <= internal_ready and s_axis_tvalid;

    m_axis_avg_tdata <= std_logic_vector(avg(7 downto 0));
    m_axis_min_tdata <= std_logic_vector(min_val);
    m_axis_max_tdata <= std_logic_vector(max_val);

    process(aclk)
    begin
        if rising_edge(aclk) then
            case state is
                when S_READ =>
                    if external_ready = '1' and inputs_valid = '1' then
                        -- Update sum and buffer
                        sum <= sum - buff(index) + unsigned(s_axis_tdata);
                        buff(index) <= x"000000" & unsigned(s_axis_tdata);

                        -- Update min and max
                        if unsigned(s_axis_tdata) < min_val then
                            min_val <= unsigned(s_axis_tdata);
                        end if;

                        if unsigned(s_axis_tdata) > max_val then
                            max_val <= unsigned(s_axis_tdata);
                        end if;

                        -- Update index, average, and transition state
                        index <= (index + 1) mod 8;
                        avg <= sum / to_unsigned(8, 32);
                        data_valid <= '1';
                        state <= S_WRITE;
                    end if;

                when S_WRITE =>
                    if m_axis_avg_tready = '1' and m_axis_min_tready = '1' and m_axis_max_tready = '1' then
                        state <= S_READ;
                        data_valid <= '0';
                    end if;
            end case;
        end if;
    end process;

end Behavioral;
