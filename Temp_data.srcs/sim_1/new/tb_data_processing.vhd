library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

entity tb_data_processing is
end tb_data_processing;

architecture sim of tb_data_processing is

  -- Clock and reset signals
  signal aclk : std_logic := '0';
  signal aresetn : std_logic := '0';

  -- Input signals
  signal btn : std_logic := '0';
  signal tin_tvalid : std_logic := '0';
  signal tin_tdata : std_logic_vector(7 downto 0) := (others => '0');

  -- Output signals
  signal tin_tready : std_logic;
  signal tout_tvalid : std_logic;
  signal tout_tready : std_logic := '0';
  signal tout_tdata : std_logic_vector(7 downto 0);

  -- Clock generation
  constant CLK_PERIOD : time := 10 ns;

  -- Unit Under Test
  component data_processing is
    Port (
      aclk : in STD_LOGIC;
      aresetn : in STD_LOGIC;
      btn : in std_logic;
      
      tin_tvalid : in STD_LOGIC;
      tin_tready : out STD_LOGIC;
      tin_tdata : in STD_LOGIC_VECTOR (7 downto 0);
      
      tout_tvalid : out STD_LOGIC;
      tout_tready : in STD_LOGIC;
      tout_tdata : out STD_LOGIC_VECTOR (7 downto 0)
    );
  end component;

  -- File handling
  file csv_file : text open read_mode is "temperature_measurements.csv";
  shared variable line_buf : line;
  shared variable temp_data : integer;

begin

  -- Clock generation process
  clk_gen : process
  begin
    while true loop
      aclk <= '0';
      wait for CLK_PERIOD / 2;
      aclk <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
  end process;

  -- Reset process
  reset_gen : process
  begin
    aresetn <= '0';
    wait for 50 ns;
    aresetn <= '1';
    wait;
  end process;

  -- Instantiating the UUT
  uut : data_processing
    port map (
      aclk => aclk,
      aresetn => aresetn,
      btn => btn,
      
      tin_tvalid => tin_tvalid,
      tin_tready => tin_tready,
      tin_tdata => tin_tdata,
      
      tout_tvalid => tout_tvalid,
      tout_tready => tout_tready,
      tout_tdata => tout_tdata
    );

  -- Stimulus process with CSV input
  stim_proc : process
    variable scaled_data : integer;
  begin
    -- Wait for reset release
    wait for 100 ns;

    -- Test case: Read and send inputs from CSV file
    tin_tvalid <= '1';
    while not endfile(csv_file) loop
      readline(csv_file, line_buf);
      read(line_buf, temp_data);

      tin_tdata <= std_logic_vector(to_unsigned(temp_data, 8));
      tin_tvalid <= '1';
      wait until tin_tready = '1';
    end loop;
    tin_tvalid <= '0';

    -- Simulate button presses
    btn <= '1';
    wait for 20 ns;
    btn <= '0';
    wait for 50 ns;

    btn <= '1';
    wait for 20 ns;
    btn <= '0';
    wait for 50 ns;

    btn <= '1';
    wait for 20 ns;
    btn <= '0';
    wait for 50 ns;

    btn <= '1';
    wait for 20 ns;
    btn <= '0';
    wait for 50 ns;

    -- Wait for output data
    tout_tready <= '1';
    while tout_tvalid = '1' loop
      wait for 10 ns;
      -- Log the output data
      report "Output Data: " & integer'image(to_integer(unsigned(tout_tdata)));
    end loop;

    -- End simulation
    wait for 100 ns;
    report "Simulation complete.";
    wait;
  end process;
  
end sim;
