library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity aggregation is
  Port ( 
    aclk : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tready : IN STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
end aggregation;

architecture Behavioral of aggregation is

type state_type is (S_READ, S_WRITE);
signal state : state_type := S_READ;

type buffer_type is array (0 to 7) of unsigned(31 downto 0);
signal buff : buffer_type := (others => (others => '0'));
signal index : integer range 0 to 7 := 0;
signal sum : unsigned(31 downto 0) := (others => '0');
signal avg : unsigned(31 downto 0) := (others => '0');

signal data_valid : STD_LOGIC := '0';
signal internal_ready, external_ready, inputs_valid : STD_LOGIC := '0';

begin
    s_axis_tready <= external_ready;
    m_axis_result_tvalid <= data_valid;

    internal_ready <= '1' when state = S_READ else '0';
    inputs_valid <= s_axis_tvalid;
    external_ready <= internal_ready and s_axis_tvalid;

    m_axis_result_tdata <= std_logic_vector(avg(7 downto 0));

    process(aclk)
    begin
        if rising_edge(aclk) then
            case state is
                when S_READ =>
                    if external_ready = '1' and inputs_valid = '1' then
                        sum <= sum - buff(index) + unsigned(s_axis_tdata);
                        buff(index) <= x"000000" & unsigned(s_axis_tdata);
                        index <= (index + 1) mod 8;
                        avg <= sum / to_unsigned(8, 32);
                        data_valid <= '1';
                        state <= S_WRITE;
                    end if;

                when S_WRITE =>
                    if m_axis_result_tready = '1' then
                        state <= S_READ;
                        data_valid <= '0';
                    end if;
            end case;
        end if;
    end process;

end Behavioral;