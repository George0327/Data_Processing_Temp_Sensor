library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.ALL;

entity tb_aggregation is
end tb_aggregation;

architecture Behavioral of tb_aggregation is

    component aggregation
        Port ( 
            aclk : IN STD_LOGIC;
            s_axis_tvalid : IN STD_LOGIC;
            s_axis_tready : OUT STD_LOGIC;
            s_axis_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            
            m_axis_result_tvalid : OUT STD_LOGIC;
            m_axis_result_tready : IN STD_LOGIC;
            m_axis_result_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;

    signal clk : STD_LOGIC := '0';
    signal s_axis_tvalid : STD_LOGIC := '0';
    signal s_axis_tready : STD_LOGIC;
    signal s_axis_tdata : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');
    
    signal m_axis_result_tvalid : STD_LOGIC;
    signal m_axis_result_tready : STD_LOGIC := '1';
    signal m_axis_result_tdata : STD_LOGIC_VECTOR(7 DOWNTO 0);

    constant clk_period : time := 10 ns;

    file csv_file : text open read_mode is "temperature_measurements.csv";
    shared variable line_buf : line;
    shared variable temp_data : integer;

begin

    uut: aggregation
        Port map (
            aclk => clk,
            s_axis_tvalid => s_axis_tvalid,
            s_axis_tready => s_axis_tready,
            s_axis_tdata => s_axis_tdata,
            
            m_axis_result_tvalid => m_axis_result_tvalid,
            m_axis_result_tready => m_axis_result_tready,
            m_axis_result_tdata => m_axis_result_tdata
        );

    -- Clock process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stimulus_process : process
begin
    s_axis_tvalid <= '0';
    wait for 20 ns;

    while not endfile(csv_file) loop
        readline(csv_file, line_buf);
        read(line_buf, temp_data);

        if temp_data < -128 then
            temp_data := -128;
        elsif temp_data > 127 then
            temp_data := 127;
        end if;

        s_axis_tdata <= std_logic_vector(to_signed(temp_data, 8));
        s_axis_tvalid <= '1';
        wait until rising_edge(clk);

        wait until s_axis_tready = '1';

        s_axis_tvalid <= '0';
        wait until rising_edge(clk); 
    end loop;

    -- End simulation
    report "Simulation complete.";
    wait;
end process;


end Behavioral;
