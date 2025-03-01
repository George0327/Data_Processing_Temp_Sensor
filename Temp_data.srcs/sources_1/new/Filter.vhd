library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity filter is
  Port ( 
    aclk : IN STD_LOGIC;
    s_axis_tvalid : IN STD_LOGIC;
    s_axis_tready : OUT STD_LOGIC;
    s_axis_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
end filter;

architecture Behavioral of filter is

type state_type is (S_READ, S_WRITE);
signal state : state_type := S_READ;

signal filtered_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');
signal data_valid : STD_LOGIC := '0';

signal internal_ready, external_ready, inputs_valid : STD_LOGIC := '0';

constant TEMP_MIN : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11101100"; -- -20
constant TEMP_MAX : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00101000"; -- 40

begin
    s_axis_tready <= external_ready;
    m_axis_tvalid <= data_valid;

    internal_ready <= '1' when state = S_READ else '0';
    inputs_valid <= s_axis_tvalid;
    external_ready <= internal_ready and s_axis_tvalid;

    m_axis_tdata <= filtered_data;

    process(aclk)
    variable buff : std_logic_vector(7 downto 0);
    begin
        if rising_edge(aclk) then
            case state is
                when S_READ =>
                    if external_ready = '1' and inputs_valid = '1' then
                        if s_axis_tdata >= TEMP_MIN and s_axis_tdata <= TEMP_MAX then
                            filtered_data <= s_axis_tdata;
                            buff := filtered_data;
                            data_valid <= '1';
                            state <= S_WRITE;
                        else
                            filtered_data <= buff;
                            data_valid <= '1';
                            state <= S_WRITE;
                        end if;
                    end if;

                when S_WRITE =>
                    if m_axis_tready = '1' then
                        state <= S_READ;
                        data_valid <= '0';
                    end if;
            end case;
        end if;
    end process;

end Behavioral;
