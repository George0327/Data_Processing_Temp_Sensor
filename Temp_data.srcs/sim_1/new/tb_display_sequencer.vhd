library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.ALL;

entity tb_display_sequencer is
-- No ports for a testbench
end tb_display_sequencer;

architecture Behavioral of tb_display_sequencer is
  -- Component declaration
  component display_sequencer is
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
  end component;

  -- Signals for driving the component
  signal aclk          : STD_LOGIC := '0';
  signal button        : STD_LOGIC := '0';
  signal avg_tvalid    : STD_LOGIC := '0';
  signal avg_tready    : STD_LOGIC;
  signal avg_tdata     : STD_LOGIC_VECTOR(7 DOWNTO 0);
  
  signal min_tvalid    : STD_LOGIC := '0';
  signal min_tready    : STD_LOGIC;
  signal min_tdata     : STD_LOGIC_VECTOR(7 DOWNTO 0);
  
  signal max_tvalid    : STD_LOGIC := '0';
  signal max_tready    : STD_LOGIC;
  signal max_tdata     : STD_LOGIC_VECTOR(7 DOWNTO 0);
  
  signal data_tvalid   : STD_LOGIC := '0';
  signal data_tready   : STD_LOGIC;
  signal data_tdata    : STD_LOGIC_VECTOR(7 DOWNTO 0);
  
  signal m_axis_tvalid : STD_LOGIC;
  signal m_axis_tready : STD_LOGIC := '1';
  signal m_axis_tdata  : STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- Clock generation process
  constant clk_period : time := 10 ns;

  -- File I/O
  file avg_file : text open read_mode is "temperature_measurements.csv";
  file min_file : text open read_mode is "temperature_measurements.csv";
  file max_file : text open read_mode is "temperature_measurements.csv";
  file data_file : text open read_mode is "temperature_measurements.csv";

  shared variable avg_line : line;
  shared variable min_line : line;
  shared variable max_line : line;
  shared variable data_line : line;

  shared variable avg_value : integer;
  shared variable min_value : integer;
  shared variable max_value : integer;
  shared variable data_value : integer;

begin
  -- Instantiate the component
  uut: display_sequencer
    Port map (
      aclk          => aclk,
      button        => button,
      avg_tvalid    => avg_tvalid,
      avg_tready    => avg_tready,
      avg_tdata     => avg_tdata,
      min_tvalid    => min_tvalid,
      min_tready    => min_tready,
      min_tdata     => min_tdata,
      max_tvalid    => max_tvalid,
      max_tready    => max_tready,
      max_tdata     => max_tdata,
      data_tvalid   => data_tvalid,
      data_tready   => data_tready,
      data_tdata    => data_tdata,
      m_axis_tvalid => m_axis_tvalid,
      m_axis_tready => m_axis_tready,
      m_axis_tdata  => m_axis_tdata
    );

  -- Clock generation
  clk_process: process
  begin
    while true loop
      aclk <= '0';
      wait for clk_period / 2;
      aclk <= '1';
      wait for clk_period / 2;
    end loop;
  end process;

  -- Stimulus process
  stimulus_process: process
  begin
    -- Initial delay
    wait for 50 ns;

    -- Load values from CSV files
    while not endfile(avg_file) loop
      readline(avg_file, avg_line);
      readline(min_file, min_line);
      readline(max_file, max_line);
      readline(data_file, data_line);

      read(avg_line, avg_value);
      read(min_line, min_value);
      read(max_line, max_value);
      read(data_line, data_value);

      -- Apply input values
      avg_tdata <= std_logic_vector(to_unsigned(avg_value, 8));
      avg_tvalid <= '1';

      min_tdata <= std_logic_vector(to_unsigned(min_value, 8));
      min_tvalid <= '1';

      max_tdata <= std_logic_vector(to_unsigned(max_value, 8));
      max_tvalid <= '1';

      data_tdata <= std_logic_vector(to_unsigned(data_value, 8));
      data_tvalid <= '1';
      
      button <= '1';
      wait for clk_period;
      button <= '0';

      -- Wait for one clock cycle
      wait until rising_edge(aclk);

      -- Wait for ready signals
      while avg_tready = '0' or min_tready = '0' or max_tready = '0' or data_tready = '0' loop
        wait until rising_edge(aclk);
      end loop;

      avg_tvalid <= '0';
      min_tvalid <= '0';
      max_tvalid <= '0';
      data_tvalid <= '0';
    end loop;

    -- Stop simulation
    wait;
  end process;

end Behavioral;
