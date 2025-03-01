library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity statistics_tb is
end statistics_tb;

architecture Behavioral of statistics_tb is

  component statistics
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
  end component;

  constant CLK_PERIOD : time := 10 ns;

  signal aclk : STD_LOGIC := '0';
  signal s_axis_tvalid : STD_LOGIC := '0';
  signal s_axis_tready : STD_LOGIC;
  signal s_axis_tdata : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');

  signal m_axis_avg_tvalid : STD_LOGIC;
  signal m_axis_avg_tready : STD_LOGIC := '1';
  signal m_axis_avg_tdata : STD_LOGIC_VECTOR(7 DOWNTO 0);

  signal m_axis_min_tvalid : STD_LOGIC;
  signal m_axis_min_tready : STD_LOGIC := '1';
  signal m_axis_min_tdata : STD_LOGIC_VECTOR(7 DOWNTO 0);

  signal m_axis_max_tvalid : STD_LOGIC;
  signal m_axis_max_tready : STD_LOGIC := '1';
  signal m_axis_max_tdata : STD_LOGIC_VECTOR(7 DOWNTO 0);

  file input_file : text open read_mode is "temperature_measurements.csv";
  shared variable input_line : line;
  shared variable data_value : integer;

begin

  uut: statistics
    Port map (
      aclk => aclk,
      s_axis_tvalid => s_axis_tvalid,
      s_axis_tready => s_axis_tready,
      s_axis_tdata => s_axis_tdata,

      m_axis_avg_tvalid => m_axis_avg_tvalid,
      m_axis_avg_tready => m_axis_avg_tready,
      m_axis_avg_tdata => m_axis_avg_tdata,

      m_axis_min_tvalid => m_axis_min_tvalid,
      m_axis_min_tready => m_axis_min_tready,
      m_axis_min_tdata => m_axis_min_tdata,

      m_axis_max_tvalid => m_axis_max_tvalid,
      m_axis_max_tready => m_axis_max_tready,
      m_axis_max_tdata => m_axis_max_tdata
    );

  -- Clock generation process
  clk_process : process
  begin
    while true loop
      aclk <= '0';
      wait for CLK_PERIOD / 2;
      aclk <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
  end process;

  -- Stimulus process
  stimulus_process : process
  begin
    wait for 20 ns;

    while not endfile(input_file) loop
      readline(input_file, input_line);
      read(input_line, data_value);

      s_axis_tdata <= std_logic_vector(to_unsigned(data_value, 8));
      s_axis_tvalid <= '1';
      wait until rising_edge(aclk);

      while s_axis_tready = '0' loop
        wait until rising_edge(aclk);
      end loop;

      s_axis_tvalid <= '0';
      wait until rising_edge(aclk);
    end loop;

    -- End simulation
    wait for 100 ns;
    assert false report "End of simulation" severity failure;
  end process;

end Behavioral;
