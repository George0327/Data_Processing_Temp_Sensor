library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.ALL;

entity tb_filter is
end tb_filter;

architecture Behavioral of tb_filter is
    component filter
        Port (
            aclk : IN STD_LOGIC;
            s_axis_tvalid : IN STD_LOGIC;
            s_axis_tready : OUT STD_LOGIC;
            s_axis_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            
            m_axis_tvalid : OUT STD_LOGIC;
            m_axis_tready : IN STD_LOGIC;
            m_axis_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;

    signal aclk : STD_LOGIC := '0';
    signal s_axis_tvalid : STD_LOGIC := '0';
    signal s_axis_tready : STD_LOGIC;
    signal s_axis_tdata : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');
    
    signal m_axis_tvalid : STD_LOGIC;
    signal m_axis_tready : STD_LOGIC := '0';
    signal m_axis_tdata : STD_LOGIC_VECTOR(7 DOWNTO 0);

    constant clk_period : time := 10 ns;

    -- File handling
    file csv_file : text open read_mode is "temperature_measurements.csv";
    shared variable line_buf : line;
    shared variable temp_data : integer;

begin
    uut: filter
        Port map (
            aclk => aclk,
            s_axis_tvalid => s_axis_tvalid,
            s_axis_tready => s_axis_tready,
            s_axis_tdata => s_axis_tdata,
            m_axis_tvalid => m_axis_tvalid,
            m_axis_tready => m_axis_tready,
            m_axis_tdata => m_axis_tdata
        );

    -- Clock generation process
    clk_process : process
    begin
        while True loop
            aclk <= '0';
            wait for clk_period / 2;
            aclk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process with CSV input
    stimulus_process: process
        variable scaled_data : integer;
    begin
        wait for 20 ns;

        while not endfile(csv_file) loop
            -- Read one line from the CSV file
            readline(csv_file, line_buf);
            read(line_buf, temp_data);

            -- Clamp the input data to the 8-bit signed range (-128 to 127)
            if temp_data < -128 then
                scaled_data := -128;
            elsif temp_data > 127 then
                scaled_data := 127;
            else
                scaled_data := temp_data;
            end if;

            -- Send the data to the filter
            s_axis_tdata <= std_logic_vector(to_signed(scaled_data, 8));
            s_axis_tvalid <= '1';
            m_axis_tready <= '1';
            wait for clk_period;

            -- Wait for output and check if it is valid
            if m_axis_tvalid = '1' then
                report "Filtered output: " & integer'image(to_integer(signed(m_axis_tdata)));
            else
                report "Data " & integer'image(scaled_data) & " was not passed by the filter.";
            end if;

            -- Reset valid signal
            s_axis_tvalid <= '0';
            wait for clk_period;
        end loop;

        -- End simulation
        report "Simulation complete.";
        wait;
    end process;

end Behavioral;
