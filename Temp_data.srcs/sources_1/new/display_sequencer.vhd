library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_sequencer is
  Port (
    aclk          : IN STD_LOGIC;
    button        : IN STD_LOGIC;
    
    avg_tvalid    : IN STD_LOGIC;
    avg_tready    : OUT STD_LOGIC;
    avg_tdata     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    min_tvalid    : IN STD_LOGIC;
    min_tready    : OUT STD_LOGIC;
    min_tdata     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    max_tvalid    : IN STD_LOGIC;
    max_tready    : OUT STD_LOGIC;
    max_tdata     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    data_tvalid   : IN STD_LOGIC;
    data_tready   : OUT STD_LOGIC;
    data_tdata    : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_tdata  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
end display_sequencer;

architecture Behavioral of display_sequencer is

  type state_type is (S_READ, S_WRITE);
  signal state : state_type := S_READ;

  signal result_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');
  signal result_valid : STD_LOGIC := '0';

  signal internal_ready, external_ready, avg_valid, min_valid, max_valid, data_valid : STD_LOGIC := '0';
  
  signal selected_input : integer range 0 to 3 := 0;

begin
  avg_tready <= external_ready;
  min_tready <= external_ready;
  max_tready <= external_ready;
  data_tready <= external_ready;
  
  internal_ready <= '1' when state = S_READ else '0';
                        
  avg_valid <= avg_tvalid;
  min_valid <= min_tvalid;
  max_valid <= max_tvalid;
  data_valid <= data_tvalid;
  
  external_ready <= (avg_valid or min_valid or max_valid or data_valid) and internal_ready;
  
  m_axis_tvalid <= '1' when state = S_WRITE else '0';
  m_axis_tdata <= result_data;

  process(aclk)
  begin
      if rising_edge(aclk) then
            case state is
                when S_READ =>
                    if external_ready = '1' and avg_valid = '1' and selected_input = 0 then
                        result_data <= avg_tdata;
                        state <= S_WRITE;
                    end if;    
                    
                    if external_ready = '1' and min_valid = '1' and selected_input = 1 then
                        result_data <= min_tdata;
                        state <= S_WRITE;
                    end if;    
                    
                    if external_ready = '1' and max_valid = '1' and selected_input = 2 then
                        result_data <= max_tdata;
                        state <= S_WRITE;
                    end if;    
                    
                    if external_ready = '1' and data_valid = '1' and selected_input = 3 then
                        result_data <= data_tdata;
                        state <= S_WRITE;
                    end if;    
                
                when S_WRITE =>
                    if m_axis_tready = '1' then
                        state <= S_READ;
                    end if;
            end case;
        end if;
  end process;
  
  process (aclk)
  begin
    if button = '1' then
        selected_input <= (selected_input + 1) mod 4;
    end if;
  end process;

end Behavioral;
